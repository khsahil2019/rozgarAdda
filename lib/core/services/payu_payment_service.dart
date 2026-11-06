import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_routes.dart';
import '../network/api_services.dart';

class PayUPaymentResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? txnId;
  final String? paymentId;
  final String? mihpayid;
  final String? bankRefNum;
  final int? id;
  final String? paidAt;
  final String? message;
  final dynamic rawData;

  const PayUPaymentResult({
    required this.isSuccess,
    this.isCancelled = false,
    this.txnId,
    this.paymentId,
    this.mihpayid,
    this.bankRefNum,
    this.id,
    this.paidAt,
    this.message,
    this.rawData,
  });

  Map<String, dynamic> toPaymentPayload({int? defaultId}) {
    return {
      if (id != null || defaultId != null) 'id': id ?? defaultId,
      'status': isSuccess ? 'success' : 'failed',
      'mihpayid': mihpayid ?? paymentId ?? '',
      'bank_ref_num': bankRefNum ?? '',
      'paid_at': paidAt ?? DateTime.now().toUtc().toIso8601String(),
      'payment_response': rawData ?? {},
    };
  }

  @override
  String toString() {
    return 'PayUPaymentResult(isSuccess: $isSuccess, isCancelled: $isCancelled, txnId: $txnId, mihpayid: $mihpayid, bankRefNum: $bankRefNum, paymentId: $paymentId, message: $message)';
  }
}

class PayUPaymentService implements PayUCheckoutProProtocol {
  static final PayUPaymentService instance = PayUPaymentService._internal();

  factory PayUPaymentService() {
    return instance;
  }

  PayUPaymentService._internal() {
    _checkoutPro = PayUCheckoutProFlutter(this);
  }

  late final PayUCheckoutProFlutter _checkoutPro;
  Completer<PayUPaymentResult>? _paymentCompleter;

  // ==========================================================
  // PAYU CREDENTIALS (Configured per Rozgar Adda Backend Specs)
  // ==========================================================

  /// Current mode: 'live' or 'test'. Defaults to 'live' as specified.
  static String mode = 'live';

  // TEST CREDENTIALS
  static const String testMerchantKey = 'j4krwD';
  static const String testMerchantSalt = 'tAPd3hikDA9qGrQvrdP2fd9QRMBzOqw7';
  static const String testPaymentUrl = 'https://test.payu.in';

  // LIVE CREDENTIALS
  static const String liveMerchantKey = 'hFKI65';
  static const String liveMerchantSalt = 'OUtXk3BuCK9289XGl4cvezy7znIDzhyY';
  static const String livePaymentUrl = 'https://secure.payu.in';

  // Active configurations based on current mode
  static bool get isLive => mode.toLowerCase() == 'live';
  static String get merchantKey => isLive ? liveMerchantKey : testMerchantKey;
  static String get merchantSalt => isLive ? liveMerchantSalt : testMerchantSalt;

  // PayU CheckoutPro Environment:
  // "0" = PRODUCTION (LIVE)
  // "1" = TEST (SANDBOX)
  static String get environment => isLive ? "0" : "1";

  // Dedicated SDK callback endpoints
  static String surl = 'https://cbext.payu.in/sdk/success';
  static String furl = 'https://cbext.payu.in/sdk/failure';

  static String merchantName = 'Rozgar Adda';
  static String primaryColor = '#1400FF';

  /// Configure mode or dynamic parameters if needed
  static void setMode(String newMode) {
    mode = newMode;
  }

  /// Launch the PayU CheckoutPro payment gateway
  Future<PayUPaymentResult> openCheckout({
    required String txnId,
    required double amount,
    required String productInfo,
    required String firstName,
    required String email,
    required String phone,
    Map<String, dynamic>? additionalParams,
  }) async {
    _paymentCompleter = Completer<PayUPaymentResult>();

    final formattedAmount = amount.toStringAsFixed(2);
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final cleanEmail = email.trim().isEmpty ? 'employer@rozgaradda.com' : email.trim();
    final cleanName = firstName.trim().isEmpty ? 'Employer' : firstName.trim();
    // PayU txnid must be strictly alphanumeric (^[a-zA-Z0-9]*$) and max 25 characters
    final alphanumericTxnId = txnId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final cleanTxnId = alphanumericTxnId.length > 25
        ? alphanumericTxnId.substring(0, 25)
        : (alphanumericTxnId.isEmpty
            ? 'TXN${DateTime.now().millisecondsSinceEpoch}'
            : alphanumericTxnId);

    // Convert all additional params to clean String values
    final cleanAdditionalParams = <String, String>{};
    if (additionalParams != null) {
      additionalParams.forEach((k, v) {
        cleanAdditionalParams[k] = (v ?? '').toString();
      });
    }

    final paymentParams = <String, dynamic>{
      PayUPaymentParamKey.key: merchantKey,
      PayUPaymentParamKey.amount: formattedAmount,
      PayUPaymentParamKey.productInfo: productInfo,
      PayUPaymentParamKey.firstName: cleanName,
      PayUPaymentParamKey.email: cleanEmail,
      PayUPaymentParamKey.phone: cleanPhone.isEmpty ? '9999999999' : cleanPhone,
      PayUPaymentParamKey.android_surl: surl,
      PayUPaymentParamKey.android_furl: furl,
      PayUPaymentParamKey.ios_surl: surl,
      PayUPaymentParamKey.ios_furl: furl,
      'surl': surl,
      'furl': furl,
      PayUPaymentParamKey.environment: environment,
      PayUPaymentParamKey.userCredential: '$merchantKey:$cleanEmail',
      PayUPaymentParamKey.transactionId: cleanTxnId,
      PayUPaymentParamKey.additionalParam: cleanAdditionalParams,
    };

    final checkoutConfig = <String, dynamic>{
      PayUCheckoutProConfigKeys.primaryColor: primaryColor,
      PayUCheckoutProConfigKeys.secondaryColor: '#FFFFFF',
      PayUCheckoutProConfigKeys.merchantName: merchantName,
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
      PayUCheckoutProConfigKeys.autoSelectOtp: true,
      PayUCheckoutProConfigKeys.autoApprove: true,
    };

    debugPrint('[PayU] Launching PayU CheckoutPro...');
    debugPrint('[PayU] Key: $merchantKey | Environment: $environment | Txn: $cleanTxnId | Amount: $formattedAmount');

    try {
      _checkoutPro.openCheckoutScreen(
        payUPaymentParams: paymentParams,
        payUCheckoutProConfig: checkoutConfig,
      ).catchError((e) {
        debugPrint('[PayU] Error in openCheckoutScreen async: $e');
        if (!(_paymentCompleter?.isCompleted ?? true)) {
          _paymentCompleter?.complete(
            PayUPaymentResult(
              isSuccess: false,
              message: 'PayU error: $e',
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('[PayU] Error invoking openCheckoutScreen: $e');
      if (!(_paymentCompleter?.isCompleted ?? true)) {
        _paymentCompleter?.complete(
          PayUPaymentResult(
            isSuccess: false,
            message: 'Unable to launch PayU checkout: $e',
          ),
        );
      }
    }

    return _paymentCompleter!.future;
  }

  @override
  dynamic generateHash(Map response) async {
    final hashName = (response[PayUHashConstantsKeys.hashName] ??
            response['hashName'] ??
            response['hash_name'] ??
            '')
        .toString();
    final hashString = (response[PayUHashConstantsKeys.hashString] ??
            response['hashString'] ??
            response['hash_string'] ??
            '')
        .toString();

    debugPrint('[PayU] generateHash requested for $hashName: $hashString');

    // Generate SHA-512 hash directly using merchantSalt
    // (Backend has no dedicated hash generation API)
    final rawStringToHash = '$hashString$merchantSalt';
    final generatedHash = sha512.convert(utf8.encode(rawStringToHash)).toString();
    debugPrint('[PayU] Generated SHA-512 hash for $hashName: $generatedHash');

    final hashPayload = <String, String>{
      hashName: generatedHash,
    };

    debugPrint('[PayU] Calling hashGenerated with payload: $hashPayload');
    try {
      await _checkoutPro.hashGenerated(hash: hashPayload);
    } catch (e) {
      debugPrint('[PayU] Error returning generated hash: $e');
    }
  }

  @override
  dynamic onPaymentSuccess(dynamic response) async {
    debugPrint('[PayU] onPaymentSuccess: $response');

    String? txnId;
    String? payuId;
    String? bankRefNum;
    int? payId;
    String? paidAt = DateTime.now().toUtc().toIso8601String();

    Map<String, dynamic> responseMap = {};
    if (response is Map) {
      responseMap.addAll(Map<String, dynamic>.from(response));
      if (response['payuResponse'] != null) {
        if (response['payuResponse'] is String) {
          try {
            final inner = jsonDecode(response['payuResponse']);
            if (inner is Map) {
              responseMap.addAll(Map<String, dynamic>.from(inner));
            }
          } catch (_) {}
        } else if (response['payuResponse'] is Map) {
          responseMap.addAll(Map<String, dynamic>.from(response['payuResponse']));
        }
      }
    } else if (response is String) {
      try {
        final decoded = jsonDecode(response);
        if (decoded is Map) {
          responseMap.addAll(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    txnId = responseMap['txnid']?.toString() ?? responseMap['transactionId']?.toString();
    payuId = responseMap['mihpayid']?.toString() ?? responseMap['payuMoneyId']?.toString();
    bankRefNum = responseMap['bank_ref_num']?.toString() ??
        responseMap['bank_ref_no']?.toString() ??
        responseMap['bankRefNum']?.toString();
    if (responseMap['id'] != null) {
      payId = int.tryParse(responseMap['id'].toString());
    }
    if (responseMap['addedon'] != null && responseMap['addedon'].toString().isNotEmpty) {
      paidAt = responseMap['addedon'].toString();
    }

    // Notify backend
    _verifyPaymentOnBackend(response);

    if (!(_paymentCompleter?.isCompleted ?? true)) {
      _paymentCompleter?.complete(
        PayUPaymentResult(
          isSuccess: true,
          txnId: txnId,
          paymentId: payuId,
          mihpayid: payuId,
          bankRefNum: bankRefNum,
          id: payId,
          paidAt: paidAt,
          message: 'Payment completed successfully!',
          rawData: response,
        ),
      );
    }
  }

  @override
  dynamic onPaymentFailure(dynamic response) {
    debugPrint('[PayU] onPaymentFailure: $response');
    String errorMessage = 'Payment failed. Please try again.';

    if (response is Map) {
      final msg = response['error_Message'] ??
          response['errorMessage'] ??
          response['errorMsg'] ??
          response['message'];
      if (msg != null && msg.toString().isNotEmpty) {
        errorMessage = msg.toString();
      }
    } else if (response != null && response.toString().isNotEmpty) {
      errorMessage = response.toString();
    }

    if (!(_paymentCompleter?.isCompleted ?? true)) {
      _paymentCompleter?.complete(
        PayUPaymentResult(
          isSuccess: false,
          message: errorMessage,
          rawData: response,
        ),
      );
    }
  }

  @override
  dynamic onPaymentCancel(Map? response) {
    debugPrint('[PayU] onPaymentCancel: $response');

    if (!(_paymentCompleter?.isCompleted ?? true)) {
      _paymentCompleter?.complete(
        PayUPaymentResult(
          isSuccess: false,
          isCancelled: true,
          message: 'Payment was cancelled by user.',
          rawData: response,
        ),
      );
    }
  }

  @override
  dynamic onError(Map? response) {
    debugPrint('[PayU] onError triggered: $response');
    String errorMsg = 'An error occurred during PayU checkout.';

    if (response != null) {
      final msg = response['errorMsg'] ?? response['errorMessage'] ?? response['message'];
      if (msg != null && msg.toString().isNotEmpty) {
        errorMsg = msg.toString();
      }
    }

    if (!(_paymentCompleter?.isCompleted ?? true)) {
      _paymentCompleter?.complete(
        PayUPaymentResult(
          isSuccess: false,
          message: errorMsg,
          rawData: response,
        ),
      );
    }
  }

  Future<void> _verifyPaymentOnBackend(dynamic response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('employer_token');

      await ApiService.post(
        ApiRoutes.verifyPayment,
        body: {
          'response': response,
        },
        accessToken: token,
      );
    } catch (e) {
      debugPrint('[PayU] Backend verify note: $e');
    }
  }
}

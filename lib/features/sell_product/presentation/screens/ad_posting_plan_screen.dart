import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/services/payu_payment_service.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../app/app_controller.dart';
import '../../domain/entities/ad_posting_plan.dart';
import '../controller/sell_product_controller.dart';
import 'sell_product_review_screen.dart';

class AdPostingPlanScreen extends StatefulWidget {
  final int? categoryId;
  final VoidCallback? onAdPublished;

  const AdPostingPlanScreen({
    super.key,
    this.categoryId,
    this.onAdPublished,
  });

  @override
  State<AdPostingPlanScreen> createState() => _AdPostingPlanScreenState();
}

class _AdPostingPlanScreenState extends State<AdPostingPlanScreen> {
  final SellProductController controller = Get.find<SellProductController>();

  AdPackageLevel _selectedLevel = AdPackageLevel.district;
  final List<AdPostingPlan> _districtPlans = AdPostingPlan.districtPackages();
  final List<AdPostingPlan> _statePlans = AdPostingPlan.statePackages();

  late AdPostingPlan _selectedPlan;
  bool _isProcessing = false;
  bool _isLoadingPlans = false;
  String? _errorMessage;

  static const Color primary = Color(0xFF1400FF);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color successGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _selectedPlan = _districtPlans.firstWhere(
      (p) => p.isPopular,
      orElse: () => _districtPlans[0],
    );
    _fetchPlansFromApi();
  }

  /// Attempts to fetch live plans from https://rozgaradda.com/api/candidate/product_sell_plans?category_id={id}
  Future<void> _fetchPlansFromApi() async {
    setState(() => _isLoadingPlans = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ??
          prefs.getString('candidate_token');

      int? effectiveCatId = widget.categoryId;
      if (effectiveCatId == null && controller.selectedCategoryIndex.value != null) {
        final idx = controller.selectedCategoryIndex.value!;
        if (idx < controller.categories.length) {
          effectiveCatId = controller.categories[idx].id;
        }
      }

      final queryParams = <String, dynamic>{};
      if (effectiveCatId != null) {
        queryParams['category_id'] = effectiveCatId;
      }

      debugPrint('[AdPostingPlanScreen] Fetching plans from ${ApiRoutes.productSellPlans} with params: $queryParams');

      final res = await ApiService.get(
        ApiRoutes.productSellPlans,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        accessToken: token,
      );

      final List<AdPostingPlan> parsedList = [];
      if (res['status'] == true && res['plans'] != null) {
        final rawPlans = res['plans'];
        if (rawPlans is Map) {
          for (final list in rawPlans.values) {
            if (list is List) {
              for (final item in list) {
                if (item is Map) {
                  try {
                    parsedList.add(AdPostingPlan.fromJson(Map<String, dynamic>.from(item)));
                  } catch (e) {
                    debugPrint('[AdPostingPlanScreen] Parse item warning: $e');
                  }
                }
              }
            }
          }
        } else if (rawPlans is List) {
          for (final item in rawPlans) {
            if (item is Map) {
              try {
                parsedList.add(AdPostingPlan.fromJson(Map<String, dynamic>.from(item)));
              } catch (e) {
                debugPrint('[AdPostingPlanScreen] Parse item warning: $e');
              }
            }
          }
        }
      }

      if (parsedList.isNotEmpty && mounted) {
        final apiDistricts = parsedList
            .where((p) => p.level == AdPackageLevel.district && p.isActive)
            .toList();
        final apiStates = parsedList
            .where((p) => p.level == AdPackageLevel.state && p.isActive)
            .toList();

        setState(() {
          if (apiDistricts.isNotEmpty) {
            _districtPlans.clear();
            _districtPlans.addAll(apiDistricts);
          }
          if (apiStates.isNotEmpty) {
            _statePlans.clear();
            _statePlans.addAll(apiStates);
          }

          final currentList = _selectedLevel == AdPackageLevel.district
              ? _districtPlans
              : _statePlans;
          _selectedPlan = currentList.firstWhere(
            (p) => p.isPopular,
            orElse: () => currentList.first,
          );
        });
      }
    } catch (e) {
      debugPrint('[AdPostingPlanScreen] Plan API note: $e. Using local defaults.');
    } finally {
      if (mounted) setState(() => _isLoadingPlans = false);
    }
  }

  List<AdPostingPlan> get _currentPlans =>
      _selectedLevel == AdPackageLevel.district ? _districtPlans : _statePlans;

  void _onLevelChanged(AdPackageLevel level) {
    if (_selectedLevel == level) return;
    setState(() {
      _selectedLevel = level;
      final plans = _currentPlans;
      _selectedPlan = plans.firstWhere(
        (p) => p.isPopular,
        orElse: () => plans.first,
      );
    });
  }

  Future<void> _handlePayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final now = DateTime.now().millisecondsSinceEpoch;
    final txnId = 'ADTXN$now';

    // Retrieve candidate details
    String candidateName = 'Seller';
    String email = 'candidate@rozgaradda.com';
    String phone = '9999999999';

    try {
      if (Get.isRegistered<AppController>()) {
        final appCtrl = Get.find<AppController>();
        final user = appCtrl.user;
        if (user != null) {
          if (user.name.isNotEmpty) candidateName = user.name;
          if (user.email.isNotEmpty) email = user.email;
          if (user.phone.isNotEmpty) phone = user.phone;
        }
      }
      final prefs = await SharedPreferences.getInstance();
      phone = prefs.getString('user_phone') ?? phone;
      email = prefs.getString('user_email') ?? email;
      candidateName = prefs.getString('user_name') ?? candidateName;
    } catch (_) {}

    try {
      final totalPayable = _selectedPlan.totalPayable;
      final adTitle = controller.titleCtrl.text.trim();

      debugPrint('[PayUAd] Launching checkout for $adTitle - Amount: $totalPayable');

      final result = await PayUPaymentService.instance.openCheckout(
        txnId: txnId,
        amount: totalPayable,
        productInfo:
            'Rozgar Adda Ad Post: ${_selectedPlan.name} (${_selectedLevel == AdPackageLevel.district ? 'District' : 'State'})',
        firstName: candidateName.split(' ').first,
        email: email,
        phone: phone,
        additionalParams: {
          PayUAdditionalParamKeys.udf1: _selectedPlan.id.toString(),
          PayUAdditionalParamKeys.udf2:
              _selectedLevel == AdPackageLevel.district ? 'district' : 'state',
          PayUAdditionalParamKeys.udf3: 'Candidate Ad',
          PayUAdditionalParamKeys.udf4: adTitle,
          PayUAdditionalParamKeys.udf5:
              'Base: ${_selectedPlan.formattedBasePrice} | GST(18%): ${_selectedPlan.formattedGstAmount} | Total: ${_selectedPlan.formattedTotalPayable}',
        },
      );

      if (!mounted) return;

      if (result.isSuccess) {
        final paymentPayload = <String, dynamic>{
          'id': _selectedPlan.id,
          'status': 'success',
          'amount': _selectedPlan.totalPayable,
          'base_price': _selectedPlan.price,
          'gst_amount': _selectedPlan.gstAmount,
          'gst_rate': '18%',
          'total_payable': _selectedPlan.totalPayable,
          'mihpayid':
              result.mihpayid ?? result.paymentId ?? (result.txnId ?? txnId),
          'bank_ref_num': result.bankRefNum ?? (result.txnId ?? txnId),
          'paid_at': result.paidAt ?? DateTime.now().toUtc().toIso8601String(),
          'payment_response': result.rawData ?? {},
        };

        // Submit product ad with payment attribution
        final success = await controller.saveProduct(
          planId: _selectedPlan.id,
          transactionId: result.txnId ?? txnId,
          paymentId: result.paymentId ?? '',
          paymentStatus: 'success',
          paymentData: paymentPayload,
        );

        if (success) {
          if (!mounted) return;
          await _showReceiptDialog(
            txnId: result.txnId ?? txnId,
            planName: _selectedPlan.name,
            basePrice: _selectedPlan.formattedBasePrice,
            gstAmount: _selectedPlan.formattedGstAmount,
            totalPaid: _selectedPlan.formattedTotalPayable,
          );
          if (widget.onAdPublished != null) {
            widget.onAdPublished!();
          } else {
            Get.offAll(() => const SellProductReviewScreen());
          }
        } else {
          setState(() {
            _errorMessage = controller.savingError.value ??
                'Payment received, but ad submission failed. Please contact support.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              result.message ?? 'Payment was cancelled or could not be processed.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Payment error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showReceiptDialog({
    required String txnId,
    required String planName,
    required String basePrice,
    required String gstAmount,
    required String totalPaid,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: successGreen,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                color: darkText,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your ad promotion plan is activated and listing is published.',
              textAlign: TextAlign.center,
              style: TextStyle(color: greyText, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: lightBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderGrey),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Plan', planName),
                  const Divider(height: 16, color: borderGrey),
                  _buildReceiptRow('Package Price', basePrice),
                  const SizedBox(height: 6),
                  _buildReceiptRow('GST (18%)', gstAmount),
                  const Divider(height: 16, color: borderGrey),
                  _buildReceiptRow('Total Paid', totalPaid, isBold: true),
                  const Divider(height: 16, color: borderGrey),
                  _buildReceiptRow('Txn ID', txnId, isMono: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Continue to Review',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    bool isMono = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: greyText, fontSize: 12.5),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? primary : darkText,
            fontSize: isBold ? 14 : 12.5,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontFamily: isMono ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Center(
          child: AppBackButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Ad Plan',
              style: TextStyle(
                color: darkText,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Choose advertising reach & duration',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: greyText,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: borderGrey, height: 1),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Summary Card
                _buildProductSummaryCard(),
                const SizedBox(height: 18),

                // Level Switch (District vs State)
                _buildLevelSelector(),
                const SizedBox(height: 18),

                // Error Banner
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Plans List
                if (_isLoadingPlans)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: primary),
                    ),
                  )
                else
                  ..._currentPlans.map((plan) => _buildPlanCard(plan)),

                const SizedBox(height: 16),

                // 18% GST Billing Breakdown Card
                _buildBillingBreakdownCard(),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(),
          ),

          // Fullscreen loader when processing PayU
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: const Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: primary),
                        SizedBox(height: 16),
                        Text(
                          'Connecting to Payment Gateway...',
                          style: TextStyle(
                            color: darkText,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductSummaryCard() {
    final title = controller.titleCtrl.text.trim().isNotEmpty
        ? controller.titleCtrl.text.trim()
        : 'Your Product Listing';
    final price = controller.priceCtrl.text.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sell_rounded, color: primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Price: ₹$price',
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildLevelTab(
              label: 'District Level Ad',
              subtitle: 'Local target buyers',
              isSelected: _selectedLevel == AdPackageLevel.district,
              onTap: () => _onLevelChanged(AdPackageLevel.district),
            ),
          ),
          Expanded(
            child: _buildLevelTab(
              label: 'State Level Ad',
              subtitle: 'State-wide reach',
              isSelected: _selectedLevel == AdPackageLevel.state,
              onTap: () => _onLevelChanged(AdPackageLevel.state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTab({
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary : mediumText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? greyText : const Color(0xFF94A3B8),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(AdPostingPlan plan) {
    final isSelected = _selectedPlan.id == plan.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBFBFF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? primary : borderGrey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name + Popular Badge + Radio
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (plan.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  color: accentAmber, size: 12),
                              SizedBox(width: 3),
                              Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primary : const Color(0xFFCBD5E1),
                      width: isSelected ? 6.5 : 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Tagline
            Text(
              plan.tagline,
              style: const TextStyle(color: greyText, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Pricing Tag with 18% GST note
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.formattedBasePrice,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '+18% GST',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${plan.durationDays} Days Active',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: borderGrey, height: 1),
            const SizedBox(height: 10),

            // Included Features
            ...plan.includedFeatures.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: successGreen, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          color: mediumText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingBreakdownCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Price & GST Breakdown',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow('Package Price', _selectedPlan.formattedBasePrice),
          const SizedBox(height: 8),
          _buildBreakdownRow('GST (18%)', _selectedPlan.formattedGstAmount),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: borderGrey, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payable Amount',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              Text(
                _selectedPlan.formattedTotalPayable,
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: greyText, fontSize: 12.5),
        ),
        Text(
          value,
          style: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: borderGrey, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TOTAL PAYABLE',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  _selectedPlan.formattedTotalPayable,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const Text(
                  '(Incl. 18% GST)',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: _isProcessing ? null : _handlePayment,
                icon: const Icon(Icons.lock_rounded, size: 16),
                label: const Text(
                  'Pay & Post Ad',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

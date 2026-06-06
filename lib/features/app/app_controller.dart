import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/features/app/entity/user_entiity.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/kyc/domain/repository/kyc_repository.dart';
import 'package:rojgar/services/storage_service.dart';
import 'package:rojgar/splash_screen.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  final StorageService _storageService = Get.find<StorageService>();

  final _isLoggedIn = false.obs;
  final _user = Rxn<UserEntity>();
  final isUserDataLoading = false.obs;
  final rxSelectedStateId = RxnInt();
  final rxSelectedStateName = RxnString();

  bool get isLoggedIn => _isLoggedIn.value;
  UserEntity? get user => _user.value;
  int? get selectedStateId => rxSelectedStateId.value;
  String? get selectedStateName => rxSelectedStateName.value;

  final rxLocale = const Locale('en').obs;
  Locale get currentLocale => rxLocale.value;

  void updateLocale(Locale newLocale) {
    if (rxLocale.value == newLocale) return;
    rxLocale.value = newLocale;
    Get.updateLocale(newLocale);
    _storageService.saveLanguageCode(newLocale.languageCode);
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
    _loadSelectedState();
    _checkLoginState();
    _configureInterceptor();
  }

  @override
  void onReady() {
    super.onReady();
    if (isLoggedIn) {
      fetchAndSyncUserData();
    }
  }

  void _loadSavedLocale() {
    final savedCode = _storageService.getLanguageCode() ?? 'en';
    rxLocale.value = Locale(savedCode);
  }

  void _loadSelectedState() {
    rxSelectedStateId.value = _storageService.getSelectedStateId();
    rxSelectedStateName.value = _storageService.getSelectedStateName();
  }

  void updateSelectedState(int id, String name) {
    rxSelectedStateId.value = id;
    rxSelectedStateName.value = name;
    _storageService.saveSelectedStateId(id);
    _storageService.saveSelectedStateName(name);
  }

  void _checkLoginState() {
    final candidateId = _storageService.getCandidateId();
    final token = _storageService.getAccessToken();
    if (candidateId != null && token != null) {
      _isLoggedIn.value = true;
      _user.value = UserEntity(
        id: candidateId,
        username: '',
        name: '',
        email: '',
        phone: '',
        address: '',
        city: '',
        state: '',
        country: '',
        zipCode: '',
        profileImage: '',
      );
    }
  }

  Future<void> fetchAndSyncUserData() async {
    final candidateId = _storageService.getCandidateId();
    if (candidateId == null) return;

    try {
      isUserDataLoading.value = true;
      final kycRepo = Get.find<KycRepository>();
      final result = await kycRepo.getKycData(candidateId);
      result.fold(
        (failure) {
          debugPrint('Failed to sync user data: ${failure.message}');
        },
        (data) {
          final candidate = data.candidate;
          _user.value = UserEntity(
            id: candidateId,
            username: candidate.email,
            name: candidate.fullName,
            email: candidate.email,
            phone: candidate.phone,
            address: candidate.address,
            city: candidate.locality,
            state: candidate.stateId?.toString() ?? '',
            country: 'India',
            zipCode: candidate.pincode,
            profileImage: '',
          );
        },
      );
    } catch (e) {
      debugPrint('Error syncing user data: $e');
    } finally {
      isUserDataLoading.value = false;
    }
  }

  void login(AuthResponse authResponse) {
    _storageService.saveCandidateId(authResponse.id);
    _storageService.saveAccessToken(authResponse.token);
    _isLoggedIn.value = true;
    _user.value = authResponse.user.toEntity();
  }

  void logout() {
    _storageService.clear();
    _isLoggedIn.value = false;
    _user.value = null;
    Get.offAll(() => const SplashScreen());
  }

  void _configureInterceptor() {
    ApiService.configure(
      interceptors: [
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = _storageService.getAccessToken();
            if (token != null && token.isNotEmpty) {
              if (!options.headers.containsKey('Authorization')) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (DioException e, handler) {
            return handler.next(e);
          },
        ),
      ],
    );
  }
}

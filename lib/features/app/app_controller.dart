import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/entity/user_entiity.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/services/storage_service.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  final StorageService _storageService = Get.find<StorageService>();

  final _isLoggedIn = false.obs;
  final _user = Rxn<UserEntity>();

  bool get isLoggedIn => _isLoggedIn.value;
  UserEntity? get user => _user.value;

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
    _checkLoginState();
  }

  void _loadSavedLocale() {
    final savedCode = _storageService.getLanguageCode() ?? 'en';
    rxLocale.value = Locale(savedCode);
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
  }
}

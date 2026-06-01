// features/app/controllers/app_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rojgar/features/app/entity/user_entiity.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

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
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('language_code') ?? 'en';
      rxLocale.value = Locale(savedCode);
    } catch (_) {
      // ignore preferences read error
    }
  }

  // void setUser(UserEntity user) {
  //   _user.value = user;
  //   _isLoggedIn.value = true;
  // }

  // void clearUser() {
  //   _user.value = null;
  //   _isLoggedIn.value = false;
  // }

  // void _checkSession() {
  //   // check token from storage
  //   final token = GetStorage().read('token');
  //   if (token != null) _isLoggedIn.value = true;
  // }
}

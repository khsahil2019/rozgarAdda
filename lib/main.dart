import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rojgar/core/bindings/initial_bindings.dart';
import 'package:rojgar/core/theme/theme.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/floating_navbar.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/splash_screen.dart';
import 'package:rojgar/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rojgar/features/employer_dashboard/presentation/screens/employer_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = Get.put(StorageService(prefs), permanent: true);

  final savedCode = storageService.getLanguageCode() ?? 'en';
  final bool isCandidateLoggedIn = storageService.getCandidateId() != null;
  final bool isEmployerLoggedIn = prefs.getInt('employer_id') != null;

  runApp(MyApp(
    initialLocale: Locale(savedCode),
    isCandidateLoggedIn: isCandidateLoggedIn,
    isEmployerLoggedIn: isEmployerLoggedIn,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.initialLocale,
    required this.isCandidateLoggedIn,
    required this.isEmployerLoggedIn,
  });

  final Locale initialLocale;
  final bool isCandidateLoggedIn;
  final bool isEmployerLoggedIn;

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Locale _locale;
  late bool _isCandidateLoggedIn;
  late bool _isEmployerLoggedIn;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _isCandidateLoggedIn = widget.isCandidateLoggedIn;
    _isEmployerLoggedIn = widget.isEmployerLoggedIn;
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    if (Get.isRegistered<AppController>()) {
      AppController.to.updateLocale(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'RozgarAdda',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.lightTheme, //TODO TEMP LIGHT THEME
          
          initialBinding: InitialBinding(),
          locale: _locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: child,
        );
      },
      child: _isCandidateLoggedIn
          ? const FloatingNavbarScreen()
          : _isEmployerLoggedIn
              ? const EmployerDashboardScreen()
              : const SplashScreen(),
    );
  }
}

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = Get.put(StorageService(prefs), permanent: true);

  final savedCode = storageService.getLanguageCode() ?? 'en';
  final bool isLoggedIn = storageService.getCandidateId() != null;
  runApp(MyApp(initialLocale: Locale(savedCode), isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.initialLocale,
    required this.isLoggedIn,
  });

  final Locale initialLocale;
  final bool isLoggedIn;

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Locale _locale;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _isLoggedIn = widget.isLoggedIn;
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
          darkTheme: AppTheme.darkTheme,
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
      child: _isLoggedIn ? const FloatingNavbarScreen() : const SplashScreen(),
    );
  }
}

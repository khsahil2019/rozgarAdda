import 'package:flutter/material.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/features/auth/presentation/screens/login_screen.dart';
import 'package:rojgar/features/news/prsentation/screens/news_screen.dart';
import 'package:rojgar/features/auth/presentation/screens/registration_screen.dart';
import 'package:rojgar/floating_navbar.dart';
import 'package:rojgar/features/buy_product/presentation/screens/product_category_list_screen.dart';
import 'package:rojgar/features/buy_product/presentation/bindings/buy_product_binding.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rojgar/features/employer_auth/presentation/screens/employer_login_screen.dart';
import 'package:rojgar/features/employer_auth/presentation/screens/employer_registration_screen.dart';
import 'package:rojgar/features/employer_auth/presentation/bindings/employer_auth_binding.dart';
import 'package:rojgar/features/employer_dashboard/presentation/screens/employer_dashboard_screen.dart';
import 'package:rojgar/features/missing_person/presentation/screens/missing_person_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Color constants
  static const Color yellowColor = Color(0xFFFFCC00);
  static const Color whiteColor = Colors.white;
  static const Color lightWhite = Color(0xAAFFFFFF);
  static const Color innerBlue = Color(0xFF1400EE);


  Future<void> _navigateWithAuthCheck({
    required BuildContext context,
    required Widget loggedInScreen,
    bool replace = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isCandidate = prefs.getInt('candidate_id') != null;
    final isEmployer = prefs.getInt('employer_id') != null;

    if (!context.mounted) return;

    Widget destination;
    if (isCandidate) {
      destination = loggedInScreen;
    } else if (isEmployer) {
      destination = const EmployerDashboardScreen();
    } else {
      destination = const LoginScreen();
    }

    if (replace) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => destination));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double logoSize = size.width * 0.38;
    final l10n = context.l10n;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2200FF), Color(0xFF0000BB)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              children: [
                // Logo Section
                SizedBox(
                  width: logoSize + 30,
                  height: logoSize + 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // White outer rounded square
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: innerBlue,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Image.asset('assets/icons/logo.png'),
                        ),
                      ),

                      // Lightning badge bottom-right
                      Positioned(
                        bottom: 5,
                        right: 20,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: yellowColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1400FF),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: Color(0xFF1400FF),
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                // App Name
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.text('app_title').split(' ').first,
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: ' ${l10n.text('app_title').split(' ').last}',
                        style: const TextStyle(
                          color: yellowColor,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                Text(
                  l10n.text('splash_tagline'),
                  style: const TextStyle(
                    color: lightWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Menu options scrollable in remaining space
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _SplashMenuItem(
                        icon: Icons.home_rounded,
                        label: l10n.text('splash_menu_home'),
                        onTap: () => _navigateWithAuthCheck(
                          context: context,
                          loggedInScreen: const FloatingNavbarScreen(),
                          replace: true,
                        ),
                      ),
                      _SplashMenuItem(
                        icon: Icons.info_outline_rounded,
                        label: l10n.text('splash_menu_about'),
                        onTap: () {
                          // TODO: navigate to About Us screen
                        },
                      ),
                      _SplashMenuItem(
                        icon: Icons.report_gmailerrorred_rounded,
                        label: l10n.text('splash_menu_missing'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MissingPersonListScreen(),
                            ),
                          );
                        },
                      ),
                      _SplashMenuItem(
                        icon: Icons.article_rounded,
                        label: l10n.text('splash_menu_news'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NewsScreen(),
                            ),
                          );
                        },
                      ),
                      _SplashMenuItem(
                        icon: Icons.storefront_rounded,
                        label: l10n.text('splash_menu_product'),
                        onTap: () {
                          Get.to(
                            () => const ProductCategoryListScreen(),
                            binding: BuyProductBinding(),
                          );
                        },
                      ),
                      _SplashMenuItem(
                        icon: Icons.person_add_alt_1_rounded,
                        label: l10n.text('splash_menu_register'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegistrationFormScreen(),
                            ),
                          );
                        },
                      ),
                      _SplashMenuItem(
                        icon: Icons.login_rounded,
                        label: l10n.text('splash_menu_login'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                      _SplashMenuItem(
                        icon: Icons.business_center_rounded,
                        label: l10n.text('splash_menu_employer_login'),
                        onTap: () {
                          Get.to(
                            () => const EmployerLoginScreen(),
                            binding: EmployerAuthBinding(),
                          );
                        },
                      ),
                      _SplashMenuItem(
                        icon: Icons.domain_add_rounded,
                        label: l10n.text('splash_menu_employer_register'),
                        onTap: () {
                          Get.to(
                            () => const EmployerRegistrationScreen(),
                            binding: EmployerAuthBinding(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SplashMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

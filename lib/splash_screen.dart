import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/auth/presentation/screens/login_screen.dart';
import 'package:rojgar/features/auth/presentation/screens/registration_screen.dart';
import 'package:rojgar/features/buy_product/presentation/bindings/buy_product_binding.dart';
import 'package:rojgar/features/buy_product/presentation/screens/product_category_list_screen.dart';
import 'package:rojgar/features/employer_auth/presentation/bindings/employer_auth_binding.dart';
import 'package:rojgar/features/employer_auth/presentation/screens/employer_login_screen.dart';
import 'package:rojgar/features/employer_auth/presentation/screens/employer_registration_screen.dart';
import 'package:rojgar/features/employer_dashboard/presentation/screens/employer_dashboard_screen.dart';
import 'package:rojgar/features/missing_person/presentation/screens/missing_person_list_screen.dart';
import 'package:rojgar/features/news/prsentation/screens/news_screen.dart';
import 'package:rojgar/floating_navbar.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = context.l10n;

    final rawTitle = l10n.text('app_title');
    final titleParts = rawTitle.contains(' ') ? rawTitle.split(' ') : ['Rozgar', 'Adda'];
    final titlePart1 = titleParts.first;
    final titlePart2 = titleParts.sublist(1).join(' ');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ── Background Soft Light Gradient ───────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEEF2FF),
                  Color(0xFFF8FAFC),
                  Color(0xFFF1F5F9),
                ],
              ),
            ),
          ),

          // Ambient Light Background Orb 1
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC7D2FE).withValues(alpha: 0.35),
              ),
            ),
          ),

          // Ambient Light Background Orb 2
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9D5FF).withValues(alpha: 0.35),
              ),
            ),
          ),

          // ── Main Content Area ────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── Hero Branding Header Card (Light Mode) ──────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Logo Icon Frame
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1400FF), Color(0xFF3B82F6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1400FF).withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/icons/logo.png',
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.business_center_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Title Text (Fitted & Wrap Protected)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: titlePart1,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: ' $titlePart2',
                                  style: const TextStyle(
                                    color: Color(0xFF1400FF),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Tagline Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF1400FF).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            l10n.text('splash_tagline'),
                            style: const TextStyle(
                              color: Color(0xFF1400FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Quick Access Menu Actions (Light Mode) ───────────
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        // Main Dashboard Direct Entry
                        _buildPrimaryActionTile(
                          context,
                          title: l10n.text('splash_menu_home'),
                          subtitle: 'Enter Candidate Dashboard & Job Search',
                          icon: Icons.dashboard_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1400FF), Color(0xFF3B82F6)],
                          ),
                          onTap: () => _navigateWithAuthCheck(
                            context: context,
                            loggedInScreen: const FloatingNavbarScreen(),
                            replace: true,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Section 1: Candidate Access
                        _buildSectionLabel('CANDIDATE PORTAL'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridActionCard(
                                icon: Icons.login_rounded,
                                title: l10n.text('splash_menu_login'),
                                subtitle: 'Candidate Login',
                                iconBg: const Color(0xFFEEF2FF),
                                iconColor: const Color(0xFF1400FF),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildGridActionCard(
                                icon: Icons.person_add_alt_1_rounded,
                                title: l10n.text('splash_menu_register'),
                                subtitle: 'Create Account',
                                iconBg: const Color(0xFFECFDF5),
                                iconColor: const Color(0xFF059669),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegistrationFormScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Section 2: Employer Access
                        _buildSectionLabel('EMPLOYER PORTAL'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridActionCard(
                                icon: Icons.business_center_rounded,
                                title: l10n.text('splash_menu_employer_login'),
                                subtitle: 'Post Jobs & Hire',
                                iconBg: const Color(0xFFF3E8FF),
                                iconColor: const Color(0xFF7C3AED),
                                onTap: () {
                                  Get.to(
                                    () => const EmployerLoginScreen(),
                                    binding: EmployerAuthBinding(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildGridActionCard(
                                icon: Icons.domain_add_rounded,
                                title: l10n.text('splash_menu_employer_register'),
                                subtitle: 'Register Business',
                                iconBg: const Color(0xFFFFF7ED),
                                iconColor: const Color(0xFFEA580C),
                                onTap: () {
                                  Get.to(
                                    () => const EmployerRegistrationScreen(),
                                    binding: EmployerAuthBinding(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Section 3: App Services & Community
                        _buildSectionLabel('DISCOVER & SERVICES'),
                        const SizedBox(height: 6),

                        _buildListActionCard(
                          icon: Icons.storefront_rounded,
                          title: l10n.text('splash_menu_product'),
                          subtitle: 'Buy & sell products on Marketplace',
                          iconBg: const Color(0xFFFFFBEB),
                          iconColor: const Color(0xFFD97706),
                          onTap: () {
                            Get.to(
                              () => const ProductCategoryListScreen(),
                              binding: BuyProductBinding(),
                            );
                          },
                        ),
                        const SizedBox(height: 8),

                        _buildListActionCard(
                          icon: Icons.article_rounded,
                          title: l10n.text('splash_menu_news'),
                          subtitle: 'Read latest career & community news',
                          iconBg: const Color(0xFFFDF2F8),
                          iconColor: const Color(0xFFDB2777),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NewsScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),

                        _buildListActionCard(
                          icon: Icons.report_gmailerrorred_rounded,
                          title: l10n.text('splash_menu_missing'),
                          subtitle: 'View missing person alerts & reports',
                          iconBg: const Color(0xFFFEF2F2),
                          iconColor: const Color(0xFFDC2626),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MissingPersonListScreen()),
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // ── Footer Copyright (Light Mode) ───────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      'RozgarAdda v1.0.4 • Empowering Careers',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildPrimaryActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1400FF).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      softWrap: true,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFFEEF2FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      softWrap: true,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      softWrap: true,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      softWrap: true,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

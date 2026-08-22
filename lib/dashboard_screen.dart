import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/careear_hub.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/features/jobs/presentation/bindings/jobs_binding.dart';
import 'package:rojgar/features/jobs/presentation/screens/select_category_screen.dart';
import 'package:rojgar/features/profile/presentation/screens/help_support_screen.dart';
import 'package:rojgar/features/state_selection/presentation/screens/select_state_screen.dart';
import 'package:rojgar/floating_navbar.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/main.dart';
import 'package:rojgar/profile_screen.dart';

import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/dashboard/models/quick_link_model.dart';
import 'features/dashboard/widgets/dashboard_drawer.dart';
import 'features/dashboard/widgets/quick_link_card.dart';

export 'features/dashboard/controllers/dashboard_controller.dart';
export 'features/dashboard/models/nav_item_model.dart';
export 'features/dashboard/models/quick_link_model.dart';
export 'features/dashboard/widgets/dashboard_drawer.dart';
export 'features/dashboard/widgets/quick_link_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FloatingNavbarScreen();
  }
}

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final String? successMessage;
  const HomeScreen({super.key, this.successMessage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppController.to.isLoggedIn) {
        AppController.to.fetchAndSyncUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double hPad = size.width * 0.04;
    final l10n = AppLocalizations.of(context);
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: DashboardDrawer(
        onClose: () => _scaffoldKey.currentState?.closeDrawer(),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              // ── Top Header & Greeting ──────────────────────────────
              _buildHeader(context, l10n, controller),

              const SizedBox(height: 10),

              // ── Premium Search Bar ─────────────────────────────────
              _buildSearchBar(context, l10n, controller),

              const SizedBox(height: 14),

              // ── Quick Links Section Header ─────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.text('dashboard_quick_links').isNotEmpty
                          ? l10n.text('dashboard_quick_links')
                          : 'Quick Links',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => const SelectCategoryScreen(),
                          binding: JobsBinding(),
                        );
                      },
                      child: Text(
                        l10n.text('view_all').isNotEmpty
                            ? l10n.text('view_all')
                            : 'View All',
                        style: const TextStyle(
                          color: Color(0xFF1400FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Quick Links Grid ───────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kQuickLinks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, i) {
                    return QuickLinkCard(link: kQuickLinks[i]);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── About Rozgar & Highlights Section ─────────────────
              _buildAboutRozgarSection(context, hPad),

              const SizedBox(height: 16),

              // ── Recent Activity Section Header ────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Text(
                  l10n.text('dashboard_recent_activity').isNotEmpty
                      ? l10n.text('dashboard_recent_activity')
                      : 'Recent Activity',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Bottom Activity Banner Card ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: _buildActivityCard(size, l10n),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, DashboardController controller) {
    final double hPad = MediaQuery.of(context).size.width * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Controls Row ───────────────────────────────────────
          Row(
            children: [
              // Drawer Menu Toggle Icon
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFF0F172A),
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Location Selector Chip
              Expanded(
                child: GestureDetector(
                  onTap: () => _showLocationBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF1400FF),
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Obx(() {
                            final stateName = AppController.to.selectedStateName;
                            return Text(
                              stateName ?? l10n.text('dashboard_location'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF1400FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF1400FF),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Language Selector Button
              GestureDetector(
                onTap: () => _showLanguageBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.translate_rounded,
                        color: Color(0xFF1400FF),
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        AppLocalizations.of(context).locale.languageCode.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // User Profile Avatar
              GestureDetector(
                onTap: () {
                  Get.to(() => const ProfileScreen());
                },
                child: Obx(() {
                  final user = AppController.to.user;
                  final initial = (user?.name.isNotEmpty == true)
                      ? user!.name[0].toUpperCase()
                      : 'R';
                  return Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1400FF), Color(0xFF4F46E5)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1400FF).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Welcome & User Name Banner ─────────────────────────────
          Obx(() {
            final user = AppController.to.user;
            final rawName = user?.name.trim() ?? '';
            final displayName = rawName.isNotEmpty
                ? rawName
                : (l10n.text('sidebar_username').isNotEmpty ? l10n.text('sidebar_username') : 'Rozgar User');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Hello, $displayName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text('👋', style: TextStyle(fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 1),
                const Text(
                  'Explore jobs, marketplace & local updates',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n, DashboardController controller) {
    final double hPad = MediaQuery.of(context).size.width * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller.searchController,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: l10n.text('dashboard_search_hint').isNotEmpty
                ? l10n.text('dashboard_search_hint')
                : 'Search for jobs, companies, skills...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w400),
            prefixIcon: Container(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search_rounded, color: Color(0xFF1400FF), size: 18),
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.to(
                      () => const SelectCategoryScreen(),
                      binding: JobsBinding(),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1400FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 3),
                        Text(
                          'Filter',
                          style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── About Rozgar Adda & Platform Highlights ────────────────────────
  Widget _buildAboutRozgarSection(BuildContext context, double hPad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'About Rozgar Adda',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1400FF).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'TRUSTED PLATFORM',
                  style: TextStyle(
                    color: Color(0xFF1400FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 4 Compact Stats Grid
          Row(
            children: [
              _buildStatPill('50K+', 'Active Jobs', Icons.work_outline_rounded, const Color(0xFF1400FF)),
              const SizedBox(width: 8),
              _buildStatPill('10K+', 'Recruiters', Icons.business_outlined, const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildStatPill('100%', 'Free Portal', Icons.bolt_rounded, const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _buildStatPill('Verified', 'KYC Safe', Icons.verified_user_outlined, const Color(0xFF6366F1)),
            ],
          ),
          const SizedBox(height: 10),

          // Feature Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1400FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.stars_rounded, color: Color(0xFF1400FF), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'India\'s Employment & Citizen Network',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rozgar Adda connects job seekers, verified employers, and local communities with authentic employment opportunities, classified marketplace listings, and citizen assistance across India.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => Get.to(() => const HelpSupportScreen()),
                        icon: const Icon(Icons.help_outline_rounded, size: 15, color: Color(0xFF1400FF)),
                        label: const Text(
                          'Helpdesk & FAQ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1400FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => Get.to(() => const CareerHubScreen()),
                        icon: const Icon(Icons.insights_rounded, size: 15),
                        label: const Text(
                          'Career Hub',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String title, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Size size, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: size.height * 0.18,
        color: const Color(0xFF8ED8D4),
        child: Image.asset(
          'assets/icons/banner.jpeg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF1400FF),
            child: const Center(
              child: Icon(Icons.image_not_supported_rounded, color: Colors.white, size: 36),
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const SelectStateScreen(),
      ),
      isScrollControlled: true,
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10nText(context, 'language_dialog_title', defaultVal: 'Select Language'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ...AppLocalizations.languages.map((lang) {
                return ListTile(
                  leading: const Icon(Icons.language_rounded, color: Color(0xFF1400FF)),
                  title: Text(lang.nativeName),
                  subtitle: Text(lang.englishName),
                  onTap: () {
                    final appState = MyApp.of(context);
                    if (appState != null) {
                      appState.setLocale(Locale(lang.code));
                    }
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String l10nText(BuildContext context, String key, {required String defaultVal}) {
    final res = AppLocalizations.of(context).text(key);
    return res.isNotEmpty && res != key ? res : defaultVal;
  }
}

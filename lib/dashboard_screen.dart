import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/features/buy_product/presentation/bindings/buy_product_binding.dart';
import 'package:rojgar/features/buy_product/presentation/screens/product_category_list_screen.dart';
import 'package:rojgar/features/jobs/presentation/bindings/jobs_binding.dart';
import 'package:rojgar/features/jobs/presentation/screens/recent_jobs_screen.dart';
import 'package:rojgar/features/jobs/presentation/screens/select_category_screen.dart';
import 'package:rojgar/features/missing_person/presentation/screens/missing_person_list_screen.dart';
import 'package:rojgar/features/news/prsentation/screens/news_screen.dart';
import 'package:rojgar/features/sell_product/presentation/screens/sell_product_category_screen.dart';
import 'package:rojgar/features/state_selection/presentation/screens/select_state_screen.dart';
import 'package:rojgar/floating_navbar.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/main.dart';
import 'package:rojgar/profile_screen.dart';

import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/dashboard/models/nav_item_model.dart';
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
    final double hPad = size.width * 0.045;
    final l10n = AppLocalizations.of(context);
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: DashboardDrawer(
        onClose: () => _scaffoldKey.currentState?.closeDrawer(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Top Header & Greeting ──────────────────────────────
              _buildHeader(context, l10n, controller),

              const SizedBox(height: 16),

              // ── Premium Search Bar ─────────────────────────────────
              _buildSearchBar(context, l10n, controller),

              const SizedBox(height: 22),

              // ── Quick Links Section ────────────────────────────────
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
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        l10n.text('view_all').isNotEmpty
                            ? l10n.text('view_all')
                            : 'View All',
                        style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Quick Links Grid ───────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kQuickLinks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.22,
                  ),
                  itemBuilder: (context, i) {
                    return QuickLinkCard(link: kQuickLinks[i]);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Recent Activity Section ────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Text(
                  l10n.text('dashboard_recent_activity').isNotEmpty
                      ? l10n.text('dashboard_recent_activity')
                      : 'Recent Activity',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Bottom Activity Banner Card ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: _buildActivityCard(size, l10n),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, DashboardController controller) {
    final double hPad = MediaQuery.of(context).size.width * 0.045;

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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFF0F172A),
                    size: 22,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Location Selector Chip
              Expanded(
                child: GestureDetector(
                  onTap: () => _showLocationBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF4F46E5),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Obx(() {
                            final stateName = AppController.to.selectedStateName;
                            return Text(
                              stateName ?? l10n.text('dashboard_location'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF4F46E5),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF4F46E5),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Language Selector Button
              GestureDetector(
                onTap: () => _showLanguageBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
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
                        color: Color(0xFF4F46E5),
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context).locale.languageCode.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 16),

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
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Explore jobs, products & local updates',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.1,
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
    final double hPad = MediaQuery.of(context).size.width * 0.045;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller.searchController,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: l10n.text('dashboard_search_hint').isNotEmpty
                ? l10n.text('dashboard_search_hint')
                : 'Search for jobs, companies, skills...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w400),
            prefixIcon: Container(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.search_rounded, color: Color(0xFF4F46E5), size: 20),
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.to(
                      () => const SelectCategoryScreen(),
                      binding: JobsBinding(),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Size size, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: size.height * 0.25,
        color: const Color(0xFF8ED8D4),
        child: Image.asset(
          'assets/icons/banner.jpeg',
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF4F46E5),
            child: const Center(
              child: Icon(Icons.image_not_supported_rounded, color: Colors.white, size: 40),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  leading: const Icon(Icons.language_rounded, color: Color(0xFF4F46E5)),
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

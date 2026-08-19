import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/features/jobs/presentation/screens/select_category_screen.dart';
import 'package:rojgar/features/jobs/presentation/screens/recent_jobs_screen.dart';
import 'package:rojgar/features/kyc/presentation/screens/edit_kyc_screen.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/main.dart';
import 'package:rojgar/features/buy_product/presentation/screens/product_category_list_screen.dart';
import 'package:rojgar/features/buy_product/presentation/bindings/buy_product_binding.dart';
import 'package:rojgar/features/sell_product/presentation/screens/sell_product_category_screen.dart';
import 'package:rojgar/features/news/prsentation/screens/news_screen.dart';
import 'package:rojgar/features/state_selection/presentation/screens/select_state_screen.dart';
import 'package:rojgar/features/state_selection/presentation/bindings/state_selection_binding.dart';
import 'package:rojgar/features/chat/presentation/screens/chat_user_list_screen.dart';
import 'package:rojgar/features/chat/presentation/bindings/chat_binding.dart';
import 'package:rojgar/features/chat/presentation/controller/chat_controller.dart';
import 'package:rojgar/features/missing_person/presentation/screens/missing_person_list_screen.dart';
import 'package:rojgar/profile_screen.dart';
import 'package:rojgar/features/profile/presentation/screens/my_applications_screen.dart';
import 'package:rojgar/features/profile/presentation/screens/my_products_screen.dart';
import 'package:rojgar/features/profile/presentation/screens/help_support_screen.dart';

class AC {
  static const Color primaryPurple = Color(0xFF5B2BE0);
  static const Color lightPurple = Color(0xFFEDE8FF);
  static const Color darkText = Color(0xFF111111);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color scaffoldBg = Color(0xFFF2F3F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color searchBg = Color(0xFFEEEFF5);
  static const Color borderColor = Color(0xFFE0E0EE);
  static const Color navBg = Color(0xFFFFFFFF);

  // Quick link icon bg colors
  static const Color blueBg = Color(0xFFDEEAFF);
  static const Color greenBg = Color(0xFFD6F5E8);
  static const Color purpleBg = Color(0xFFEEDDFF);
  static const Color orangeBg = Color(0xFFFFEDD5);
  static const Color pinkBg = Color(0xFFFFDDDD);
  static const Color cyanBg = Color(0xFFD5F5FF);

  // Icon colors
  static const Color blueIcon = Color(0xFF2255DD);
  static const Color greenIcon = Color(0xFF1E9E5E);
  static const Color purpleIcon = Color(0xFF8833CC);
  static const Color orangeIcon = Color(0xFFDD6611);
  static const Color pinkIcon = Color(0xFFDD3366);
  static const Color cyanIcon = Color(0xFF0099CC);
}

// ─────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────
class QuickLink {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String imageUrl;
  const QuickLink(
    this.label,
    this.icon,
    this.bgColor,
    this.iconColor,
    this.imageUrl,
  );
}

const List<QuickLink> kQuickLinks = [
  QuickLink(
    'Find Jobs',
    Icons.work_rounded,
    AC.blueBg,
    AC.blueIcon,
    'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=400&q=80',
  ),
  QuickLink(
    'KYC Status',
    Icons.verified_rounded,
    AC.greenBg,
    AC.greenIcon,
    'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=400&q=80',
  ),
  QuickLink(
    'Sell Products',
    Icons.storefront_rounded,
    AC.greenBg,
    AC.greenIcon,
    'https://images.unsplash.com/photo-1573216755088-971e32839531?auto=format&fit=crop&w=400&q=80',
  ),
  // QuickLink(
  //   'Marketplace',
  //   Icons.storefront_rounded,
  //   AC.purpleBg,
  //   AC.purpleIcon,
  //   '',
  // ),
  QuickLink(
    'News',
    Icons.payments_rounded,
    AC.orangeBg,
    AC.orangeIcon,
    'https://i.ibb.co/qFXNhgFD/Whats-App-Image-2026-06-06-at-12-45-46-AM.jpg',
  ),
  QuickLink(
    'Missing Persons',
    Icons.support_agent_rounded,
    AC.pinkBg,
    AC.pinkIcon,

    'https://images.unsplash.com/photo-1737154590393-20c0b8c389ae?auto=format&fit=crop&w=400&q=80',
  ),
  // QuickLink(
  //   'Skill Up',
  //   Icons.school_rounded,
  //   AC.cyanBg,
  //   AC.cyanIcon,
  //   'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=400&q=80',
  // ),
  QuickLink(
    'Recent Jobs',
    Icons.school_rounded,
    AC.cyanBg,
    Color.fromARGB(255, 174, 152, 255),
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=400&q=80',
  ),
  // QuickLink(
  //   'Post Job',
  //   Icons.add_business_rounded,
  //   AC.orangeBg,
  //   AC.orangeIcon,
  //   'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=400&q=80',
  // ),
];

// ─────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.successMessage});

  final String? successMessage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  bool _sidebarOpen = false;
  late AnimationController _sidebarController;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRegistrationSuccessDialog(widget.successMessage!);
      });
    }
  }

  void _showRegistrationSuccessDialog(String email) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.text('registration_success_title')),
          content: Text('${l10n.text('registration_success_message')}$email'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.text('ok')),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _openSidebar() {
    setState(() => _sidebarOpen = true);
    _sidebarController.forward();
  }

  void _closeSidebar() {
    _sidebarController.reverse().then((_) {
      if (mounted) setState(() => _sidebarOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.045;

    return Scaffold(
      backgroundColor: AC.scaffoldBg,
      body: Stack(
        children: [
          // ── Main content ──────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top Header ─────────────────────
                _buildHeader(hPad, l10n),

                // ── Search Bar ─────────────────────
                _buildSearchBar(hPad, l10n),

                const SizedBox(height: 4),

                // ── Scrollable Body ────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),

                        // Quick Links header
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.text('dashboard_quick_links'),
                                style: const TextStyle(
                                  color: AC.darkText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  l10n.text('view_all'),
                                  style: const TextStyle(
                                    color: AC.primaryPurple,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Quick Links Grid
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: kQuickLinks.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.22,
                                ),
                            itemBuilder: (context, i) =>
                                _QuickLinkCard(link: kQuickLinks[i]),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Recent Activity
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Text(
                            l10n.text('dashboard_recent_activity'),
                            style: const TextStyle(
                              color: AC.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Activity Card
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: _buildActivityCard(size, l10n),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Sidebar Overlay ────────────────────
          if (_sidebarOpen)
            AnimatedBuilder(
              animation: _sidebarController,
              builder: (context, _) {
                return Stack(
                  children: [
                    // Dark scrim
                    GestureDetector(
                      onTap: _closeSidebar,
                      child: FadeTransition(
                        opacity: _sidebarController,
                        child: Container(color: Colors.black.withOpacity(0.45)),
                      ),
                    ),
                    // Sidebar panel
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _sidebarController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: _CollapsibleSidebar(onClose: _closeSidebar),
                    ),
                  ],
                );
              },
            ),
        ],
      ),

      // // ── Bottom Navigation ─────────────────
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ──────────────────────────────────
  Widget _buildHeader(double hPad, AppLocalizations l10n) {
    return Container(
      color: AC.scaffoldBg,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      child: Row(
        children: [
          // Hamburger — tappable
          GestureDetector(
            onTap: _openSidebar,
            child: const Icon(Icons.menu_rounded, color: AC.darkText, size: 26),
          ),

          const SizedBox(width: 10),

          // Location chip
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.to(
                  () => const SelectStateScreen(fromDashboard: true),
                  binding: StateSelectionBinding(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AC.lightPurple,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AC.primaryPurple,
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
                            color: AC.primaryPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        );
                      }),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AC.primaryPurple,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Language selector button
          _buildLanguageSelectorButton(context),

          const SizedBox(width: 10),

          // // Avatar
          // Container(
          //   width: 40,
          //   height: 40,
          //   decoration: BoxDecoration(
          //     color: AC.lightPurple,
          //     shape: BoxShape.circle,
          //   ),
          //   child: const Icon(
          //     Icons.person_rounded,
          //     color: AC.primaryPurple,
          //     size: 22,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectorButton(BuildContext context) {
    final currentLangCode = Localizations.localeOf(context).languageCode;
    final currentLang = AppLocalizations.languages.firstWhere(
      (lang) => lang.code == currentLangCode,
      orElse: () => AppLocalizations.languages.first,
    );

    return GestureDetector(
      onTap: () => _showLanguageBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AC.borderColor, width: 1.2),
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
              color: AC.primaryPurple,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              currentLang.nativeName,
              style: const TextStyle(
                color: AC.darkText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AC.greyText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final currentLangCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                l10n.text('language_dialog_title'),
                style: const TextStyle(
                  color: AC.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                l10n.text('language_dialog_message'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AC.greyText,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              // Language List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AppLocalizations.languages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final lang = AppLocalizations.languages[index];
                    final bool isSelected = lang.code == currentLangCode;

                    return GestureDetector(
                      onTap: () async {
                        final appState = MyApp.of(context);
                        if (appState != null) {
                          await appState.setLocale(Locale(lang.code));
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AC.lightPurple : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AC.primaryPurple
                                : AC.borderColor.withValues(alpha: 0.6),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AC.primaryPurple.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.01),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Left language abbreviation badge
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AC.primaryPurple
                                    : AC.scaffoldBg,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  lang.code.toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AC.darkText.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Language Names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.nativeName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AC.primaryPurple
                                          : AC.darkText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lang.englishName,
                                    style: const TextStyle(
                                      color: AC.greyText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Selection Indicator
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AC.primaryPurple,
                                size: 22,
                              )
                            else
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AC.borderColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Search ───────────────────────────────────
  Widget _buildSearchBar(double hPad, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AC.searchBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          style: const TextStyle(color: AC.darkText, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.text('dashboard_search_hint'),
            hintStyle: const TextStyle(color: AC.greyText, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AC.greyText,
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Activity Card ────────────────────────────
  Widget _buildActivityCard(Size size, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: size.height * 0.25,
        color: const Color(0xFF8ED8D4),
        child: Stack(
          children: [
            Image.asset(
              'assets/icons/banner.jpeg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Background office scene illustration
            // CustomPaint(
            //   size: Size(size.width, size.height * 0.25),
            //   painter: _OfficePainter(),
            // ),

            // NEW JOB badge
            // Positioned(
            //   top: 14,
            //   left: 14,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 12,
            //       vertical: 5,
            //     ),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: Text(
            //       l10n.text('dashboard_new_job_badge'),
            //       style: const TextStyle(
            //         color: AC.primaryPurple,
            //         fontSize: 12,
            //         fontWeight: FontWeight.w800,
            //         letterSpacing: 0.5,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
      _NavItem(Icons.work_rounded, Icons.work_outline_rounded, 'Jobs'),
      _NavItem(Icons.storefront_rounded, Icons.storefront_outlined, 'Market'),
      _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AC.navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        i == _navIndex
                            ? items[i].activeIcon
                            : items[i].inactiveIcon,
                        color: i == _navIndex ? AC.primaryPurple : AC.greyText,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: i == _navIndex
                              ? AC.primaryPurple
                              : AC.greyText,
                          fontSize: 11,
                          fontWeight: i == _navIndex
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUICK LINK CARD
// ─────────────────────────────────────────────
class _QuickLinkCard extends StatelessWidget {
  final QuickLink link;
  const _QuickLinkCard({required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              link.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: link.iconColor.withValues(alpha: 0.9),
                  child: Center(
                    child: Icon(
                      link.icon,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 48,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: link.iconColor.withValues(alpha: 0.4),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Gradient Overlay for Tint and Text Contrast
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    link.iconColor.withValues(alpha: 0.3),
                    link.iconColor.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            // Tappable InkWell with Text
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (link.label == 'Missing Persons') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MissingPersonListScreen(),
                        ),
                      );
                    } else if (link.label == 'Post Job') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            ).text('post_job_coming_soon'),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            if (link.label == 'KYC Status') {
                              return EditKycScreen();
                            } else if (link.label == 'Sell Products') {
                              return SellProductCategoryScreen();
                            } else if (link.label == 'News') {
                              return const NewsScreen();
                            } else if (link.label == 'Recent Jobs') {
                              return const RecentJobsScreen();
                            } else {
                              return const SelectCategoryScreen();
                            }
                          },
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).text(link.label.toLowerCase().replaceAll(' ', '_')),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// OFFICE SCENE PAINTER
// ─────────────────────────────────────────────
// class _OfficePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size s) {
//     // Teal background
//     canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF8ED8D4));

//     // Floor
//     canvas.drawRect(
//       Rect.fromLTWH(0, s.height * 0.78, s.width, s.height * 0.22),
//       Paint()..color = const Color(0xFF7BC8C4),
//     );

//     // Table
//     final tablePaint = Paint()..color = const Color(0xFFE8C87A);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(
//           s.width * 0.08,
//           s.height * 0.58,
//           s.width * 0.72,
//           s.height * 0.06,
//         ),
//         const Radius.circular(4),
//       ),
//       tablePaint,
//     );
//     // Table legs
//     for (final lx in [s.width * 0.12, s.width * 0.72]) {
//       canvas.drawRect(
//         Rect.fromLTWH(lx, s.height * 0.64, s.width * 0.03, s.height * 0.16),
//         tablePaint,
//       );
//     }

//     // Laptop on table
//     final lapPaint = Paint()..color = const Color(0xFF9999BB);
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(
//           s.width * 0.35,
//           s.height * 0.42,
//           s.width * 0.18,
//           s.height * 0.16,
//         ),
//         const Radius.circular(3),
//       ),
//       lapPaint,
//     );
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(
//           s.width * 0.32,
//           s.height * 0.57,
//           s.width * 0.24,
//           s.height * 0.03,
//         ),
//         const Radius.circular(2),
//       ),
//       lapPaint,
//     );

//     // Screen glow
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(
//           s.width * 0.36,
//           s.height * 0.43,
//           s.width * 0.16,
//           s.height * 0.13,
//         ),
//         const Radius.circular(2),
//       ),
//       Paint()..color = const Color(0xFFCCDDFF),
//     );

//     // Blue divider / document
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(
//           s.width * 0.42,
//           s.height * 0.38,
//           s.width * 0.12,
//           s.height * 0.22,
//         ),
//         const Radius.circular(3),
//       ),
//       Paint()..color = const Color(0xFFAAAAAFF).withOpacity(0.5),
//     );

//     // Person 1 – left (leaning, yellow shirt)
//     _drawPerson(
//       canvas,
//       s,
//       cx: s.width * 0.14,
//       topY: s.height * 0.2,
//       bodyColor: const Color(0xFFE8A030),
//       pantsColor: const Color(0xFF3355AA),
//       skinColor: const Color(0xFFD4A080),
//       leaning: true,
//     );

//     // Person 2 – center-left (sitting, pink shirt)
//     _drawPerson(
//       canvas,
//       s,
//       cx: s.width * 0.36,
//       topY: s.height * 0.3,
//       bodyColor: const Color(0xFFDDAACF),
//       pantsColor: const Color(0xFF444466),
//       skinColor: const Color(0xFFD4A080),
//       sitting: true,
//     );

//     // Person 3 – center (standing, white shirt)
//     _drawPerson(
//       canvas,
//       s,
//       cx: s.width * 0.54,
//       topY: s.height * 0.18,
//       bodyColor: const Color(0xFFEEEEEE),
//       pantsColor: const Color(0xFF223366),
//       skinColor: const Color(0xFFD4A080),
//     );

//     // Person 4 – right (sitting, orange/rust shirt)
//     _drawPerson(
//       canvas,
//       s,
//       cx: s.width * 0.76,
//       topY: s.height * 0.3,
//       bodyColor: const Color(0xFFCC7755),
//       pantsColor: const Color(0xFF334466),
//       skinColor: const Color(0xFFD4A080),
//       sitting: true,
//     );

//     // Hanging lamp 1
//     _drawLamp(canvas, s, s.width * 0.3, const Color(0xFFFFEE88));
//     // Hanging lamp 2
//     _drawLamp(canvas, s, s.width * 0.55, const Color(0xFFFFEE88));

//     // Plant (right side)
//     _drawPlant(canvas, s, s.width * 0.9);
//   }

//   void _drawPerson(
//     Canvas canvas,
//     Size s, {
//     required double cx,
//     required double topY,
//     required Color bodyColor,
//     required Color pantsColor,
//     required Color skinColor,
//     bool leaning = false,
//     bool sitting = false,
//   }) {
//     final skin = Paint()..color = skinColor;
//     final body = Paint()..color = bodyColor;
//     final pants = Paint()..color = pantsColor;
//     final hair = Paint()..color = const Color(0xFF332211);

//     final double headR = s.width * 0.045;
//     final double bodyH = s.height * 0.22;
//     final double bodyW = s.width * 0.1;

//     // Head
//     final headCx = cx + (leaning ? s.width * 0.05 : 0);
//     final headCy = topY + headR;
//     canvas.drawCircle(Offset(headCx, headCy), headR, skin);
//     // Hair
//     final hairP = Path();
//     hairP.addArc(
//       Rect.fromCircle(center: Offset(headCx, headCy), radius: headR),
//       3.14,
//       3.14,
//     );
//     canvas.drawPath(hairP, hair);

//     if (sitting) {
//       // Torso
//       canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromLTWH(cx - bodyW / 2, topY + headR * 2, bodyW, bodyH * 0.38),
//           const Radius.circular(4),
//         ),
//         body,
//       );
//       // Legs horizontal
//       canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromLTWH(
//             cx - bodyW * 0.8,
//             topY + headR * 2 + bodyH * 0.38,
//             bodyW * 1.6,
//             bodyH * 0.14,
//           ),
//           const Radius.circular(4),
//         ),
//         pants,
//       );
//     } else if (leaning) {
//       // Torso angled
//       final torsoPath = Path();
//       torsoPath.moveTo(cx, topY + headR * 2);
//       torsoPath.lineTo(cx + bodyW * 0.8, topY + headR * 2 + bodyH * 0.18);
//       torsoPath.lineTo(
//         cx + bodyW * 0.8 + bodyW * 0.6,
//         topY + headR * 2 + bodyH * 0.18,
//       );
//       torsoPath.lineTo(cx + bodyW * 0.6, topY + headR * 2);
//       torsoPath.close();
//       canvas.drawPath(torsoPath, body);
//       // Legs
//       for (final lx in [cx - bodyW * 0.15, cx + bodyW * 0.35]) {
//         canvas.drawRRect(
//           RRect.fromRectAndRadius(
//             Rect.fromLTWH(
//               lx,
//               topY + headR * 2 + bodyH * 0.18,
//               bodyW * 0.28,
//               bodyH * 0.45,
//             ),
//             const Radius.circular(4),
//           ),
//           pants,
//         );
//       }
//     } else {
//       // Normal standing
//       canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromLTWH(cx - bodyW / 2, topY + headR * 2, bodyW, bodyH * 0.38),
//           const Radius.circular(4),
//         ),
//         body,
//       );
//       for (final lx in [cx - bodyW * 0.32, cx + bodyW * 0.04]) {
//         canvas.drawRRect(
//           RRect.fromRectAndRadius(
//             Rect.fromLTWH(
//               lx,
//               topY + headR * 2 + bodyH * 0.38,
//               bodyW * 0.28,
//               bodyH * 0.4,
//             ),
//             const Radius.circular(4),
//           ),
//           pants,
//         );
//       }
//     }
//   }

//   void _drawLamp(Canvas canvas, Size s, double cx, Color lightColor) {
//     final cord = Paint()
//       ..color = const Color(0xFF888888)
//       ..strokeWidth = 1.5;
//     canvas.drawLine(Offset(cx, 0), Offset(cx, s.height * 0.22), cord);

//     final shade = Paint()..color = const Color(0xFFEEEECC);
//     final shadePath = Path();
//     shadePath.moveTo(cx - s.width * 0.04, s.height * 0.22);
//     shadePath.lineTo(cx - s.width * 0.025, s.height * 0.32);
//     shadePath.lineTo(cx + s.width * 0.025, s.height * 0.32);
//     shadePath.lineTo(cx + s.width * 0.04, s.height * 0.22);
//     shadePath.close();
//     canvas.drawPath(shadePath, shade);

//     // Light glow
//     canvas.drawCircle(
//       Offset(cx, s.height * 0.32),
//       s.width * 0.04,
//       Paint()
//         ..color = lightColor.withOpacity(0.3)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
//     );
//   }

//   void _drawPlant(Canvas canvas, Size s, double cx) {
//     // Pot
//     final potPath = Path();
//     potPath.moveTo(cx - s.width * 0.04, s.height * 0.72);
//     potPath.lineTo(cx - s.width * 0.03, s.height * 0.84);
//     potPath.lineTo(cx + s.width * 0.03, s.height * 0.84);
//     potPath.lineTo(cx + s.width * 0.04, s.height * 0.72);
//     potPath.close();
//     canvas.drawPath(potPath, Paint()..color = const Color(0xFFDDDDDD));

//     // Stem
//     canvas.drawLine(
//       Of// ─────────────────────────────────────────────
// REDESIGNED COLLAPSIBLE SIDEBAR DRAWER
// ─────────────────────────────────────────────
class _CollapsibleSidebar extends StatefulWidget {
  final VoidCallback onClose;
  const _CollapsibleSidebar({required this.onClose});

  @override
  State<_CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<_CollapsibleSidebar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final sw = size.width * 0.82;

    return Container(
      width: sw > 330 ? 330 : sw,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 36,
            spreadRadius: 2,
            offset: const Offset(10, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Top Brand Header ───────────────────────
            _buildBrandHeader(context, l10n),

            // ── Scrollable Body ────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // ── User Profile Banner Card ──────────────────
                    _buildUserProfileCard(context, l10n),

                    const SizedBox(height: 20),

                    // ── Menu Section 1: DISCOVER & JOBS ──────────
                    _buildSectionHeader('DISCOVER & WORK'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.grid_view_rounded,
                      labelKey: 'nav_home',
                      defaultLabel: 'Home Dashboard',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      isActive: _selectedIndex == 0,
                      onTap: () {
                        setState(() => _selectedIndex = 0);
                        widget.onClose();
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.work_rounded,
                      labelKey: 'find_jobs',
                      defaultLabel: 'Find Jobs',
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                      isActive: _selectedIndex == 1,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                        widget.onClose();
                        Get.to(() => const SelectCategoryScreen());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.shopping_bag_rounded,
                      labelKey: 'buy_products',
                      defaultLabel: 'Buy Products',
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF7C3AED),
                      isActive: _selectedIndex == 2,
                      onTap: () {
                        setState(() => _selectedIndex = 2);
                        widget.onClose();
                        Get.to(
                          () => const ProductCategoryListScreen(),
                          binding: BuyProductBinding(),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.sell_rounded,
                      labelKey: 'sell_products',
                      defaultLabel: 'Sell Products',
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFEA580C),
                      isActive: _selectedIndex == 3,
                      onTap: () {
                        setState(() => _selectedIndex = 3);
                        widget.onClose();
                        Get.to(() => const SellProductCategoryScreen());
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Menu Section 2: COMMUNITY & SERVICES ─────
                    _buildSectionHeader('COMMUNITY & SERVICES'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.chat_bubble_rounded,
                      labelKey: 'messages',
                      defaultLabel: 'Messages',
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: const Color(0xFF4F46E5),
                      badge: 'CHAT',
                      badgeBg: const Color(0xFF6366F1),
                      isActive: _selectedIndex == 4,
                      onTap: () {
                        setState(() => _selectedIndex = 4);
                        widget.onClose();
                        if (!Get.isRegistered<ChatController>()) {
                          ChatBinding().dependencies();
                        }
                        Get.to(() => const ChatUserListScreen());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.newspaper_rounded,
                      labelKey: 'news',
                      defaultLabel: 'Latest News',
                      iconBg: const Color(0xFFFDF2F8),
                      iconColor: const Color(0xFFDB2777),
                      badge: 'NEW',
                      badgeBg: const Color(0xFFEC4899),
                      isActive: _selectedIndex == 5,
                      onTap: () {
                        setState(() => _selectedIndex = 5);
                        widget.onClose();
                        Get.to(() => const NewsScreen());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.person_search_rounded,
                      labelKey: 'missing_persons',
                      defaultLabel: 'Missing Persons',
                      iconBg: const Color(0xFFFEF2F2),
                      iconColor: const Color(0xFFDC2626),
                      badge: 'ALERT',
                      badgeBg: const Color(0xFFEF4444),
                      isActive: _selectedIndex == 6,
                      onTap: () {
                        setState(() => _selectedIndex = 6);
                        widget.onClose();
                        Get.to(() => const MissingPersonListScreen());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.history_rounded,
                      labelKey: 'recent_jobs',
                      defaultLabel: 'Recent Jobs',
                      iconBg: const Color(0xFFF0FDFA),
                      iconColor: const Color(0xFF0D9488),
                      isActive: _selectedIndex == 7,
                      onTap: () {
                        setState(() => _selectedIndex = 7);
                        widget.onClose();
                        Get.to(() => const RecentJobsScreen());
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Menu Section 3: ACCOUNT & SUPPORT ───────
                    _buildSectionHeader('ACCOUNT & SUPPORT'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context,
                      icon: Icons.verified_user_rounded,
                      labelKey: 'kyc_status',
                      defaultLabel: 'KYC Status',
                      iconBg: const Color(0xFFFAF5FF),
                      iconColor: const Color(0xFF9333EA),
                      badge: 'STATUS',
                      badgeBg: const Color(0xFF10B981),
                      isActive: _selectedIndex == 8,
                      onTap: () {
                        setState(() => _selectedIndex = 8);
                        widget.onClose();
                        Get.to(() => const EditKycScreen());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.assignment_turned_in_rounded,
                      labelKey: 'my_applications',
                      defaultLabel: 'My Applications',
                      iconBg: const Color(0xFFF0F9FF),
                      iconColor: const Color(0xFF0284C7),
                      isActive: _selectedIndex == 9,
                      onTap: () {
                        setState(() => _selectedIndex = 9);
                        widget.onClose();
                        Get.to(() => const MyApplicationsScreen());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.inventory_2_rounded,
                      labelKey: 'my_products',
                      defaultLabel: 'My Products',
                      iconBg: const Color(0xFFFFFBEB),
                      iconColor: const Color(0xFFD97706),
                      isActive: _selectedIndex == 10,
                      onTap: () {
                        setState(() => _selectedIndex = 10);
                        widget.onClose();
                        Get.to(() => const MyProductsScreen());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.headset_mic_rounded,
                      labelKey: 'support',
                      defaultLabel: 'Help & Support',
                      iconBg: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF475569),
                      isActive: _selectedIndex == 11,
                      onTap: () {
                        setState(() => _selectedIndex = 11);
                        widget.onClose();
                        Get.to(() => const HelpSupportScreen());
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Footer Section (Logout & App Version) ────
            _buildFooter(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/icons/logo.png",
                  errorBuilder: (_, __, ___) => const Icon(Icons.business_center, color: AC.primaryPurple),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'RozgarAdda',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Careers & Marketplace',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFF334155),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        widget.onClose();
        Get.to(() => const ProfileScreen());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Obx(() {
              if (AppController.to.isUserDataLoading.value) {
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  ),
                );
              }
              final user = AppController.to.user;
              final name = user?.name.isNotEmpty == true
                  ? user!.name
                  : AppLocalizations.of(context).text('sidebar_username');

              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

              return Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.25),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.verified_rounded,
                                    color: Colors.white,
                                    size: 11,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'KYC Verified',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String labelKey,
    required String defaultLabel,
    required Color iconBg,
    required Color iconColor,
    required bool isActive,
    required VoidCallback onTap,
    String? badge,
    Color? badgeBg,
  }) {
    final localized = AppLocalizations.of(context).text(labelKey);
    final displayLabel = (localized.isNotEmpty && localized != labelKey) ? localized : defaultLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: iconColor.withValues(alpha: 0.1),
          highlightColor: iconColor.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AC.primaryPurple.withValues(alpha: 0.09)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isActive
                  ? Border.all(color: AC.primaryPurple.withValues(alpha: 0.2), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isActive ? AC.primaryPurple : iconBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AC.primaryPurple.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    displayLabel,
                    style: TextStyle(
                      color: isActive ? AC.primaryPurple : const Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeBg ?? AC.primaryPurple).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeBg ?? AC.primaryPurple,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else if (isActive)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AC.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF2F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFEF4444),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Confirm Logout',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ],
                    ),
                    content: const Text(
                      'Are you sure you want to log out of RozgarAdda?',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  widget.onClose();
                  AppController.to.logout();
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFCA5A5).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.text('logout').isNotEmpty && l10n.text('logout') != 'logout'
                          ? l10n.text('logout')
                          : 'Log Out',
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'RozgarAdda v1.0.4',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(' • ', style: TextStyle(color: Color(0xFFCBD5E1))),
              Text(
                'Empowering Careers',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
},
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Logout ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: GestureDetector(
                onTap: () {
                  widget.onClose();
                  AppController.to.logout();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDD3344),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        AppLocalizations.of(context).text('logout'),
                        style: const TextStyle(
                          color: Color(0xFFDD3344),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

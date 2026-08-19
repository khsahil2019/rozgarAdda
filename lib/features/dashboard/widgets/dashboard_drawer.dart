import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/features/buy_product/presentation/bindings/buy_product_binding.dart';
import 'package:rojgar/features/buy_product/presentation/screens/product_category_list_screen.dart';
import 'package:rojgar/features/jobs/presentation/bindings/jobs_binding.dart';
import 'package:rojgar/features/jobs/presentation/screens/recent_jobs_screen.dart';
import 'package:rojgar/features/jobs/presentation/screens/select_category_screen.dart';
import 'package:rojgar/features/kyc/presentation/screens/edit_kyc_screen.dart' hide AC;
import 'package:rojgar/features/missing_person/presentation/screens/missing_person_list_screen.dart';
import 'package:rojgar/features/news/prsentation/screens/news_screen.dart';
import 'package:rojgar/features/profile/presentation/screens/help_support_screen.dart';
import 'package:rojgar/features/profile/presentation/screens/my_applications_screen.dart';
import 'package:rojgar/features/profile/presentation/screens/my_products_screen.dart';
import 'package:rojgar/features/sell_product/presentation/screens/sell_product_category_screen.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/profile_screen.dart';

class DashboardDrawer extends StatefulWidget {
  final VoidCallback onClose;
  const DashboardDrawer({super.key, required this.onClose});

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {
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
                        Get.to(
                          () => const SelectCategoryScreen(),
                          binding: JobsBinding(),
                        );
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
                    // _buildMenuItem(
                    //   context,
                    //   icon: Icons.chat_bubble_rounded,
                    //   labelKey: 'messages',
                    //   defaultLabel: 'Messages',
                    //   iconBg: const Color(0xFFEEF2FF),
                    //   iconColor: const Color(0xFF4F46E5),
                    //   badge: 'CHAT',
                    //   badgeBg: const Color(0xFF6366F1),
                    //   isActive: _selectedIndex == 4,
                    //   onTap: () {
                    //     setState(() => _selectedIndex = 4);
                    //     widget.onClose();
                    //     if (!Get.isRegistered<ChatController>()) {
                    //       ChatBinding().dependencies();
                    //     }
                    //     Get.to(() => const ChatUserListScreen());
                    //   },
                    // ),
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
                        Get.to(() => EditKycScreen());
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
                  errorBuilder: (_, __, ___) => const Icon(Icons.business_center, color: Color(0xFF7C3AED)),
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
                  ? const Color(0xFF7C3AED).withValues(alpha: 0.09)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isActive
                  ? Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.2), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF7C3AED) : iconBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
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
                      color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF1E293B),
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
                      color: (badgeBg ?? const Color(0xFF7C3AED)).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeBg ?? const Color(0xFF7C3AED),
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
                      color: Color(0xFF7C3AED),
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
}

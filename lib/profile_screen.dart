// ─────────────────────────────────────────────
// PREMIUM ROZGAR PROFILE SCREEN
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/widgets/network_image_service.dart';
import 'features/app/app_controller.dart';
import 'features/kyc/presentation/screens/edit_kyc_screen.dart';
import 'features/profile/presentation/screens/change_password_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/help_support_screen.dart';
import 'features/profile/presentation/screens/my_applications_screen.dart';
import 'features/profile/presentation/screens/my_products_screen.dart';
import 'localization/app_localizations.dart';
import 'main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _primary = Color(0xFF1400FF);
  static const Color _darkText = Color(0xFF0F172A);
  static const Color _greyText = Color(0xFF64748B);
  static const Color _borderGrey = Color(0xFFE2E8F0);
  static const Color _scaffoldBg = Color(0xFFF8FAFC);
  static const Color _cardBg = Colors.white;
  static const Color _red = Color(0xFFEF4444);

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                color: _red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.text('logout_confirm_title').isNotEmpty &&
                        l10n.text('logout_confirm_title') != 'logout_confirm_title'
                    ? l10n.text('logout_confirm_title')
                    : 'Confirm Logout',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: _darkText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.text('logout_confirm_message').isNotEmpty &&
                  l10n.text('logout_confirm_message') != 'logout_confirm_message'
              ? l10n.text('logout_confirm_message')
              : 'Are you sure you want to log out of your account?',
          style: const TextStyle(
            color: _greyText,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _borderGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.text('cancel').isNotEmpty && l10n.text('cancel') != 'cancel'
                        ? l10n.text('cancel')
                        : 'Cancel',
                    style: const TextStyle(
                      color: _greyText,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.text('logout').isNotEmpty && l10n.text('logout') != 'logout'
                        ? l10n.text('logout')
                        : 'Logout',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AppController.to.logout();
    }
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
              const Text(
                'Select App Language',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _darkText),
              ),
              const SizedBox(height: 16),
              ...AppLocalizations.languages.map((lang) {
                final isCurrent = AppLocalizations.of(context).locale.languageCode == lang.code;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? _primary.withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: isCurrent ? _primary : _greyText,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: isCurrent ? _primary : _darkText,
                    ),
                  ),
                  subtitle: Text(lang.englishName, style: const TextStyle(fontSize: 12, color: _greyText)),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle_rounded, color: _primary, size: 20)
                      : null,
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

  @override
  Widget build(BuildContext context) {
    if (AppController.to.user != null && AppController.to.user!.name.isEmpty) {
      AppController.to.fetchAndSyncUserData();
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          l10n.text('profile_my_profile').isNotEmpty &&
                  l10n.text('profile_my_profile') != 'profile_my_profile'
              ? l10n.text('profile_my_profile')
              : 'My Profile',
          style: const TextStyle(
            color: _darkText,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1400FF).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: _primary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _borderGrey),
        ),
      ),
      body: Obx(() {
        if (AppController.to.isUserDataLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }
        final user = AppController.to.user;
        final candidateId = user?.id;
        final name = user?.name.isNotEmpty == true
            ? user!.name
            : (l10n.text('sidebar_username').isNotEmpty ? l10n.text('sidebar_username') : 'Rozgar User');
        final email = user?.email.isNotEmpty == true ? user!.email : '';
        final phone = user?.phone.isNotEmpty == true ? user!.phone : '';
        final avatarUrl = user?.profileImage;
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Profile Banner Card ────────────────────
              _buildHeroProfileCard(
                context,
                name: name,
                email: email,
                phone: phone,
                candidateId: candidateId,
                initial: initial,
                avatarUrl: avatarUrl,
              ),

              const SizedBox(height: 16),

              // ── Quick Shortcuts Row ────────────────────────
              _buildQuickShortcutsGrid(context, l10n),

              const SizedBox(height: 18),

              // ── Section 1: Account Settings Group ──────────
              _buildSectionHeader('ACCOUNT MANAGEMENT'),
              const SizedBox(height: 6),
              _buildGroupedCard([
                _GroupedTileData(
                  icon: Icons.person_outline_rounded,
                  label: l10n.text('profile_edit_profile'),
                  defaultLabel: 'Personal Information & Resume',
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF2563EB),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ),
                ),
                _GroupedTileData(
                  icon: Icons.verified_user_outlined,
                  label: l10n.text('profile_kyc_status'),
                  defaultLabel: 'KYC & Document Verification',
                  iconBg: const Color(0xFFFAF5FF),
                  iconColor: const Color(0xFF9333EA),
                  badge: 'VERIFIED',
                  badgeBg: const Color(0xFF10B981),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditKycScreen()),
                  ),
                ),
                _GroupedTileData(
                  icon: Icons.lock_outline_rounded,
                  label: l10n.text('profile_change_password'),
                  defaultLabel: 'Change Password & Security',
                  iconBg: const Color(0xFFFEFCE8),
                  iconColor: const Color(0xFFCA8A04),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  ),
                ),
              ]),

              const SizedBox(height: 18),

              // ── Section 2: Activity & Listings Group ───────
              _buildSectionHeader('MY ACTIVITY & LISTINGS'),
              const SizedBox(height: 6),
              _buildGroupedCard([
                _GroupedTileData(
                  icon: Icons.work_outline_rounded,
                  label: l10n.text('profile_my_applications'),
                  defaultLabel: 'My Job Applications',
                  iconBg: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF059669),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
                  ),
                ),
                _GroupedTileData(
                  icon: Icons.storefront_outlined,
                  label: l10n.text('profile_my_products'),
                  defaultLabel: 'My Listed Products & Items',
                  iconBg: const Color(0xFFFFF7ED),
                  iconColor: const Color(0xFFEA580C),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyProductsScreen()),
                  ),
                ),
              ]),

              const SizedBox(height: 18),

              // ── Section 3: Preferences & Support Group ─────
              _buildSectionHeader('PREFERENCES & SUPPORT'),
              const SizedBox(height: 6),
              _buildGroupedCard([
                _GroupedTileData(
                  icon: Icons.translate_rounded,
                  label: 'App Language',
                  defaultLabel: 'App Language (${AppLocalizations.of(context).locale.languageCode.toUpperCase()})',
                  iconBg: const Color(0xFFEEF2FF),
                  iconColor: const Color(0xFF1400FF),
                  onTap: () => _showLanguageBottomSheet(context),
                ),
                _GroupedTileData(
                  icon: Icons.help_outline_rounded,
                  label: l10n.text('profile_help_support'),
                  defaultLabel: 'Helpdesk, FAQs & Contact Support',
                  iconBg: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF475569),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                  ),
                ),
              ]),

              const SizedBox(height: 22),

              // ── Logout Action Button ───────────────────────
              _buildLogoutButton(context, l10n),

              const SizedBox(height: 18),

              // ── App Footer ─────────────────────────────────
              Center(
                child: Text(
                  'Rozgar Adda v1.0.0 • Verified Employment Platform',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _greyText.withValues(alpha: 0.8),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroProfileCard(
    BuildContext context, {
    required String name,
    required String email,
    required String phone,
    required int? candidateId,
    required String initial,
    String? avatarUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1400FF), Color(0xFF3B82F6), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1400FF).withValues(alpha: 0.28),
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
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              // Profile Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: ClipOval(
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImageService(
                              imageUrl: avatarUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // User Info Details
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
                        fontSize: 18.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (phone.isNotEmpty || email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone.isNotEmpty ? phone : email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'KYC Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (candidateId != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'ID: #$candidateId',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShortcutsGrid(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _buildShortcutCard(
          context,
          icon: Icons.work_history_rounded,
          title: 'Applications',
          bgColor: const Color(0xFF1400FF),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _buildShortcutCard(
          context,
          icon: Icons.storefront_rounded,
          title: 'My Products',
          bgColor: const Color(0xFFEA580C),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyProductsScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _buildShortcutCard(
          context,
          icon: Icons.verified_user_rounded,
          title: 'KYC Status',
          bgColor: const Color(0xFF10B981),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditKycScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderGrey, width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: bgColor, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _darkText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: _greyText,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<_GroupedTileData> items) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderGrey, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          final displayLabel = (item.label.isNotEmpty && !item.label.contains('_'))
              ? item.label
              : item.defaultLabel;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: i == 0
                      ? const BorderRadius.vertical(top: Radius.circular(18))
                      : (isLast
                          ? const BorderRadius.vertical(bottom: Radius.circular(18))
                          : BorderRadius.zero),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.iconBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.iconColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayLabel,
                            style: const TextStyle(
                              color: _darkText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (item.badge != null)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (item.badgeBg ?? _primary).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item.badge!,
                              style: TextStyle(
                                color: item.badgeBg ?? _primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                  indent: 66,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _logout(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
              width: 1.1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: _red,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.text('logout').isNotEmpty && l10n.text('logout') != 'logout'
                    ? l10n.text('logout')
                    : 'Log Out',
                style: const TextStyle(
                  color: _red,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupedTileData {
  final IconData icon;
  final String label;
  final String defaultLabel;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeBg;

  _GroupedTileData({
    required this.icon,
    required this.label,
    required this.defaultLabel,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    this.badge,
    this.badgeBg,
  });
}

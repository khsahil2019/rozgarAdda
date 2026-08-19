// ─────────────────────────────────────────────
// REDESIGNED PROFILE SCREEN
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/app/app_controller.dart';
import 'features/kyc/presentation/screens/edit_kyc_screen.dart';
import 'features/profile/presentation/screens/change_password_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/help_support_screen.dart';
import 'features/profile/presentation/screens/my_applications_screen.dart';
import 'features/profile/presentation/screens/my_products_screen.dart';
import 'localization/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _red = Color(0xFFEF4444);
  static const Color _scaffoldBg = Color(0xFFF8FAFC);

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            Text(
              l10n.text('logout_confirm_title').isNotEmpty &&
                      l10n.text('logout_confirm_title') != 'logout_confirm_title'
                  ? l10n.text('logout_confirm_title')
                  : 'Confirm Logout',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          l10n.text('logout_confirm_message').isNotEmpty &&
                  l10n.text('logout_confirm_message') != 'logout_confirm_message'
              ? l10n.text('logout_confirm_message')
              : 'Are you sure you want to log out of your account?',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              l10n.text('cancel').isNotEmpty && l10n.text('cancel') != 'cancel'
                  ? l10n.text('cancel')
                  : 'Cancel',
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.text('logout').isNotEmpty && l10n.text('logout') != 'logout'
                  ? l10n.text('logout')
                  : 'Logout',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AppController.to.logout();
    }
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          l10n.text('profile_my_profile').isNotEmpty &&
                  l10n.text('profile_my_profile') != 'profile_my_profile'
              ? l10n.text('profile_my_profile')
              : 'My Profile',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF4F46E5),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (AppController.to.isUserDataLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          );
        }
        final user = AppController.to.user;
        final candidateId = user?.id;
        final name = user?.name.isNotEmpty == true
            ? user!.name
            : l10n.text('sidebar_username');
        final subtitle = user?.email.isNotEmpty == true
            ? user!.email
            : (user?.phone.isNotEmpty == true ? user!.phone : '');
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Avatar Banner Card ─────────────────────
              _buildHeroProfileCard(context, name, subtitle, candidateId, initial),

              const SizedBox(height: 20),

              // ── Quick Stat / Shortcut Grid ─────────────────
              _buildQuickShortcutsGrid(context, l10n),

              const SizedBox(height: 24),

              // ── Section 1: Account Settings ────────────────
              _buildSectionHeader('ACCOUNT MANAGEMENT'),
              const SizedBox(height: 8),
              _buildProfileTile(
                context,
                icon: Icons.person_outline_rounded,
                label: l10n.text('profile_edit_profile'),
                defaultLabel: 'Edit Profile Information',
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
              _buildProfileTile(
                context,
                icon: Icons.verified_user_outlined,
                label: l10n.text('profile_kyc_status'),
                defaultLabel: 'KYC & Document Verification',
                iconBg: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF9333EA),
                badge: 'STATUS',
                badgeBg: const Color(0xFF10B981),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditKycScreen()),
                ),
              ),
              _buildProfileTile(
                context,
                icon: Icons.lock_outline_rounded,
                label: l10n.text('profile_change_password'),
                defaultLabel: 'Change Password',
                iconBg: const Color(0xFFFEFCE8),
                iconColor: const Color(0xFFCA8A04),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                ),
              ),

              const SizedBox(height: 20),

              // ── Section 2: Activity & Services ─────────────
              _buildSectionHeader('MY ACTIVITY & LISTINGS'),
              const SizedBox(height: 8),
              _buildProfileTile(
                context,
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
              _buildProfileTile(
                context,
                icon: Icons.storefront_outlined,
                label: l10n.text('profile_my_products'),
                defaultLabel: 'My Listed Products',
                iconBg: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFEA580C),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProductsScreen()),
                ),
              ),

              const SizedBox(height: 20),

              // ── Section 3: Help & Support ──────────────────
              _buildSectionHeader('HELP & PREFERENCES'),
              const SizedBox(height: 8),
              _buildProfileTile(
                context,
                icon: Icons.help_outline_rounded,
                label: l10n.text('profile_help_support'),
                defaultLabel: 'Help & Support Center',
                iconBg: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF475569),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                ),
              ),

              const SizedBox(height: 28),

              // ── Logout Action Button ───────────────────────
              _buildLogoutButton(context, l10n),

              const SizedBox(height: 28),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroProfileCard(
    BuildContext context,
    String name,
    String subtitle,
    int? candidateId,
    String initial,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.25),
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
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
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
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
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.verified_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'KYC Verified',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (candidateId != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '#ID: $candidateId',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildQuickShortcutsGrid(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _buildShortcutCard(
          context,
          icon: Icons.work_rounded,
          title: 'Applications',
          bgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _buildShortcutCard(
          context,
          icon: Icons.shopping_bag_rounded,
          title: 'My Products',
          bgColor: const Color(0xFFFFF7ED),
          iconColor: const Color(0xFFEA580C),
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
          bgColor: const Color(0xFFFAF5FF),
          iconColor: const Color(0xFF9333EA),
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
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String defaultLabel,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
    String? badge,
    Color? badgeBg,
  }) {
    final displayLabel = (label.isNotEmpty && !label.contains('_')) ? label : defaultLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    displayLabel,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeBg ?? const Color(0xFF4F46E5)).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeBg ?? const Color(0xFF4F46E5),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
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
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _logout(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: _red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.text('logout').isNotEmpty && l10n.text('logout') != 'logout'
                    ? l10n.text('logout')
                    : 'Log Out',
                style: const TextStyle(
                  color: _red,
                  fontSize: 16,
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

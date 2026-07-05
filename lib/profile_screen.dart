// ─────────────────────────────────────────────
// PROFILE SCREEN
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/app/app_controller.dart';
import 'features/profile/presentation/screens/change_password_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/help_support_screen.dart';
import 'features/profile/presentation/screens/my_applications_screen.dart';
import 'features/profile/presentation/screens/my_products_screen.dart';
import 'localization/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen();

  static const Color _greyText = Color(0xFF8A8FA3);
  static const Color _scaffoldBg = Color(0xFFF5F6FA);
  static const Color _red = Color(0xFFDD3344);

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n.text('logout_confirm_title'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(l10n.text('logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              l10n.text('cancel'),
              style: const TextStyle(color: _greyText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              l10n.text('logout'),
              style: const TextStyle(color: _red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    AppController.to.logout();
  }

  @override
  Widget build(BuildContext context) {
    if (AppController.to.user != null && AppController.to.user!.name.isEmpty) {
      AppController.to.fetchAndSyncUserData();
    }

    return Scaffold(
      backgroundColor: _scaffoldBg,
      body: SafeArea(
        child: Obx(() {
          if (AppController.to.isUserDataLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1400FF)),
            );
          }
          final user = AppController.to.user;
          final candidateId = user?.id;
          final name = user?.name.isNotEmpty == true
              ? user!.name
              : context.l10n.text('profile_my_profile');
          final subtitle = user?.email.isNotEmpty == true
              ? user!.email
              : (user?.phone.isNotEmpty == true ? user!.phone : '');

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // ── Avatar Card ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1400FF), Color(0xFF4433FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (candidateId != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${context.l10n.text('profile_id_label')}: $candidateId',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Menu Items ───────────────────────────
                _ProfileTile(
                  icon: Icons.person_outline_rounded,
                  label: context.l10n.text('profile_edit_profile'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),
                // _ProfileTile(
                //   icon: Icons.verified_outlined,
                //   label: context.l10n.text('profile_kyc_status'),
                //   onTap: () {},
                // ),
                _ProfileTile(
                  icon: Icons.storefront_outlined,
                  label: context.l10n.text('profile_my_products'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyProductsScreen()),
                  ),
                ),
                _ProfileTile(
                  icon: Icons.work_outline_rounded,
                  label: context.l10n.text('profile_my_applications'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyApplicationsScreen(),
                    ),
                  ),
                ),
                _ProfileTile(
                  icon: Icons.lock_outline_rounded,
                  label: context.l10n.text('profile_change_password'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  ),
                ),
                _ProfileTile(
                  icon: Icons.help_outline_rounded,
                  label: context.l10n.text('profile_help_support'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Logout Button ────────────────────────
                GestureDetector(
                  onTap: () => _logout(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFCCCC),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: _red, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.text('logout'),
                          style: const TextStyle(
                            color: _red,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF1400FF), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8A8FA3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

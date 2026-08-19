import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/auth/presentation/bindings/auth_binding.dart';
import 'package:rojgar/features/auth/presentation/screens/login_screen.dart';
import 'package:rojgar/features/employer_dashboard/presentation/bindings/employer_dashboard_binding.dart';
import 'package:rojgar/features/employer_dashboard/presentation/screens/employer_dashboard_screen.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/splash_screen.dart';

import '../controllers/employer_login_controller.dart';
import '../bindings/employer_auth_binding.dart';
import 'employer_registration_screen.dart';

class EmployerLoginScreen extends GetView<EmployerLoginController> {
  const EmployerLoginScreen({super.key});

  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                context.l10n.text('login_error_title'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ],
          ),
          content: Text(
            message.isNotEmpty ? message : 'Something went wrong. Please try again.',
            style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(context.l10n.text('ok'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login(BuildContext context) async {
    final emailVal = controller.email.value.trim();
    final passwordVal = controller.password.value;

    if (emailVal.isEmpty || passwordVal.isEmpty) {
      _showErrorDialog(context, context.l10n.text('login_error_empty'));
      return;
    }
    if (!controller.acceptedTerms.value) {
      _showErrorDialog(context, context.l10n.text('login_terms_error'));
      return;
    }

    try {
      await controller.login(
        onError: (errorMsg) {
          _showErrorDialog(context, errorMsg);
        },
        onSuccess: () {
          Get.offAll(
            () => const EmployerDashboardScreen(),
            binding: EmployerDashboardBinding(),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(context, 'Login failed. Please check your credentials.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double hPad = size.width * 0.06;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3E8FF).withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDDD6FE).withValues(alpha: 0.4),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Top Navigation Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const SplashScreen()),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: darkText,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
                          ),
                          child: const Text(
                            'Employer Portal',
                            style: TextStyle(
                              color: primaryPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.035),

                    // Logo + Header Title Card
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryPurple.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.business_center_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.text('login_welcome_back'),
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.text('employer_login_subtitle'),
                            style: const TextStyle(
                              color: greyText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.035),

                    // Form Container Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email Label
                          Text(
                            l10n.text('login_email_label'),
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInputField(
                            hintText: l10n.text('login_email_hint'),
                            controller: controller.emailController,
                            prefixIcon: Icons.alternate_email_rounded,
                            obscureText: false,
                          ),

                          const SizedBox(height: 18),

                          // Password Label
                          Text(
                            l10n.text('login_password_label'),
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => _buildInputField(
                              hintText: '••••••••',
                              controller: controller.passwordController,
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: controller.isPasswordObscured.value,
                              showSuffix: true,
                              onSuffixTap: controller.togglePasswordObscurity,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Terms and Conditions Checkbox
                          GestureDetector(
                            onTap: controller.toggleTermsAcceptance,
                            child: Row(
                              children: [
                                Obx(
                                  () => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: controller.acceptedTerms.value
                                          ? primaryPurple
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: controller.acceptedTerms.value
                                            ? primaryPurple
                                            : const Color(0xFFCBD5E1),
                                        width: 1.8,
                                      ),
                                    ),
                                    child: controller.acceptedTerms.value
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.text('login_terms_agree'),
                                    style: const TextStyle(
                                      color: darkText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Employer Sign In Action Button
                          Obx(
                            () => _signInBtn(
                              onTap: controller.isLoginEnabled
                                  ? () => _login(context)
                                  : null,
                              isEnabled: controller.isLoginEnabled,
                              isLoading: controller.isLoading.value,
                              signInLabel: l10n.text('login_sign_in'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Candidate Login Link
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.off(
                            () => const LoginScreen(),
                            binding: AuthBinding(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Are you a Candidate? ",
                                style: TextStyle(color: greyText, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "Candidate Login",
                                style: TextStyle(
                                  color: primaryPurple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Employer Registration Link Footer
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.off(
                            () => const EmployerRegistrationScreen(),
                            binding: EmployerAuthBinding(),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${l10n.text('login_no_account')} ',
                                style: const TextStyle(
                                  color: greyText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: l10n.text('login_register'),
                                style: const TextStyle(
                                  color: primaryPurple,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData prefixIcon,
    required bool obscureText,
    TextEditingController? controller,
    bool showSuffix = false,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: primaryPurple, size: 20),
          suffixIcon: showSuffix
              ? IconButton(
                  onPressed: onSuffixTap,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  static Widget _signInBtn({
    required VoidCallback? onTap,
    required bool isEnabled,
    required String signInLabel,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: isEnabled
            ? const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
              )
            : null,
        color: isEnabled ? null : const Color(0xFFCBD5E1),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primaryPurple.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        signInLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

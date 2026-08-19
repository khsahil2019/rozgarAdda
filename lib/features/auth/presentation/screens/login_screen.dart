import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/features/auth/presentation/controller/login_controller.dart';
import 'package:rojgar/features/auth/presentation/screens/registration_screen.dart';
import 'package:rojgar/features/state_selection/presentation/bindings/state_selection_binding.dart';
import 'package:rojgar/features/state_selection/presentation/screens/select_state_screen.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/splash_screen.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);

  Future<void> _login(BuildContext context) async {
    final username = controller.username.value.trim();
    final password = controller.password.value;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(context, context.l10n.text('login_error_empty'));
      return;
    }
    if (!controller.acceptedTerms.value) {
      _showErrorDialog(context, context.l10n.text('login_terms_error'));
      return;
    }

    try {
      await controller.login();
      if (!context.mounted) return;
      Get.off(
        () => SelectStateScreen(successMessage: username),
        binding: StateSelectionBinding(),
      );
    } catch (e) {
      if (!context.mounted) return;
      final errorMessage = e is Failure
          ? e.message
          : context.l10n.text('login_error_generic');
      _showErrorDialog(context, errorMessage);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    final l10n = context.l10n;
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
                l10n.text('login_error_title'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryIndigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.text('ok'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
                color: const Color(0xFFC7D2FE).withValues(alpha: 0.3),
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
                color: const Color(0xFFE9D5FF).withValues(alpha: 0.3),
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
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                          ),
                          child: const Text(
                            'Candidate Sign In',
                            style: TextStyle(
                              color: primaryIndigo,
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
                                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryIndigo.withValues(alpha: 0.3),
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
                            l10n.text('login_subtitle'),
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
                          // Username / Email Label
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
                            controller: controller.usernameController,
                            prefixIcon: Icons.alternate_email_rounded,
                            obscureText: false,
                          ),

                          const SizedBox(height: 18),

                          // Password Label & Forgot Action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.text('login_password_label'),
                                style: const TextStyle(
                                  color: darkText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  l10n.text('login_forgot'),
                                  style: const TextStyle(
                                    color: primaryIndigo,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
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
                                          ? primaryIndigo
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: controller.acceptedTerms.value
                                            ? primaryIndigo
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

                          // Sign In Action Button
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

                    SizedBox(height: size.height * 0.035),

                    // Registration Navigation Link Footer
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegistrationFormScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 1),
                          ),
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
                                    color: primaryIndigo,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
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
          prefixIcon: Icon(prefixIcon, color: primaryIndigo, size: 20),
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
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              )
            : null,
        color: isEnabled ? null : const Color(0xFFCBD5E1),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primaryIndigo.withValues(alpha: 0.35),
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

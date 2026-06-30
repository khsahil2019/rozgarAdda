import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/features/auth/presentation/screens/login_screen.dart';
import 'package:rojgar/features/auth/presentation/bindings/auth_binding.dart';
import 'package:rojgar/splash_screen.dart';
import '../controllers/employer_login_controller.dart';
import 'employer_registration_screen.dart';
import '../../presentation/bindings/employer_auth_binding.dart';
import '../../../employer_dashboard/presentation/screens/employer_dashboard_screen.dart';
import '../../../employer_dashboard/presentation/bindings/employer_dashboard_binding.dart';

class EmployerLoginScreen extends GetView<EmployerLoginController> {
  const EmployerLoginScreen({super.key});

  // Visual constants matching Candidate styling
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color lightLavender = Color(0xFFEAEAF8);
  static const Color borderColor = Color(0xFFD0D5F5);
  static const Color fieldBg = Color(0xFFF7F8FF);
  static const Color scaffoldBg = Color(0xFFFFFFFF);

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.l10n.text('login_error_title')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.text('ok')),
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double hPad = size.width * 0.06;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlue, size: 24),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              );
            },
          ),
        ),
        centerTitle: true,
        title: Text(
          l10n.text('employer_login_title'),
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.04),

              // Employer Branding Icon
              SizedBox(
                width: 90.w,
                child: Image.asset(
                  'assets/icons/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: size.height * 0.028),

              // Heading
              Text(
                l10n.text('login_welcome_back'),
                style: const TextStyle(
                  color: darkText,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Subheading
              Text(
                l10n.text('employer_login_subtitle'),
                style: const TextStyle(
                  color: greyText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: size.height * 0.04),

              // Email Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.text('login_email_label'),
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Email Field
              _buildInputField(
                hintText: l10n.text('login_email_hint'),
                controller: controller.emailController,
                prefixIcon: Icons.mail_outline_rounded,
                obscureText: false,
              ),

              const SizedBox(height: 18),

              // Password Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.text('login_password_label'),
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Password Field
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

              const SizedBox(height: 16),

              // Terms Acceptance
              Row(
                children: [
                  GestureDetector(
                    onTap: controller.toggleTermsAcceptance,
                    child: Obx(
                      () => Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.acceptedTerms.value
                              ? primaryBlue
                              : Colors.transparent,
                          border: Border.all(
                            color: controller.acceptedTerms.value
                                ? primaryBlue
                                : greyText,
                            width: 1.5,
                          ),
                        ),
                        child: controller.acceptedTerms.value
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.text('login_terms_agree'),
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.032),

              // Sign In Button
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

              SizedBox(height: size.height * 0.035),

              // Switch to Candidate flow option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Are you a Candidate? ",
                    style: TextStyle(color: greyText, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.off(
                        () => const LoginScreen(),
                        binding: AuthBinding(),
                      );
                    },
                    child: Text(
                      "Candidate Login",
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Register text
              GestureDetector(
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
                        text: l10n.text('login_no_account'),
                        style: const TextStyle(
                          color: greyText,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: l10n.text('login_register'),
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
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
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: greyText, fontSize: 15),
          prefixIcon: Icon(prefixIcon, color: primaryBlue, size: 20),
          suffixIcon: showSuffix
              ? IconButton(
                  onPressed: onSuffixTap,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: greyText,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
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
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isEnabled ? primaryBlue : const Color(0xFFB8BCCD),
        boxShadow: [
          BoxShadow(
            color: (isEnabled ? primaryBlue : const Color(0xFFB8BCCD))
                .withAlpha((0.35 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
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
                : Text(
                    signInLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

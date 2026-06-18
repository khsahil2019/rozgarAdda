import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../controllers/employer_register_controller.dart';
import 'employer_login_screen.dart';
import '../../presentation/bindings/employer_auth_binding.dart';
import '../../../employer_dashboard/presentation/screens/employer_dashboard_screen.dart';
import '../../../employer_dashboard/presentation/bindings/employer_dashboard_binding.dart';

class EmployerRegistrationScreen extends GetView<EmployerRegisterController> {
  const EmployerRegistrationScreen({super.key});

  // Visual constants matching styling
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

  Future<void> _register(BuildContext context) async {
    if (controller.companyName.value.trim().isEmpty ||
        controller.contactPerson.value.trim().isEmpty ||
        controller.email.value.trim().isEmpty ||
        controller.phone.value.trim().isEmpty ||
        controller.password.value.isEmpty ||
        controller.address.value.trim().isEmpty) {
      _showErrorDialog(context, context.l10n.text('registration_error_fields'));
      return;
    }

    if (!controller.acceptedTerms.value) {
      _showErrorDialog(context, context.l10n.text('registration_error_terms'));
      return;
    }

    await controller.register(
      onError: (errorMsg) {
        _showErrorDialog(context, errorMsg);
      },
      onSuccess: () {
        // Direct route to Employer Dashboard upon successful signup
        Get.off(
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
              Get.off(
                () => const EmployerLoginScreen(),
                binding: EmployerAuthBinding(),
              );
            },
          ),
        ),
        centerTitle: true,
        title: Text(
          l10n.text('employer_register_title'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.03),
                
                Center(
                  child: Text(
                    l10n.text('employer_register_subtitle'),
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: size.height * 0.03),

                // Form Fields
                _buildFieldLabel('${l10n.text('registration_personal_info')} - Company Name'),
                const SizedBox(height: 6),
                _buildInputField(
                  hintText: 'Enter company name',
                  controller: controller.companyNameController,
                  prefixIcon: Icons.apartment_rounded,
                ),

                const SizedBox(height: 16),

                _buildFieldLabel('Contact Person'),
                const SizedBox(height: 6),
                _buildInputField(
                  hintText: 'Enter contact person name',
                  controller: controller.contactPersonController,
                  prefixIcon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 16),

                _buildFieldLabel(l10n.text('registration_email')),
                const SizedBox(height: 6),
                _buildInputField(
                  hintText: l10n.text('registration_email_hint'),
                  controller: controller.emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                _buildFieldLabel(l10n.text('registration_phone_number')),
                const SizedBox(height: 6),
                _buildInputField(
                  hintText: '10-digit mobile number',
                  controller: controller.phoneController,
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                _buildFieldLabel('Office Address'),
                const SizedBox(height: 6),
                _buildInputField(
                  hintText: 'Enter complete office address',
                  controller: controller.addressController,
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                _buildFieldLabel(l10n.text('registration_password')),
                const SizedBox(height: 6),
                Obx(
                  () => _buildInputField(
                    hintText: l10n.text('registration_password_hint'),
                    controller: controller.passwordController,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: controller.isPasswordObscured.value,
                    showSuffix: true,
                    onSuffixTap: controller.togglePasswordObscurity,
                  ),
                ),

                const SizedBox(height: 20),

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

                const SizedBox(height: 24),

                // Register Button
                Obx(
                  () => _registerBtn(
                    onTap: controller.isRegisterEnabled
                        ? () => _register(context)
                        : null,
                    isEnabled: controller.isRegisterEnabled,
                    isLoading: controller.isLoading.value,
                    label: l10n.text('registration_create_account'),
                  ),
                ),

                const SizedBox(height: 24),

                // Already have account Switch
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.off(
                        () => const EmployerLoginScreen(),
                        binding: EmployerAuthBinding(),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: l10n.text('registration_already_account'),
                            style: const TextStyle(
                              color: greyText,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: l10n.text('registration_login'),
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
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData prefixIcon,
    TextEditingController? controller,
    bool obscureText = false,
    bool showSuffix = false,
    VoidCallback? onSuffixTap,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
        keyboardType: keyboardType,
        maxLines: maxLines,
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

  Widget _registerBtn({
    required VoidCallback? onTap,
    required bool isEnabled,
    required String label,
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
                    label,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../../../employer_dashboard/presentation/bindings/employer_dashboard_binding.dart';
import '../../../employer_dashboard/presentation/screens/employer_dashboard_screen.dart';
import '../controllers/employer_register_controller.dart';
import '../bindings/employer_auth_binding.dart';
import 'employer_login_screen.dart';

class EmployerRegistrationScreen extends GetView<EmployerRegisterController> {
  const EmployerRegistrationScreen({super.key});

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
            message.isNotEmpty ? message : 'Registration error. Please check your inputs.',
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

  Future<void> _register(BuildContext context) async {
    if (controller.companyName.value.trim().isEmpty ||
        controller.contactPerson.value.trim().isEmpty ||
        controller.email.value.trim().isEmpty ||
        controller.phone.value.trim().isEmpty ||
        controller.password.value.isEmpty ||
        controller.address.value.trim().isEmpty ||
        controller.identityProofPath.value == null) {
      _showErrorDialog(context, 'Please upload identity proof and complete all required fields.');
      return;
    }

    if (!controller.acceptedTerms.value) {
      _showErrorDialog(context, context.l10n.text('registration_error_terms'));
      return;
    }

    try {
      await controller.register(
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
      _showErrorDialog(context, 'Registration failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double hPad = size.width * 0.06;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Get.off(
                  () => const EmployerLoginScreen(),
                  binding: EmployerAuthBinding(),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          l10n.text('employer_register_title'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),

                Center(
                  child: Text(
                    l10n.text('employer_register_subtitle'),
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // Form Fields Container Card
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
                        prefixIcon: Icons.alternate_email_rounded,
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

                      const SizedBox(height: 18),

                      _buildFieldLabel('Identity Proof (ID Proof)'),
                      const SizedBox(height: 6),
                      _buildUploadBox(context),

                      const SizedBox(height: 20),

                      // Terms Acceptance Checkbox
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
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Already have account Switch Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.off(
                        () => const EmployerLoginScreen(),
                        binding: EmployerAuthBinding(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${l10n.text('registration_already_account')} ',
                              style: const TextStyle(
                                color: greyText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: l10n.text('registration_login'),
                              style: const TextStyle(
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
                ),

                const SizedBox(height: 32),
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
        fontSize: 13,
        fontWeight: FontWeight.w700,
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
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

  Widget _registerBtn({
    required VoidCallback? onTap,
    required bool isEnabled,
    required String label,
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
                        label,
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

  Widget _buildUploadBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryPurple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: primaryPurple,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload ID Proof',
            style: TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Select JPG, PNG, or PDF file',
            style: TextStyle(color: greyText, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Obx(() {
            final path = controller.identityProofPath.value;
            if (path != null) {
              final fileName = path.split('/').last.split('\\').last;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: controller.pickIdentityProof,
                    child: const Text(
                      'Choose Another File',
                      style: TextStyle(
                        color: primaryPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            }

            return OutlinedButton(
              onPressed: controller.pickIdentityProof,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryPurple, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Choose File',
                style: TextStyle(
                  color: primaryPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

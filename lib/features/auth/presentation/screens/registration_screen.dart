import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/theme/theme.extension.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/features/auth/presentation/controller/register_controller.dart';
import 'package:rojgar/dashboard_screen.dart';

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class RegistrationFormScreen extends GetView<RegisterController> {
  const RegistrationFormScreen({super.key});

  Future<void> _submitRegistration(BuildContext context) async {
    final l10n = context.l10n;
    final fullName = controller.fullName.value.trim();
    final phone = controller.phone.value.trim();
    final email = controller.email.value.trim();
    final username = controller.username.value.trim();
    final password = controller.password.value;
    final locality = controller.locality.value.trim();
    final pincode = controller.pincode.value.trim();
    final address = controller.address.value.trim();
    final otp = controller.otpValue.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        locality.isEmpty ||
        pincode.isEmpty ||
        address.isEmpty ||
        otp.isEmpty) {
      _showMessage(context, l10n.text('registration_error_fields'));
      return;
    }

    if (!controller.isPhoneVerified.value) {
      _showMessage(context, l10n.text('registration_error_phone_verify'));
      return;
    }

    if (controller.selectedStateId.value == null) {
      _showMessage(context, l10n.text('registration_error_state'));
      return;
    }

    if (controller.selectedDistrictId.value == null) {
      _showMessage(context, l10n.text('registration_error_district'));
      return;
    }
    if (!controller.acceptedTerms.value) {
      _showMessage(context, l10n.text('registration_error_terms'));
      return;
    }

    try {
      await controller.register();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen(successMessage: email)),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      final errorMessage = e is Failure
          ? e.message
          : 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage);
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.05;

    return Scaffold(
      backgroundColor: colors.background,
      // ── AppBar ──────────────────────────────
      appBar: AppBar(
        backgroundColor: colors.brandColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.text('app_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            Text(
              l10n.text('registration_join_tagline'),
              style: const TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Progress bar row ───────────────
            Container(
              color: colors.surface,
              padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.text('registration_progress'),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        child: Text(
                          l10n.text('registration_step'),
                          style: TextStyle(
                            color: colors.brandColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: colors.divider,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.33,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ════════════════════════════
                  // PERSONAL INFO
                  // ════════════════════════════
                  _sectionHeader(
                    context,
                    Icons.person_outline,
                    l10n.text('registration_personal_info'),
                  ),
                  const SizedBox(height: 14),

                  // Full Name
                  _fieldLabel(context, l10n.text('registration_full_name')),
                  const SizedBox(height: 6),
                  _inputField(
                    context,
                    hint: l10n.text('registration_full_name_hint'),
                    controller: controller.fullNameController,
                  ),

                  const SizedBox(height: 14),

                  // Phone Number
                  _fieldLabel(context, l10n.text('registration_phone_number')),
                  const SizedBox(height: 6),
                  _phoneField(context),

                  const SizedBox(height: 10),

                  // OTP Box
                  _otpSection(context, size),

                  const SizedBox(height: 14),

                  // Email
                  _fieldLabel(context, l10n.text('registration_email')),
                  const SizedBox(height: 6),
                  _inputField(
                    context,
                    hint: l10n.text('registration_email_hint'),
                    keyboard: TextInputType.emailAddress,
                    controller: controller.emailController,
                  ),

                  const SizedBox(height: 22),

                  // ════════════════════════════
                  // ADDRESS DETAILS
                  // ════════════════════════════
                  _sectionHeader(
                    context,
                    Icons.location_on_outlined,
                    l10n.text('registration_address_details'),
                  ),
                  const SizedBox(height: 14),

                  // State + District
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(
                              context,
                              l10n.text('registration_state'),
                            ),
                            const SizedBox(height: 6),
                            _stateField(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(
                              context,
                              l10n.text('registration_district'),
                            ),
                            const SizedBox(height: 6),
                            _districtField(context),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Area + Pincode
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(
                              context,
                              l10n.text('registration_area'),
                            ),
                            const SizedBox(height: 6),
                            _localityField(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(
                              context,
                              l10n.text('registration_pincode'),
                            ),
                            const SizedBox(height: 6),
                            _inputField(
                              context,
                              hint: l10n.text('registration_pincode_hint'),
                              keyboard: TextInputType.number,
                              controller: controller.pincodeController,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Full Address
                  _fieldLabel(context, l10n.text('registration_full_address')),
                  const SizedBox(height: 6),
                  _multilineField(
                    context,
                    l10n.text('registration_full_address_hint'),
                    controller: controller.addressController,
                  ),

                  const SizedBox(height: 22),

                  // ════════════════════════════
                  // IDENTITY VERIFICATION
                  // ════════════════════════════
                  _sectionHeader(
                    context,
                    Icons.badge_outlined,
                    l10n.text('registration_identity_verification'),
                  ),
                  const SizedBox(height: 14),

                  _uploadBox(context),

                  const SizedBox(height: 22),

                  // ════════════════════════════
                  // ACCOUNT CREDENTIALS
                  // ════════════════════════════
                  _sectionHeader(
                    context,
                    Icons.lock_outline_rounded,
                    l10n.text('registration_account_credentials'),
                  ),
                  const SizedBox(height: 14),

                  _fieldLabel(context, l10n.text('registration_username')),
                  const SizedBox(height: 6),
                  _inputField(
                    context,
                    hint: l10n.text('registration_username_hint'),
                    controller: controller.usernameController,
                  ),

                  const SizedBox(height: 14),

                  _fieldLabel(context, l10n.text('registration_password')),
                  const SizedBox(height: 6),
                  _passwordField(context),

                  const SizedBox(height: 16),

                  // Terms checkbox
                  _termsRow(context),

                  const SizedBox(height: 20),

                  // Create Account button
                  _createAccountBtn(context),

                  const SizedBox(height: 14),

                  // Bottom login text
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: l10n.text('registration_already_account'),
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: l10n.text('registration_login'),
                            style: TextStyle(
                              color: colors.brandColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, color: colors.brandColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: colors.brandColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    final colors = context.colors;
    return Text(
      label,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _inputField(
    BuildContext context, {
    required String hint,
    TextInputType keyboard = TextInputType.text,
    Widget? suffix,
    Widget? prefix,
    TextEditingController? controller,
  }) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(color: colors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _phoneField(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: colors.border, width: 1.2),
              ),
            ),
            child: Text(
              '+91',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final isVerified = controller.isPhoneVerified.value;
              return TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                enabled: !isVerified,
                style: TextStyle(
                  color: isVerified ? colors.textSecondary : colors.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: '00000 00000',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              );
            }),
          ),
          // ── Send OTP button inside the phone row ──────────────────────────
          Obx(() {
            final isVerified = controller.isPhoneVerified.value;
            final isSending = controller.isSendingOtp.value;
            if (isVerified) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      context.l10n.text('registration_phone_verified'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => controller.resetPhoneVerification(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: colors.brandColor,
                    ),
                    child: Text(
                      context.l10n.text('sell_change'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            }
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final err = await controller.sendOtp();
                        if (!context.mounted) return;
                        if (err != null) {
                          _showMessage(context, err);
                        } else {
                          _showMessage(
                            context,
                            context.l10n.text('registration_otp_sent_success'),
                            isSuccess: true,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.warning,
                  foregroundColor: colors.textPrimary,
                  disabledBackgroundColor: colors.warning.withValues(
                    alpha: 0.5,
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: isSending
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        context.l10n.text('registration_send_otp'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── OTP section (6-digit, auto-advance, reactive) ──────────────────────────
  Widget _otpSection(BuildContext context, Size size) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Obx(() {
      if (!controller.isOtpSent.value) return const SizedBox.shrink();
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: controller.isPhoneVerified.value
                  ? Colors.green
                  : colors.border,
              width: 1.4,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.text('registration_otp_hint'),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),

              // ── 6 OTP digit boxes ─────────────────────────────────────
              Row(
                children: List.generate(6, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border, width: 1.2),
                      ),
                      child: TextField(
                        controller: controller.otpControllers[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        enabled: !controller.isPhoneVerified.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && i < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (val.isEmpty && i > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 14),

              // ── Verify button + resend row ────────────────────────────
              if (!controller.isPhoneVerified.value)
                Row(
                  children: [
                    // Verify OTP button
                    Expanded(
                      child: Obx(
                        () => InkWell(
                          onTap: controller.isVerifyingOtp.value
                              ? null
                              : () async {
                                  final err = await controller.verifyOtp();
                                  if (!context.mounted) return;
                                  if (err != null) {
                                    _showMessage(context, err);
                                  } else {
                                    _showMessage(
                                      context,
                                      l10n.text(
                                        'registration_otp_verify_success',
                                      ),
                                      isSuccess: true,
                                    );
                                  }
                                },
                          // style: ElevatedButton.styleFrom(
                          //   backgroundColor: colors.brandColor,
                          //   foregroundColor: Colors.white,
                          //   elevation: 0,
                          //   padding: EdgeInsets.symmetric(vertical: 0),
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(10.r),
                          //   ),
                          // ),
                          child: controller.isVerifyingOtp.value
                              ? SizedBox(
                                  width: 16.sp,
                                  height: 16.sp,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.r),

                                  decoration: BoxDecoration(
                                    color: colors.brandColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l10n.text('registration_verify_otp'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.background,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Resend countdown
                    Obx(() {
                      final seconds = controller.resendCountdown.value;
                      if (seconds > 0) {
                        return Text(
                          '${context.l10n.text('registration_otp_resend_in')} $seconds${context.l10n.text('registration_otp_resend_sec')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () async {
                          final err = await controller.sendOtp();
                          if (!context.mounted) return;
                          if (err != null) {
                            _showMessage(context, err);
                          } else {
                            _showMessage(
                              context,
                              l10n.text('registration_otp_sent_success'),
                              isSuccess: true,
                            );
                          }
                        },
                        child: Text(
                          l10n.text('registration_otp_resend'),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.brandColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      );
                    }),
                  ],
                )
              else
                // Verified badge
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.text('registration_otp_verify_success'),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _selectorField(
    BuildContext context, {
    required String hint,
    required String value,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isNotEmpty ? value : hint,
                style: TextStyle(
                  color: value.isNotEmpty
                      ? colors.textPrimary
                      : colors.textSecondary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _stateField(BuildContext context) {
    return Obx(() {
      final selectedStateName =
          controller.states
              .firstWhereOrNull((s) => s.id == controller.selectedStateId.value)
              ?.name ??
          '';
      return _selectorField(
        context,
        hint: context.l10n.text('registration_select_state'),
        value: selectedStateName,
        onTap: () {
          _showSearchableBottomSheet(
            context: context,
            title: context.l10n.text('registration_select_state'),
            searchHint: 'Search state...',
            items: controller.states,
            isLoading: controller.isStatesLoading,
            onSelected: (state) => controller.selectState(state.id),
          );
        },
      );
    });
  }

  Widget _districtField(BuildContext context) {
    return Obx(() {
      final selectedDistrictName =
          controller.districts
              .firstWhereOrNull(
                (d) => d.id == controller.selectedDistrictId.value,
              )
              ?.name ??
          '';
      return _selectorField(
        context,
        hint: 'Select District',
        value: selectedDistrictName,
        onTap: () {
          if (controller.selectedStateId.value == null) {
            _showMessage(context, 'Please select a state first');
            return;
          }
          _showSearchableBottomSheet(
            context: context,
            title: 'Select District',
            searchHint: 'Search district...',
            items: controller.districts,
            isLoading: controller.isDistrictsLoading,
            onSelected: (district) => controller.selectDistrict(district.id),
          );
        },
      );
    });
  }

  Widget _localityField(BuildContext context) {
    return Obx(() {
      return _selectorField(
        context,
        hint: context.l10n.text('registration_area_hint'),
        value: controller.selectedLocalityName.value ?? '',
        onTap: () {
          if (controller.selectedDistrictId.value == null) {
            _showMessage(context, 'Please select a district first');
            return;
          }
          _showSearchableBottomSheet(
            context: context,
            title: context.l10n.text('registration_area'),
            searchHint: 'Search locality...',
            items: controller.localities,
            isLoading: controller.isLocalitiesLoading,
            onSelected: (loc) => controller.selectLocality(loc),
            emptyMessage: 'No localities found',
          );
        },
      );
    });
  }

  void _showSearchableBottomSheet({
    required BuildContext context,
    required String title,
    required String searchHint,
    required RxList<DropdownItem> items,
    required RxBool isLoading,
    required Function(DropdownItem) onSelected,
    String? emptyMessage,
  }) {
    final size = MediaQuery.of(context).size;
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ct) {
        final searchRx = ''.obs;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ct).viewInsets.bottom),
          child: Container(
            height: size.height * 0.7,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colors.fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border, width: 1.2),
                  ),
                  child: TextField(
                    onChanged: (val) => searchRx.value = val,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: searchHint,
                      hintStyle: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: colors.brandColor,
                        ),
                      );
                    }
                    final filtered = items
                        .where(
                          (item) => item.name.toLowerCase().contains(
                            searchRx.value.toLowerCase().trim(),
                          ),
                        )
                        .toList();
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          emptyMessage ?? 'No items found',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: colors.divider),
                      itemBuilder: (context, idx) {
                        final item = filtered[idx];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          onTap: () {
                            onSelected(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _multilineField(
    BuildContext context,
    String hint, {
    TextEditingController? controller,
  }) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: TextStyle(color: colors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _uploadBox(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.brandColor, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.brandColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              color: colors.brandColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.text('registration_upload_title'),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.text('registration_upload_hint'),
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          fileName,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: controller.pickIdentityProof,
                    child: Text(
                      l10n.text('registration_choose_file'),
                      style: TextStyle(
                        color: colors.brandColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }

            return OutlinedButton(
              onPressed: controller.pickIdentityProof,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.brandColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 10,
                ),
              ),
              child: Text(
                l10n.text('registration_choose_file'),
                style: TextStyle(
                  color: colors.brandColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: colors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 1.2),
        ),
        child: TextField(
          controller: controller.passwordController,
          obscureText: controller.isPasswordObscured.value,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.text('registration_password_hint'),
            hintStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordObscured.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colors.textSecondary,
                size: 20,
              ),
              onPressed: controller.togglePasswordObscurity,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _termsRow(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: controller.toggleTermsAcceptance,
          child: Obx(
            () => Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.acceptedTerms.value
                    ? colors.brandColor
                    : Colors.transparent,
                border: Border.all(
                  color: controller.acceptedTerms.value
                      ? colors.brandColor
                      : colors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: controller.acceptedTerms.value
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
              children: [
                TextSpan(text: l10n.text('registration_terms_prefix')),
                TextSpan(
                  text: l10n.text('registration_terms_link'),
                  style: TextStyle(
                    color: colors.brandColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: l10n.text('registration_terms_and')),
                TextSpan(
                  text: l10n.text('registration_terms_privacy'),
                  style: TextStyle(
                    color: colors.brandColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: l10n.text('registration_terms_suffix')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _createAccountBtn(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Obx(
      () => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: controller.isRegistrationEnabled
                ? [colors.brandColor, const Color(0xFF6644FF), colors.warning]
                : const [Color(0xFFB8BCCD), Color(0xFFB8BCCD)],
            stops: controller.isRegistrationEnabled
                ? const [0.0, 0.6, 1.0]
                : const [0.0, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (controller.isRegistrationEnabled
                          ? colors.brandColor
                          : const Color(0xFFB8BCCD))
                      .withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: controller.isRegistrationEnabled
                ? () => _submitRegistration(context)
                : null,
            child: Center(
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.text('registration_create_account'),
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
      ),
    );
  }
}

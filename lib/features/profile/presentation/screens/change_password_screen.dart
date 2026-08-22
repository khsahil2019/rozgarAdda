import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import '../controller/profile_controller.dart';

// Unified Rozgar Brand Color Tokens
class _CC {
  static const Color primary = Color(0xFF1400FF);
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightGreyText = Color(0xFF94A3B8);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  late final ProfileController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 6) strength += 0.35;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) {
      strength += 0.2;
    }
    if (RegExp(r'[0-9]').hasMatch(password) || RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.2;
    }
    return strength.clamp(0.0, 1.0);
  }

  String _getStrengthLabel(double strength) {
    if (strength <= 0) return '';
    if (strength < 0.4) return 'Weak password';
    if (strength < 0.75) return 'Medium strength';
    return 'Strong password';
  }

  Color _getStrengthColor(double strength) {
    if (strength < 0.4) return _CC.dangerRed;
    if (strength < 0.75) return _CC.warningOrange;
    return _CC.successGreen;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final msg = await _ctrl.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
      newPasswordConfirmation: _confirmCtrl.text,
    );
    if (msg != null && mounted) {
      Get.snackbar(
        'Success',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _CC.successGreen.withValues(alpha: 0.95),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _CC.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Password',
                style: TextStyle(
                  color: _CC.darkText,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Update your account login security',
                style: TextStyle(
                  color: _CC.greyText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _CC.borderGrey),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Security Hero Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_CC.primary, _CC.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _CC.primary.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure Your Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Ensure your new password contains at least 6 characters with a mix of letters and numbers.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Container Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _CC.borderGrey),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordField(
                        ctrl: _currentCtrl,
                        label: 'Current Password',
                        hint: 'Enter your existing password',
                        show: _showCurrent,
                        onToggle: () => setState(() => _showCurrent = !_showCurrent),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Please enter your current password' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        ctrl: _newCtrl,
                        label: 'New Password',
                        hint: 'Enter your new strong password',
                        show: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        onChanged: (v) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter a new password';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      if (_newCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildStrengthIndicator(_newCtrl.text),
                      ],
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        ctrl: _confirmCtrl,
                        label: 'Confirm New Password',
                        hint: 'Re-enter your new password',
                        show: _showConfirm,
                        onToggle: () => setState(() => _showConfirm = !_showConfirm),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your new password';
                          if (v != _newCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                Obx(() {
                  final isSubmitting = _ctrl.isChangingPassword.value;
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _CC.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.lock_reset_rounded, size: 20, color: Colors.white),
                      label: Text(
                        isSubmitting ? 'Updating Password...' : 'Update Password',
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthIndicator(String password) {
    final strength = _calculatePasswordStrength(password);
    final color = _getStrengthColor(strength);
    final label = _getStrengthLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              '${(strength * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 4,
            backgroundColor: _CC.borderGrey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
    required FormFieldValidator<String> validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _CC.darkText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: !show,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14.5,
            color: _CC.darkText,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _CC.lightGreyText, fontSize: 13),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: _CC.primary,
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: _CC.greyText,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: _CC.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _CC.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _CC.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _CC.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _CC.dangerRed),
            ),
          ),
        ),
      ],
    );
  }
}

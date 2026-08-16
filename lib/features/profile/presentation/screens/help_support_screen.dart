import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import '../controller/profile_controller.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileController _ctrl;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _emailCtrl;
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();
    final user = AppController.to.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _mobileCtrl = TextEditingController(text: user?.phone ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final msg = await _ctrl.submitInquiry(
      name: _nameCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
    );
    if (msg != null && mounted) {
      Get.snackbar(
        'Inquiry Sent!',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_rounded,
            color: Colors.white, size: 24),
      );
      _subjectCtrl.clear();
      _messageCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF17181C), size: 20),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF17181C),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.sp),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Banner ────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(18.sp),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1400FF), Color(0xFF4433FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.support_agent_rounded,
                          color: Colors.white, size: 30),
                    ),
                    SizedBox(height: 12.sp),
                    const Text(
                      'We\'re Here to Help',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    Text(
                      'Fill in the form below and our team\nwill get back to you shortly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.sp),

              // ── Fields ────────────────────────────────────────────
              _buildField(_nameCtrl, 'Your Name', Icons.person_outline_rounded,
                  required: true),
              _buildField(_mobileCtrl, 'Mobile Number', Icons.phone_outlined,
                  keyboard: TextInputType.phone, required: true),
              _buildField(_emailCtrl, 'Email Address', Icons.email_outlined,
                  keyboard: TextInputType.emailAddress, required: true),
              _buildField(_subjectCtrl, 'Subject', Icons.subject_rounded,
                  required: true),

              // Message
              Padding(
                padding: EdgeInsets.only(bottom: 14.sp),
                child: TextFormField(
                  controller: _messageCtrl,
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Message is required'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: const Icon(Icons.message_outlined,
                          color: Color(0xFF8A8FA3), size: 20),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: const TextStyle(color: Color(0xFF8A8FA3)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF1400FF), width: 1.5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.sp, vertical: 14.sp),
                  ),
                ),
              ),
              SizedBox(height: 8.sp),

              // ── Submit ────────────────────────────────────────────
              Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      _ctrl.isSubmittingInquiry.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1400FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _ctrl.isSubmittingInquiry.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    _ctrl.isSubmittingInquiry.value
                        ? 'Sending...'
                        : 'Send Inquiry',
                    style: TextStyle(
                        fontSize: 15.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(height: 24.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool required = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.sp),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF8A8FA3), size: 20),
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Color(0xFF8A8FA3)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1400FF), width: 1.5),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
        ),
      ),
    );
  }
}

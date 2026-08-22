import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/profile_controller.dart';

class _C {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color fieldBg = Color(0xFFF8FAFC);
  static const Color successGreen = Color(0xFF10B981);
}

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

  final List<String> _topics = [
    'Job Application',
    'KYC Verification',
    'Sell Product',
    'Account & Login',
    'Other Issue',
  ];

  int? _selectedTopicIndex;

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

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'Action Not Supported',
        'Unable to open $urlString',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
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
        'Inquiry Sent Successfully',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.successGreen,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
      );
      _subjectCtrl.clear();
      _messageCtrl.clear();
      setState(() => _selectedTopicIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _C.scaffoldBg,
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
          title: Text(
            l10n.text('profile_help_support'),
            style: const TextStyle(
              color: _C.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _C.borderGrey),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero Support Card ────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_C.primary, Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _C.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'How can we help you?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Our support team typically responds within 24 business hours.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Quick Contact Action Tiles ───────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildContactTile(
                        icon: Icons.phone_in_talk_rounded,
                        title: 'Call Support',
                        subtitle: 'Mon - Sat (9AM - 6PM)',
                        color: const Color(0xFF10B981),
                        onTap: () => _launchUrl('tel:+918000000000'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildContactTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email Us',
                        subtitle: 'support@rozgar.com',
                        color: _C.primary,
                        onTap: () => _launchUrl('mailto:support@rozgar.com?subject=Support%20Inquiry'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Main Inquiry Form Card ───────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _C.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _C.borderGrey),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1400FF).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.send_rounded, color: _C.primary, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Send us an Inquiry',
                            style: TextStyle(
                              color: _C.darkText,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Topic Chips
                      const Text(
                        'Select Topic',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _C.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_topics.length, (i) {
                          final isSelected = _selectedTopicIndex == i;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedTopicIndex = null;
                                  _subjectCtrl.clear();
                                } else {
                                  _selectedTopicIndex = i;
                                  _subjectCtrl.text = _topics[i];
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _C.primary
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? _C.primary : _C.borderGrey,
                                ),
                              ),
                              child: Text(
                                _topics[i],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _C.mediumText,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),

                      _FieldLabel('Your Name *'),
                      _buildField(
                        _nameCtrl,
                        'Enter your full name',
                        Icons.person_outline_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Mobile Number *'),
                                _buildField(
                                  _mobileCtrl,
                                  '10-digit number',
                                  Icons.phone_iphone_rounded,
                                  keyboard: TextInputType.phone,
                                  required: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Email Address *'),
                                _buildField(
                                  _emailCtrl,
                                  'name@email.com',
                                  Icons.mail_outline_rounded,
                                  keyboard: TextInputType.emailAddress,
                                  required: true,
                                  isEmail: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _FieldLabel('Subject *'),
                      _buildField(
                        _subjectCtrl,
                        'Brief summary of your query',
                        Icons.topic_outlined,
                        required: true,
                      ),
                      const SizedBox(height: 12),

                      _FieldLabel('Detailed Message *'),
                      TextFormField(
                        controller: _messageCtrl,
                        maxLines: 4,
                        style: const TextStyle(
                          color: _C.darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please provide detailed message'
                            : null,
                        decoration: InputDecoration(
                          hintText: 'Describe your issue or query in detail...',
                          hintStyle: const TextStyle(
                            color: _C.greyText,
                            fontSize: 13.5,
                            fontWeight: FontWeight.normal,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 50),
                            child: Icon(Icons.notes_rounded, color: _C.greyText, size: 18),
                          ),
                          filled: true,
                          fillColor: _C.fieldBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _C.borderGrey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _C.borderGrey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _C.primary, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── FAQ Accordion Section ────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _C.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _C.borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.help_outline_rounded, color: _C.primary, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Frequently Asked Questions',
                            style: TextStyle(
                              color: _C.darkText,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFaqTile(
                        question: 'How do I apply for jobs on Rozgar?',
                        answer:
                            'Browse available jobs, select a job posting that fits your skills, and click the "Apply Now" button to submit your application and resume.',
                      ),
                      const Divider(height: 1, color: _C.borderGrey),
                      _buildFaqTile(
                        question: 'How long does KYC verification take?',
                        answer:
                            'KYC documents are reviewed within 24 to 48 business hours. You can view your real-time status in the KYC section.',
                      ),
                      const Divider(height: 1, color: _C.borderGrey),
                      _buildFaqTile(
                        question: 'How do I track my submitted inquiries?',
                        answer:
                            'Our support team will reply directly to your registered email address and phone number.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomSheet: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 14,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: _C.borderGrey, width: 1),
            ),
          ),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _ctrl.isSubmittingInquiry.value ? null : _submit,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _ctrl.isSubmittingInquiry.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'SUBMIT INQUIRY',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.borderGrey),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: _C.darkText,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: _C.greyText,
                fontSize: 11.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          question,
          style: const TextStyle(
            color: _C.darkText,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconColor: _C.primary,
        collapsedIconColor: _C.greyText,
        children: [
          Text(
            answer,
            style: const TextStyle(
              color: _C.greyText,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool required = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(
        color: _C.darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) {
          return 'This field is required';
        }
        if (isEmail && v != null && v.trim().isNotEmpty) {
          final emailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
          if (!emailValid) return 'Enter a valid email';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _C.greyText,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, color: _C.greyText, size: 18),
        filled: true,
        fillColor: _C.fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.borderGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _C.darkText,
        ),
      ),
    );
  }
}

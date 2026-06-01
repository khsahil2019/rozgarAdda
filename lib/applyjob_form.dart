import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/storage_service.dart';

const String _applyJobEndpoint = 'https://rozgaradda.com/api/apply-job';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color white = Colors.white;
  static const Color background = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF1A1AE6);
  static const Color darkBlue = Color(0xFF1010CC);
  static const Color stepLabel = Color(0xFF2222DD);
  static const Color darkText = Color(0xFF111122);
  static const Color greyText = Color(0xFF888899);
  static const Color inputBorder = Color(0xFFDDDDE8);
  static const Color inputBg = Color(0xFFFAFAFC);
  static const Color inputHint = Color(0xFFBBBBCC);
  static const Color progressBg = Color(0xFFEEEEF5);
  static const Color progressFill = Color(0xFF2222DD);
  static const Color sectionIcon = Color(0xFF2222DD);
  static const Color uploadBorder = Color(0xFF9999DD);
  static const Color uploadBg = Color(0xFFF8F8FE);
  static const Color uploadIconBg = Color(0xFFDDDDF8);
  static const Color checkBorder = Color(0xFFCCCCDD);
  static const Color linkBlue = Color(0xFF2222DD);
  static const Color footerText = Color(0xFFAAAAAB);
  static const Color agreeBg = Color(0xFFF4F4FA);
  static const Color cardShadow = Color(0x08000000);
}

void main() => runApp(const JobApplicationApp());

class JobApplicationApp extends StatelessWidget {
  const JobApplicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This secondary MaterialApp is mainly for preview; localization
    // from the root app will typically be used instead.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const JobApplicationScreen(),
    );
  }
}

class JobApplicationScreen extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobApplicationScreen({
    super.key,
    this.jobId = 1,
    this.jobTitle = 'Senior Product Designer',
  });

  @override
  State<JobApplicationScreen> createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _experienceYearsCtrl = TextEditingController();
  final _experienceMonthsCtrl = TextEditingController();
  final _expectedSalaryCtrl = TextEditingController();
  final _noticePeriodCtrl = TextEditingController();
  final _educationLevelCtrl = TextEditingController();
  final _educationDetailsCtrl = TextEditingController();
  final _keySkillsCtrl = TextEditingController();

  PlatformFile? _resumeFile;
  bool _agreed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _experienceYearsCtrl.dispose();
    _experienceMonthsCtrl.dispose();
    _expectedSalaryCtrl.dispose();
    _noticePeriodCtrl.dispose();
    _educationLevelCtrl.dispose();
    _educationDetailsCtrl.dispose();
    _keySkillsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null || file.path!.isEmpty) {
      _showSnackBar('Unable to read selected file.', isError: true);
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      _showSnackBar('Resume must be under 10MB.', isError: true);
      return;
    }
    setState(() => _resumeFile = file);
  }

  Future<void> _submitApplication() async {
    final _pref = await SharedPreferences.getInstance();
    if (!_formKey.currentState!.validate()) return;
    if (_resumeFile?.path == null) {
      _showSnackBar('Please upload your resume.', isError: true);
      return;
    }
    if (!_agreed) {
      _showSnackBar('Please accept terms to continue.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageService.keyAccessToken);

      if (token == null || token.isEmpty) {
        _showSnackBar(
          'Login token not found. Please login again.',
          isError: true,
        );
        return;
      }

      final fullName =
          '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();

      await ApiService.uploadFiles(
        method: 'POST',
        url: '$_applyJobEndpoint/${widget.jobId}',
        accessToken: token,
        fields: {
          'full_name': fullName,
          'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'experience_years': _experienceYearsCtrl.text.trim(),
          'experience_months': _experienceMonthsCtrl.text.trim(),
          'expected_salary': _expectedSalaryCtrl.text.trim(),
          'notice_period': _noticePeriodCtrl.text.trim().toString(),
          'education_level': _educationLevelCtrl.text.trim(),
          'education_details': _educationDetailsCtrl.text.trim(),
          'key_skills': _keySkillsCtrl.text.trim(),
        },
        files: {'resume': _resumeFile!.path!},
      );

      if (!mounted) return;
      _showSnackBar('Application submitted successfully.');
      Navigator.maybePop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(topPad),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildProgressSection(l10n),
                    const SizedBox(height: 32),
                    _buildSectionTitle(
                      Icons.person_outline_rounded,
                      l10n.text('apply_personal_info'),
                    ),
                    const SizedBox(height: 20),
                    _buildLabeledField(
                      l10n.text('apply_first_name'),
                      'John',
                      controller: _firstNameCtrl,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      l10n.text('apply_last_name'),
                      'Doe',
                      controller: _lastNameCtrl,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      l10n.text('apply_email'),
                      'john.doe@example.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      'Phone',
                      '9876543210',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle(
                      Icons.work_outline_rounded,
                      l10n.text('apply_professional_details'),
                    ),
                    const SizedBox(height: 20),
                    _buildLabeledField(
                      'Experience Years',
                      '2',
                      controller: _experienceYearsCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      'Experience Months',
                      '6',
                      controller: _experienceMonthsCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      'Expected Salary',
                      '35000',
                      controller: _expectedSalaryCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      'Notice Period',
                      '30days',
                      controller: _noticePeriodCtrl,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      'Education Level',
                      'B.Tech',
                      controller: _educationLevelCtrl,
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      label: 'Education Details',
                      hint:
                          'B.Tech in Computer Science from Rajasthan University',
                      controller: _educationDetailsCtrl,
                    ),
                    const SizedBox(height: 16),
                    _buildTextArea(
                      label: 'Key Skills',
                      hint: 'Laravel, PHP, MySQL, JavaScript, jQuery',
                      controller: _keySkillsCtrl,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle(
                      Icons.upload_file_outlined,
                      l10n.text('apply_resume_upload'),
                    ),
                    const SizedBox(height: 16),
                    _buildUploadBox(),
                    const SizedBox(height: 12),
                    _buildAgreementRow(l10n),
                    const SizedBox(height: 24),
                    _buildSubmitButton(l10n),
                    const SizedBox(height: 28),
                    _buildFooter(l10n),
                    SizedBox(height: bottomPad + 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 22,
              color: AppColors.darkText,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.jobTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const Icon(Icons.share_outlined, size: 22, color: AppColors.darkText),
        ],
      ),
    );
  }

  Widget _buildProgressSection(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.text('apply_step_label'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.stepLabel,
                letterSpacing: 0.4,
                height: 1.5,
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '50%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  l10n.text('apply_complete'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 7,
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppColors.progressBg,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.progressFill,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.sectionIcon, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryBlue,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField(
    String label,
    String hint, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorder, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Required';
              }
              if (keyboardType == TextInputType.emailAddress &&
                  !RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  ).hasMatch(value!.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox() {
    final fileName = _resumeFile?.name;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickResume,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.uploadBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _resumeFile == null
                  ? AppColors.uploadBorder
                  : AppColors.primaryBlue,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.uploadIconBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                fileName ?? 'Click to upload resume',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                fileName == null
                    ? 'PDF, DOC, DOCX up to 10MB'
                    : 'Tap to change file',
                style: const TextStyle(fontSize: 12, color: AppColors.greyText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorder, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Required' : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
                height: 1.5,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementRow(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.agreeBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _agreed ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _agreed
                      ? AppColors.primaryBlue
                      : AppColors.checkBorder,
                  width: 1.5,
                ),
              ),
              child: _agreed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.text('apply_agree'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkText,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1AE6), Color(0xFF3333FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _isSubmitting ? null : _submitApplication,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSubmitting)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              else ...[
                Text(
                  l10n.text('apply_submit'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFFFCC00),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.text('apply_footer'),
        style: const TextStyle(fontSize: 11, color: AppColors.footerText),
        textAlign: TextAlign.center,
      ),
    );
  }
}

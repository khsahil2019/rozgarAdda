import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rojgar/core/widgets/network_image_service.dart';
import 'package:rojgar/features/jobs/domain/entities/available_job_entity.dart';
import 'applyjob_form.dart';
import 'package:rojgar/features/jobs/presentation/controller/jobs_controller.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF8FAFC);
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightLabel = Color(0xFF94A3B8);
  static const Color highlightCardBg = Color(0xFFEEF2FF);
  static const Color tagBg = Color(0xFFF1F5F9);
  static const Color tagText = Color(0xFF4F46E5);
  static const Color yellow = Color(0xFFF59E0B);
  static const Color green = Color(0xFF10B981);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFF1F5F9);
}

class JobDetailScreen extends StatelessWidget {
  final AvailableJob job;
  final String? imageUrl;

  const JobDetailScreen({super.key, required this.job, this.imageUrl});

  // Legacy constructor for backwards compatibility
  static Widget placeholder({
    int jobId = 1,
    String jobTitle = 'Job Opportunity',
    String company = 'Company',
    String location = 'Location',
    String salary = 'Salary',
    String jobType = 'Full Time',
    String? contactPhone,
  }) {
    final dummy = AvailableJob(
      id: jobId,
      employerId: 0,
      categoryId: 0,
      roleId: 0,
      title: jobTitle,
      jobType: jobType,
      shifts: const [],
      workLocationType: '',
      stateName: '',
      addressLine1: location,
      addressLine2: '',
      pincode: '',
      payType: '',
      minSalary: null,
      maxSalary: null,
      perks: const [],
      educationLevel: '',
      englishLevel: '',
      experienceLevel: '',
      additionalRequirements: const {},
      skills: const [],
      languages: const [],
      vacancy: 1,
      isWalkin: false,
      contactPreference: '',
      contactPhone: contactPhone,
      viewsCount: 0,
      applicationsCount: 0,
      status: '',
      createdAt: DateTime.now(),
    );
    return JobDetailScreen(job: dummy);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────────
            _buildHeader(context),

            // ── Scrollable Content ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Top Hero Info Card
                    _buildHeroCard(context),

                    const SizedBox(height: 16),

                    // Salary Highlight Card
                    _buildSalaryCard(),

                    const SizedBox(height: 16),

                    // Job Requirements & Highlights
                    _buildHighlightsCard(),

                    const SizedBox(height: 16),

                    // Job Description / Additional Details
                    _buildJobDescription(),

                    const SizedBox(height: 16),

                    // Employer & Safety Advisory Disclaimer
                    _buildDisclaimerSection(context, l10n),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ── Bottom Action Bar ────────────────────────────────────────────────
            _buildBottomBar(context, bottomPad),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Squircle Back Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Job Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Share button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Share.share('https://rozgaradda.com/job-details/${job.id}');
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.share_rounded,
                      color: Color(0xFF4F46E5),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Job Info Card ──────────────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context) {
    final parts = <String>[];
    if (job.addressLine1.isNotEmpty) parts.add(job.addressLine1);
    if (job.addressLine2.isNotEmpty) parts.add(job.addressLine2);
    if (job.stateName.isNotEmpty) parts.add(job.stateName);
    final locationString = parts.join(', ');

    final companyName = job.addressLine1.isNotEmpty
        ? job.addressLine1
        : (job.stateName.isNotEmpty ? job.stateName : 'Verified Employer');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo Avatar Frame
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? NetworkImageService(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: _logoPlaceholder(),
                        )
                      : _logoPlaceholder(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF10B981),
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Location Row
          if (locationString.isNotEmpty)
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    locationString,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 14),

          // Tag Pills (Vacancy, Job Type, Walk-in)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTagPill(
                icon: Icons.people_outline_rounded,
                text: '${job.vacancy} ${job.vacancy == 1 ? "Vacancy" : "Vacancies"}',
                bgColor: const Color(0xFFF1F5F9),
                textColor: const Color(0xFF334155),
              ),
              _buildTagPill(
                icon: Icons.work_outline_rounded,
                text: job.jobType.isNotEmpty ? job.jobType : 'Full Time',
                bgColor: const Color(0xFFEEF2FF),
                textColor: const Color(0xFF4F46E5),
              ),
              if (job.isWalkin)
                _buildTagPill(
                  icon: Icons.directions_walk_rounded,
                  text: 'Walk-in Interview',
                  bgColor: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFFD97706),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagPill({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Salary Highlight Card ────────────────────────────────────────────────────
  Widget _buildSalaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTIMATED SALARY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job.salaryDisplay,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoPlaceholder() {
    return const Center(
      child: Icon(
        Icons.work_outline_rounded,
        color: Color(0xFF4F46E5),
        size: 26,
      ),
    );
  }

  // ── Job Highlights & Specifications Card ─────────────────────────────────────
  Widget _buildHighlightsCard() {
    final gender = (job.additionalRequirements['gender'] ?? '').toString();
    final genderLabel = gender.isNotEmpty ? _capitalizeFirst(gender) : 'Any Gender';

    final experienceLabel = job.experienceLevel.toLowerCase() == 'fresher'
        ? 'Fresher'
        : (job.experienceLevel.isNotEmpty ? job.experienceLevel : 'Any Experience');

    final shiftLabel = job.shifts.isNotEmpty
        ? job.shifts
            .map((s) => s.replaceAll('_', ' ').split(' ').map(_capitalizeFirst).join(' '))
            .join(', ')
        : 'Any Shift';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Specifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          _buildGridSpecRow(
            icon1: Icons.school_outlined,
            title1: 'Education',
            val1: job.educationLevel.isNotEmpty ? job.educationLevel : 'Any Degree',
            icon2: Icons.history_edu_outlined,
            title2: 'Experience',
            val2: experienceLabel,
          ),

          const SizedBox(height: 14),

          _buildGridSpecRow(
            icon1: Icons.translate_rounded,
            title1: 'English Level',
            val1: job.englishLevel.isNotEmpty ? job.englishLevel : 'Basic',
            icon2: Icons.schedule_outlined,
            title2: 'Shifts',
            val2: shiftLabel,
          ),

          if (job.skills.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 14),
            const Text(
              'Required Skills',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridSpecRow({
    required IconData icon1,
    required String title1,
    required String val1,
    required IconData icon2,
    required String title2,
    required String val2,
  }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon1, size: 18, color: const Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title1,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      val1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon2, size: 18, color: const Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title2,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      val2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Job Description Section ─────────────────────────────────────────────────
  Widget _buildJobDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Overview & Role Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We are hiring for the role of ${job.title}. Qualified candidates will work at our office / facility located at ${job.addressLine1.isNotEmpty ? job.addressLine1 : "assigned location"}. Applications will be reviewed promptly upon submission.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Safety Disclaimer Section ──────────────────────────────────────────────
  Widget _buildDisclaimerSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RozgarAdda Safety Assurance',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Never pay money or share OTPs for job placements. Authentic employers do not request candidate fees.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB45309),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Action Bar ───────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, double bottomPad) {
    final bool showCall = job.contactPhone != null && job.contactPhone!.isNotEmpty;
    final bool showWhatsApp = job.whatsappNumber != null && job.whatsappNumber!.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showCall)
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _makeCall(job.contactPhone, job.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: const Color(0xFF4F46E5),
                  ),
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text(
                    'Call HR',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),

          if (showCall) const SizedBox(width: 10),

          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobApplicationScreen(
                        jobId: job.id,
                        jobTitle: job.title,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Apply Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Future<void> _makeCall(String? phone, int jobId) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Contact phone number is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      if (Get.isRegistered<JobsController>()) {
        Get.find<JobsController>().logCallAndChatApply(
          jobId: jobId,
          type: 'call',
          phone: phone,
        );
      }
    } catch (e) {
      debugPrint('Error logging call application: $e');
    }
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not place a call to $phone',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

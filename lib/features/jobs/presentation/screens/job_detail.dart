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

                    // Walk-in Interview Banner (if walk-in)
                    if (job.isWalkin) ...[
                      _buildWalkinCard(),
                      const SizedBox(height: 16),
                    ],

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
    final companyName = job.addressLine1.isNotEmpty
        ? job.addressLine1
        : (job.stateName.isNotEmpty ? job.stateName : 'Verified Employer');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: const Color(0xFFF8FAFC),
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
          const SizedBox(width: 12),

          // Title & Subtitle Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF10B981),
                      size: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Bookmark Button
          const _BookmarkButton(),
          const SizedBox(width: 8),

          // Share button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Share.share('Check out this job opportunity: ${job.title} at $companyName\nhttps://rozgaradda.com/job-details/${job.id}');
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Color(0xFF4F46E5),
                  size: 18,
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

  // ── Walk-in Interview Card ──────────────────────────────────────────────────
  Widget _buildWalkinCard() {
    final dateStr = job.walkinDate ?? 'As scheduled';
    final timeStr = (job.walkinTime != null && job.walkinTime!.isNotEmpty)
        ? '${job.walkinTime}${job.walkinEndTime != null && job.walkinEndTime!.isNotEmpty ? " - ${job.walkinEndTime}" : ""}'
        : '10:00 AM - 5:00 PM';
    final venueStr = (job.walkinVenue != null && job.walkinVenue!.isNotEmpty)
        ? job.walkinVenue!
        : (job.addressLine1.isNotEmpty ? job.addressLine1 : 'Company Premises');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Walk-in Interview Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Direct entry for candidate interview',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFFDE68A), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 15, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        timeStr,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF78350F)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_city_rounded, size: 15, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  venueStr,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF78350F)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
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

          const SizedBox(height: 14),

          _buildGridSpecRow(
            icon1: Icons.person_outline_rounded,
            title1: 'Gender Required',
            val1: genderLabel,
            icon2: Icons.business_center_outlined,
            title2: 'Work Location',
            val2: job.workLocationLabel.isNotEmpty ? job.workLocationLabel : 'Office',
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

          if (job.perks.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 14),
            const Text(
              'Perks & Benefits',
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
              children: job.perks.map((perk) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                      Text(
                        perk,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
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
    final hasDesc = job.jobDescription != null && job.jobDescription!.trim().isNotEmpty;
    final descText = hasDesc
        ? job.jobDescription!.trim()
        : 'We are actively hiring for the position of ${job.title}. Selected candidates will be responsible for daily operational tasks and team coordination at our facility located at ${job.addressLine1.isNotEmpty ? job.addressLine1 : "the designated location"}. We encourage motivated candidates with suitable qualifications to apply.';

    final locationName = job.addressLine1.isNotEmpty
        ? job.addressLine1
        : (job.stateName.isNotEmpty ? job.stateName : 'Specified Location');

    final shiftText = job.shifts.isNotEmpty
        ? job.shifts.map((s) => s.replaceAll('_', ' ').split(' ').map(_capitalizeFirst).join(' ')).join(', ')
        : 'Standard Shift';

    final expText = job.experienceLevel.toLowerCase() == 'fresher'
        ? 'Fresher Candidates Welcome'
        : (job.experienceLevel.isNotEmpty ? job.experienceLevel : 'Not Specified');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          // Section Header with Icon Badge
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                ),
                child: const Icon(
                  Icons.assignment_ind_rounded,
                  color: Color(0xFF4F46E5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Overview & Role Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Key responsibilities & employment details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),

          // Overview Text Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            ),
            child: Text(
              descText,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Role Key Highlights Checklist Grid
          const Text(
            'Role Key Highlights',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          _buildOverviewBullet(
            icon: Icons.work_outline_rounded,
            iconColor: const Color(0xFF4F46E5),
            label: 'Designation',
            value: job.title,
          ),
          const SizedBox(height: 8),
          _buildOverviewBullet(
            icon: Icons.place_outlined,
            iconColor: const Color(0xFFEF4444),
            label: 'Work Location',
            value: '$locationName (${job.workLocationLabel})',
          ),
          const SizedBox(height: 8),
          _buildOverviewBullet(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF3B82F6),
            label: 'Shift Pattern',
            value: shiftText,
          ),
          const SizedBox(height: 8),
          _buildOverviewBullet(
            icon: Icons.school_outlined,
            iconColor: const Color(0xFF8B5CF6),
            label: 'Min Qualification',
            value: job.educationLevel.isNotEmpty ? job.educationLevel : 'Any Qualification',
          ),
          const SizedBox(height: 8),
          _buildOverviewBullet(
            icon: Icons.badge_outlined,
            iconColor: const Color(0xFFF59E0B),
            label: 'Experience Needed',
            value: expText,
          ),

          const SizedBox(height: 16),

          // Candidate Tip Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tip: Ensure your contact info and resume details are up-to-date before applying.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3730A3),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewBullet({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

  Widget _buildBottomBar(BuildContext context, double bottomPad) {
    final String? phone = (job.contactPhone != null && job.contactPhone!.trim().isNotEmpty)
        ? job.contactPhone!.trim()
        : null;
    final String? whatsapp = (job.whatsappNumber != null && job.whatsappNumber!.trim().isNotEmpty)
        ? job.whatsappNumber!.trim()
        : phone;

    final bool showCall = phone != null || job.enableCall;
    final bool showWhatsApp = whatsapp != null || job.enableChat;

    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, 14, bottomPad + 12),
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
          if (showCall) ...[
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _makeCall(phone ?? job.contactPhone, job.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text(
                    'Call HR',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          if (showWhatsApp) ...[
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _openWhatsApp(whatsapp ?? phone, job.title, job.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                    backgroundColor: const Color(0xFFF0FDF4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: const Color(0xFF166534),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 15, color: Color(0xFF25D366)),
                  label: const Text(
                    'WhatsApp',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF166534),
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          Expanded(
            flex: 4,
            child: SizedBox(
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
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
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Apply Now',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    softWrap: false,
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

  Future<void> _openWhatsApp(String? rawNumber, String title, int jobId) async {
    if (rawNumber == null || rawNumber.isEmpty) return;
    String cleanNumber = rawNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanNumber.startsWith('+')) {
      if (cleanNumber.length == 10) {
        cleanNumber = '+91$cleanNumber';
      } else if (!cleanNumber.startsWith('91') && cleanNumber.length == 12) {
        cleanNumber = '+$cleanNumber';
      }
    }
    try {
      if (Get.isRegistered<JobsController>()) {
        Get.find<JobsController>().logCallAndChatApply(
          jobId: jobId,
          type: 'chat',
          phone: cleanNumber,
        );
      }
    } catch (_) {}
    final message = Uri.encodeComponent('Hi, I am interested in your job posting: $title on RozgarAdda.');
    final Uri url = Uri.parse('https://wa.me/$cleanNumber?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open WhatsApp');
    }
  }
}

class _BookmarkButton extends StatefulWidget {
  const _BookmarkButton();

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _isSaved = !_isSaved);
          Get.snackbar(
            _isSaved ? 'Bookmark Saved' : 'Bookmark Removed',
            _isSaved ? 'Job saved to your bookmarks' : 'Job removed from your bookmarks',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isSaved ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isSaved ? const Color(0xFFFCD34D) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Icon(
            _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: _isSaved ? const Color(0xFFD97706) : const Color(0xFF64748B),
            size: 18,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rojgar/core/widgets/network_image_service.dart';
import 'package:rojgar/features/jobs/domain/entities/available_job_entity.dart';
import 'applyjob_form.dart';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color white = Colors.white;
  static const Color background = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF2222DD);
  static const Color titleDark = Color(0xFF17181C);
  static const Color darkText = Color(0xFF17181C);
  static const Color greyText = Color(0xFF72757F);
  static const Color lightLabel = Color(0xFF9999AA);
  static const Color highlightCardBg = Color(0xFFEFF4FF);
  static const Color tagBg = Color(0xFFF1F2F5);
  static const Color tagText = Color(0xFF3333CC);
  static const Color yellow = Color(0xFFFFC400);
  static const Color green = Color(0xFF25D366);
  static const Color borderLight = Color(0xFFEEEEF4);
  static const Color dividerColor = Color(0xFFE7E9EE);
}

class JobDetailScreen extends StatelessWidget {
  final AvailableJob job;
  final String? imageUrl;

  const JobDetailScreen({
    super.key,
    required this.job,
    this.imageUrl,
  });

  // Legacy constructor for backwards compatibility (e.g. careear_hub.dart)
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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────────
            _buildHeader(context),
            // ── Scrollable Content ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTopSection(),
                    const SizedBox(height: 20),
                    _buildHighlightsCard(),
                    const SizedBox(height: 24),
                    _buildJobDescription(),
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
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkText, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          // Center decorative line
          Expanded(
            child: Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF222299),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Share button
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              foregroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.share_outlined, size: 16),
            label: const Text(
              'Share',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.darkText, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ── Top Section (logo, title, salary, company, location, vacancy) ─────────
  Widget _buildTopSection() {
    // Build location string
    final parts = <String>[];
    if (job.addressLine1.isNotEmpty) parts.add(job.addressLine1);
    if (job.addressLine2.isNotEmpty) parts.add(job.addressLine2);
    if (job.stateName.isNotEmpty) parts.add(job.stateName);
    final locationString = parts.join(', ');

    // Build company name (use addressLine1 as company name if available, else stateName)
    final companyName = job.addressLine1.isNotEmpty
        ? job.addressLine1
        : (job.stateName.isNotEmpty ? job.stateName : 'Company');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo + Title + Heart
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Company logo/image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? NetworkImageService(
                      imageUrl: imageUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorWidget: _logoPlaceholder(),
                    )
                  : _logoPlaceholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                job.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.greyText,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Salary
        _iconRow(
          icon: Icons.payment_outlined,
          text: job.salaryDisplay,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        // Company
        _iconRow(
          icon: Icons.business_outlined,
          text: companyName,
          textStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.darkText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Location
        if (locationString.isNotEmpty)
          _iconRow(
            icon: Icons.location_on_outlined,
            text: locationString,
            textStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.darkText,
              fontWeight: FontWeight.w400,
            ),
          ),
        const SizedBox(height: 14),
        // Vacancy tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.tagBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${job.vacancy} ${job.vacancy == 1 ? "Vacancy" : "Vacancies"}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.work_outline_rounded,
        color: AppColors.primaryBlue,
        size: 26,
      ),
    );
  }

  Widget _iconRow({
    required IconData icon,
    required String text,
    required TextStyle textStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.greyText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: textStyle),
        ),
      ],
    );
  }

  // ── Job Highlights Card ─────────────────────────────────────────────────────
  Widget _buildHighlightsCard() {
    // Parse gender from additionalRequirements
    final gender = (job.additionalRequirements['gender'] ?? '').toString();
    final genderLabel = gender.isNotEmpty ? _capitalizeFirst(gender) : 'Any Gender';

    // Experience label
    final experienceLabel = job.experienceLevel.toLowerCase() == 'fresher'
        ? 'Fresher'
        : (job.experienceLevel.isNotEmpty ? job.experienceLevel : 'Any');

    // Shift label
    final shiftLabel = job.shifts.isNotEmpty
        ? job.shifts
            .map((s) => s
                .replaceAll('_', ' ')
                .split(' ')
                .map(_capitalizeFirst)
                .join(' '))
            .join(', ')
        : 'Any Shift';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.highlightCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Highlights title
          const Text(
            'Job Highlights',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          // Experience
          _highlightRow(
            icon: Icons.star_border_rounded,
            label: 'Experience',
            value: experienceLabel,
          ),
          const SizedBox(height: 14),
          // Qualification
          _highlightRow(
            icon: Icons.menu_book_outlined,
            label: 'Qualification',
            value: job.educationLevel.isNotEmpty
                ? _capitalizeFirst(job.educationLevel)
                : 'Any',
          ),
          const SizedBox(height: 14),
          // Gender
          _highlightRow(
            icon: Icons.people_outline_rounded,
            label: 'Gender',
            value: genderLabel,
          ),

          // Preferences section (if shifts available)
          const SizedBox(height: 18),
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 14),
          // Shift timing
          _highlightRow(
            icon: Icons.wb_sunny_outlined,
            label: 'Shift timing',
            value: shiftLabel,
          ),
        ],
      ),
    );
  }

  Widget _highlightRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.greyText),
        const SizedBox(width: 12),
        Text(
          '$label:  ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.greyText,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  // ── Job Description ──────────────────────────────────────────────────────────
  Widget _buildJobDescription() {
    final description = job.jobDescription ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Description',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 10),
        if (job.title.isNotEmpty)
          Text(
            'Job Title: ${job.title}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.greyText,
              height: 1.6,
            ),
          ),
        ],
        // Skills section
        if (job.skills.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Skills Required',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.skills
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEAF8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
        // Perks section
        if (job.perks.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Perks & Benefits',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.perks
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8EA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.replaceAll('_', ' ').split(' ').map(_capitalizeFirst).join(' '),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
        // Walk-in info
        if (job.isWalkin && job.walkinDate != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCC00), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚶 Walk-in Interview',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                if (job.walkinDate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Date: ${job.walkinDate}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.greyText),
                  ),
                ],
                if (job.walkinTime != null)
                  Text(
                    'Time: ${job.walkinTime}${job.walkinEndTime != null ? " - ${job.walkinEndTime}" : ""}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.greyText),
                  ),
                if (job.walkinVenue != null)
                  Text(
                    'Venue: ${job.walkinVenue}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.greyText),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Bottom Bar ───────────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, double bottomPad) {
    final bool showCall = job.enableCall && job.contactPhone != null && job.contactPhone!.isNotEmpty;
    final bool showChat = job.enableChat && ((job.whatsappNumber != null && job.whatsappNumber!.isNotEmpty) || (job.contactPhone != null && job.contactPhone!.isNotEmpty));
    final bool showApply = job.applyOnly || (!showCall && !showChat);

    final List<Widget> buttons = [];

    if (showApply) {
      buttons.add(
        Expanded(
          child: SizedBox(
            height: 52,
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
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (showChat) {
      buttons.add(
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _openWhatsApp(job.whatsappNumber ?? job.contactPhone, job.title),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                foregroundColor: const Color(0xFF25D366),
                padding: EdgeInsets.zero,
              ),
              icon: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  'assets/icons/whatsapp.png',
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: Color(0xFF25D366),
                  ),
                ),
              ),
              label: const Text(
                'Chat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (showCall) {
      buttons.add(
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _makeCall(job.contactPhone),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.darkText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.phone_rounded, size: 18),
              label: const Text(
                'Call HR',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Add spacing between buttons
    final List<Widget> spacedButtons = [];
    for (int i = 0; i < buttons.length; i++) {
      spacedButtons.add(buttons[i]);
      if (i < buttons.length - 1) {
        spacedButtons.add(const SizedBox(width: 12));
      }
    }

    // If no buttons are enabled, default to Apply Now as fallback
    if (spacedButtons.isEmpty) {
      return Container(
        color: AppColors.white,
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
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
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text(
              'Apply Now',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 12),
      child: Row(children: spacedButtons),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Future<void> _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Contact phone number is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not make a call',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _openWhatsApp(String? phone, String title) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Contact phone number is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final message = Uri.encodeComponent(
      'Hello, I am interested in your job posting: "$title".',
    );
    final Uri url = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp. Please check if WhatsApp is installed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

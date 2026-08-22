import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rojgar/core/widgets/network_image_service.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/features/jobs/domain/entities/available_job_entity.dart';
import 'package:rojgar/features/jobs/presentation/screens/job_detail.dart';
import 'package:rojgar/features/jobs/presentation/controller/jobs_controller.dart';
import 'package:share_plus/share_plus.dart';

class _CardColors {
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color subText = Color(0xFF475569);
  static const Color mutedText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color bgTint = Color(0xFFF8FAFC);
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color emeraldText = Color(0xFF059669);
  static const Color indigoBg = Color(0xFFEEF2FF);
}

class JobCardWidget extends StatelessWidget {
  final AvailableJob job;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onFavoriteTap;

  const JobCardWidget({
    super.key,
    required this.job,
    this.imageUrl,
    this.onTap,
    this.onWhatsAppTap,
    this.onCallTap,
    this.onShareTap,
    this.onFavoriteTap,
  });

  String _getJobImageUrl(AvailableJob job) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    return '';
  }

  String _getLocalizedJobType(String type, String lang) {
    if (lang == 'mr') {
      switch (type) {
        case 'full_time':
          return 'फूल टाइम';
        case 'part_time':
          return 'पार्ट टाइम';
        case 'contract':
          return 'कॉन्ट्रॅक्ट';
        case 'internship':
          return 'इंटर्नशिप';
        default:
          return 'फूल टाइम';
      }
    }
    switch (type) {
      case 'full_time':
        return 'Full Time';
      case 'part_time':
        return 'Part Time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      default:
        return 'Full Time';
    }
  }

  String _getLocalizedExperience(String exp, String lang) {
    if (lang == 'mr') {
      if (exp.toLowerCase() == 'fresher') {
        return 'फ्रेशर';
      }
      return '$exp वर्षे';
    }
    if (exp.toLowerCase() == 'fresher') {
      return 'Fresher';
    }
    return '$exp years';
  }

  String _getLocalizedEducation(String edu, String lang) {
    if (lang == 'mr') {
      switch (edu.toLowerCase()) {
        case '10th pass':
          return '१० वी';
        case '12th pass':
          return '१२ वी';
        case 'graduate':
          return 'पदवीधर';
        default:
          return edu;
      }
    }
    return edu;
  }

  String _getLocalizedTitle(String title, String lang) {
    if (lang == 'mr') {
      if (title.toLowerCase().contains('tempo driver')) {
        return 'टेम्पो ड्रायव्हर';
      }
      if (title.toLowerCase().contains('clerk')) {
        return 'क्लर्क';
      }
      if (title.toLowerCase().contains('office executive')) {
        return 'ऑफिस एक्झिक्युटिव्ह';
      }
      if (title.toLowerCase().contains('delivery partner')) {
        return 'डिलिव्हरी पार्टनर';
      }
      if (title.toLowerCase().contains('graphic designer')) {
        return 'ग्राफिक डिझायनर';
      }
      if (title.toLowerCase().contains('warehouse associate')) {
        return 'वेअरहाउस असोसिएट';
      }
      if (title.toLowerCase().contains('telecalling agent')) {
        return 'टेलीकॉलर';
      }
    }
    return title;
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            JobDetailScreen(job: job, imageUrl: _getJobImageUrl(job)),
      ),
    );
  }

  Future<void> _makeCall() async {
    final phone = job.contactPhone;
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
          jobId: job.id,
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

  Future<void> _openWhatsApp() async {
    final phone = job.whatsappNumber ?? job.contactPhone;
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
          jobId: job.id,
          type: 'chat',
          phone: phone,
        );
      }
    } catch (e) {
      debugPrint('Error logging chat application: $e');
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final message = Uri.encodeComponent(
      'Hello, I am interested in your job posting: "${job.title}".',
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

  Future<void> _shareJob() async {
    await Share.share('https://rozgaradda.com/job-details/${job.id}');
  }

  Widget _buildMetaChip(IconData icon, String text, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _CardColors.bgTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? _CardColors.primaryIndigo,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: _CardColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = l10n.locale.languageCode;
    final localizedTitle = _getLocalizedTitle(job.title, lang);
    final localizedLocation = job.stateName;
    final localizedJobType = _getLocalizedJobType(job.jobType, lang);
    final localizedExperience = _getLocalizedExperience(
      job.experienceLevel,
      lang,
    );
    final localizedEducation = _getLocalizedEducation(job.educationLevel, lang);

    final bool showCall = job.showCallButton;
    final bool showChat = job.showChatButton;
    final bool showApply = job.showApplyButton;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _CardColors.borderGrey, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap ?? () => _navigateToDetail(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header: Image, Title, Company & Vacancy ────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail Image
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _CardColors.indigoBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFC7D2FE),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: NetworkImageService(
                            imageUrl: _getJobImageUrl(job),
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: _CardColors.indigoBg,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.work_rounded,
                                color: _CardColors.primaryIndigo,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Company Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    localizedTitle,
                                    style: const TextStyle(
                                      color: _CardColors.darkText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                      height: 1.25,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: _CardColors.primaryIndigo,
                                  size: 14,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              job.addressLine1.isNotEmpty
                                  ? job.addressLine1
                                  : 'Verified Employer',
                              style: const TextStyle(
                                color: _CardColors.subText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Middle Section: Salary Badge & Vacancies ───────────
                  Row(
                    children: [
                      // Salary Badge
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _CardColors.emeraldBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: _CardColors.emeraldText,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  job.salaryDisplay,
                                  style: const TextStyle(
                                    color: _CardColors.emeraldText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Vacancies Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _CardColors.indigoBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFC7D2FE),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.groups_rounded,
                              color: _CardColors.primaryIndigo,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${job.vacancy} ${job.vacancy == 1 ? "Open" : "Openings"}',
                              style: const TextStyle(
                                color: _CardColors.primaryIndigo,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Metadata Info Chips Grid ───────────────────────────
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (localizedLocation.isNotEmpty)
                        _buildMetaChip(
                          Icons.location_on_rounded,
                          localizedLocation,
                          iconColor: const Color(0xFFEF4444),
                        ),
                      _buildMetaChip(
                        Icons.work_history_rounded,
                        localizedJobType,
                        iconColor: const Color(0xFF3B82F6),
                      ),
                      _buildMetaChip(
                        Icons.workspace_premium_rounded,
                        localizedExperience,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                      if (localizedEducation.isNotEmpty)
                        _buildMetaChip(
                          Icons.school_rounded,
                          localizedEducation,
                          iconColor: const Color(0xFF8B5CF6),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 10),

                  // ── Action Buttons Bar ─────────────────────────────────
                  Row(
                    children: [
                      // Share / More Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onShareTap ?? _shareJob,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _CardColors.bgTint,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _CardColors.borderGrey,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              color: _CardColors.subText,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // CTA Buttons (Apply, WhatsApp, Call)
                      ...() {
                        final List<Widget> activeButtons = [];
                        if (showApply) {
                          activeButtons.add(
                            Expanded(
                              child: Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4F46E5),
                                      Color(0xFF6366F1),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed:
                                      onTap ?? () => _navigateToDetail(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    l10n.text('jobs_apply'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        if (showChat) {
                          activeButtons.add(
                            Expanded(
                              child: SizedBox(
                                height: 36,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      onWhatsAppTap ?? () => _openWhatsApp(),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF25D366),
                                      width: 1.2,
                                    ),
                                    backgroundColor: const Color(0xFFF0FDF4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    foregroundColor: const Color(0xFF166534),
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: Image.asset(
                                      'assets/icons/whatsapp.png',
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.chat_bubble_rounded,
                                        size: 14,
                                        color: Color(0xFF25D366),
                                      ),
                                    ),
                                  ),
                                  label: const Text(
                                    'WhatsApp',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        if (showCall) {
                          activeButtons.add(
                            Expanded(
                              child: Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: onCallTap ?? () => _makeCall(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: const Icon(
                                    Icons.phone_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    lang == 'mr' ? 'कॉल करा' : 'Call Employer',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final List<Widget> rowChildren = [];
                        for (int i = 0; i < activeButtons.length; i++) {
                          rowChildren.add(activeButtons[i]);
                          if (i < activeButtons.length - 1) {
                            rowChildren.add(const SizedBox(width: 8));
                          }
                        }
                        return rowChildren;
                      }(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

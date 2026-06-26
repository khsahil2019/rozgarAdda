import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rojgar/core/widgets/network_image_service.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/features/jobs/domain/entities/available_job_entity.dart';
import 'package:rojgar/features/jobs/presentation/screens/job_detail.dart';

class _CardColors {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF17181C);
  static const Color grey = Color(0xFF72757F);
  static const Color borderGrey = Color(0xFFD7DADF);
  static const Color chipBg = Color(0xFFF7F8FB);
  static const Color green = Color(0xFF2E7D32);
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
    switch (job.id) {
      case 101:
        return 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=150';
      case 102:
        return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=150';
      case 103:
        return 'https://images.unsplash.com/photo-1534536281715-e28d76689b4d?w=150';
      case 104:
        return 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150';
      case 105:
        return 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=150';
      case 106:
        return 'https://images.unsplash.com/photo-1549923746-c502d488f3aa?w=150';
      default:
        return 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=150';
    }
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

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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
    final phone = job.contactPhone;
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
    Get.snackbar(
      'Shared',
      'Job link shared successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = l10n.locale.languageCode;
    final localizedTitle = _getLocalizedTitle(job.title, lang);
    final localizedSubcategory = _getLocalizedTitle(job.title, lang);
    final localizedLocation = job.stateName;
    final localizedJobType = _getLocalizedJobType(job.jobType, lang);
    final localizedExperience = _getLocalizedExperience(
      job.experienceLevel,
      lang,
    );
    final localizedEducation = _getLocalizedEducation(job.educationLevel, lang);

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap ?? () => _navigateToDetail(context),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: NetworkImageService(
                        imageUrl: _getJobImageUrl(job),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 56,
                          height: 56,
                          color: _CardColors.chipBg,
                          child: const Icon(
                            Icons.work_outline_rounded,
                            color: _CardColors.primaryBlue,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  localizedTitle,
                                  style: const TextStyle(
                                    color: Color(0xFF007AFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF007AFF),
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.addressLine1.isNotEmpty
                                ? job.addressLine1
                                : 'Company',
                            style: const TextStyle(
                              color: _CardColors.darkText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            localizedSubcategory,
                            style: const TextStyle(
                              color: _CardColors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.salaryDisplay,
                            style: const TextStyle(
                              color: _CardColors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onFavoriteTap,
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${job.vacancy} ${job.vacancy == 1 ? "Vacancy" : "Vacancies"}',
                    style: const TextStyle(
                      color: _CardColors.darkText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE7E9EE), height: 1),
                const SizedBox(height: 12),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.1),
                    1: FlexColumnWidth(0.9),
                  },
                  children: [
                    TableRow(
                      children: [
                        _buildMetadataItem(
                          Icons.location_on,
                          localizedLocation,
                        ),
                        _buildMetadataItem(
                          Icons.access_time_filled,
                          localizedJobType,
                        ),
                      ],
                    ),
                    const TableRow(
                      children: [SizedBox(height: 8), SizedBox(height: 8)],
                    ),
                    TableRow(
                      children: [
                        _buildMetadataItem(Icons.work, localizedExperience),
                        _buildMetadataItem(Icons.menu_book, localizedEducation),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (value) {
                  if (value == 'share') {
                    if (onShareTap != null) {
                      onShareTap!();
                    } else {
                      _shareJob();
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(
                          Icons.share,
                          size: 18,
                          color: _CardColors.darkText,
                        ),
                        SizedBox(width: 8),
                        Text('Share Job'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: onWhatsAppTap ?? () => _openWhatsApp(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFD7DADF),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: _CardColors.darkText,
                      padding: EdgeInsets.zero,
                    ),
                    icon: SizedBox(
                      width: 18,
                      height: 18,
                      child: Image.asset(
                        'assets/icons/whatsapp.png',
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: Color(0xFF25D366),
                            ),
                      ),
                    ),
                    label: const Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _CardColors.darkText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: onCallTap ?? () => _makeCall(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _CardColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    icon: const Icon(
                      Icons.phone_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      lang == 'mr' ? 'कॉल' : 'Call',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

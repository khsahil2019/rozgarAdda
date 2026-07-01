import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_share_plus/open.dart';
// import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import '../controllers/employer_dashboard_controller.dart';
import '../../domain/entities/job_application_entity.dart';

class JobApplicantsScreen extends StatelessWidget {
  final int jobId;
  final String jobTitle;

  const JobApplicantsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  // Color constants
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color accentYellow = Color(0xFFFFCC00);

  Future<void> _makeCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendEmail(String email, String title) async {
    final url = Uri.parse('mailto:$email?subject=Application%20for%20$title');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendWhatsApp(String phone, String name, String title) async {
    final message =
        "Hello $name, this is regarding your application for the '$title' job on Rozgar Adda.";

    Open.whatsApp(whatsAppNumber: phone, text: message);
    // FlutterOpenWhatsapp.sendSingleMessage(phone, message);

    // final url = Uri.parse('https://wa.me/91$phone?text=${Uri.encodeComponent(message)}');
    // if (await canLaunchUrl(url)) {
    //   await launchUrl(url, mode: LaunchMode.externalApplication);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final EmployerDashboardController controller = Get.find();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.text('employer_dashboard_applicants_title'),
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: primaryBlue),
            tooltip: 'Export Applicants',
            onPressed: () async {
              try {
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                  barrierDismissible: false,
                );
                
                final filePath = await controller.exportApplications(jobId);
                
                Get.back(); // close the loading dialog
                
                if (filePath != null) {
                  Get.snackbar(
                    'Success',
                    'Applications exported successfully.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 5),
                    mainButton: TextButton(
                      onPressed: () async {
                        try {
                          final result = await OpenFilex.open(filePath);
                          if (result.type != ResultType.done) {
                            Get.snackbar(
                              'Error',
                              'Could not open file: ${result.message}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Could not open file: $e',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: const Text(
                        'OPEN',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              } catch (e) {
                Get.back(); // close the loading dialog
                Get.snackbar(
                  'Export Failed',
                  e.toString(),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: Obx(() {
        final List<JobApplication> apps =
            controller.jobApplications[jobId] ?? [];
        final stats = controller.jobStats[jobId] ?? {};
        final views = controller.jobVisitorCounts[jobId] ?? 0;

        return Column(
          children: [
            _buildStatsDashboard(context, stats, views),
            Expanded(
              child: apps.isEmpty
                  ? _buildEmptyState(context, l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: apps.length,
                      itemBuilder: (ctx, index) {
                        final app = apps[index];
                        return _buildApplicantCard(context, controller, app);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildApplicantCard(
    BuildContext context,
    EmployerDashboardController controller,
    JobApplication app,
  ) {
    Color statusColor = Colors.orange;
    if (app.status == 'accepted') statusColor = Colors.green;
    if (app.status == 'rejected') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showApplicantDetailsBottomSheet(context, controller, app),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAEAF8),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                app.candidateName.isEmpty ? '?' : app.candidateName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        app.candidateName,
                                        style: const TextStyle(
                                          color: darkText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        app.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Experience: ${app.experienceYears} Years ${app.experienceMonths} Months',
                                  style: const TextStyle(
                                    color: greyText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Education: ${app.educationLevel} (${app.educationDetails})',
                                  style: const TextStyle(color: greyText, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(height: 1, color: const Color(0xFFEEEEEE)),

                    // Skills and Details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (app.keySkills.isNotEmpty) ...[
                            const Text(
                              'Skills:',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: app.keySkills.split(',').map((skill) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F1FA),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    skill.trim(),
                                    style: const TextStyle(
                                      color: Color(0xFF4B4F69),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFBFD),
                ),
                child: Row(
                  children: [
                    // Quick Contact Actions
                    IconButton(
                      onPressed: () => _makeCall(app.phone),
                      icon: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.green,
                        size: 22,
                  ),
                      tooltip: 'Call Candidate',
                    ),
                    IconButton(
                      onPressed: () =>
                          _sendWhatsApp(app.phone, app.candidateName, jobTitle),
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF25D366),
                        size: 22,
                      ),
                      tooltip: 'WhatsApp Candidate',
                    ),
                    IconButton(
                      onPressed: () => _sendEmail(app.email, jobTitle),
                      icon: const Icon(
                        Icons.mail_outline_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      tooltip: 'Email Candidate',
                    ),

                    const Spacer(),

                    // Acceptance Buttons
                    if (app.status == 'pending') ...[
                      TextButton(
                        onPressed: () => controller.updateApplicationStatus(
                          jobId,
                          app.id,
                          'rejected',
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => controller.updateApplicationStatus(
                          jobId,
                          app.id,
                          'accepted',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ] else
                      Text(
                        'Decision Made',
                        style: TextStyle(
                          color: greyText,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApplicantDetailsBottomSheet(
    BuildContext context,
    EmployerDashboardController controller,
    JobApplication initialApp,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<JobApplication?>(
          future: controller.getApplicationDetails(initialApp.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                ),
              );
            }

            final app = snapshot.data ?? initialApp;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull handler line
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header with name & status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          app.candidateName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                      ),
                      _buildStatusTag(app.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),

                  // Detailed fields
                  _buildDetailRow(Icons.phone_android_rounded, 'Phone', app.phone),
                  _buildDetailRow(Icons.email_outlined, 'Email', app.email),
                  _buildDetailRow(
                    Icons.school_outlined,
                    'Education',
                    '${app.educationLevel} (${app.educationDetails})',
                  ),
                  _buildDetailRow(
                    Icons.history_rounded,
                    'Experience',
                    '${app.experienceYears} Years ${app.experienceMonths} Months',
                  ),
                  _buildDetailRow(Icons.payment_rounded, 'Expected Salary', '₹${app.expectedSalary}'),
                  _buildDetailRow(Icons.access_time_rounded, 'Notice Period', app.noticePeriod),
                  _buildDetailRow(Icons.psychology_outlined, 'Key Skills', app.keySkills),
                  if (app.resumePath.isNotEmpty)
                    _buildDetailRow(Icons.description_outlined, 'Resume File', app.resumePath.split('/').last),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatusTag(String status) {
    Color statusColor = Colors.orange;
    if (status == 'accepted') statusColor = Colors.green;
    if (status == 'rejected') statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not specified' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(
    BuildContext context,
    Map<String, int> stats,
    int views,
  ) {
    final newCount = stats['new'] ?? stats['pending'] ?? 0;
    final shortlisted = stats['shortlisted'] ?? stats['accepted'] ?? 0;
    final rejected = stats['rejected'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Performance',
            style: TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatMiniCard(
                  title: 'Views',
                  value: views.toString(),
                  icon: Icons.visibility_outlined,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatMiniCard(
                  title: 'New',
                  value: newCount.toString(),
                  icon: Icons.fiber_new_outlined,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatMiniCard(
                  title: 'Shortlisted',
                  value: shortlisted.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatMiniCard(
                  title: 'Rejected',
                  value: rejected.toString(),
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMiniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: greyText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEAEAF8),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.people_alt_outlined,
                color: primaryBlue,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.text('employer_dashboard_no_applicants'),
              style: const TextStyle(
                color: greyText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

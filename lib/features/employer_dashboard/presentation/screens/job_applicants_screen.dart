import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final message = "Hello $name, this is regarding your application for the '$title' job on Rozgar Adda.";
    final url = Uri.parse('https://wa.me/91$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
          style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: Obx(() {
        final List<JobApplication> apps = controller.jobApplications[jobId] ?? [];

        if (apps.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: const Color(0xFFEAEAF8), borderRadius: BorderRadius.circular(40)),
                    child: const Icon(Icons.people_alt_outlined, color: primaryBlue, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.text('employer_dashboard_no_applicants'),
                    style: const TextStyle(color: greyText, fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: apps.length,
          itemBuilder: (ctx, index) {
            final app = apps[index];
            return _buildApplicantCard(context, controller, app);
          },
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
                      app.candidateName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: primaryBlue, fontSize: 20, fontWeight: FontWeight.bold),
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
                              style: const TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              app.status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Experience: ${app.experienceYears} Years ${app.experienceMonths} Months',
                        style: const TextStyle(color: greyText, fontSize: 13, fontWeight: FontWeight.w500),
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
                    style: TextStyle(color: darkText, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: app.keySkills.split(',').map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F1FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          skill.trim(),
                          style: const TextStyle(color: Color(0xFF4B4F69), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFBFD),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Quick Contact Actions
                IconButton(
                  onPressed: () => _makeCall(app.phone),
                  icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.green, size: 22),
                  tooltip: 'Call Candidate',
                ),
                IconButton(
                  onPressed: () => _sendWhatsApp(app.phone, app.candidateName, jobTitle),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 22),
                  tooltip: 'WhatsApp Candidate',
                ),
                IconButton(
                  onPressed: () => _sendEmail(app.email, jobTitle),
                  icon: const Icon(Icons.mail_outline_rounded, color: Colors.redAccent, size: 22),
                  tooltip: 'Email Candidate',
                ),
                
                const Spacer(),

                // Acceptance Buttons
                if (app.status == 'pending') ...[
                  TextButton(
                    onPressed: () => controller.updateApplicationStatus(jobId, app.id, 'rejected'),
                    child: const Text('Reject', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => controller.updateApplicationStatus(jobId, app.id, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else
                  Text(
                    'Decision Made',
                    style: TextStyle(color: greyText, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

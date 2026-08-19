import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:open_share_plus/open.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import '../controllers/employer_dashboard_controller.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/job_application_entity.dart';

class JobApplicantsScreen extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobApplicantsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  // Modern Theme Colors
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1E202C);
  static const Color greyText = Color(0xFF7E8494);
  static const Color lightBg = Color(0xFFF7F8FC);
  static const Color borderGrey = Color(0xFFE8EAF2);
  static const Color statusGreen = Color(0xFF00C853);
  static const Color statusOrange = Color(0xFFFF9100);
  static const Color statusRed = Color(0xFFFF1744);

  final EmployerDashboardController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // Reset filters when entering screen
    controller.applicantSearchQuery.value = '';
    controller.applicantStatusFilter.value = 'all';
  }

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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.text('employer_dashboard_applicants_title'),
              style: const TextStyle(
                color: darkText,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.jobTitle,
              style: const TextStyle(
                color: greyText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkText),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Text(
                "Export Excel",
                style: TextStyle(color: primaryBlue, fontSize: 12.sp),
              ),
              tooltip: 'Export Applicants',
              onPressed: () async {
                try {
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    ),
                    barrierDismissible: false,
                  );

                  final filePath = await controller.exportApplications(
                    widget.jobId,
                  );

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
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderGrey),
        ),
      ),
      body: Obx(() {
        final List<JobApplication> apps = controller.getFilteredApplicants(
          widget.jobId,
        );
        final stats = controller.jobStats[widget.jobId] ?? {};
        final views = controller.jobVisitorCounts[widget.jobId] ?? 0;

        return Column(
          children: [
            // Performance stats summary widgets
            _buildStatsDashboard(context, stats, views),

            // Search bar
            _buildSearchBar(context),

            // Applicant counts row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final currentFilter = controller.applicantStatusFilter.value
                        .toUpperCase();
                    return Text(
                      'SHOWING: $currentFilter',
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    );
                  }),
                  Text(
                    '${apps.length} Candidates',
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // List of candidates
            Expanded(
              child: apps.isEmpty
                  ? _buildEmptyState(context, l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: apps.length,
                      itemBuilder: (ctx, index) {
                        final app = apps[index];
                        return _buildApplicantCard(context, app);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  // Interactive Stats Dashboard
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Stats Summary',
            style: TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatMiniCard(
                  title: 'Views',
                  value: views.toString(),
                  icon: Icons.bar_chart_rounded,
                  color: primaryBlue,
                  filterVal: 'all',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatMiniCard(
                  title: 'New',
                  value: newCount.toString(),
                  icon: Icons.fiber_new_rounded,
                  color: statusOrange,
                  filterVal: 'pending',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatMiniCard(
                  title: 'Selected',
                  value: shortlisted.toString(),
                  icon: Icons.check_circle_rounded,
                  color: statusGreen,
                  filterVal: 'accepted',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatMiniCard(
                  title: 'Rejected',
                  value: rejected.toString(),
                  icon: Icons.cancel_rounded,
                  color: statusRed,
                  filterVal: 'rejected',
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
    required String filterVal,
  }) {
    return Obx(() {
      final isSelected = controller.applicantStatusFilter.value == filterVal;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.applicantStatusFilter.value = filterVal;
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : color.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Modern Search Bar UI
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => controller.applicantSearchQuery.value = val,
        style: const TextStyle(color: darkText, fontSize: 15),
        decoration: const InputDecoration(
          hintText: 'Search by candidate name or key skill...',
          hintStyle: TextStyle(color: greyText, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: primaryBlue, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  // Modern Applicant Card UI
  Widget _buildApplicantCard(BuildContext context, JobApplication app) {
    Color statusColor = statusOrange;
    if (app.status == 'accepted' || app.status == 'shortlisted') {
      statusColor = statusGreen;
    } else if (app.status == 'rejected') {
      statusColor = statusRed;
    } else if (app.status == 'reviewed') {
      statusColor = primaryBlue;
    } else if (app.status == 'hired') {
      statusColor = Colors.teal;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showApplicantDetailsBottomSheet(context, app),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular Profile Avatar with Initials
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryBlue.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            app.candidateName.isEmpty
                                ? '?'
                                : app.candidateName
                                      .substring(0, 1)
                                      .toUpperCase(),
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Details Section
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
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        statusColor == statusGreen
                                            ? Icons.check_circle_rounded
                                            : (statusColor == statusRed
                                                  ? Icons.cancel_rounded
                                                  : Icons.info_rounded),
                                        color: statusColor,
                                        size: 13.sp,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'STATUS: ${app.status.toUpperCase()}',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Experience Row
                            Text(
                              'Exp: ${app.experienceYears} Yrs ${app.experienceMonths} Mos',
                              style: const TextStyle(
                                color: greyText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Education Row
                            Text(
                              'Edu: ${app.educationLevel} (${app.educationDetails})',
                              style: const TextStyle(
                                color: greyText,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Skill chips
                            if (app.keySkills.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: app.keySkills.split(',').take(3).map((
                                  skill,
                                ) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: lightBg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: borderGrey),
                                    ),
                                    child: Text(
                                      skill.trim(),
                                      style: const TextStyle(
                                        color: darkText,
                                        fontSize: 11,
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
              ),

              // Divider
              Container(height: 1, color: borderGrey),

              // Bottom Tray with Contact Actions & Decisions
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: const Color(0xFFFAFBFC),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Communication Shortcuts
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Call Button with Phone Number
                          GestureDetector(
                            onTap: () => _makeCall(app.phone),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone_in_talk_rounded,
                                    size: 20.sp,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    app.phone,
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // WhatsApp Button with "Chat" Label
                          GestureDetector(
                            onTap: () => _sendWhatsApp(
                              app.phone,
                              app.candidateName,
                              widget.jobTitle,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF25D366,
                                ).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFF25D366,
                                  ).withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/icons/whatsapp.png",
                                    width: 20.sp,
                                    height: 20.sp,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Chat',
                                    style: TextStyle(
                                      color: const Color(0xFF075E54),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Email Button with "Open Mail" Label
                          GestureDetector(
                            onTap: () => _sendEmail(app.email, widget.jobTitle),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.mail_rounded,
                                    size: 20.sp,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Open Mail',
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Status and Update Button in the next line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Current Status Indicator

                        // Update Button
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showStatusUpdateDialog(context, app),
                          icon: Icon(
                            Icons.edit_note_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Update Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildContactButton({
    required Widget icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );
  }

  // Modern Details Bottom Sheet
  void _showApplicantDetailsBottomSheet(
    BuildContext context,
    JobApplication initialApp,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<JobApplication?>(
          future: controller.getApplicationDetails(initialApp.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 320,
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
                  // Pull handler bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          app.candidateName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      _buildStatusTag(app.status),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Container(height: 1, color: borderGrey),
                  const SizedBox(height: 20),

                  // Detailed items with nice modern rows
                  _buildDetailRow(
                    Icons.phone_android_rounded,
                    'Mobile Number',
                    app.phone,
                  ),
                  _buildDetailRow(
                    Icons.email_rounded,
                    'Email Address',
                    app.email,
                  ),
                  _buildDetailRow(
                    Icons.school_rounded,
                    'Education details',
                    '${app.educationLevel} (${app.educationDetails})',
                  ),
                  _buildDetailRow(
                    Icons.history_rounded,
                    'Work Experience',
                    '${app.experienceYears} Years ${app.experienceMonths} Months',
                  ),
                  _buildDetailRow(
                    Icons.currency_rupee_rounded,
                    'Expected Salary',
                    app.expectedSalary.isNotEmpty
                        ? '₹${app.expectedSalary} / month'
                        : 'Not specified',
                  ),
                  _buildDetailRow(
                    Icons.access_time_filled_rounded,
                    'Notice Period',
                    app.noticePeriod,
                  ),
                  _buildDetailRow(
                    Icons.psychology_rounded,
                    'Key Skills & Technologies',
                    app.keySkills,
                  ),
                  if (app.resumePath.isNotEmpty)
                    _buildDetailRow(
                      Icons.description_rounded,
                      'Resume Document',
                      app.resumePath.split('/').last,
                    ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back(); // close applicant details sheet
                        _showStatusUpdateDialog(context, app);
                      },
                      icon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                      ),
                      label: const Text('Update Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
    Color color = statusOrange;
    if (status == 'accepted' || status == 'shortlisted') color = statusGreen;
    if (status == 'rejected') color = statusRed;
    if (status == 'reviewed') color = primaryBlue;
    if (status == 'hired') color = Colors.teal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, JobApplication app) {
    final selectedStatus = app.status.obs;
    final commentsController = TextEditingController();

    // Set initial status selection (if it's one of the valid enums, otherwise default to reviewed or shortlisted)
    if ([
      'shortlisted',
      'reviewed',
      'rejected',
      'hired',
    ].contains(app.status.toLowerCase())) {
      selectedStatus.value = app.status.toLowerCase();
    } else {
      selectedStatus.value = 'reviewed';
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Update Application Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: darkText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: greyText),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Column(
                  children: [
                    _buildStatusOption(
                      title: 'Shortlisted',
                      statusVal: 'shortlisted',
                      selectedVal: selectedStatus.value,
                      color: statusGreen,
                      onTap: () => selectedStatus.value = 'shortlisted',
                    ),
                    _buildStatusOption(
                      title: 'Reviewed',
                      statusVal: 'reviewed',
                      selectedVal: selectedStatus.value,
                      color: primaryBlue,
                      onTap: () => selectedStatus.value = 'reviewed',
                    ),
                    _buildStatusOption(
                      title: 'Rejected',
                      statusVal: 'rejected',
                      selectedVal: selectedStatus.value,
                      color: statusRed,
                      onTap: () => selectedStatus.value = 'rejected',
                    ),
                    _buildStatusOption(
                      title: 'Hired',
                      statusVal: 'hired',
                      selectedVal: selectedStatus.value,
                      color: Colors.teal,
                      onTap: () => selectedStatus.value = 'hired',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Comments (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentsController,
                maxLines: 3,
                style: const TextStyle(color: darkText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter comments here...',
                  hintStyle: const TextStyle(color: greyText, fontSize: 13),
                  filled: true,
                  fillColor: lightBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await controller.updateApplicationStatus(
                      widget.jobId,
                      app.id,
                      selectedStatus.value,
                      comments: commentsController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Update Status',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatusOption({
    required String title,
    required String statusVal,
    required String selectedVal,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSelected = statusVal == selectedVal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : borderGrey,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : greyText,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: darkText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: primaryBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: greyText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
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

  Widget _buildEmptyState(BuildContext context, dynamic l10n) {
    return EmptyStateWidget(
      icon: Icons.people_outline_rounded,
      title: l10n.text('employer_dashboard_no_applicants').isNotEmpty
          ? l10n.text('employer_dashboard_no_applicants')
          : 'No Job Applicants Found',
      subtitle: 'No candidate applications match your current filters or search query.',
      primaryButtonText: 'Reset Filters',
      onPrimaryPressed: () {
        controller.applicantSearchQuery.value = '';
        controller.applicantStatusFilter.value = 'all';
      },
    );
  }
}

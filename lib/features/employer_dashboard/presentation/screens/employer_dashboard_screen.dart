import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/splash_screen.dart';
import '../controllers/employer_dashboard_controller.dart';
import 'post_job_form_screen.dart';
import 'job_applicants_screen.dart';

class EmployerDashboardScreen extends GetView<EmployerDashboardController> {
  const EmployerDashboardScreen({super.key});

  // Color constants
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color accentYellow = Color(0xFFFFCC00);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.text('employer_dashboard_title'),
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: primaryBlue),
            onPressed: () {
              _showLogoutConfirmDialog(context);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const PostJobFormScreen());
        },
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 22),
        label: Text(
          l10n.text('employer_dashboard_post_job'),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadDashboard(),
        color: primaryBlue,
        child: Obx(() {
          if (controller.isLoading.value && controller.postedJobs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics Bento section
                _buildMetricsSection(context),

                const SizedBox(height: 24),

                // Recent posts title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.text('recent_jobs_title'),
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${controller.postedJobs.length} Jobs',
                      style: const TextStyle(color: greyText, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Jobs list
                if (controller.postedJobs.isEmpty)
                  _buildEmptyState(context)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.postedJobs.length,
                    itemBuilder: (ctx, index) {
                      final job = controller.postedJobs[index];
                      return _buildJobCard(context, job);
                    },
                  ),
                
                const SizedBox(height: 80), // extra padding for FAB
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.text('logout_confirm_title')),
          content: Text(l10n.text('logout_confirm_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.text('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await controller.logout();
                Get.offAll(() => const SplashScreen());
              },
              child: Text(l10n.text('logout'), style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        // Jobs Count Card
        Expanded(
          child: _buildMetricCard(
            title: l10n.text('employer_dashboard_total_jobs'),
            value: controller.postedJobs.length.toString(),
            icon: Icons.work_outline_rounded,
            cardColor: const Color(0xFF1400FF),
            textColor: Colors.white,
            iconColor: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(width: 12),
        // Applications Count Card
        Expanded(
          child: _buildMetricCard(
            title: l10n.text('employer_dashboard_total_applications'),
            value: controller.totalApplications.toString(),
            icon: Icons.people_outline_rounded,
            cardColor: Colors.white,
            textColor: darkText,
            iconColor: primaryBlue.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        // Total Views Card
        Expanded(
          child: _buildMetricCard(
            title: l10n.text('employer_dashboard_total_views'),
            value: controller.totalViews.toString(),
            icon: Icons.visibility_outlined,
            cardColor: Colors.white,
            textColor: darkText,
            iconColor: primaryBlue.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(icon, size: 44, color: iconColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAF8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.work_history_outlined, color: primaryBlue, size: 36),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.text('employer_dashboard_no_jobs'),
            style: const TextStyle(color: greyText, fontSize: 15, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, dynamic job) {
    final l10n = context.l10n;
    final int appCount = controller.jobApplications[job.id]?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => JobApplicantsScreen(jobId: job.id, jobTitle: job.title));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location and Salary
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: greyText, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${job.addressLine1}, ${job.stateName}',
                      style: const TextStyle(color: greyText, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee_rounded, color: greyText, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      job.salaryDisplay,
                      style: const TextStyle(color: darkText, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule_rounded, color: greyText, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      job.jobTypeLabel,
                      style: const TextStyle(color: greyText, fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Container(height: 1, color: const Color(0xFFF1F1F1)),
                const SizedBox(height: 12),

                // Views and Applications Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.visibility_outlined, color: primaryBlue, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${job.viewsCount} views',
                          style: const TextStyle(color: darkText, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.people_outline_rounded, color: primaryBlue, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '$appCount applicants',
                          style: const TextStyle(color: darkText, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          l10n.text('employer_dashboard_view_applicants'),
                          style: const TextStyle(
                            color: primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: primaryBlue, size: 18),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

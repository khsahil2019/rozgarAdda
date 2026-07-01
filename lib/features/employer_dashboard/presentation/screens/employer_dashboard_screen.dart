import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/splash_screen.dart';
import '../controllers/employer_dashboard_controller.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';
import 'post_job_form_screen.dart';
import 'job_applicants_screen.dart';

class EmployerDashboardScreen extends GetView<EmployerDashboardController> {
  const EmployerDashboardScreen({super.key});

  // Modern Color System
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1E202C);
  static const Color greyText = Color(0xFF7E8494);
  static const Color lightBg = Color(0xFFF7F8FC);
  static const Color borderGrey = Color(0xFFE8EAF2);
  static const Color activeGreen = Color(0xFF00C853);
  static const Color pendingOrange = Color(0xFFFF9100);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.text('employer_dashboard_title'),
          style: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: primaryBlue,
                size: 20,
              ),
              onPressed: () => _showLogoutConfirmDialog(context),
              tooltip: 'Logout',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderGrey),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.checkStatusAndNavigateToPost(() {
            Get.to(() => const PostJobFormScreen());
          });
        },
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          l10n.text('employer_dashboard_post_job'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadDashboard(),
        color: primaryBlue,
        strokeWidth: 2.5,
        child: Obx(() {
          if (controller.isLoading.value && controller.postedJobs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
                strokeWidth: 3,
              ),
            );
          }

          final filteredJobs = controller.filteredJobs;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Bento Grid Metrics
                _buildBentoMetrics(context),

                const SizedBox(height: 28),

                // Search & Filter Header
                _buildSearchAndFilters(context),

                const SizedBox(height: 16),

                // Jobs list title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.text('recent_jobs_title'),
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderGrey),
                      ),
                      child: Text(
                        '${filteredJobs.length} Jobs',
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Jobs list
                if (filteredJobs.isEmpty)
                  _buildEmptyState(context)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredJobs.length,
                    itemBuilder: (ctx, index) {
                      final job = filteredJobs[index];
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

  Future<void> _exportJobApplications(BuildContext context, int jobId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: primaryBlue)),
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
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.text('logout_confirm_title'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            l10n.text('logout_confirm_message'),
            style: const TextStyle(color: greyText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                l10n.text('cancel'),
                style: const TextStyle(
                  color: greyText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await controller.logout();
                Get.offAll(() => const SplashScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.text('logout'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Bento Box Metrics
  Widget _buildBentoMetrics(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Big Card: Total Jobs
        Expanded(
          flex: 5,
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1400FF), Color(0xFF6B5BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    Icons.work_rounded,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n
                              .text('employer_dashboard_total_jobs')
                              .toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Active Hiring',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      controller.postedJobs.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Right Column: Applications & Views
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildSmallBentoCard(
                title: l10n.text('employer_dashboard_total_applications'),
                value: controller.totalApplications.toString(),
                icon: Icons.people_alt_rounded,
                color: primaryBlue,
              ),
              const SizedBox(height: 12),
              _buildSmallBentoCard(
                title: l10n.text('employer_dashboard_total_views'),
                value: controller.totalViews.toString(),
                icon: Icons.bar_chart_rounded,
                color: activeGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBentoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ],
      ),
    );
  }

  // Modern Search & Status Filters UI
  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      children: [
        // Modern Search Bar
        Container(
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
            onChanged: (val) => controller.searchQuery.value = val,
            style: const TextStyle(color: darkText, fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Search jobs by title or location...',
              hintStyle: TextStyle(color: greyText, fontSize: 14),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: primaryBlue,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Filter Chips Row
        Obx(() {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Jobs', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending'),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.statusFilter.value == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : darkText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.statusFilter.value = value;
        }
      },
      selectedColor: primaryBlue,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? Colors.transparent : borderGrey),
      ),
      elevation: isSelected ? 2 : 0,
      pressElevation: 1,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.work_off_rounded,
              color: primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.text('employer_dashboard_no_jobs'),
            style: const TextStyle(
              color: darkText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Create a new job post to start receiving candidate applications.',
            style: TextStyle(color: greyText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Modern Job Card UI
  Widget _buildJobCard(BuildContext context, AvailableJob job) {
    final l10n = context.l10n;
    final int appCount = controller.jobApplications[job.id]?.length ?? 0;

    // Status color
    final isPending = job.status.toLowerCase() == 'pending';
    final statusColor = isPending ? pendingOrange : activeGreen;
    final statusBg =
        isPending
            ? pendingOrange.withValues(alpha: 0.08)
            : activeGreen.withValues(alpha: 0.08);

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
          child: InkWell(
            onTap: () {
              Get.to(
                () => JobApplicantsScreen(jobId: job.id, jobTitle: job.title),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          job.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location and Salary Info
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: greyText,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${job.addressLine1}, ${job.stateName}',
                          style: const TextStyle(
                            color: greyText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Salary and type badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.currency_rupee_rounded,
                              color: darkText,
                              size: 13,
                            ),
                            Text(
                              job.salaryDisplay,
                              style: const TextStyle(
                                color: darkText,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          job.jobTypeLabel,
                          style: const TextStyle(
                            color: greyText,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Container(height: 1, color: borderGrey),
                  const SizedBox(height: 12),

                  // Views and Applicants count footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            color: primaryBlue.withValues(alpha: 0.8),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${job.viewsCount} views',
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.people_alt_rounded,
                            color: primaryBlue.withValues(alpha: 0.8),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$appCount applicants',
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            l10n.text('employer_dashboard_view_applicants'),
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: primaryBlue,
                            size: 18,
                          ),
                        ],
                      ),
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

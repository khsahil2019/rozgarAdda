import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rojgar/splash_screen.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../controllers/employer_dashboard_controller.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';
import 'post_job_form_screen.dart';
import 'job_applicants_screen.dart';

class EmployerDashboardScreen extends GetView<EmployerDashboardController> {
  const EmployerDashboardScreen({super.key});

  // Premium Modern Color Palette
  static const Color primary = Color(0xFF1400FF);
  static const Color primaryDark = Color(0xFF0C00B8);
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightGreyText = Color(0xFF94A3B8);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Status & Accent Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color infoBlue = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFF0F9FF);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF5F3FF);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return DateFormat('dd MMM yyyy').format(dateTime);
    } else if (difference.inDays > 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatJobLocation(AvailableJob job) {
    final parts = <String>[];
    if (job.addressLine1.trim().isNotEmpty) {
      parts.add(job.addressLine1.trim());
    }
    if (job.stateName.trim().isNotEmpty && !parts.contains(job.stateName.trim())) {
      parts.add(job.stateName.trim());
    }
    if (job.pincode.trim().isNotEmpty && parts.length < 2) {
      parts.add('PIN ${job.pincode.trim()}');
    }
    if (parts.isEmpty) {
      return job.workLocationLabel;
    }
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: _buildModernAppBar(context),
      floatingActionButton: _buildPostJobFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () => controller.loadDashboard(),
        color: primary,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        child: Obx(() {
          if (controller.isLoading.value && controller.postedJobs.isEmpty) {
            return _buildSkeletonLoading();
          }

          final filteredJobs = controller.filteredJobs;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header, Metrics & Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome & Verification Banner
                      _buildWelcomeHeader(context),

                      const SizedBox(height: 14),

                      // Bento Grid Metrics (Hero + 3 Stat Tiles)
                      _buildBentoGridMetrics(context),

                      const SizedBox(height: 16),

                      // Notification Alert if pending applications exist
                      if (controller.totalPendingReviewCount > 0) ...[
                        _buildPendingApplicantsAlert(context),
                        const SizedBox(height: 16),
                      ],

                      // Search Bar & Filter Controls
                      _buildSearchAndFilters(context),

                      const SizedBox(height: 18),

                      // Section Header with Job Count & Sort Selector
                      _buildJobListHeader(context, filteredJobs.length),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Jobs List
              if (filteredJobs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildEmptyState(context),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, index) {
                      final job = filteredJobs[index];
                      return _buildPremiumJobCard(context, job);
                    }, childCount: filteredJobs.length),
                  ),
                ),

              // Bottom Spacer for Floating Action Button
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          );
        }),
      ),
    );
  }

  // ==========================================
  // APP BAR
  // ==========================================
  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primary, primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Employer Dashboard',
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Rozgar Adda Business',
                  style: TextStyle(
                    color: greyText,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Refresh Action
        Container(
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: lightBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderGrey),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primary, size: 20),
            onPressed: () => controller.loadDashboard(),
            tooltip: 'Refresh Dashboard',
            splashRadius: 20,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: EdgeInsets.zero,
          ),
        ),

        // Logout Action
        Container(
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 19,
            ),
            onPressed: () => _showLogoutConfirmDialog(context),
            tooltip: 'Logout',
            splashRadius: 20,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: borderGrey),
      ),
    );
  }

  // ==========================================
  // FLOATING ACTION BUTTON
  // ==========================================
  Widget _buildPostJobFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        controller.checkStatusAndNavigateToPost(() {
          Get.to(() => const PostJobFormScreen());
        });
      },
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
      label: const Text(
        'Post a Job',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 0.1,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==========================================
  // WELCOME HEADER
  // ==========================================
  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withValues(alpha: 0.1), primaryLight.withValues(alpha: 0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: primary.withValues(alpha: 0.2), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.business_rounded, color: primary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _getGreeting(),
                        style: const TextStyle(
                          color: greyText,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Obx(
                        () => Text(
                          controller.companyName.value.isNotEmpty
                              ? controller.companyName.value
                              : (controller.employerId.value != 0
                                  ? 'Employer #${controller.employerId.value}'
                                  : 'Hiring Manager'),
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: successGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 10,
                            color: successGreen,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: successGreen,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Quick Post Shortcut
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.checkStatusAndNavigateToPost(() {
                  Get.to(() => const PostJobFormScreen());
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: primary, size: 15),
                    SizedBox(width: 3),
                    Text(
                      'Post Job',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
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

  // ==========================================
  // BENTO GRID METRICS
  // ==========================================
  Widget _buildBentoGridMetrics(BuildContext context) {
    return Column(
      children: [
        // Top Hero Card (Active Jobs & Direct Status)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E00BF), Color(0xFF1400FF), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background Decorative Icon
              Positioned(
                right: -15,
                bottom: -20,
                child: Icon(
                  Icons.work_outline_rounded,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                color: Color(0xFFFFD54F),
                                size: 13,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'HIRING OVERVIEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
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
                      // Active Openings Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: successGreen.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: successGreen.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF69F0AE),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Obx(
                              () => Text(
                                '${controller.activeJobsCount} Active',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL JOB OPENINGS',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Obx(
                              () => FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  controller.postedJobs.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Quick Filter shortcut
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.statusFilter.value =
                                controller.statusFilter.value == 'active'
                                    ? 'all'
                                    : 'active';
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'View Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 3 Stat Mini Cards Row with Scalable Content
        Row(
          children: [
            // Total Applications
            Expanded(
              child: _buildMetricTile(
                icon: Icons.people_alt_rounded,
                iconColor: primary,
                bgColor: infoLight,
                title: 'Applications',
                value: controller.totalApplications.toString(),
                subtitle: 'Candidates',
              ),
            ),
            const SizedBox(width: 8),
            // Total Views
            Expanded(
              child: _buildMetricTile(
                icon: Icons.visibility_rounded,
                iconColor: successGreen,
                bgColor: successLight,
                title: 'Job Views',
                value: controller.totalViews.toString(),
                subtitle: 'Impressions',
              ),
            ),
            const SizedBox(width: 8),
            // Shortlisted
            Expanded(
              child: _buildMetricTile(
                icon: Icons.star_rounded,
                iconColor: purpleAccent,
                bgColor: purpleLight,
                title: 'Shortlisted',
                value: controller.totalShortlistedCount.toString(),
                subtitle: 'Top Talent',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: lightGreyText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: darkText,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: greyText,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PENDING APPLICANTS ALERT
  // ==========================================
  Widget _buildPendingApplicantsAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warningOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: warningOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.pending_actions_rounded,
              color: warningOrange,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pending Candidate Reviews',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'You have ${controller.totalPendingReviewCount} new applicant${controller.totalPendingReviewCount > 1 ? 's' : ''} to review.',
                  style: const TextStyle(color: Color(0xFFB45309), fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SEARCH & FILTERS
  // ==========================================
  Widget _buildSearchAndFilters(BuildContext context) {
    final searchController = TextEditingController(
      text: controller.searchQuery.value,
    );
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: searchController.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(
            () => TextField(
              controller: searchController,
              onChanged: (val) => controller.searchQuery.value = val,
              style: const TextStyle(
                color: darkText,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search jobs, locations, or skills...',
                hintStyle: const TextStyle(
                  color: lightGreyText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primary,
                  size: 20,
                ),
                suffixIcon:
                    controller.searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.cancel_rounded,
                            color: greyText,
                            size: 18,
                          ),
                          onPressed: () {
                            searchController.clear();
                            controller.searchQuery.value = '';
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 14,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Filter Pills Row
        Obx(() {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildSegmentFilterChip(
                  label: 'All Openings',
                  count: controller.postedJobs.length,
                  value: 'all',
                  icon: Icons.apps_rounded,
                ),
                const SizedBox(width: 8),
                _buildSegmentFilterChip(
                  label: 'Active',
                  count: controller.activeJobsCount,
                  value: 'active',
                  icon: Icons.check_circle_rounded,
                  badgeColor: successGreen,
                ),
                const SizedBox(width: 8),
                _buildSegmentFilterChip(
                  label: 'Pending',
                  count: controller.pendingJobsCount,
                  value: 'pending',
                  icon: Icons.hourglass_top_rounded,
                  badgeColor: warningOrange,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSegmentFilterChip({
    required String label,
    required int count,
    required String value,
    required IconData icon,
    Color? badgeColor,
  }) {
    final isSelected = controller.statusFilter.value == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.statusFilter.value = value,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : borderGrey,
              width: 1.2,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : greyText,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : darkText,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : (badgeColor != null
                              ? badgeColor.withValues(alpha: 0.12)
                              : lightBg),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color:
                        isSelected
                            ? Colors.white
                            : (badgeColor ?? darkText),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // JOBS LIST HEADER WITH SORT
  // ==========================================
  Widget _buildJobListHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Job Postings',
              style: TextStyle(
                color: darkText,
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count showing',
                style: const TextStyle(
                  color: primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        // Sort Options Popup
        Obx(() {
          String sortLabel = 'Newest';
          if (controller.sortBy.value == 'applicants') {
            sortLabel = 'Applicants';
          } else if (controller.sortBy.value == 'views') {
            sortLabel = 'Views';
          }

          return PopupMenuButton<String>(
            initialValue: controller.sortBy.value,
            onSelected: (val) => controller.sortBy.value = val,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderGrey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_rounded, color: greyText, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    sortLabel,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: greyText,
                    size: 16,
                  ),
                ],
              ),
            ),
            itemBuilder:
                (ctx) => [
                  const PopupMenuItem(
                    value: 'newest',
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 15, color: primary),
                        SizedBox(width: 8),
                        Text(
                          'Newest First',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'applicants',
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          size: 15,
                          color: primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Most Applicants',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'views',
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 15,
                          color: primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Most Viewed',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          );
        }),
      ],
    );
  }

  // ==========================================
  // PREMIUM JOB CARD
  // ==========================================
  Widget _buildPremiumJobCard(BuildContext context, AvailableJob job) {
    final int appCount = controller.jobApplications[job.id]?.length ?? 0;
    final stats = controller.jobStats[job.id] ?? {};
    final int shortlistedCount = stats['shortlisted'] ?? 0;
    final int pendingCount = stats['new'] ?? 0;

    final isPending = job.status.toLowerCase() == 'pending';
    final statusColor = isPending ? warningOrange : successGreen;
    final statusBg =
        isPending ? warningOrange.withValues(alpha: 0.1) : successGreen.withValues(alpha: 0.1);

    final locationText = _formatJobLocation(job);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.to(
                () => JobApplicantsScreen(jobId: job.id, jobTitle: job.title),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Title & Status Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Avatar Icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withValues(alpha: 0.08),
                              primaryLight.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.work_rounded,
                            color: primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Title & Time Ago
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                color: darkText,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: lightGreyText,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Posted ${_formatTimeAgo(job.createdAt)}',
                                  style: const TextStyle(
                                    color: greyText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location & Work Mode Badges (Responsive Wrap)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Location Badge
                      _buildTagPill(
                        context: context,
                        icon: Icons.location_on_rounded,
                        text: locationText,
                        bgColor: lightBg,
                        textColor: mediumText,
                        iconColor: greyText,
                      ),
                      // Job Type
                      _buildTagPill(
                        context: context,
                        icon: Icons.business_center_outlined,
                        text: job.jobTypeLabel,
                        bgColor: lightBg,
                        textColor: mediumText,
                        iconColor: greyText,
                      ),
                      // Location Mode
                      _buildTagPill(
                        context: context,
                        icon: Icons.place_outlined,
                        text: job.workLocationLabel,
                        bgColor: lightBg,
                        textColor: mediumText,
                        iconColor: greyText,
                      ),
                      // Vacancies
                      if (job.vacancy > 0)
                        _buildTagPill(
                          context: context,
                          icon: Icons.group_outlined,
                          text: '${job.vacancy} Openings',
                          bgColor: primary.withValues(alpha: 0.05),
                          textColor: primary,
                          iconColor: primary,
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Salary Highlight Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Icon(
                                  Icons.currency_rupee_rounded,
                                  color: primary,
                                  size: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  job.salaryDisplay,
                                  style: const TextStyle(
                                    color: darkText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Walk-in Badge if applicable
                        if (job.isWalkin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: warningOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_walk_rounded,
                                  color: warningOrange,
                                  size: 12,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Walk-in',
                                  style: TextStyle(
                                    color: warningOrange,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mini Stats Row (Views, Total Apps, Shortlisted, Pending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCardMiniStat(
                            icon: Icons.visibility_rounded,
                            color: infoBlue,
                            value: '${job.viewsCount}',
                            label: 'Views',
                          ),
                        ),
                        Container(width: 1, height: 22, color: borderGrey),
                        Expanded(
                          child: _buildCardMiniStat(
                            icon: Icons.people_alt_rounded,
                            color: primary,
                            value: '$appCount',
                            label: 'Applicants',
                          ),
                        ),
                        Container(width: 1, height: 22, color: borderGrey),
                        Expanded(
                          child: _buildCardMiniStat(
                            icon: Icons.star_rounded,
                            color: purpleAccent,
                            value: '$shortlistedCount',
                            label: 'Shortlisted',
                          ),
                        ),
                        if (pendingCount > 0) ...[
                          Container(width: 1, height: 22, color: borderGrey),
                          Expanded(
                            child: _buildCardMiniStat(
                              icon: Icons.hourglass_top_rounded,
                              color: warningOrange,
                              value: '$pendingCount',
                              label: 'Pending',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Actions Row
                  Row(
                    children: [
                      // View Applicants Button (Primary)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(
                              () => JobApplicantsScreen(
                                jobId: job.id,
                                jobTitle: job.title,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'View Applicants',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Export Excel Icon Button
                      Container(
                        decoration: BoxDecoration(
                          color: lightBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderGrey),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.download_rounded,
                            color: primary,
                            size: 18,
                          ),
                          onPressed: () => _exportJobApplications(context, job.id),
                          tooltip: 'Export to Excel',
                          constraints: const BoxConstraints(
                            minWidth: 38,
                            minHeight: 38,
                          ),
                          padding: EdgeInsets.zero,
                        ),
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

  Widget _buildTagPill({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    final maxWidth = MediaQuery.of(context).size.width - 90;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: iconColor),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMiniStat({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: greyText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SKELETON LOADING
  // ==========================================
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (ctx, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderGrey),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          height: 14,
                          decoration: BoxDecoration(
                            color: lightBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 70,
                          height: 11,
                          decoration: BoxDecoration(
                            color: lightBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 34,
                decoration: BoxDecoration(
                  color: lightBg,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================
  Widget _buildEmptyState(BuildContext context) {
    final isSearching = controller.searchQuery.isNotEmpty || controller.statusFilter.value != 'all';

    if (isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: primary,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'No Matching Job Openings',
                style: TextStyle(
                  color: darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Try searching with different keywords or reset your filters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: greyText, fontSize: 12.5),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  controller.searchQuery.value = '';
                  controller.statusFilter.value = 'all';
                },
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text(
                  'Reset All Filters',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: primary),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return EmptyStateWidget(
      icon: Icons.post_add_rounded,
      title: 'No Job Openings Posted',
      subtitle:
          'Create a new job posting to start receiving verified candidates and managing applications.',
      primaryButtonText: 'Post Your First Job',
      onPrimaryPressed: () {
        controller.checkStatusAndNavigateToPost(() {
          Get.to(() => const PostJobFormScreen());
        });
      },
    );
  }

  // ==========================================
  // EXPORT APPLICATIONS
  // ==========================================
  Future<void> _exportJobApplications(BuildContext context, int jobId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: primary)),
        barrierDismissible: false,
      );

      final filePath = await controller.exportApplications(jobId);

      Get.back(); // close loading dialog

      if (filePath != null) {
        Get.bottomSheet(
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: borderGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: successGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: successGreen,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Candidates Exported Successfully!',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  filePath.split('/').last,
                  style: const TextStyle(
                    fontSize: 12,
                    color: greyText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Get.back();
                          try {
                            await Share.shareXFiles(
                              [XFile(filePath)],
                              text: 'Candidate list for Job #$jobId',
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Share Error',
                              e.toString(),
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Share File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: const BorderSide(color: primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Get.back();
                          try {
                            final result = await OpenFilex.open(filePath);
                            if (result.type != ResultType.done) {
                              await Share.shareXFiles(
                                [XFile(filePath)],
                                text: 'Candidate list for Job #$jobId',
                              );
                            }
                          } catch (e) {
                            await Share.shareXFiles(
                              [XFile(filePath)],
                              text: 'Candidate list for Job #$jobId',
                            );
                          }
                        },
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: const Text('Open File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      }
    } catch (e) {
      Get.back(); // close loading dialog
      Get.snackbar(
        'Export Failed',
        e is Failure ? e.message : e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // ==========================================
  // LOGOUT CONFIRMATION DIALOG
  // ==========================================
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              const Flexible(
                child: Text(
                  'Confirm Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out of your employer portal?',
            style: TextStyle(color: greyText, fontSize: 13.5),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

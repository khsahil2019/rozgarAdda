import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:rojgar/core/widgets/empty_state_widget.dart';
import '../controller/profile_controller.dart';

// Unified Rozgar Brand Color Tokens
class _AC {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
}

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late final ProfileController _ctrl;
  final RxString _selectedFilter = 'all'.obs;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();
    _ctrl.loadApplications();
  }

  List<dynamic> _getFilteredList(List<dynamic> list) {
    final filter = _selectedFilter.value.toLowerCase();
    if (filter == 'all') return list;
    if (filter == 'pending') {
      return list.where((a) {
        final s = (a.status as String? ?? '').toLowerCase();
        return s == 'pending' || s == 'new' || s == 'under_review' || s == 'applied';
      }).toList();
    }
    if (filter == 'accepted') {
      return list.where((a) {
        final s = (a.status as String? ?? '').toLowerCase();
        return s == 'accepted' || s == 'hired' || s == 'shortlisted' || s == 'approved';
      }).toList();
    }
    if (filter == 'rejected') {
      return list.where((a) {
        final s = (a.status as String? ?? '').toLowerCase();
        return s == 'rejected' || s == 'declined';
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _AC.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Applications',
                style: TextStyle(
                  color: _AC.darkText,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
              ),
              Obx(() {
                final count = _ctrl.applications.length;
                return Text(
                  count == 0 ? 'Track your submissions' : '$count Applications Submitted',
                  style: const TextStyle(
                    color: _AC.greyText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _AC.borderGrey),
          ),
        ),
        body: Obx(() {
          if (_ctrl.isLoadingApplications.value) {
            return _buildLoadingSkeleton();
          }
          if (_ctrl.applicationsError.value != null) {
            return _buildErrorView(_ctrl.applicationsError.value!);
          }
          if (_ctrl.applications.isEmpty) {
            return const _EmptyView();
          }

          final allList = _ctrl.applications;
          final filteredList = _getFilteredList(allList);

          return Column(
            children: [
              // Filter Segment Bar
              _buildFilterBar(allList),

              // Applications List
              Expanded(
                child: RefreshIndicator(
                  color: _AC.primary,
                  onRefresh: _ctrl.loadApplications,
                  child: filteredList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _AC.primary.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.filter_list_off_rounded,
                                    size: 40,
                                    color: _AC.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'No applications in this category',
                                  style: TextStyle(
                                    color: _AC.darkText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (_, index) =>
                              _ApplicationCard(app: filteredList[index]),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFilterBar(List<dynamic> allList) {
    int pendingCount = 0;
    int acceptedCount = 0;
    int rejectedCount = 0;

    for (var a in allList) {
      final s = (a.status as String? ?? '').toLowerCase();
      if (s == 'pending' || s == 'new' || s == 'under_review' || s == 'applied') {
        pendingCount++;
      } else if (s == 'accepted' || s == 'hired' || s == 'shortlisted' || s == 'approved') {
        acceptedCount++;
      } else if (s == 'rejected' || s == 'declined') {
        rejectedCount++;
      }
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterPill('all', 'All (${allList.length})'),
            const SizedBox(width: 8),
            _buildFilterPill('pending', 'Pending ($pendingCount)'),
            const SizedBox(width: 8),
            _buildFilterPill('accepted', 'Accepted / Hired ($acceptedCount)'),
            const SizedBox(width: 8),
            _buildFilterPill('rejected', 'Rejected ($rejectedCount)'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String filterKey, String label) {
    return Obx(() {
      final active = _selectedFilter.value == filterKey;
      return InkWell(
        onTap: () => _selectedFilter.value = filterKey,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? _AC.primary : _AC.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? _AC.primary : _AC.borderGrey,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _AC.mediumText,
              fontSize: 12,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (ctx, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _AC.borderGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 90,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.shade200,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 12,
                    color: Colors.grey.shade200,
                  ),
                  Container(
                    width: 80,
                    height: 12,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _AC.dangerRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, color: _AC.dangerRed, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Applications',
              style: TextStyle(
                color: _AC.darkText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _AC.greyText, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _ctrl.loadApplications,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AC.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Application Card ─────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final dynamic app;
  const _ApplicationCard({required this.app});

  String get _normalizedStatus {
    final s = (app.status as String? ?? '').toLowerCase().trim();
    if (s == 'accepted' || s == 'hired' || s == 'approved') return 'hired';
    if (s == 'shortlisted') return 'shortlisted';
    if (s == 'rejected' || s == 'declined') return 'rejected';
    return 'pending';
  }

  Color get _statusColor {
    switch (_normalizedStatus) {
      case 'hired':
      case 'shortlisted':
        return _AC.successGreen;
      case 'rejected':
        return _AC.dangerRed;
      default:
        return _AC.warningOrange;
    }
  }

  Color get _statusBg {
    return _statusColor.withValues(alpha: 0.08);
  }

  String get _statusLabel {
    final raw = (app.status as String? ?? 'Pending').trim();
    if (raw.isEmpty) return 'Pending';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  String get _salaryFormatted {
    final raw = double.tryParse(app.expectedSalary?.toString() ?? '') ?? 0;
    if (raw == 0) return 'Not Specified';
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return '₹${formatter.format(raw.toInt())}';
  }

  @override
  Widget build(BuildContext context) {
    final companyName = (app.companyName as String? ?? 'Employer').trim();
    final jobTitle = (app.jobTitle as String? ?? 'Job Position').trim();
    final experience = (app.experience as String? ?? 'Fresher').trim();
    final appliedOn = (app.appliedOn as String? ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _AC.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _AC.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      companyName.isNotEmpty ? companyName[0].toUpperCase() : 'J',
                      style: const TextStyle(
                        color: _AC.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobTitle,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: _AC.darkText,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.business_rounded, size: 13, color: _AC.greyText),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              companyName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _AC.greyText,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel.toUpperCase(),
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _AC.borderGrey),
            const SizedBox(height: 12),
            // Metadata Badges
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: appliedOn.isNotEmpty ? appliedOn : 'Recent',
                  ),
                ),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.work_history_outlined,
                    label: experience,
                  ),
                ),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.currency_rupee_rounded,
                    label: _salaryFormatted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _AC.greyText),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: _AC.mediumText,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: EmptyStateWidget(
          icon: Icons.business_center_rounded,
          title: 'No Applications Yet',
          subtitle: 'Start exploring active job openings and submit applications to track progress here.',
          primaryButtonText: 'Explore Jobs',
          onPrimaryPressed: () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}

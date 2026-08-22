import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_share_plus/open.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../controllers/employer_dashboard_controller.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/job_application_entity.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';

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
  // Premium Enterprise ATS Color Palette
  static const Color primary = Color(0xFF1400FF);
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightGreyText = Color(0xFF94A3B8);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color fieldBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);

  // Status Colors
  static const Color statusGreen = Color(0xFF10B981);
  static const Color statusOrange = Color(0xFFF59E0B);
  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusTeal = Color(0xFF0D9488);
  static const Color statusBlue = Color(0xFF0284C7);

  final EmployerDashboardController controller = Get.find();
  final TextEditingController _searchCtrl = TextEditingController();

  final RxSet<int> _selectedApplicationIds = <int>{}.obs;
  final RxBool _isSelectionMode = false.obs;

  @override
  void initState() {
    super.initState();
    controller.applicantSearchQuery.value = '';
    controller.applicantStatusFilter.value = 'all';
    _searchCtrl.addListener(() {
      controller.applicantSearchQuery.value = _searchCtrl.text;
    });
    controller.fetchApplicationsForJob(widget.jobId);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSelectMode() {
    _isSelectionMode.value = !_isSelectionMode.value;
    if (!_isSelectionMode.value) {
      _selectedApplicationIds.clear();
    }
  }

  void _toggleCandidateSelection(int id) {
    if (_selectedApplicationIds.contains(id)) {
      _selectedApplicationIds.remove(id);
    } else {
      _selectedApplicationIds.add(id);
    }
  }

  void _selectAllFiltered() {
    final filtered = controller.getFilteredApplicants(widget.jobId);
    _selectedApplicationIds.addAll(filtered.map((a) => a.id));
  }

  void _deselectAll() {
    _selectedApplicationIds.clear();
  }

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Call Failed',
        'Could not launch dialer for $phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendEmail(String email, String title) async {
    final url = Uri.parse(
      'mailto:$email?subject=Application for $title on Rozgar Adda',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Mail Failed',
        'Could not open mail client for $email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendWhatsApp(String phone, String name, String title) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final message =
        "Hello $name, this is regarding your application for '$title' on Rozgar Adda. When are you available for an interview?";
    try {
      Open.whatsApp(whatsAppNumber: cleanPhone, text: message);
    } catch (e) {
      Get.snackbar(
        'WhatsApp Unavailable',
        'Could not open WhatsApp on this device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _exportCandidates() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: primary),
        ),
        barrierDismissible: false,
      );

      final filePath = await controller.exportApplications(widget.jobId);
      Get.back(); // Dismiss loading dialog

      if (filePath != null) {
        final totalCount = controller.jobApplications[widget.jobId]?.length ?? 0;
        _showExportSuccessModal(filePath, totalCount);
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Export Failed',
        e is Failure ? e.message : e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _exportSelectedCandidates() async {
    if (_selectedApplicationIds.isEmpty) {
      Get.snackbar(
        'No Selection',
        'Please select at least one candidate application to export.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: primary),
        ),
        barrierDismissible: false,
      );

      final selectedIds = _selectedApplicationIds.toList();
      final filePath = await controller.exportSelectedApplications(
        selectedApplicationIds: selectedIds,
        jobId: widget.jobId,
      );
      Get.back(); // Dismiss loading dialog

      if (filePath != null) {
        final count = selectedIds.length;
        _selectedApplicationIds.clear();
        _isSelectionMode.value = false;
        _showExportSuccessModal(filePath, count);
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Export Failed',
        e is Failure ? e.message : e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showExportSuccessModal(String filePath, int count) {
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
                color: statusGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: statusGreen,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$count Candidate(s) Exported Successfully!',
              style: const TextStyle(
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
                          text: 'Candidate export list for ${widget.jobTitle}',
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
                            text: 'Candidate export list for ${widget.jobTitle}',
                          );
                        }
                      } catch (e) {
                        await Share.shareXFiles(
                          [XFile(filePath)],
                          text: 'Candidate export list for ${widget.jobTitle}',
                        );
                      }
                    },
                    icon: const Icon(Icons.folder_open_rounded, size: 18),
                    label: const Text('Open Excel/CSV'),
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

  String _formatAppliedDate(DateTime? dt) {
    if (dt == null) return 'Recent';
    try {
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) {
        return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      }
      return DateFormat('dd MMM').format(dt);
    } catch (_) {
      return 'Recent';
    }
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
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Get.back(),
              tooltip: 'Back to Dashboard',
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Job Applicants',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                widget.jobTitle,
                style: const TextStyle(
                  color: greyText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            Obx(() {
              final isSelecting = _isSelectionMode.value;
              final filtered = controller.getFilteredApplicants(widget.jobId);
              final isAllSelected = filtered.isNotEmpty &&
                  _selectedApplicationIds.length >= filtered.length;

              if (isSelecting) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (isAllSelected) {
                          _deselectAll();
                        } else {
                          _selectAllFiltered();
                        }
                      },
                      child: Text(
                        isAllSelected ? 'Deselect All' : 'Select All',
                        style: const TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedApplicationIds.isNotEmpty ? statusGreen : primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: _selectedApplicationIds.isNotEmpty
                          ? _exportSelectedCandidates
                          : () {
                              _selectAllFiltered();
                              _exportSelectedCandidates();
                            },
                      icon: const Icon(Icons.file_download_outlined, size: 14),
                      label: Text(
                        _selectedApplicationIds.isNotEmpty
                            ? 'Export (${_selectedApplicationIds.length})'
                            : 'Export All',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Exit Selection Mode',
                      icon: const Icon(Icons.close_rounded, color: darkText, size: 20),
                      onPressed: _toggleSelectMode,
                    ),
                    const SizedBox(width: 4),
                  ],
                );
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: _toggleSelectMode,
                    icon: const Icon(Icons.checklist_rounded, size: 15),
                    label: const Text(
                      'Select',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary.withValues(alpha: 0.25)),
                      backgroundColor: primary.withValues(alpha: 0.05),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(0, 34),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: ElevatedButton.icon(
                      onPressed: _exportCandidates,
                      icon: const Icon(Icons.file_download_outlined, size: 15),
                      label: const Text(
                        'Export All',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(0, 34),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: borderGrey),
          ),
        ),
        body: Column(
          children: [
            // 1. Grid Pipeline Filter Bar (No Slider - 100% on screen)
            Obx(() {
              final List<JobApplication> allApps =
                  controller.jobApplications[widget.jobId] ?? [];
              final stats = controller.jobStats[widget.jobId] ?? {};
              return _buildGridPipelineBar(stats, allApps);
            }),

            // 2. Search Box & Active Filter Indicator
            _buildSearchBoxAndIndicator(),

            // 3. Candidate Applications List
            Expanded(
              child: Obx(() {
                final List<JobApplication> allApps =
                    controller.jobApplications[widget.jobId] ?? [];
                final List<JobApplication> filteredApps =
                    controller.getFilteredApplicants(widget.jobId);
                final hasSelection = _selectedApplicationIds.isNotEmpty;

                if (controller.isJobApplicationsLoading[widget.jobId] == true && allApps.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: primary),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchApplicationsForJob(widget.jobId),
                  color: primary,
                  child: filteredApps.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          children: [
                            _buildEmptyState(),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            hasSelection ? 86 : 24,
                          ),
                          itemCount: filteredApps.length,
                          itemBuilder: (ctx, index) {
                            final app = filteredApps[index];
                            try {
                              return _buildCandidateCard(app);
                            } catch (e, st) {
                              debugPrint('Error building candidate card: $e\n$st');
                              return _buildSimpleCandidateCard(app);
                            }
                          },
                        ),
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: Obx(() {
          final isSelecting = _isSelectionMode.value;
          final hasSelection = _selectedApplicationIds.isNotEmpty;
          if (!isSelecting && !hasSelection) return const SizedBox.shrink();
          return _buildStickyFloatingBottomBar();
        }),
      ),
    );
  }

  Widget _buildStickyFloatingBottomBar() {
    return SafeArea(
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: darkText,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedApplicationIds.isNotEmpty ? primary : Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_selectedApplicationIds.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _selectedApplicationIds.isNotEmpty
                    ? 'Selected'
                    : 'Tap cards or Select All',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (_selectedApplicationIds.isNotEmpty) ...[
                TextButton(
                  onPressed: _deselectAll,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedApplicationIds.isNotEmpty ? statusGreen : primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedApplicationIds.isNotEmpty
                    ? _exportSelectedCandidates
                    : () {
                        _selectAllFiltered();
                        _exportSelectedCandidates();
                      },
                icon: const Icon(Icons.file_download_outlined, size: 15),
                label: Text(
                  _selectedApplicationIds.isNotEmpty
                      ? 'Export Excel (${_selectedApplicationIds.length})'
                      : 'Select & Export All',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
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
  // 1. GRID PIPELINE FILTER BAR (NO SLIDER)
  // ==========================================
  Widget _buildGridPipelineBar(
    Map<String, int> stats,
    List<JobApplication> allApps,
  ) {
    final totalCount = allApps.length;
    final pendingCount = allApps
        .where(
          (a) {
            final s = a.status.toLowerCase();
            return s == 'pending' ||
                s == 'new' ||
                s == 'applied' ||
                s == 'under_review' ||
                s == '0' ||
                s.isEmpty;
          },
        )
        .length;
    final shortlistedCount = allApps
        .where(
          (a) {
            final s = a.status.toLowerCase();
            return s == 'shortlisted' ||
                s == 'accepted' ||
                s == 'shortlist' ||
                s == '1';
          },
        )
        .length;
    final hiredCount = allApps
        .where((a) {
          final s = a.status.toLowerCase();
          return s == 'hired' || s == 'selected';
        })
        .length;
    final rejectedCount = allApps
        .where((a) {
          final s = a.status.toLowerCase();
          return s == 'rejected' || s == 'reject' || s == '2';
        })
        .length;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // 1. All Candidates
          Expanded(
            child: _buildGridStageCard(
              title: 'All',
              count: '$totalCount',
              filterKey: 'all',
              color: primary,
              icon: Icons.people_alt_rounded,
            ),
          ),
          const SizedBox(width: 8),

          // 2. Pending / New
          Expanded(
            child: _buildGridStageCard(
              title: 'Pending',
              count: '$pendingCount',
              filterKey: 'pending',
              color: statusOrange,
              icon: Icons.hourglass_top_rounded,
            ),
          ),
          const SizedBox(width: 8),

          // 3. Shortlisted
          Expanded(
            child: _buildGridStageCard(
              title: 'Shortlist',
              count: '$shortlistedCount',
              filterKey: 'shortlisted',
              color: statusGreen,
              icon: Icons.star_rounded,
            ),
          ),
          const SizedBox(width: 8),

          // 4. Hired
          Expanded(
            child: _buildGridStageCard(
              title: 'Hired',
              count: '$hiredCount',
              filterKey: 'hired',
              color: statusTeal,
              icon: Icons.check_circle_rounded,
            ),
          ),
          const SizedBox(width: 8),

          // 5. Rejected
          Expanded(
            child: _buildGridStageCard(
              title: 'Rejected',
              count: '$rejectedCount',
              filterKey: 'rejected',
              color: statusRed,
              icon: Icons.cancel_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridStageCard({
    required String title,
    required String count,
    required String filterKey,
    required Color color,
    required IconData icon,
  }) {
    final isSelected =
        controller.applicantStatusFilter.value.toLowerCase() ==
        filterKey.toLowerCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.applicantStatusFilter.value = filterKey,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color : fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : borderGrey,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 16,
              ),
              const SizedBox(height: 3),
              Text(
                count,
                style: TextStyle(
                  color: isSelected ? Colors.white : darkText,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : greyText,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. SEARCH BOX & STAGE INDICATOR
  // ==========================================
  Widget _buildSearchBoxAndIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Search Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderGrey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(
                color: darkText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search candidate, skills, education...',
                hintStyle: const TextStyle(color: lightGreyText, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primary,
                  size: 20,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchCtrl,
                  builder: (context, value, _) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: greyText,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              controller.applicantSearchQuery.value = '';
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Count & Status Row
          Obx(() {
            final filtered = controller.getFilteredApplicants(widget.jobId);
            final currentFilter = controller.applicantStatusFilter.value.toUpperCase();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STAGE: $currentFilter',
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${filtered.length} Candidates Found',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 3. CANDIDATE CARD UI
  // ==========================================
  Widget _buildCandidateCard(JobApplication app) {
    Color statusColor = statusOrange;
    String statusTitle = 'PENDING';
    IconData statusIcon = Icons.hourglass_top_rounded;

    final normStatus = app.status.toLowerCase();
    if (normStatus == 'accepted' || normStatus == 'shortlisted') {
      statusColor = statusGreen;
      statusTitle = 'SHORTLISTED';
      statusIcon = Icons.star_rounded;
    } else if (normStatus == 'hired') {
      statusColor = statusTeal;
      statusTitle = 'HIRED';
      statusIcon = Icons.check_circle_rounded;
    } else if (normStatus == 'rejected') {
      statusColor = statusRed;
      statusTitle = 'REJECTED';
      statusIcon = Icons.cancel_rounded;
    } else if (normStatus == 'reviewed') {
      statusColor = statusBlue;
      statusTitle = 'REVIEWED';
      statusIcon = Icons.visibility_rounded;
    }

    final initial = app.candidateName.isNotEmpty
        ? app.candidateName.substring(0, 1).toUpperCase()
        : '?';

    final isSelecting = _isSelectionMode.value;
    final isSelected = _selectedApplicationIds.contains(app.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? primary : borderGrey,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primary.withValues(alpha: 0.08)
                : const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section
              InkWell(
                onLongPress: () {
                  if (!_isSelectionMode.value) {
                    _isSelectionMode.value = true;
                  }
                  _toggleCandidateSelection(app.id);
                },
                onTap: () {
                  if (_isSelectionMode.value) {
                    _toggleCandidateSelection(app.id);
                  } else {
                    _showApplicantDetailsBottomSheet(context, app);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox when multi-select active
                      if (isSelecting)
                        GestureDetector(
                          onTap: () => _toggleCandidateSelection(app.id),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12, top: 12),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected ? primary : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? primary : greyText,
                                width: 1.8,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 14)
                                : null,
                          ),
                        ),

                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withValues(alpha: 0.12),
                              primaryLight.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    app.candidateName.isNotEmpty
                                        ? app.candidateName
                                        : 'Anonymous Candidate',
                                    style: const TextStyle(
                                      color: darkText,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusTitle,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Experience & Education Chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildInfoTag(
                                  icon: Icons.work_outline_rounded,
                                  label:
                                      '${app.experienceYears}y ${app.experienceMonths}m Exp',
                                ),
                                if (app.educationLevel.isNotEmpty)
                                  _buildInfoTag(
                                    icon: Icons.school_outlined,
                                    label: app.educationLevel,
                                  ),
                                _buildInfoTag(
                                  icon: Icons.calendar_today_rounded,
                                  label: _formatAppliedDate(app.appliedAt),
                                ),
                              ],
                            ),

                            // Skills Row
                            if (app.keySkills.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 5,
                                runSpacing: 4,
                                children: app.keySkills
                                    .split(',')
                                    .take(3)
                                    .map((s) => s.trim())
                                    .where((s) => s.isNotEmpty)
                                    .map(
                                      (skill) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: fieldBg,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: borderGrey),
                                        ),
                                        child: Text(
                                          skill,
                                          style: const TextStyle(
                                            color: mediumText,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
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

              // Bottom Action Bar (Call, WhatsApp, Email, Update Status)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: const Color(0xFFFAFBFC),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Call Action
                      _buildActionButton(
                        icon: Icons.phone_in_talk_rounded,
                        label: 'Call',
                        color: statusGreen,
                        onTap: () => _makeCall(app.phone),
                      ),
                      const SizedBox(width: 8),

                      // WhatsApp Action
                      _buildActionButton(
                        icon: Icons.chat_bubble_rounded,
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        onTap: () => _sendWhatsApp(
                          app.phone,
                          app.candidateName,
                          widget.jobTitle,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Mail Action
                      _buildActionButton(
                        icon: Icons.mail_rounded,
                        label: 'Email',
                        color: statusRed,
                        onTap: () => _sendEmail(app.email, widget.jobTitle),
                      ),

                      const SizedBox(width: 12),

                      // Update Status Button
                      ElevatedButton.icon(
                        onPressed: () => _showStatusUpdateDialog(context, app),
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: const Text('Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildSimpleCandidateCard(JobApplication app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primary.withValues(alpha: 0.1),
            child: Text(
              app.candidateName.isNotEmpty ? app.candidateName[0].toUpperCase() : 'C',
              style: const TextStyle(color: primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.candidateName.isNotEmpty ? app.candidateName : 'Candidate',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  app.phone.isNotEmpty ? app.phone : app.email,
                  style: const TextStyle(color: greyText, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
            onPressed: () => _showApplicantDetailsBottomSheet(context, app),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: greyText),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: greyText,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. APPLICANT FULL DETAILS BOTTOM SHEET
  // ==========================================
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: FutureBuilder<JobApplication?>(
          future: controller.getApplicationDetails(initialApp.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 320,
                child: Center(
                  child: CircularProgressIndicator(color: primary),
                ),
              );
            }

            final app = snapshot.data ?? initialApp;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
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

                  // Header with candidate avatar & name
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primary, primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            app.candidateName.isNotEmpty
                                ? app.candidateName.substring(0, 1).toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.candidateName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: darkText,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Applied for: ${widget.jobTitle}',
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: borderGrey, height: 1),
                  const SizedBox(height: 16),

                  // Direct Contact Actions Bar
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makeCall(app.phone),
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _sendWhatsApp(
                            app.phone,
                            app.candidateName,
                            widget.jobTitle,
                          ),
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _sendEmail(app.email, widget.jobTitle),
                          icon: const Icon(Icons.mail_rounded, size: 16),
                          label: const Text('Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Information Cards
                  _buildDetailRow(
                    Icons.phone_android_rounded,
                    'Phone Number',
                    app.phone,
                  ),
                  _buildDetailRow(
                    Icons.email_rounded,
                    'Email Address',
                    app.email,
                  ),
                  _buildDetailRow(
                    Icons.school_rounded,
                    'Education',
                    '${app.educationLevel} (${app.educationDetails})',
                  ),
                  _buildDetailRow(
                    Icons.work_rounded,
                    'Total Experience',
                    '${app.experienceYears} Years ${app.experienceMonths} Months',
                  ),
                  _buildDetailRow(
                    Icons.currency_rupee_rounded,
                    'Expected Salary',
                    app.expectedSalary.isNotEmpty
                        ? '₹${AvailableJob.formatAmount(app.expectedSalary)} / month'
                        : 'Negotiable / Not specified',
                  ),
                  _buildDetailRow(
                    Icons.timer_rounded,
                    'Notice Period',
                    app.noticePeriod.isNotEmpty
                        ? app.noticePeriod
                        : 'Immediate Joiner',
                  ),
                  _buildDetailRow(
                    Icons.star_rounded,
                    'Skills & Competencies',
                    app.keySkills,
                  ),

                  if (app.resumePath.isNotEmpty)
                    _buildDetailRow(
                      Icons.description_rounded,
                      'Uploaded Resume',
                      app.resumePath.split('/').last,
                    ),

                  const SizedBox(height: 16),

                  // Status Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showStatusUpdateDialog(context, app);
                      },
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text(
                        'Change Application Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: greyText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not specified' : value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. STATUS UPDATE BOTTOM SHEET
  // ==========================================
  void _showStatusUpdateDialog(BuildContext context, JobApplication app) {
    final selectedStatus = app.status.toLowerCase().obs;
    final commentsCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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

              Row(
                children: [
                  const Text(
                    'Update Candidate Status',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: darkText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: greyText),
                    onPressed: () => Get.back(),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text(
                'Select New Pipeline Stage:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: mediumText,
                ),
              ),
              const SizedBox(height: 8),

              Obx(
                () => Column(
                  children: [
                    _buildStatusOption(
                      title: 'Shortlisted for Interview',
                      subtitle: 'Candidate meets criteria and moves forward',
                      statusVal: 'shortlisted',
                      selectedVal: selectedStatus.value,
                      color: statusGreen,
                      icon: Icons.star_rounded,
                      onTap: () => selectedStatus.value = 'shortlisted',
                    ),
                    _buildStatusOption(
                      title: 'Hired & Selected',
                      subtitle: 'Candidate accepted job offer',
                      statusVal: 'hired',
                      selectedVal: selectedStatus.value,
                      color: statusTeal,
                      icon: Icons.check_circle_rounded,
                      onTap: () => selectedStatus.value = 'hired',
                    ),
                    _buildStatusOption(
                      title: 'Under Review',
                      subtitle: 'Profile currently being evaluated',
                      statusVal: 'reviewed',
                      selectedVal: selectedStatus.value,
                      color: statusBlue,
                      icon: Icons.visibility_rounded,
                      onTap: () => selectedStatus.value = 'reviewed',
                    ),
                    _buildStatusOption(
                      title: 'Rejected',
                      subtitle: 'Candidate not suitable for this position',
                      statusVal: 'rejected',
                      selectedVal: selectedStatus.value,
                      color: statusRed,
                      icon: Icons.cancel_rounded,
                      onTap: () => selectedStatus.value = 'rejected',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const Text(
                'Internal Notes / Comments (Optional):',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: mediumText,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderGrey),
                ),
                child: TextField(
                  controller: commentsCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: darkText, fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Cleared 1st technical round, good communication',
                    hintStyle: TextStyle(color: lightGreyText, fontSize: 12.5),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await controller.updateApplicationStatus(
                      widget.jobId,
                      app.id,
                      selectedStatus.value,
                      comments: commentsCtrl.text.trim(),
                    );
                    Get.snackbar(
                      'Status Updated',
                      'Candidate status set to ${selectedStatus.value.toUpperCase()}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: statusGreen,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                  child: const Text(
                    'Confirm Status Update',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildStatusOption({
    required String title,
    required String subtitle,
    required String statusVal,
    required String selectedVal,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSelected = statusVal == selectedVal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : borderGrey,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : borderGrey,
                ),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isSelected ? color : darkText,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: greyText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 6. EMPTY STATE
  // ==========================================
  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.people_outline_rounded,
      title: 'No Candidates Found',
      subtitle:
          'No candidate applications match your selected stage or search keywords.',
      primaryButtonText: 'Reset Filters',
      onPrimaryPressed: () {
        _searchCtrl.clear();
        controller.applicantSearchQuery.value = '';
        controller.applicantStatusFilter.value = 'all';
      },
    );
  }
}

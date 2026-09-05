import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:rojgar/core/widgets/fast_loader.dart';
import 'package:rojgar/core/widgets/network_image_service.dart';
import 'package:rojgar/features/jobs/domain/entities/available_job_entity.dart';
import 'package:rojgar/features/jobs/domain/repository/jobs_repository.dart';
import 'package:rojgar/features/jobs/presentation/bindings/jobs_binding.dart';
import 'package:rojgar/features/jobs/presentation/controller/jobs_controller.dart';
import 'package:rojgar/features/jobs/presentation/screens/job_detail.dart';
import 'package:rojgar/core/services/meta_analytics_service.dart';
import 'package:rojgar/localization/app_localizations.dart';

class _C {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color fieldBg = Color(0xFFF8FAFC);
}

class CareerHubScreen extends StatefulWidget {
  const CareerHubScreen({super.key});

  @override
  State<CareerHubScreen> createState() => _CareerHubScreenState();
}

class _CareerHubScreenState extends State<CareerHubScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final JobsController _jobsController;

  bool _isLoading = true;
  String? _errorMessage;
  List<AvailableJob> _allJobs = [];
  final Set<int> _bookmarkedJobIds = <int>{};

  int _selectedTab = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<JobsController>()) {
      JobsBinding().dependencies();
    }
    _jobsController = Get.find<JobsController>();

    _loadJobs();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_jobsController.categories.isEmpty) {
        await _jobsController.fetchCategories();
      }
      final repository = Get.find<JobsRepository>();
      final result = await repository.getLatestJobs();
      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = failure.message;
              _allJobs = [];
            });
          }
        },
        (jobs) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = null;
              _allJobs = jobs;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          _allJobs = [];
        });
      }
    }
  }

  List<String> _getTabs() {
    final defaultTabs = ['All Jobs', 'Remote', 'Full-Time', 'Part-Time'];
    final categoryNames = _jobsController.categories
        .map((c) => c.name.trim())
        .where((name) => name.isNotEmpty)
        .take(5)
        .toList();

    return [...defaultTabs, ...categoryNames];
  }

  String _getJobImageUrl(AvailableJob job) {
    try {
      final category = _jobsController.categories.firstWhereOrNull(
        (c) => c.id == job.categoryId,
      );
      if (category != null && category.imageUrl.trim().isNotEmpty) {
        return category.imageUrl.trim();
      }
    } catch (_) {}
    return '';
  }

  String _getJobCategoryName(AvailableJob job) {
    try {
      final category = _jobsController.categories.firstWhereOrNull(
        (c) => c.id == job.categoryId,
      );
      if (category != null && category.name.trim().isNotEmpty) {
        return category.name.trim();
      }
    } catch (_) {}
    return '';
  }

  String _formatPostedAgo(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
  }

  List<AvailableJob> get _filteredJobs {
    final tabs = _getTabs();
    final selectedTabName = _selectedTab < tabs.length ? tabs[_selectedTab] : 'All Jobs';

    return _allJobs.where((job) {
      // Tab filtering
      if (selectedTabName == 'Remote') {
        final isRemote = job.workLocationType.toLowerCase().contains('remote') ||
            job.jobType.toLowerCase().contains('remote') ||
            job.stateName.toLowerCase().contains('remote') ||
            job.addressLine1.toLowerCase().contains('remote');
        if (!isRemote) return false;
      } else if (selectedTabName == 'Full-Time') {
        if (!job.jobType.toLowerCase().contains('full')) {
          return false;
        }
      } else if (selectedTabName == 'Part-Time') {
        if (!job.jobType.toLowerCase().contains('part')) {
          return false;
        }
      } else if (selectedTabName != 'All Jobs') {
        // Category tab filter
        final matchedCategory = _jobsController.categories.firstWhereOrNull(
          (c) => c.name.toLowerCase().trim() == selectedTabName.toLowerCase().trim(),
        );
        if (matchedCategory != null && job.categoryId != matchedCategory.id) {
          return false;
        }
      }

      // Search query filtering
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = job.title.toLowerCase().contains(q);
        final matchState = job.stateName.toLowerCase().contains(q);
        final matchAddress = job.addressLine1.toLowerCase().contains(q);
        final matchType = job.jobTypeLabel.toLowerCase().contains(q);
        final matchCategory = _getJobCategoryName(job).toLowerCase().contains(q);
        final matchSkills = job.skills.any((s) => s.toLowerCase().contains(q));

        return matchTitle || matchState || matchAddress || matchType || matchCategory || matchSkills;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayedJobs = _filteredJobs;
    final tabs = _getTabs();

    if (_selectedTab >= tabs.length) {
      _selectedTab = 0;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _C.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Get.back(),
              tooltip: 'Back',
            ),
          ),
          title: Text(
            l10n.text('careerhub_title').isNotEmpty ? l10n.text('careerhub_title') : 'Career Hub',
            style: const TextStyle(
              color: _C.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded, color: _C.darkText, size: 22),
              onPressed: _loadJobs,
            ),
            IconButton(
              tooltip: 'Clear Filters',
              icon: const Icon(Icons.tune_rounded, color: _C.darkText, size: 22),
              onPressed: () {
                _searchCtrl.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedTab = 0;
                });
              },
            ),
            const SizedBox(width: 4),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _C.borderGrey),
          ),
        ),
        body: Column(
          children: [
            // ── Search & Filter Section ──────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                children: [
                  // Search Input
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _C.fieldBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _C.borderGrey, width: 1),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v.trim()),
                      onSubmitted: (v) {
                        if (v.trim().isNotEmpty) {
                          MetaAnalyticsService.instance.logSearch(query: v.trim(), contentType: 'jobs');
                        }
                      },
                      style: const TextStyle(
                        color: _C.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.text('careerhub_search_hint').isNotEmpty
                            ? l10n.text('careerhub_search_hint')
                            : 'Search roles, skills, locations...',
                        hintStyle: const TextStyle(color: _C.greyText, fontSize: 13.5),
                        prefixIcon: const Icon(Icons.search_rounded, color: _C.primary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: _C.greyText, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Pills
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tabs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final isActive = i == _selectedTab;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTab = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive ? _C.primary : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? _C.primary : _C.borderGrey,
                              ),
                            ),
                            child: Text(
                              tabs[i],
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                color: isActive ? Colors.white : _C.mediumText,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _C.borderGrey),

            // ── Jobs List ────────────────────────────────────────────
            Expanded(
              child: _buildContent(displayedJobs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<AvailableJob> displayedJobs) {
    if (_isLoading) {
      return const FastListSkeleton(itemCount: 6, cardHeight: 150.0);
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _C.darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _loadJobs,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    if (displayedJobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadJobs,
        color: _C.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1400FF).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.work_off_outlined, color: _C.primary, size: 40),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No jobs matching your filter',
                    style: TextStyle(
                      color: _C.darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Try changing your search term or category filters',
                    style: TextStyle(color: _C.greyText, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.primary,
                      side: const BorderSide(color: _C.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedTab = 0;
                      });
                    },
                    child: const Text('Reset All Filters', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: _C.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        itemCount: displayedJobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final job = displayedJobs[i];
          return _buildJobCard(context, job);
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, AvailableJob job) {
    final imageUrl = _getJobImageUrl(job);
    final categoryName = _getJobCategoryName(job);
    final isBookmarked = _bookmarkedJobIds.contains(job.id);
    final postedAgo = _formatPostedAgo(job.createdAt);
    final locationText = job.stateName.isNotEmpty
        ? (job.addressLine1.isNotEmpty ? '${job.addressLine1}, ${job.stateName}' : job.stateName)
        : (job.addressLine1.isNotEmpty ? job.addressLine1 : 'India');

    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(
                  job: job,
                  imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: company logo + title + bookmark
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company / Job Image Thumbnail
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _C.borderGrey,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: imageUrl.isNotEmpty
                            ? NetworkImageService(
                                imageUrl: imageUrl,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  color: const Color(0xFFEEF2FF),
                                  padding: const EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/icons/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.work_outline_rounded,
                                      color: _C.primary,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFEEF2FF),
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/icons/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.work_outline_rounded,
                                    color: _C.primary,
                                    size: 26,
                                  ),
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
                            job.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: _C.darkText,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            job.contactPerson != null && job.contactPerson!.trim().isNotEmpty
                                ? job.contactPerson!.trim()
                                : (categoryName.isNotEmpty ? categoryName : 'Rozgar verified vacancy'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: _C.greyText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isBookmarked) {
                            _bookmarkedJobIds.remove(job.id);
                          } else {
                            _bookmarkedJobIds.add(job.id);
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              !isBookmarked ? 'Job Saved to Bookmarks' : 'Removed from Bookmarks',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isBookmarked ? _C.primary : _C.greyText,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location & Posted row
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: _C.greyText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        locationText,
                        style: const TextStyle(color: _C.greyText, fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time_rounded, size: 14, color: _C.greyText),
                    const SizedBox(width: 4),
                    Text(
                      postedAgo,
                      style: const TextStyle(color: _C.greyText, fontSize: 12.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pills: Type, Experience, Salary
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildPill(job.jobTypeLabel, isHighlight: true),
                    if (job.experienceLevel.isNotEmpty)
                      _buildPill(job.experienceLabel, isHighlight: false),
                    _buildPill(job.salaryDisplay, isHighlight: false, isSalary: true),
                  ],
                ),
                const SizedBox(height: 14),

                const Divider(height: 1, color: _C.borderGrey),
                const SizedBox(height: 12),

                // Bottom row: View Details & Apply
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tap for details & requirements',
                      style: TextStyle(fontSize: 11.5, color: _C.greyText),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _C.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Apply Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                        ],
                      ),
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

  Widget _buildPill(String label, {bool isHighlight = false, bool isSalary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFF1400FF).withValues(alpha: 0.08)
            : (isSalary ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight
              ? const Color(0xFF1400FF).withValues(alpha: 0.2)
              : (isSalary ? const Color(0xFF86EFAC) : _C.borderGrey),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isHighlight
              ? _C.primary
              : (isSalary ? const Color(0xFF15803D) : _C.mediumText),
        ),
      ),
    );
  }
}

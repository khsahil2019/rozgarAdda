import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:rojgar/features/jobs/presentation/screens/job_detail.dart';
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

class JobListingItem {
  final int id;
  final Color logoColor;
  final String title;
  final String company;
  final String location;
  final String jobType;
  final String salary;
  final String experience;
  final String category;
  final String postedAgo;
  bool bookmarked;

  JobListingItem({
    required this.id,
    required this.logoColor,
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
    required this.salary,
    required this.experience,
    required this.category,
    required this.postedAgo,
    this.bookmarked = false,
  });
}

class CareerHubScreen extends StatefulWidget {
  const CareerHubScreen({super.key});

  @override
  State<CareerHubScreen> createState() => _CareerHubScreenState();
}

class _CareerHubScreenState extends State<CareerHubScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedTab = 0;
  String _searchQuery = '';

  final List<String> _tabs = [
    'All Jobs',
    'Remote',
    'Full-Time',
    'High Salary',
    'Engineering',
    'Sales',
  ];

  final List<JobListingItem> _allJobs = [
    JobListingItem(
      id: 101,
      logoColor: const Color(0xFF1400FF),
      title: 'Senior Flutter Developer',
      company: 'TechMatrix Solutions',
      location: 'Bangalore / Remote',
      jobType: 'Full-Time',
      salary: '₹ 80,000 - ₹ 1,20,000 / mo',
      experience: '3-5 yrs',
      category: 'Engineering',
      postedAgo: 'Just now',
      bookmarked: false,
    ),
    JobListingItem(
      id: 102,
      logoColor: const Color(0xFF10B981),
      title: 'Digital Marketing Specialist',
      company: 'GrowthPulse Agency',
      location: 'Mumbai, MH',
      jobType: 'Full-Time',
      salary: '₹ 45,000 - ₹ 65,000 / mo',
      experience: '2-4 yrs',
      category: 'Sales',
      postedAgo: '2 hours ago',
      bookmarked: true,
    ),
    JobListingItem(
      id: 103,
      logoColor: const Color(0xFFF59E0B),
      title: 'UI/UX Product Designer',
      company: 'Creative Labs India',
      location: 'Remote',
      jobType: 'Remote',
      salary: '₹ 60,000 - ₹ 90,000 / mo',
      experience: '2-5 yrs',
      category: 'Engineering',
      postedAgo: '1 day ago',
      bookmarked: false,
    ),
    JobListingItem(
      id: 104,
      logoColor: const Color(0xFF6366F1),
      title: 'Operations & Branch Manager',
      company: 'Apex Logistics Hub',
      location: 'Pune, MH',
      jobType: 'Full-Time',
      salary: '₹ 50,000 - ₹ 75,000 / mo',
      experience: '4-7 yrs',
      category: 'Sales',
      postedAgo: '2 days ago',
      bookmarked: false,
    ),
    JobListingItem(
      id: 105,
      logoColor: const Color(0xFF0EA5E9),
      title: 'Backend Python Architect',
      company: 'CloudNext Systems',
      location: 'Hyderabad, TS',
      jobType: 'Remote',
      salary: '₹ 1,10,000 - ₹ 1,60,000 / mo',
      experience: '5+ yrs',
      category: 'Engineering',
      postedAgo: '3 days ago',
      bookmarked: false,
    ),
    JobListingItem(
      id: 106,
      logoColor: const Color(0xFFEC4899),
      title: 'Business Development Executive',
      company: 'Rozgar Enterprise Solutions',
      location: 'Delhi NCR',
      jobType: 'Full-Time',
      salary: '₹ 35,000 - ₹ 55,000 / mo',
      experience: '1-3 yrs',
      category: 'Sales',
      postedAgo: '4 days ago',
      bookmarked: false,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<JobListingItem> get _filteredJobs {
    return _allJobs.where((job) {
      // Tab filtering
      if (_selectedTab == 1 && !job.jobType.toLowerCase().contains('remote') && !job.location.toLowerCase().contains('remote')) {
        return false;
      }
      if (_selectedTab == 2 && !job.jobType.toLowerCase().contains('full-time')) {
        return false;
      }
      if (_selectedTab == 3 && !job.salary.contains('80,000') && !job.salary.contains('1,10,000') && !job.salary.contains('60,000')) {
        return false;
      }
      if (_selectedTab == 4 && job.category != 'Engineering') {
        return false;
      }
      if (_selectedTab == 5 && job.category != 'Sales') {
        return false;
      }

      // Search query filtering
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = job.title.toLowerCase().contains(q);
        final matchCompany = job.company.toLowerCase().contains(q);
        final matchLocation = job.location.toLowerCase().contains(q);
        final matchCategory = job.category.toLowerCase().contains(q);
        return matchTitle || matchCompany || matchLocation || matchCategory;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayedJobs = _filteredJobs;

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
              tooltip: 'Search Jobs',
              icon: const Icon(Icons.tune_rounded, color: _C.darkText, size: 22),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
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
                      style: const TextStyle(
                        color: _C.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.text('careerhub_search_hint').isNotEmpty
                            ? l10n.text('careerhub_search_hint')
                            : 'Search roles, skills, companies...',
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
                      itemCount: _tabs.length,
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
                              _tabs[i],
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
              child: displayedJobs.isEmpty
                  ? Center(
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
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                      itemCount: displayedJobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final job = displayedJobs[i];
                        return _buildJobCard(context, job);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobListingItem job) {
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
                builder: (context) => JobDetailScreen.placeholder(
                  jobId: job.id,
                  jobTitle: job.title,
                  company: job.company,
                  location: job.location,
                  salary: job.salary,
                  jobType: job.jobType,
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
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: job.logoColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: job.logoColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          job.company.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: job.logoColor,
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
                            job.company,
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
                          job.bookmarked = !job.bookmarked;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              job.bookmarked ? 'Job Saved to Bookmarks' : 'Removed from Bookmarks',
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
                          job.bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: job.bookmarked ? _C.primary : _C.greyText,
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
                    Text(
                      job.location,
                      style: const TextStyle(color: _C.greyText, fontSize: 12.5),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time_rounded, size: 14, color: _C.greyText),
                    const SizedBox(width: 4),
                    Text(
                      job.postedAgo,
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
                    _buildPill(job.jobType, isHighlight: true),
                    _buildPill(job.experience, isHighlight: false),
                    _buildPill(job.salary, isHighlight: false, isSalary: true),
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

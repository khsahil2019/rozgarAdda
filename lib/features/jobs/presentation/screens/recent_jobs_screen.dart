import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';
import 'package:open_share_plus/open.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rojgar/core/widgets/network_image_service.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/features/jobs/domain/entities/available_job_entity.dart';
import 'package:rojgar/features/jobs/domain/entities/job_category.dart';
import 'package:rojgar/features/jobs/domain/repository/jobs_repository.dart';
import 'package:rojgar/features/jobs/presentation/controller/jobs_controller.dart';
import 'package:rojgar/features/jobs/presentation/screens/job_detail.dart';
import 'package:rojgar/features/jobs/presentation/widgets/job_card_widget.dart';

enum _FilterSection {
  category,
  jobType,
  salary,
  education,
  experience,
  freshness,
  location,
}

class _Colors {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF17181C);
  static const Color grey = Color(0xFF72757F);
  static const Color lightGrey = Color(0xFF9AA0AA);
  static const Color borderGrey = Color(0xFFD7DADF);
  static const Color scaffoldBg = Color(0xFFF4F5F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color chipBg = Color(0xFFF7F8FB);
  static const Color chipText = Color(0xFF1E2228);
  static const Color chipAccent = Color(0xFFEAF2FF);
  static const Color green = Color(0xFF2E7D32);
  static const Color yellow = Color(0xFFFFC107);
  static const Color yellowFilter = Color(0xFFFFC400);
  static const Color red = Color(0xFFE84E5F);
}

class RecentJobsScreen extends StatefulWidget {
  const RecentJobsScreen({super.key});

  @override
  State<RecentJobsScreen> createState() => _RecentJobsScreenState();
}

class _RecentJobsScreenState extends State<RecentJobsScreen> {
  late final PageController _pageController;
  final TextEditingController _searchController = TextEditingController();
  late final JobsController _jobsController;

  bool _isLoading = true;
  String? _errorMessage;
  List<AvailableJob> _recentJobs = [];
  List<AvailableJob> _filteredJobs = [];

  double _currentPage = 0.0;
  String _searchQuery = '';
  int _selectedTabIndex = 0;
  Timer? _autoSlideTimer;

  // Index-based filter state (matching available_jobs_screen.dart)
  int _selectedCategoryIndex = 0; // 0 = All Categories
  int _selectedJobTypeIndex = 0;
  int _selectedSalaryIndex = 0;
  int _selectedEducationIndex = 0;
  int _selectedExperienceIndex = 0;
  int _selectedFreshnessIndex = 0;
  int? _filterStateId;
  int? _filterDistrictId;
  int? _filterLocalityId;
  String? _filterStateName;
  String? _filterDistrictName;
  String? _filterLocalityName;

  static const List<String> _jobTypeOptions = [
    'Any',
    'Full-time',
    'Part-time',
    'Contract',
    'Work From Home',
  ];

  static const List<String> _salaryOptions = [
    'Salary Range',
    '₹10k - ₹15k',
    '₹15k - ₹18k',
    '₹18k - ₹25k',
  ];

  static const List<String> _educationOptions = [
    'Education',
    '10th Pass',
    '12th Pass',
    'Graduate',
    'Post Graduate',
    'Other',
  ];

  static const List<String> _experienceOptions = [
    'Work Experience',
    'Fresher',
    '1-2 Years',
    '3-5 Years',
    '5+ Years',
  ];

  static const List<String> _freshnessOptions = [
    'Freshness',
    'Last 4 days',
    'Last 7 days',
    'Last 14 days',
    'Last 30 days',
  ];



  String _getJobImageUrl(AvailableJob job) {
    switch (job.id) {
      case 101:
        return 'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=150';
      case 102:
        return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=150';
      case 103:
        return 'https://images.unsplash.com/photo-1534536281715-e28d76689b4d?w=150';
      case 104:
        return 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150';
      case 105:
        return 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=150';
      case 106:
        return 'https://images.unsplash.com/photo-1549923746-c502d488f3aa?w=150';
      default:
        return 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=150';
    }
  }

  @override
  void initState() {
    super.initState();
    _jobsController = Get.find<JobsController>();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _filterJobs();
      });
    });

    _loadRecentJobs();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final itemCount = _recentJobs.take(5).length;
      if (itemCount <= 1) return;
      final nextPage = _currentPage.round() + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentJobs({
    int? stateId,
    int? districtId,
    int? localityId,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recentJobs.clear();
      _filteredJobs.clear();
    });

    try {
      final repository = Get.find<JobsRepository>();
      final result = await repository.getLatestJobs(
        stateId: stateId,
        districtId: districtId,
        localityId: localityId,
      );
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (jobs) {
          setState(() {
            _isLoading = false;
            _recentJobs = jobs;
            _filterJobs();
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ── Salary / Experience / Freshness helpers ──────────────────────────────
  double? _parseSalary(String? value) {
    if (value == null) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  bool _matchSalary(AvailableJob job, int index) {
    double minLimit = 0;
    double maxLimit = 999999999;
    if (index == 1) {
      minLimit = 10000;
      maxLimit = 15000;
    } else if (index == 2) {
      minLimit = 15000;
      maxLimit = 18000;
    } else if (index == 3) {
      minLimit = 18000;
      maxLimit = 25000;
    } else {
      return true;
    }
    if (job.fixedSalary != null && job.fixedSalary!.isNotEmpty) {
      final fs = _parseSalary(job.fixedSalary);
      if (fs != null) return fs >= minLimit && fs <= maxLimit;
    }
    final minS = _parseSalary(job.minSalary);
    final maxS = _parseSalary(job.maxSalary);
    if (minS != null && maxS != null)
      return !(maxS < minLimit || minS > maxLimit);
    if (minS != null) return minS <= maxLimit;
    return false;
  }

  int? _parseExp(String value) {
    if (value.toLowerCase() == 'fresher') return 0;
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  bool _matchExperience(AvailableJob job, int index) {
    final expVal = _parseExp(job.experienceLevel);
    if (expVal == null) return true;
    if (index == 1) return expVal == 0;
    if (index == 2) return expVal >= 1 && expVal <= 2;
    if (index == 3) return expVal >= 3 && expVal <= 5;
    if (index == 4) return expVal >= 5;
    return true;
  }

  bool _matchFreshness(AvailableJob job, int index) {
    final diff = DateTime.now().difference(job.createdAt).inDays;
    if (index == 1) return diff <= 4;
    if (index == 2) return diff <= 7;
    if (index == 3) return diff <= 14;
    if (index == 4) return diff <= 30;
    return true;
  }

  void _filterJobs() {
    final query = _searchQuery.toLowerCase().trim();
    final categories = _jobsController.categories;
    _filteredJobs = _recentJobs.where((job) {
      // 1. Search Query filter
      final matchesSearch =
          query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.stateName.toLowerCase().contains(query) ||
          job.addressLine1.toLowerCase().contains(query) ||
          job.jobTypeLabel.toLowerCase().contains(query);
      if (!matchesSearch) return false;

      // 2. Category filter
      if (_selectedCategoryIndex != 0 && categories.isNotEmpty) {
        final catIdx = _selectedCategoryIndex - 1; // -1 because index 0 = All
        if (catIdx >= 0 && catIdx < categories.length) {
          if (job.categoryId != categories[catIdx].id) return false;
        }
      }

      // 3. Job Type filter
      if (_selectedJobTypeIndex != 0) {
        final selectedType = _jobTypeOptions[_selectedJobTypeIndex]
            .toLowerCase();
        final typeString = selectedType
            .replaceAll('-', '_')
            .replaceAll(' ', '_');
        if (job.jobType.toLowerCase() != typeString) return false;
      }

      // 3. Salary filter
      if (_selectedSalaryIndex != 0) {
        if (!_matchSalary(job, _selectedSalaryIndex)) return false;
      }

      // 4. Education filter
      if (_selectedEducationIndex != 0) {
        final selectedEdu = _educationOptions[_selectedEducationIndex]
            .toLowerCase();
        if (!job.educationLevel.toLowerCase().contains(selectedEdu)) {
          return false;
        }
      }

      // 5. Experience filter
      if (_selectedExperienceIndex != 0) {
        if (!_matchExperience(job, _selectedExperienceIndex)) return false;
      }

      // 6. Freshness filter
      if (_selectedFreshnessIndex != 0) {
        if (!_matchFreshness(job, _selectedFreshnessIndex)) return false;
      }



      return true;
    }).toList();
  }

  String _getTab1Label(String lang) {
    if (lang == 'mr') return 'जॉब सर्च करा';
    if (lang == 'hi') return 'जॉब सर्च करें';
    return 'Find Jobs';
  }

  String _getTab2Label(String lang) {
    if (lang == 'mr') return 'माझा जॉब प्रोफाईल';
    if (lang == 'hi') return 'मेरा जॉब प्रोफाइल';
    return 'My Profile';
  }

  String _getPostJobLabel(String lang) {
    return '+ Post a job';
  }

  String _getSeeAllLabel(String lang) {
    if (lang == 'mr') return 'सर्व पहा';
    if (lang == 'hi') return 'सभी देखें';
    return 'See All';
  }

  String _getSponsorLabel(String lang) {
    if (lang == 'mr') return 'स्पॉन्सर जॉब्स';
    if (lang == 'hi') return 'प्रायोजित जॉब्स';
    return 'Sponsor Jobs';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _Colors.scaffoldBg,
      appBar: AppBar(
        bottomOpacity: 0,
        title: Text(
          l10n.locale.languageCode == 'mr'
              ? 'नोकऱ्या'
              : l10n.text('recent_jobs_title'),
          style: const TextStyle(
            color: _Colors.darkText,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),

        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _Colors.darkText),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
        //     child: ElevatedButton.icon(
        //       onPressed: () {
        //         Get.snackbar(
        //           'Post a Job',
        //           'Post a job functionality coming soon!',
        //           snackPosition: SnackPosition.BOTTOM,
        //         );
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: _Colors.yellow,
        //         foregroundColor: _Colors.darkText,
        //         elevation: 0,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(10),
        //         ),
        //         padding: const EdgeInsets.symmetric(horizontal: 12),
        //       ),
        //       icon: const Icon(Icons.add, size: 16, color: _Colors.darkText),
        //       label: Text(
        //         _getPostJobLabel(l10n.locale.languageCode),
        //         style: const TextStyle(
        //           fontWeight: FontWeight.w800,
        //           fontSize: 14,
        //           color: _Colors.darkText,
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(48),
        //   child: _buildCustomTabBar(l10n),
        // ),
      ),
      body: SafeArea(child: _buildBody(size, l10n)),
    );
  }

  Widget _buildBody(Size size, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _Colors.primaryBlue),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(l10n);
    }

    if (_recentJobs.isEmpty) {
      return _buildEmptyState(l10n);
    }

    if (_selectedTabIndex == 1) {
      return _buildProfileView(l10n);
    }

    return CustomScrollView(
      slivers: [
        // Filters Section Header (No search field to match screenshots)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: _buildFilterChips(l10n),
          ),
        ),

        // Horizontal Slider Section (Snapping cards)
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getSponsorLabel(l10n.locale.languageCode),
                      style: const TextStyle(
                        color: _Colors.darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          Text(
                            _getSeeAllLabel(l10n.locale.languageCode),
                            style: const TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Color(0xFF007AFF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const ForwardOnlyScrollPhysics(),
                  itemBuilder: (context, index) {
                    final itemCount = _recentJobs.take(5).length;
                    if (itemCount == 0) return const SizedBox.shrink();
                    final job = _recentJobs[index % itemCount];
                    return _buildSliderCard(job, index);
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildPageIndicator(),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // All Recent Openings title header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'All Recent Openings (${_filteredJobs.length})',
                  style: const TextStyle(
                    color: _Colors.darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Vertical List Section
        _filteredJobs.isEmpty
            ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 54,
                          color: _Colors.grey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No jobs match your search',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final isBanner = (index + 1) % 4 == 0;
                      if (isBanner) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Image.asset(
                            'assets/icons/warning.png',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        );
                      }
                      final jobIndex = index - (index ~/ 4);
                      final job = _filteredJobs[jobIndex];
                      return _buildVerticalJobCard(job, l10n);
                    },
                    childCount: _filteredJobs.isEmpty
                        ? 0
                        : _filteredJobs.length + (_filteredJobs.length - 1) ~/ 3,
                  ),
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  String _getLocalizedJobType(String type, String lang) {
    if (lang == 'mr') {
      switch (type) {
        case 'full_time':
          return 'फूल टाइम';
        case 'part_time':
          return 'पार्ट टाइम';
        case 'contract':
          return 'कॉन्ट्रॅक्ट';
        case 'internship':
          return 'इंटर्नशिप';
        default:
          return 'फूल टाइम';
      }
    }
    switch (type) {
      case 'full_time':
        return 'Full Time';
      case 'part_time':
        return 'Part Time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      default:
        return 'Full Time';
    }
  }

  String _getLocalizedExperience(String exp, String lang) {
    if (lang == 'mr') {
      if (exp.toLowerCase() == 'fresher') {
        return 'फ्रेशर';
      }
      return '$exp वर्षे';
    }
    if (exp.toLowerCase() == 'fresher') {
      return 'Fresher';
    }
    return '$exp years';
  }

  String _getLocalizedEducation(String edu, String lang) {
    if (lang == 'mr') {
      switch (edu.toLowerCase()) {
        case '10th pass':
          return '१० वी';
        case '12th pass':
          return '१२ वी';
        case 'graduate':
          return 'पदवीधर';
        default:
          return edu;
      }
    }
    return edu;
  }

  String _getLocalizedTitle(String title, String lang) {
    if (lang == 'mr') {
      if (title.toLowerCase().contains('tempo driver'))
        return 'टेम्पो ड्रायव्हर';
      if (title.toLowerCase().contains('clerk')) return 'क्लर्क';
      if (title.toLowerCase().contains('office executive'))
        return 'ऑफिस एक्झिक्युटिव्ह';
      if (title.toLowerCase().contains('delivery partner'))
        return 'डिलिव्हरी पार्टनर';
      if (title.toLowerCase().contains('graphic designer'))
        return 'ग्राफिक डिझायनर';
      if (title.toLowerCase().contains('warehouse associate'))
        return 'वेअरहाउस असोसिएट';
      if (title.toLowerCase().contains('telecalling agent')) return 'टेलीकॉलर';
    }
    return title;
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderCard(AvailableJob job, int index) {
    final l10n = AppLocalizations.of(context);
    final lang = l10n.locale.languageCode;
    final localizedTitle = _getLocalizedTitle(job.title, lang);
    final localizedLocation = job.stateName;
    final localizedEducation = _getLocalizedEducation(job.educationLevel, lang);

    final bool showCall =
        job.enableCall &&
        job.contactPhone != null &&
        job.contactPhone!.isNotEmpty;
    final bool showChat =
        job.enableChat &&
        ((job.whatsappNumber != null && job.whatsappNumber!.isNotEmpty) ||
            (job.contactPhone != null && job.contactPhone!.isNotEmpty));
    final bool showApply = job.applyOnly || (!showCall && !showChat);

    double scale = 1.0;
    if (_pageController.hasClients && _pageController.position.haveDimensions) {
      double diff = _currentPage - index;
      scale = (1 - (diff.abs() * 0.08)).clamp(0.8, 1.0);
    } else {
      scale = index == 0 ? 1.0 : 0.92;
    }

    return Transform.scale(
      scale: scale,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: _Colors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _Colors.borderGrey.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Part: Logo, Title with arrow, Company, Salary
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageService(
                    imageUrl: _getJobImageUrl(job),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      width: 48,
                      height: 48,
                      color: _Colors.chipBg,
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: _Colors.primaryBlue,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Right Arrow
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              localizedTitle,
                              style: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF007AFF),
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Company Name
                      Text(
                        job.addressLine1.isNotEmpty
                            ? job.addressLine1
                            : 'Company',
                        style: const TextStyle(
                          color: _Colors.darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Salary
                      Text(
                        job.salaryDisplay,
                        style: const TextStyle(
                          color: _Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFE7E9EE), height: 1),
            const SizedBox(height: 8),
            // Middle Part: Location and Qualification rows
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          localizedLocation,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.school, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          localizedEducation,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Bottom Part: Full-width blue Call button
            Row(
              children: () {
                final List<Widget> activeButtons = [];
                if (showApply) {
                  activeButtons.add(
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToDetail(job),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _Colors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            l10n.text('jobs_apply'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (showChat) {
                  activeButtons.add(
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => _openWhatsApp(
                            job.whatsappNumber ?? job.contactPhone,
                            job.title,
                            job.id,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFD7DADF),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            foregroundColor: _Colors.darkText,
                            padding: EdgeInsets.zero,
                          ),
                          icon: SizedBox(
                            width: 18,
                            height: 18,
                            child: Image.asset(
                              'assets/icons/whatsapp.png',
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 16,
                                    color: Color(0xFF25D366),
                                  ),
                            ),
                          ),
                          label: const Text(
                            'Chat',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _Colors.darkText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (showCall) {
                  activeButtons.add(
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () => _makeCall(job.contactPhone, job.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _Colors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          icon: const Icon(
                            Icons.phone_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            lang == 'mr' ? 'कॉल' : 'Call',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final List<Widget> rowChildren = [];
                for (int i = 0; i < activeButtons.length; i++) {
                  rowChildren.add(activeButtons[i]);
                  if (i < activeButtons.length - 1) {
                    rowChildren.add(const SizedBox(width: 8));
                  }
                }
                return rowChildren;
              }(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalJobCard(AvailableJob job, AppLocalizations l10n) {
    return JobCardWidget(
      job: job,
      onTap: () => _navigateToDetail(job),
      onWhatsAppTap: () => _openWhatsApp(
        job.whatsappNumber ?? job.contactPhone,
        job.title,
        job.id,
      ),
      onCallTap: () => _makeCall(job.contactPhone, job.id),
      onShareTap: () => _shareJob(job),
    );
  }

  Widget _buildPageIndicator() {
    int slideCount = _recentJobs.take(5).length;
    if (slideCount <= 1) return const SizedBox.shrink();

    double normalizedPage = _currentPage % slideCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slideCount, (index) {
        double diff = (normalizedPage - index).abs();
        if (diff > slideCount / 2) {
          diff = slideCount - diff;
        }
        bool isActive = diff < 0.5;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? _Colors.yellow : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? _Colors.yellow : const Color(0xFF72757F),
              width: 1.2,
            ),
          ),
        );
      }),
    );
  }

  // ── Filter chip row ───────────────────────────────────────────────────────
  Widget _buildFilterChipButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(minWidth: 35.sp, maxWidth: 180.sp),
          padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 3.sp),
          decoration: BoxDecoration(
            color: _Colors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Colors.borderGrey, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _Colors.chipText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 1.w),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _Colors.lightGrey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final categories = _jobsController.categories;
    final categoryLabel = _selectedCategoryIndex == 0 || categories.isEmpty
        ? 'Job Category'
        : categories[_selectedCategoryIndex - 1].name;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChipButton(
            label: categoryLabel,
            onTap: () =>
                _showFilterSheet(initialSection: _FilterSection.category),
          ),
          const SizedBox(width: 10),
          _buildFilterChipButton(
            label: _selectedJobTypeIndex == 0
                ? 'Job Type'
                : _jobTypeOptions[_selectedJobTypeIndex],
            onTap: () =>
                _showFilterSheet(initialSection: _FilterSection.jobType),
          ),
          const SizedBox(width: 10),
          _buildFilterChipButton(
            label: _salaryOptions[_selectedSalaryIndex],
            onTap: () =>
                _showFilterSheet(initialSection: _FilterSection.salary),
          ),
          const SizedBox(width: 10),
          _buildFilterChipButton(
            label: _educationOptions[_selectedEducationIndex],
            onTap: () =>
                _showFilterSheet(initialSection: _FilterSection.education),
          ),
          const SizedBox(width: 10),
          _buildFilterChipButton(
            label: _experienceOptions[_selectedExperienceIndex],
            onTap: () =>
                _showFilterSheet(initialSection: _FilterSection.experience),
          ),
          const SizedBox(width: 10),
          _buildFilterChipButton(
            label: _freshnessOptions[_selectedFreshnessIndex],
            onTap: () =>
                _showFilterSheet(initialSection: _FilterSection.freshness),
          ),
          const SizedBox(width: 10),
          _buildFilterChipButton(
            label: _filterLocalityName ??
                _filterDistrictName ??
                _filterStateName ??
                'Location',
            onTap: () =>
                _showFilterSheet(initialSection: _FilterSection.location),
          ),
        ],
      ),
    );
  }

  // ── Bottom-sheet filter panel (mirrors available_jobs_screen.dart) ────────
  Future<void> _showFilterSheet({
    required _FilterSection initialSection,
  }) async {
    final selected = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final sections = _FilterSection.values;
        var activeSection = initialSection;

        int? tempStateId = _filterStateId;
        int? tempDistrictId = _filterDistrictId;
        int? tempLocalityId = _filterLocalityId;
        String? tempStateName = _filterStateName;
        String? tempDistrictName = _filterDistrictName;
        String? tempLocalityName = _filterLocalityName;

        if (_jobsController.states.isEmpty) {
          _jobsController.fetchStates();
        }
        if (tempStateId != null && _jobsController.districts.isEmpty) {
          _jobsController.fetchDistricts(tempStateId);
        }
        if (tempDistrictId != null && _jobsController.localities.isEmpty) {
          _jobsController.fetchLocalities(tempDistrictId);
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories = _jobsController.categories;
            final options = activeSection == _FilterSection.category
                ? <String>[] // not used for category (uses grid)
                : _optionsForSection(activeSection);
            final currentIndex = _selectedIndexForSection(activeSection);

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.88,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _Colors.darkText,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: _Colors.darkText,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 135,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8F8FA),
                              border: Border(
                                right: BorderSide(
                                  color: Color(0xFFE8EAF0),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListView.separated(
                              itemCount: sections.length,
                              separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                thickness: 1,
                                indent: 16,
                                endIndent: 8,
                              ),
                              itemBuilder: (_, index) {
                                final section = sections[index];
                                final isActive = section == activeSection;
                                return InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      activeSection = section;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: Border(
                                        left: BorderSide(
                                          color: isActive
                                              ? _Colors.primaryBlue
                                              : Colors.transparent,
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      _sectionTitle(section),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? _Colors.primaryBlue
                                            : _Colors.darkText,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: activeSection == _FilterSection.category
                                ? GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      14,
                                      16,
                                      16,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 0.92,
                                        ),
                                    itemCount: categories.length,
                                    itemBuilder: (_, index) {
                                      final cat = categories[index];
                                      // index 0 in the chip = All, so cat index 0 → chip index 1
                                      final isSelected =
                                          _selectedCategoryIndex == index + 1;
                                      return _RecentCategoryCard(
                                        category: cat,
                                        isSelected: isSelected,
                                        onTap: () {
                                          setState(() {
                                            _selectedCategoryIndex = index + 1;
                                            _filterJobs();
                                          });
                                          setModalState(() {});
                                        },
                                      );
                                    },
                                  )
                                : activeSection == _FilterSection.location
                                    ? _buildLocationFilterView(
                                        context,
                                        setModalState,
                                        tempStateId,
                                        tempDistrictId,
                                        tempLocalityId,
                                        (stateId, stateName) {
                                          tempStateId = stateId;
                                          tempStateName = stateName;
                                          tempDistrictId = null;
                                          tempDistrictName = null;
                                          tempLocalityId = null;
                                          tempLocalityName = null;
                                        },
                                        (districtId, districtName) {
                                          tempDistrictId = districtId;
                                          tempDistrictName = districtName;
                                          tempLocalityId = null;
                                          tempLocalityName = null;
                                        },
                                        (localityId, localityName) {
                                          tempLocalityId = localityId;
                                          tempLocalityName = localityName;
                                        },
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          14,
                                          16,
                                          16,
                                        ),
                                        itemCount: options.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (_, index) {
                                          final option = options[index];
                                          final isSelected = index == currentIndex;
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                _setSelectedIndexForSection(
                                                  activeSection,
                                                  index,
                                                );
                                                _filterJobs();
                                              });
                                              setModalState(() {});
                                            },
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFFF7F8FC)
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(
                                                  16,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      option,
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.w700,
                                                        color: _Colors.darkText,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? _Colors.darkText
                                                            : const Color(
                                                                0xFF8A8E97,
                                                              ),
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: isSelected
                                                        ? const Center(
                                                            child: Icon(
                                                              Icons.circle_rounded,
                                                              size: 14,
                                                              color:
                                                                  _Colors.darkText,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20.sp),
                      height: 60.sp,
                      padding: EdgeInsets.all(10.sp),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategoryIndex = 0;
                                  _selectedJobTypeIndex = 0;
                                  _selectedSalaryIndex = 0;
                                  _selectedEducationIndex = 0;
                                  _selectedExperienceIndex = 0;
                                  _selectedFreshnessIndex = 0;
                                  _filterStateId = null;
                                  _filterDistrictId = null;
                                  _filterLocalityId = null;
                                  _filterStateName = null;
                                  _filterDistrictName = null;
                                  _filterLocalityName = null;
                                });
                                setModalState(() {
                                  tempStateId = null;
                                  tempDistrictId = null;
                                  tempLocalityId = null;
                                  tempStateName = null;
                                  tempDistrictName = null;
                                  tempLocalityName = null;
                                  activeSection = _FilterSection.jobType;
                                });
                                _loadRecentJobs();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: _Colors.primaryBlue,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.sp),
                              ),
                              child: Text(
                                'Clear filter',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _Colors.darkText,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.sp),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _filterStateId = tempStateId;
                                  _filterDistrictId = tempDistrictId;
                                  _filterLocalityId = tempLocalityId;
                                  _filterStateName = tempStateName;
                                  _filterDistrictName = tempDistrictName;
                                  _filterLocalityName = tempLocalityName;
                                });
                                _loadRecentJobs(
                                  stateId: _filterStateId,
                                  districtId: _filterDistrictId,
                                  localityId: _filterLocalityId,
                                );
                                Navigator.pop(context, true);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _Colors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.sp),
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == true) {
      setState(() {});
    }
  }

  String _sectionTitle(_FilterSection section) {
    return switch (section) {
      _FilterSection.category => 'Job Category',
      _FilterSection.jobType => 'Job Type',
      _FilterSection.salary => 'Salary Range',
      _FilterSection.education => 'Education',
      _FilterSection.experience => 'Work Experience',
      _FilterSection.freshness => 'Freshness',
      _FilterSection.location => 'Location',
    };
  }

  List<String> _optionsForSection(_FilterSection section) {
    return switch (section) {
      _FilterSection.category => [], // rendered as grid, not list
      _FilterSection.jobType => _jobTypeOptions,
      _FilterSection.salary => _salaryOptions,
      _FilterSection.education => _educationOptions,
      _FilterSection.experience => _experienceOptions,
      _FilterSection.freshness => _freshnessOptions,
      _FilterSection.location => [],
    };
  }

  int _selectedIndexForSection(_FilterSection section) {
    return switch (section) {
      _FilterSection.category => _selectedCategoryIndex,
      _FilterSection.jobType => _selectedJobTypeIndex,
      _FilterSection.salary => _selectedSalaryIndex,
      _FilterSection.education => _selectedEducationIndex,
      _FilterSection.experience => _selectedExperienceIndex,
      _FilterSection.freshness => _selectedFreshnessIndex,
      _FilterSection.location => 0,
    };
  }

  void _setSelectedIndexForSection(_FilterSection section, int index) {
    switch (section) {
      case _FilterSection.category:
        _selectedCategoryIndex = index;
        break;
      case _FilterSection.jobType:
        _selectedJobTypeIndex = index;
        break;
      case _FilterSection.salary:
        _selectedSalaryIndex = index;
        break;
      case _FilterSection.education:
        _selectedEducationIndex = index;
        break;
      case _FilterSection.experience:
        _selectedExperienceIndex = index;
        break;
      case _FilterSection.freshness:
        _selectedFreshnessIndex = index;
        break;
      case _FilterSection.location:
        break;
    }
  }

  Widget _buildProfileView(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _Colors.borderGrey, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _Colors.primaryBlue.withValues(alpha: 0.1),
                        border: Border.all(
                          color: _Colors.primaryBlue,
                          width: 1.5,
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rohan Shinde',
                            style: TextStyle(
                              color: _Colors.darkText,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '+91 9876543210',
                            style: TextStyle(
                              color: _Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'KYC Verified',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: _Colors.borderGrey),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildProfileInfoItem(
                        icon: Icons.work_outline_rounded,
                        label: 'Preferred Job',
                        value: 'Driver / Office',
                      ),
                    ),
                    Expanded(
                      child: _buildProfileInfoItem(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: 'Sangli, Maharashtra',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Education & Experience',
            style: TextStyle(
              color: _Colors.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _Colors.borderGrey, width: 1),
            ),
            child: Column(
              children: [
                _buildProfileDetailItem(
                  icon: Icons.school_outlined,
                  title: '12th Pass',
                  subtitle: 'Sangli High School (2022)',
                ),
                Divider(color: _Colors.borderGrey),
                _buildProfileDetailItem(
                  icon: Icons.history_rounded,
                  title: '1-3 Years Experience',
                  subtitle: 'Driver at local logistics company',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Edit Profile',
                  'Profile edit page is coming soon!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _Colors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text(
                'Edit Profile Details',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Resume',
                  'Downloading Resume...',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _Colors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: _Colors.primaryBlue,
              ),
              icon: const Icon(Icons.download_rounded),
              label: const Text(
                'Download CV / Resume',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: _Colors.grey, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: _Colors.darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildProfileDetailItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _Colors.primaryBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _Colors.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unable to load recent jobs',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadRecentJobs,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Colors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline_rounded,
              size: 72,
              color: _Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.text('no_recent_jobs'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecentJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: _Colors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeCall(String? phone, int jobId) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Contact phone number is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      await _jobsController.logCallAndChatApply(
        jobId: jobId,
        type: 'call',
        phone: phone,
      );
    } catch (e) {
      debugPrint('Error logging call application: $e');
    }
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not place a call to $phone',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _openWhatsApp(String? phone, String title, int jobId) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Contact phone number is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      await _jobsController.logCallAndChatApply(
        jobId: jobId,
        type: 'chat',
        phone: phone,
      );
    } catch (e) {
      debugPrint('Error logging chat application: $e');
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final message = 'Hello, I am interested in your job posting: "$title".';
    Open.whatsApp(whatsAppNumber: cleanPhone, text: message);
    // final Uri url = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    // if (await canLaunchUrl(url)) {
    //   await launchUrl(url);
    // } else {
    //   Get.snackbar(
    //     'Error',
    //     'Could not open WhatsApp. Please check if WhatsApp is installed.',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }

  Future<void> _shareJob(AvailableJob job) async {
    await Share.share('https://rozgaradda.com/job-details/${job.id}');
  }

  void _navigateToDetail(AvailableJob job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
    );
  }

  Widget _buildLocationFilterView(
    BuildContext context,
    void Function(void Function()) setModalState,
    int? currentStateId,
    int? currentDistrictId,
    int? currentLocalityId,
    void Function(int?, String?) onStateChanged,
    void Function(int?, String?) onDistrictChanged,
    void Function(int?, String?) onLocalityChanged,
  ) {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // State Selection
            const Text(
              'State',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _Colors.darkText),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _Colors.borderGrey, width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: currentStateId,
                  isExpanded: true,
                  hint: Text(
                    _jobsController.isLoadingStates.value
                        ? 'Loading states...'
                        : 'Select State',
                    style: const TextStyle(color: _Colors.grey, fontSize: 14),
                  ),
                  dropdownColor: Colors.white,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Any State'),
                    ),
                    ..._jobsController.states.map(
                      (state) => DropdownMenuItem<int?>(
                        value: state.id,
                        child: Text(state.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: _jobsController.isLoadingStates.value
                      ? null
                      : (value) {
                          String? name;
                          if (value != null) {
                            name = _jobsController.states.firstWhere((s) => s.id == value).name;
                          }
                          onStateChanged(value, name);
                          if (value != null) {
                            _jobsController.fetchDistricts(value);
                          }
                          setModalState(() {});
                        },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // District Selection
            const Text(
              'District',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _Colors.darkText),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _Colors.borderGrey, width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: currentStateId == null ? null : currentDistrictId,
                  isExpanded: true,
                  hint: Text(
                    currentStateId == null
                        ? 'Select state first'
                        : _jobsController.isLoadingDistricts.value
                            ? 'Loading districts...'
                            : 'Select District',
                    style: const TextStyle(color: _Colors.grey, fontSize: 14),
                  ),
                  dropdownColor: Colors.white,
                  items: currentStateId == null
                      ? []
                      : [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Any District'),
                          ),
                          ..._jobsController.districts.map(
                            (district) => DropdownMenuItem<int?>(
                              value: district.id,
                              child: Text(district.name, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                  onChanged: (currentStateId == null || _jobsController.isLoadingDistricts.value)
                      ? null
                      : (value) {
                          String? name;
                          if (value != null) {
                            name = _jobsController.districts.firstWhere((d) => d.id == value).name;
                          }
                          onDistrictChanged(value, name);
                          if (value != null) {
                            _jobsController.fetchLocalities(value);
                          }
                          setModalState(() {});
                        },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Locality Selection
            const Text(
              'Locality',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _Colors.darkText),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _Colors.borderGrey, width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: currentDistrictId == null ? null : currentLocalityId,
                  isExpanded: true,
                  hint: Text(
                    currentDistrictId == null
                        ? 'Select district first'
                        : _jobsController.isLoadingLocalities.value
                            ? 'Loading localities...'
                            : 'Select Locality',
                    style: const TextStyle(color: _Colors.grey, fontSize: 14),
                  ),
                  dropdownColor: Colors.white,
                  items: currentDistrictId == null
                      ? []
                      : [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Any Locality'),
                          ),
                          ..._jobsController.localities.map(
                            (locality) => DropdownMenuItem<int?>(
                              value: locality.id,
                              child: Text(locality.name, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                  onChanged: (currentDistrictId == null || _jobsController.isLoadingLocalities.value)
                      ? null
                      : (value) {
                          String? name;
                          if (value != null) {
                            name = _jobsController.localities.firstWhere((l) => l.id == value).name;
                          }
                          onLocalityChanged(value, name);
                          setModalState(() {});
                        },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Category grid card (mirrors _CategoryFilterCard in available_jobs_screen) ──
class _RecentCategoryCard extends StatelessWidget {
  final JobCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecentCategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF7F8FC) : _Colors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? _Colors.primaryBlue : _Colors.borderGrey,
              width: isSelected ? 1.6 : 1.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(17),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetworkImageService(
                        imageUrl: category.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: _Colors.chipBg,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.category_rounded,
                            color: _Colors.primaryBlue,
                            size: 30,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          color: _Colors.primaryBlue.withValues(alpha: 0.12),
                        ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _Colors.primaryBlue
                                : Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSelected ? Icons.check_rounded : Icons.add,
                            size: 18,
                            color: isSelected ? Colors.white : _Colors.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Text(
                  category.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _Colors.darkText,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForwardOnlyScrollPhysics extends ScrollPhysics {
  const ForwardOnlyScrollPhysics({super.parent});

  @override
  ForwardOnlyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ForwardOnlyScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Prevent scrolling backwards (user swiping left-to-right is offset > 0)
    if (offset > 0) {
      return 0.0;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Prevent any decrease in scroll pixels (going backward)
    if (value < position.pixels) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }
}

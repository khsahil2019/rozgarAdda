import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rojgar/core/widgets/network_image_service.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/features/jobs/domain/entities/available_job_entity.dart';
import 'package:rojgar/features/jobs/presentation/screens/job_detail.dart';
import 'package:rojgar/features/jobs/presentation/widgets/job_card_widget.dart';

class _Colors {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF17181C);
  static const Color grey = Color(0xFF72757F);
  static const Color borderGrey = Color(0xFFD7DADF);
  static const Color scaffoldBg = Color(0xFFF4F5F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color chipBg = Color(0xFFF7F8FB);
  static const Color chipAccent = Color(0xFFEAF2FF);
  static const Color green = Color(0xFF2E7D32);
  static const Color yellow = Color(0xFFFFC107);
}

class RecentJobsScreen extends StatefulWidget {
  const RecentJobsScreen({super.key});

  @override
  State<RecentJobsScreen> createState() => _RecentJobsScreenState();
}

class _RecentJobsScreenState extends State<RecentJobsScreen> {
  late final PageController _pageController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<AvailableJob> _recentJobs = [];
  List<AvailableJob> _filteredJobs = [];

  double _currentPage = 0.0;
  String _searchQuery = '';
  String _selectedJobType = 'all';
  String _selectedCategory = 'all';
  String _selectedSalaryRange = 'all';
  String _selectedQualification = 'all';
  int _selectedTabIndex = 0;

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  static final List<AvailableJob> _mockJobs = [
    AvailableJob(
      id: 101,
      employerId: 1,
      categoryId: 2,
      roleId: 3,
      title: 'Tempo Driver',
      jobType: 'full_time',
      shifts: const ['Day Shift'],
      workLocationType: 'office',
      stateName: 'Sangli, सांगली',
      addressLine1: 'Rajhans Namkeen',
      addressLine2: 'Sangli Gidc',
      pincode: '416416',
      payType: 'monthly',
      minSalary: '13000',
      maxSalary: '16000',
      perks: const ['Cab', 'Meals'],
      educationLevel: '10th Pass',
      englishLevel: 'Basic',
      experienceLevel: '1-3',
      additionalRequirements: {},
      skills: const ['Driving', 'GPS'],
      languages: const ['Marathi', 'Hindi'],
      vacancy: 3,
      isWalkin: true,
      contactPreference: 'call',
      viewsCount: 120,
      applicationsCount: 45,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AvailableJob(
      id: 102,
      employerId: 2,
      categoryId: 2,
      roleId: 4,
      title: 'Clerk',
      jobType: 'full_time',
      shifts: const ['Day Shift'],
      workLocationType: 'office',
      stateName: 'Sangli, सांगली (-मिरज)',
      addressLine1: 'Shri Janata Light House',
      addressLine2: 'Link Road',
      pincode: '416416',
      payType: 'monthly',
      minSalary: '8000',
      maxSalary: '12000',
      perks: const ['Insurance'],
      educationLevel: '12th Pass',
      englishLevel: 'Intermediate',
      experienceLevel: '1-3',
      additionalRequirements: {},
      skills: const ['Excel', 'Data entry'],
      languages: const ['Marathi', 'English'],
      vacancy: 2,
      isWalkin: false,
      contactPreference: 'whatsapp',
      viewsCount: 340,
      applicationsCount: 112,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AvailableJob(
      id: 103,
      employerId: 3,
      categoryId: 2,
      roleId: 5,
      title: 'Office Executive',
      jobType: 'full_time',
      shifts: const ['Day Shift'],
      workLocationType: 'office',
      stateName: 'Sangli Nagar, सांगली मि',
      addressLine1: 'SEVEN LAXMI CONSTRUCTION',
      addressLine2: 'Nagar Road',
      pincode: '416416',
      payType: 'monthly',
      minSalary: '8000',
      maxSalary: '15000',
      perks: const ['Fuel allowance'],
      educationLevel: '12th Pass',
      englishLevel: 'Basic',
      experienceLevel: '1-3',
      additionalRequirements: {},
      skills: const ['Administration', 'Typing'],
      languages: const ['Marathi', 'Hindi'],
      vacancy: 1,
      isWalkin: false,
      contactPreference: 'call',
      viewsCount: 140,
      applicationsCount: 12,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AvailableJob(
      id: 104,
      employerId: 4,
      categoryId: 3,
      roleId: 8,
      title: 'Graphic Designer',
      jobType: 'full_time',
      shifts: const ['Day Shift'],
      workLocationType: 'hybrid',
      stateName: 'Pune',
      addressLine1: 'Kothrud',
      addressLine2: 'Paud Road',
      pincode: '411038',
      payType: 'monthly',
      minSalary: '25000',
      maxSalary: '35000',
      perks: const ['Free snacks', 'Annual bonus'],
      educationLevel: 'Graduate',
      englishLevel: 'Intermediate',
      experienceLevel: '2',
      additionalRequirements: const {},
      skills: const ['Photoshop', 'Illustrator', 'Figma'],
      languages: const ['English', 'Marathi'],
      vacancy: 2,
      isWalkin: false,
      contactPreference: 'email',
      viewsCount: 204,
      applicationsCount: 38,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AvailableJob(
      id: 105,
      employerId: 5,
      categoryId: 4,
      roleId: 10,
      title: 'Warehouse Associate',
      jobType: 'full_time',
      shifts: const ['Night Shift'],
      workLocationType: 'office',
      stateName: 'Ahmedabad',
      addressLine1: 'Sanand',
      addressLine2: 'GIDC',
      pincode: '382110',
      payType: 'monthly',
      fixedSalary: '16500',
      perks: const ['Overtime pay', 'PF & ESIC'],
      educationLevel: '10th Pass',
      englishLevel: 'Basic',
      experienceLevel: 'fresher',
      additionalRequirements: {},
      skills: const ['Inventory management', 'Packaging'],
      languages: const ['Gujarati', 'Hindi'],
      vacancy: 25,
      isWalkin: true,
      contactPreference: 'call',
      viewsCount: 450,
      applicationsCount: 156,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AvailableJob(
      id: 106,
      employerId: 6,
      categoryId: 1,
      roleId: 2,
      title: 'Telecalling Agent',
      jobType: 'part_time',
      shifts: const ['Day Shift'],
      workLocationType: 'office',
      stateName: 'Hyderabad',
      addressLine1: 'Madhapur',
      addressLine2: 'Hitec City',
      pincode: '500081',
      payType: 'monthly',
      minSalary: '10000',
      maxSalary: '15000',
      perks: const ['Performance incentive'],
      educationLevel: '12th Pass',
      englishLevel: 'Intermediate',
      experienceLevel: '1',
      additionalRequirements: const {},
      skills: const ['Customer support', 'Telesales'],
      languages: const ['Telugu', 'English', 'Hindi'],
      vacancy: 15,
      isWalkin: false,
      contactPreference: 'whatsapp',
      viewsCount: 310,
      applicationsCount: 89,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  Future<void> _loadRecentJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recentJobs.clear();
      _filteredJobs.clear();
    });

    try {
      // Simulate network latency
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _isLoading = false;
        _recentJobs = List.from(_mockJobs);
        _filterJobs();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterJobs() {
    final query = _searchQuery.toLowerCase().trim();
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
      if (_selectedCategory != 'all') {
        int expectedCatId = -1;
        if (_selectedCategory == 'Driver') expectedCatId = 2;
        if (_selectedCategory == 'Office') expectedCatId = 2;
        if (_selectedCategory == 'Delivery') expectedCatId = 5;
        if (_selectedCategory == 'Design') expectedCatId = 3;
        if (_selectedCategory == 'Warehouse') expectedCatId = 4;
        if (_selectedCategory == 'Support') expectedCatId = 1;

        if (expectedCatId != -1 && job.categoryId != expectedCatId) {
          if (_selectedCategory == 'Driver' &&
              !job.title.toLowerCase().contains('driver')) {
            return false;
          }
          if (_selectedCategory == 'Office' &&
              !job.title.toLowerCase().contains('clerk')) {
            return false;
          }
          if (expectedCatId != 2) return false;
        }
      }

      // 3. Job Type filter
      if (_selectedJobType != 'all') {
        if (job.jobType != _selectedJobType) return false;
      }

      // 4. Salary filter
      if (_selectedSalaryRange != 'all') {
        final double minSal = double.tryParse(job.minSalary ?? '0') ?? 0;
        final double maxSal =
            double.tryParse(job.maxSalary ?? '999999') ?? 999999;

        if (_selectedSalaryRange == '10k-15k') {
          if (maxSal < 10000 || minSal > 15000) return false;
        } else if (_selectedSalaryRange == '15k-25k') {
          if (maxSal < 15000 || minSal > 25000) return false;
        } else if (_selectedSalaryRange == '25k+') {
          if (minSal < 25000) return false;
        }
      }

      // 5. Qualification filter
      if (_selectedQualification != 'all') {
        if (job.educationLevel.toLowerCase() !=
            _selectedQualification.toLowerCase()) {
          return false;
        }
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

  Widget _buildCustomTabBar(AppLocalizations l10n) {
    final lang = l10n.locale.languageCode;
    final tabs = [_getTab1Label(lang), _getTab2Label(lang)];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE7E9EE), width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? _Colors.darkText : _Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    width: isSelected ? 80 : 0,
                    decoration: BoxDecoration(
                      color: _Colors.darkText,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
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
                  itemCount: _recentJobs.take(5).length,
                  itemBuilder: (context, index) {
                    final job = _recentJobs[index];
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final job = _filteredJobs[index];
                    return _buildVerticalJobCard(job, l10n);
                  }, childCount: _filteredJobs.length),
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
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => _makeCall(job.contactPhone),
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
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalJobCard(AvailableJob job, AppLocalizations l10n) {
    return JobCardWidget(
      job: job,
      onTap: () => _navigateToDetail(job),
      onWhatsAppTap: () => _openWhatsApp(job.contactPhone, job.title),
      onCallTap: () => _makeCall(job.contactPhone),
      onShareTap: () => _shareJob(job),
    );
  }

  Widget _buildPageIndicator() {
    int slideCount = _recentJobs.take(5).length;
    if (slideCount <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slideCount, (index) {
        double diff = (_currentPage - index).abs();
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

  Widget _buildDropdownChip({
    required String label,
    required String activeValue,
    required List<PopupMenuEntry<String>> items,
    required Function(String) onSelected,
  }) {
    final isFiltering = activeValue != 'all';
    return Theme(
      data: Theme.of(context).copyWith(cardColor: Colors.white),
      child: PopupMenuButton<String>(
        onSelected: onSelected,
        itemBuilder: (context) => items,
        offset: const Offset(0, 40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isFiltering ? _Colors.chipAccent : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFiltering ? _Colors.primaryBlue : _Colors.borderGrey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFiltering ? '$label: $activeValue' : label,
                style: TextStyle(
                  color: isFiltering ? _Colors.primaryBlue : _Colors.darkText,
                  fontWeight: isFiltering ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isFiltering ? _Colors.primaryBlue : _Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildDropdownChip(
            label: 'Category',
            activeValue: _selectedCategory,
            items: const [
              PopupMenuItem(value: 'all', child: Text('All Categories')),
              PopupMenuItem(value: 'Driver', child: Text('Driver')),
              PopupMenuItem(value: 'Office', child: Text('Office / Clerk')),
              PopupMenuItem(value: 'Delivery', child: Text('Delivery')),
              PopupMenuItem(value: 'Design', child: Text('Graphic Design')),
              PopupMenuItem(value: 'Warehouse', child: Text('Warehouse')),
              PopupMenuItem(
                value: 'Support',
                child: Text('Telecalling / Support'),
              ),
            ],
            onSelected: (val) {
              setState(() {
                _selectedCategory = val;
                _filterJobs();
              });
            },
          ),
          const SizedBox(width: 8),
          _buildDropdownChip(
            label: 'Job Type',
            activeValue: _selectedJobType,
            items: const [
              PopupMenuItem(value: 'all', child: Text('All Job Types')),
              PopupMenuItem(value: 'full_time', child: Text('Full Time')),
              PopupMenuItem(value: 'part_time', child: Text('Part Time')),
              PopupMenuItem(value: 'contract', child: Text('Contract')),
            ],
            onSelected: (val) {
              setState(() {
                _selectedJobType = val;
                _filterJobs();
              });
            },
          ),
          const SizedBox(width: 8),
          _buildDropdownChip(
            label: 'Salary',
            activeValue: _selectedSalaryRange,
            items: const [
              PopupMenuItem(value: 'all', child: Text('All Salaries')),
              PopupMenuItem(value: '10k-15k', child: Text('₹10k - ₹15k')),
              PopupMenuItem(value: '15k-25k', child: Text('₹15k - ₹25k')),
              PopupMenuItem(value: '25k+', child: Text('₹25k+')),
            ],
            onSelected: (val) {
              setState(() {
                _selectedSalaryRange = val;
                _filterJobs();
              });
            },
          ),
          const SizedBox(width: 8),
          _buildDropdownChip(
            label: 'Qualification',
            activeValue: _selectedQualification,
            items: const [
              PopupMenuItem(value: 'all', child: Text('All Qualifications')),
              PopupMenuItem(value: '10th Pass', child: Text('10th Pass')),
              PopupMenuItem(value: '12th Pass', child: Text('12th Pass')),
              PopupMenuItem(value: 'Graduate', child: Text('Graduate')),
            ],
            onSelected: (val) {
              setState(() {
                _selectedQualification = val;
                _filterJobs();
              });
            },
          ),
        ],
      ),
    );
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

  Future<void> _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Contact phone number is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
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

  Future<void> _openWhatsApp(String? phone, String title) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Contact phone number is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final message = Uri.encodeComponent(
      'Hello, I am interested in your job posting: "$title".',
    );
    final Uri url = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp. Please check if WhatsApp is installed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _shareJob(AvailableJob job) async {
    Get.snackbar(
      'Shared',
      'Job link shared successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _navigateToDetail(AvailableJob job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailScreen(
          jobId: job.id,
          jobTitle: job.title,
          company: job.stateName.isNotEmpty ? job.stateName : 'Company',
          location: job.addressLine1.isNotEmpty
              ? job.addressLine1
              : job.stateName,
          salary: job.salaryDisplay,
          jobType: job.jobTypeLabel,
          contactPhone: job.contactPhone,
        ),
      ),
    );
  }
}

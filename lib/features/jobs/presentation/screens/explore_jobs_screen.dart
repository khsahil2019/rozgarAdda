import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/job_detail.dart';
import '../controller/jobs_controller.dart';
import '../../domain/entities/job_category.dart';

enum _FilterSection {
  category,
  jobType,
  salary,
  education,
  experience,
  freshness,
  location,
}

class AppColors {
  static const Color background = Color(0xFFF4F5F8);
  static const Color white = Colors.white;
  static const Color primaryBlue = Color(0xFF0F5FFF);
  static const Color darkText = Color(0xFF17181C);
  static const Color grey = Color(0xFF72757F);
  static const Color lightGrey = Color(0xFF9AA0AA);
  static const Color borderGrey = Color(0xFFD7DADF);
  static const Color cardShadow = Color(0x12000000);
  static const Color chipBg = Color(0xFFF7F8FB);
  static const Color chipText = Color(0xFF1E2228);
  static const Color chipAccent = Color(0xFFEAF2FF);
  static const Color yellow = Color(0xFFFFC400);
  static const Color green = Color(0xFF25D366);
  static const Color red = Color(0xFFE84E5F);
}

class JobListing {
  final int id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String vacancy;
  final String jobType;
  final String details;
  final String imageUrl;

  const JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.vacancy,
    required this.jobType,
    required this.details,
    required this.imageUrl,
  });
}

class ExploreJobsScreen extends StatefulWidget {
  final JobCategory initialCategory;

  const ExploreJobsScreen({super.key, required this.initialCategory});

  @override
  State<ExploreJobsScreen> createState() => _ExploreJobsScreenState();
}

class _ExploreJobsScreenState extends State<ExploreJobsScreen> {
  late final JobsController controller;

  int _selectedCategoryIndex = 0;
  int _selectedJobTypeIndex = 0;
  int _selectedSalaryIndex = 0;
  int _selectedEducationIndex = 0;
  int _selectedExperienceIndex = 0;
  int _selectedFreshnessIndex = 0;
  int _selectedLocationIndex = 0;

  static const List<String> _jobTypeOptions = [
    'Job Type',
    'Full-time',
    'Part-time',
    'Contract',
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

  static const List<String> _locationOptions = [
    'Location',
    'Noida',
    'Greater Noida',
    'Delhi',
    'Gurugram',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<JobsController>();

    final idx = controller.categories.indexWhere(
      (cat) => cat.id == widget.initialCategory.id,
    );
    if (idx != -1) {
      _selectedCategoryIndex = idx;
    }
    if (controller.selectedCategory.value?.id != widget.initialCategory.id) {
      controller.selectCategory(widget.initialCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Obx(() {
          final categories = controller.categories;
          if (categories.isNotEmpty &&
              _selectedCategoryIndex >= categories.length) {
            _selectedCategoryIndex = 0;
          }

          final selectedCategory = categories.isNotEmpty
              ? categories[_selectedCategoryIndex]
              : widget.initialCategory;
          final selectedCategoryName = selectedCategory.name;
          final jobs = _buildJobs(selectedCategoryName, selectedCategory);

          return Column(
            children: [
              _buildHeader(selectedCategoryName),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterRow(categories),
                      const SizedBox(height: 18),
                      _buildLocationRow(selectedCategoryName),
                      const SizedBox(height: 8),
                      _buildCategoryHint(selectedCategoryName),
                      const SizedBox(height: 18),
                      if (controller.isLoadingCategories.value &&
                          categories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        )
                      else if (controller.categoriesError.value != null &&
                          categories.isEmpty)
                        _buildErrorState()
                      else if (controller.isLoadingJobRoles.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        )
                      else if (controller.jobRolesError.value != null)
                        _buildMessageState(
                          controller.jobRolesError.value!,
                          onRetry: () {
                            controller.fetchJobRoles(selectedCategory.id);
                          },
                        )
                      else if (jobs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Text(
                              'No jobs found for this selection.',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: jobs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            return _buildJobCard(jobs[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<JobListing> _buildJobs(String scopeName, JobCategory? category) {
    final salary = _selectedSalaryIndex == 0
        ? '₹15000 - ₹18000'
        : _salaryOptions[_selectedSalaryIndex];
    final jobType = _selectedJobTypeIndex == 0
        ? 'Full-time'
        : _jobTypeOptions[_selectedJobTypeIndex];
    final imageUrl =
        category?.imageUrl ??
        'https://images.unsplash.com/photo-1521791136064-7986c2920216?auto=format&fit=crop&w=400&q=80';

    final roles = controller.jobRoles;
    if (roles.isEmpty) return const [];

    return roles
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final role = entry.value;
          return JobListing(
            id: role.id,
            title: role.name,
            company: scopeName,
            location: 'LOCATION',
            salary: index.isEven ? salary : 'Open',
            vacancy: index.isEven ? '1 Vacancy' : 'Multiple Vacancies',
            jobType: jobType,
            details: 'Job role ID ${role.id}',
            imageUrl: imageUrl,
          );
        })
        .toList(growable: false);
  }

  Widget _buildHeader(String selectedCategoryName) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _headerIconButton(Icons.play_circle_fill_rounded),
          const SizedBox(width: 10),
          const Text(
            'ROZGAR JOBS',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          _badgeIcon(Icons.post_add_rounded),
          const SizedBox(width: 14),
          _notificationIcon(),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFFFFD84D),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.darkText, size: 20),
    );
  }

  Widget _badgeIcon(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.darkText, size: 24),
    );
  }

  Widget _notificationIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.darkText,
          size: 30,
        ),
        Positioned(
          right: -5,
          top: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '10+',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(List<JobCategory> categories) {
    final categoryLabel = categories.isEmpty
        ? 'Job Category'
        : categories[_selectedCategoryIndex].name;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: categoryLabel,
            onTap: categories.isEmpty
                ? null
                : () => _showFilterSheet(
                    categories: categories,
                    initialSection: _FilterSection.category,
                  ),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            label: _jobTypeOptions[_selectedJobTypeIndex],
            onTap: () => _showFilterSheet(
              categories: categories,
              initialSection: _FilterSection.jobType,
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            label: _salaryOptions[_selectedSalaryIndex],
            onTap: () => _showFilterSheet(
              categories: categories,
              initialSection: _FilterSection.salary,
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            label: _educationOptions[_selectedEducationIndex],
            onTap: () => _showFilterSheet(
              categories: categories,
              initialSection: _FilterSection.education,
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            label: _experienceOptions[_selectedExperienceIndex],
            onTap: () => _showFilterSheet(
              categories: categories,
              initialSection: _FilterSection.experience,
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            label: _freshnessOptions[_selectedFreshnessIndex],
            onTap: () => _showFilterSheet(
              categories: categories,
              initialSection: _FilterSection.freshness,
            ),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            label: _locationOptions[_selectedLocationIndex],
            onTap: () => _showFilterSheet(
              categories: categories,
              initialSection: _FilterSection.location,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrey, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.chipText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.lightGrey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(String selectedCategoryName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Jobs near ',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                  ),
                ),
                TextSpan(
                  text: 'Film City, Sector 16A, Noida, Noida',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Padding(
          padding: EdgeInsets.only(top: 14),
          child: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primaryBlue,
            size: 34,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryHint(String selectedCategoryName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.chipAccent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Showing jobs in $selectedCategoryName',
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.categoriesError.value ?? 'An error occurred.',
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: controller.fetchCategories,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageState(String message, {required VoidCallback onRetry}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobListing job) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(
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
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE7E9EE), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      job.imageUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 58,
                          height: 58,
                          color: AppColors.chipBg,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.work_outline_rounded,
                            color: AppColors.primaryBlue,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job.salary,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.share_rounded,
                      color: AppColors.grey,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.apartment_rounded,
                    color: AppColors.grey,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.company,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.grey,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.location,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F2F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  job.vacancy,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        foregroundColor: AppColors.darkText,
                        backgroundColor: AppColors.white,
                      ),
                      icon: const Icon(Icons.chat, color: Color(0xFF1EBE5D)),
                      label: const Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.darkText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: const Text(
                        'Call HR',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderGrey,
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 34,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterSheet({
    required List<JobCategory> categories,
    required _FilterSection initialSection,
  }) async {
    final selected = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final sections = _FilterSection.values;
        var activeSection = initialSection;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final options = _optionsForSection(activeSection, categories);
            final currentIndex = _selectedIndexForSection(
              activeSection,
              categories,
            );

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.88,
                decoration: const BoxDecoration(
                  color: AppColors.white,
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
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.darkText,
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
                                              ? AppColors.yellow
                                              : Colors.transparent,
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      _sectionTitle(section),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? AppColors.yellow
                                            : AppColors.darkText,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child:
                                      activeSection == _FilterSection.category
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
                                            final category = categories[index];
                                            final isSelected =
                                                index == _selectedCategoryIndex;
                                            return _CategoryFilterCard(
                                              category: category,
                                              isSelected: isSelected,
                                              onTap: () async {
                                                final navigator = Navigator.of(
                                                  context,
                                                );
                                                setState(() {
                                                  _selectedCategoryIndex =
                                                      index;
                                                });
                                                await controller.selectCategory(
                                                  category,
                                                );
                                                navigator.pop(true);
                                              },
                                            );
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
                                            final isSelected =
                                                index == currentIndex;
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _setSelectedIndexForSection(
                                                    activeSection,
                                                    index,
                                                    categories,
                                                  );
                                                });
                                                setModalState(() {});
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? const Color(0xFFF7F8FC)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        option,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColors
                                                              .darkText,
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
                                                              ? AppColors
                                                                    .darkText
                                                              : const Color(
                                                                  0xFF8A8E97,
                                                                ),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: isSelected
                                                          ? const Center(
                                                              child: Icon(
                                                                Icons
                                                                    .circle_rounded,
                                                                size: 14,
                                                                color: AppColors
                                                                    .darkText,
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
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    18,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedCategoryIndex = 0;
                                              _selectedJobTypeIndex = 0;
                                              _selectedSalaryIndex = 0;
                                              _selectedEducationIndex = 0;
                                              _selectedExperienceIndex = 0;
                                              _selectedFreshnessIndex = 0;
                                              _selectedLocationIndex = 0;
                                            });
                                            setModalState(() {
                                              activeSection =
                                                  _FilterSection.category;
                                            });
                                            if (categories.isNotEmpty) {
                                              controller.selectCategory(
                                                categories.first,
                                              );
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFF0C000),
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                          ),
                                          child: const Text(
                                            'Clear filter',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: AppColors.yellow,
                                            foregroundColor: AppColors.darkText,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                          ),
                                          child: const Text(
                                            'Submit',
                                            style: TextStyle(
                                              fontSize: 18,
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

  List<String> _optionsForSection(
    _FilterSection section,
    List<JobCategory> categories,
  ) {
    return switch (section) {
      _FilterSection.category => [
        'All Categories',
        ...categories.map((item) => item.name),
      ],
      _FilterSection.jobType => _jobTypeOptions,
      _FilterSection.salary => _salaryOptions,
      _FilterSection.education => _educationOptions,
      _FilterSection.experience => _experienceOptions,
      _FilterSection.freshness => _freshnessOptions,
      _FilterSection.location => _locationOptions,
    };
  }

  int _selectedIndexForSection(
    _FilterSection section,
    List<JobCategory> categories,
  ) {
    return switch (section) {
      _FilterSection.category =>
        categories.isEmpty ? 0 : _selectedCategoryIndex + 1,
      _FilterSection.jobType => _selectedJobTypeIndex,
      _FilterSection.salary => _selectedSalaryIndex,
      _FilterSection.education => _selectedEducationIndex,
      _FilterSection.experience => _selectedExperienceIndex,
      _FilterSection.freshness => _selectedFreshnessIndex,
      _FilterSection.location => _selectedLocationIndex,
    };
  }

  void _setSelectedIndexForSection(
    _FilterSection section,
    int index,
    List<JobCategory> categories,
  ) {
    switch (section) {
      case _FilterSection.category:
        setState(() {
          _selectedCategoryIndex = index == 0 ? 0 : index - 1;
        });
        if (categories.isNotEmpty) {
          controller.selectCategory(categories[_selectedCategoryIndex]);
        }
        return;
      case _FilterSection.jobType:
        _selectedJobTypeIndex = index;
        return;
      case _FilterSection.salary:
        _selectedSalaryIndex = index;
        return;
      case _FilterSection.education:
        _selectedEducationIndex = index;
        return;
      case _FilterSection.experience:
        _selectedExperienceIndex = index;
        return;
      case _FilterSection.freshness:
        _selectedFreshnessIndex = index;
        return;
      case _FilterSection.location:
        _selectedLocationIndex = index;
        return;
    }
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppColors.white,
      elevation: 10,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Jobs',
                selected: true,
              ),
              _NavItem(icon: Icons.checklist_rounded, label: 'Applies'),
              _NavItem(icon: Icons.favorite_border_rounded, label: 'Saved'),
              _NavItem(icon: Icons.person_outline_rounded, label: 'My Profile'),
              _NavItem(icon: Icons.menu_rounded, label: 'Menu'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.darkText : AppColors.lightGrey;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CategoryFilterCard extends StatelessWidget {
  final JobCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterCard({
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
            color: isSelected ? const Color(0xFFF7F8FC) : AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderGrey,
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
                      Image.network(
                        category.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.chipBg,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.category_rounded,
                              color: AppColors.primaryBlue,
                              size: 30,
                            ),
                          );
                        },
                      ),
                      if (isSelected)
                        Container(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                        ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSelected ? Icons.check_rounded : Icons.add,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : AppColors.darkText,
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
                    color: AppColors.darkText,
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

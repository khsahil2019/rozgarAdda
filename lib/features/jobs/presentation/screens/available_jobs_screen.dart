import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/jobs/presentation/screens/job_detail.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/network_image_service.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/entities/available_job_entity.dart';
import '../../domain/entities/job_category.dart';
import '../../domain/entities/job_role_entity.dart';
import '../controller/jobs_controller.dart';

enum _FilterSection {
  category,
  role,
  jobType,
  salary,
  education,
  experience,
  freshness,
  location,
}

class _C {
  static const Color primaryBlue = Color(0xFF0F5FFF);
  static const Color darkText = Color(0xFF17181C);
  static const Color grey = Color(0xFF72757F);
  static const Color lightGrey = Color(0xFF9AA0AA);
  static const Color borderGrey = Color(0xFFD7DADF);
  static const Color scaffoldBg = Color(0xFFF4F5F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color chipBg = Color(0xFFF7F8FB);
  static const Color chipText = Color(0xFF1E2228);
  static const Color chipAccent = Color(0xFFEAF2FF);
  static const Color yellow = Color(0xFFFFC400);
  static const Color red = Color(0xFFE84E5F);
}

class AvailableJobsScreen extends StatefulWidget {
  final JobRoleEntity role;

  const AvailableJobsScreen({super.key, required this.role});

  @override
  State<AvailableJobsScreen> createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends State<AvailableJobsScreen> {
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

    // Ensure selectedRole is set
    controller.selectedRole.value = widget.role;

    // Initialize selected category index
    if (controller.selectedCategory.value != null) {
      final idx = controller.categories.indexWhere(
        (cat) => cat.id == controller.selectedCategory.value!.id,
      );
      if (idx != -1) {
        _selectedCategoryIndex = idx;
      }
    }

    // Fetch available jobs
    controller.fetchAvailableJobs(widget.role.id);
  }

  // ── Helper state selectors ───────────────────────────────────────────────
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
      if (fs != null) {
        return fs >= minLimit && fs <= maxLimit;
      }
    }

    final minS = _parseSalary(job.minSalary);
    final maxS = _parseSalary(job.maxSalary);

    if (minS != null && maxS != null) {
      return !(maxS < minLimit || minS > maxLimit);
    }
    if (minS != null) {
      return minS <= maxLimit;
    }
    return false;
  }

  int? _parseExp(String value) {
    if (value.toLowerCase() == 'fresher') return 0;
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  bool _matchExperience(AvailableJob job, int index) {
    final expVal = _parseExp(job.experienceLevel);
    if (expVal == null) return true;

    if (index == 1) {
      // Fresher
      return expVal == 0;
    } else if (index == 2) {
      // 1-2 Years
      return expVal >= 1 && expVal <= 2;
    } else if (index == 3) {
      // 3-5 Years
      return expVal >= 3 && expVal <= 5;
    } else if (index == 4) {
      // 5+ Years
      return expVal >= 5;
    }
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

  Future<void> _changeCategory(JobCategory cat) async {
    await controller.selectCategory(cat);
    if (controller.jobRoles.isNotEmpty) {
      controller.selectRole(controller.jobRoles.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            Expanded(
              child: Obx(() {
                final categories = controller.categories;
                if (categories.isNotEmpty &&
                    _selectedCategoryIndex >= categories.length) {
                  _selectedCategoryIndex = 0;
                }

                final selectedCategory = categories.isNotEmpty
                    ? categories[_selectedCategoryIndex]
                    : controller.selectedCategory.value;
                final selectedCategoryName =
                    selectedCategory?.name ?? 'Category';

                if (controller.isLoadingAvailableJobs.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: _C.primaryBlue),
                  );
                }

                if (controller.availableJobsError.value != null) {
                  return _buildErrorState(context, controller, l10n);
                }

                // Filter available jobs locally
                final filteredJobs = controller.availableJobs.where((job) {
                  // 1. Job Type
                  if (_selectedJobTypeIndex != 0) {
                    final selectedType = _jobTypeOptions[_selectedJobTypeIndex]
                        .toLowerCase();
                    final typeString = selectedType
                        .replaceAll('-', '_')
                        .replaceAll(' ', '_');
                    if (job.jobType.toLowerCase() != typeString) {
                      return false;
                    }
                  }

                  // 2. Salary
                  if (_selectedSalaryIndex != 0) {
                    if (!_matchSalary(job, _selectedSalaryIndex)) {
                      return false;
                    }
                  }

                  // 3. Education
                  if (_selectedEducationIndex != 0) {
                    final selectedEdu =
                        _educationOptions[_selectedEducationIndex]
                            .toLowerCase();
                    if (!job.educationLevel.toLowerCase().contains(
                      selectedEdu,
                    )) {
                      return false;
                    }
                  }

                  // 4. Experience
                  if (_selectedExperienceIndex != 0) {
                    if (!_matchExperience(job, _selectedExperienceIndex)) {
                      return false;
                    }
                  }

                  // 5. Freshness
                  if (_selectedFreshnessIndex != 0) {
                    if (!_matchFreshness(job, _selectedFreshnessIndex)) {
                      return false;
                    }
                  }

                  // 6. Location
                  if (_selectedLocationIndex != 0) {
                    final selectedLoc = _locationOptions[_selectedLocationIndex]
                        .toLowerCase();
                    final inLoc =
                        job.addressLine1.toLowerCase().contains(selectedLoc) ||
                        job.addressLine2.toLowerCase().contains(selectedLoc) ||
                        job.stateName.toLowerCase().contains(selectedLoc);
                    if (!inLoc) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterRow(categories),
                            const SizedBox(height: 18),
                            _buildLocationRow(),
                            const SizedBox(height: 8),
                            _buildCategoryHint(selectedCategoryName),
                            const SizedBox(height: 18),
                            if (filteredJobs.isEmpty)
                              _buildEmptyState(l10n)
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredJobs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 18),
                                itemBuilder: (context, index) {
                                  final job = filteredJobs[index];
                                  final categoryImg =
                                      selectedCategory?.imageUrl ?? '';
                                  return _buildJobCard(job, categoryImg, l10n);
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: _C.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _C.scaffoldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _C.darkText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(() {
              final roleName =
                  controller.selectedRole.value?.name ?? widget.role.name;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.text('jobs_available_title'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _C.darkText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    roleName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _C.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(List<JobCategory> categories) {
    final categoryLabel = categories.isEmpty
        ? 'Job Category'
        : categories[_selectedCategoryIndex].name;
    final roleLabel = controller.selectedRole.value?.name ?? widget.role.name;
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
            label: roleLabel,
            onTap: () => _showFilterSheet(
              categories: categories,
              initialSection: _FilterSection.role,
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
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.borderGrey, width: 1.2),
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
                    color: _C.chipText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _C.lightGrey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
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
                    color: _C.grey,
                    fontSize: 19,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                  ),
                ),
                TextSpan(
                  text: 'Film City, Sector 16A, Noida, Noida',
                  style: TextStyle(
                    color: _C.primaryBlue,
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
            color: _C.primaryBlue,
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
        color: _C.chipAccent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Showing jobs in $selectedCategoryName',
        style: const TextStyle(
          color: _C.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildJobCard(
    AvailableJob job,
    String categoryImageUrl,
    AppLocalizations l10n,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
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
                  NetworkImageService(
                    imageUrl: categoryImageUrl,
                    width: 58,
                    height: 58,
                    borderRadius: BorderRadius.circular(10),
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      width: 58,
                      height: 58,
                      color: _C.chipBg,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: _C.primaryBlue,
                        size: 28,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: _C.darkText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job.salaryDisplay,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _C.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _shareJob(job),
                    icon: const Icon(
                      Icons.share_rounded,
                      color: _C.grey,
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
                  const Icon(Icons.apartment_rounded, color: _C.grey, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.stateName.isNotEmpty ? job.stateName : 'Company',
                      style: const TextStyle(
                        fontSize: 18,
                        color: _C.grey,
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
                    color: _C.grey,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.addressLine1.isNotEmpty
                          ? job.addressLine1
                          : job.stateName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: _C.grey,
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
                  job.vacancy == 1 ? '1 Vacancy' : '${job.vacancy} Vacancies',
                  style: const TextStyle(
                    color: _C.darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 30.h,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _openWhatsApp(job.contactPhone, job.title),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _C.borderGrey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 5.sp),
                          foregroundColor: _C.darkText,
                          backgroundColor: Colors.white,
                        ),
                        icon: SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: Image.asset('assets/icons/whatsapp.png'),
                        ),
                        label: Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: () => _makeCall(job.contactPhone),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _C.yellow,
                          foregroundColor: _C.darkText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 5.sp),
                        ),
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: Text(
                          'Call HR',
                          style: TextStyle(
                            fontSize: 15.sp,
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _C.borderGrey, width: 1.2),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 34,
                        color: _C.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F2F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_off_outlined,
                color: _C.primaryBlue,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.text('jobs_no_jobs_found'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _C.grey,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    JobsController controller,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _C.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _C.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              controller.availableJobsError.value ??
                  l10n.text('jobs_no_jobs_found'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _C.darkText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final roleId =
                    controller.selectedRole.value?.id ?? widget.role.id;
                controller.fetchAvailableJobs(roleId);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.text('sell_retry')),
            ),
          ],
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
                                color: _C.darkText,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context, false),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: _C.darkText,
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
                                              ? _C.primaryBlue
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
                                            ? _C.primaryBlue
                                            : _C.darkText,
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
                                                setState(() {
                                                  _selectedCategoryIndex =
                                                      index;
                                                });
                                                await _changeCategory(category);
                                                setModalState(() {
                                                  activeSection =
                                                      _FilterSection.role;
                                                });
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
                                                          color: _C.darkText,
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
                                                              ? _C.darkText
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
                                                                color:
                                                                    _C.darkText,
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
                                              _changeCategory(categories.first);
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
                                              color: _C.darkText,
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
                                            backgroundColor: _C.yellow,
                                            foregroundColor: _C.darkText,
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
      _FilterSection.role => 'Job Role',
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
      _FilterSection.role => controller.jobRoles.map((r) => r.name).toList(),
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
      _FilterSection.role => () {
        final currentRole = controller.selectedRole.value;
        if (currentRole == null) return 0;
        final idx = controller.jobRoles.indexWhere(
          (r) => r.id == currentRole.id,
        );
        return idx != -1 ? idx : 0;
      }(),
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
          final cat = categories[_selectedCategoryIndex];
          _changeCategory(cat);
        }
        return;
      case _FilterSection.role:
        if (controller.jobRoles.isNotEmpty &&
            index >= 0 &&
            index < controller.jobRoles.length) {
          final newRole = controller.jobRoles[index];
          controller.selectRole(newRole);
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
            color: isSelected ? const Color(0xFFF7F8FC) : _C.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? _C.primaryBlue : _C.borderGrey,
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
                          color: _C.chipBg,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.category_rounded,
                            color: _C.primaryBlue,
                            size: 30,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          color: _C.primaryBlue.withValues(alpha: 0.12),
                        ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _C.primaryBlue
                                : Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSelected ? Icons.check_rounded : Icons.add,
                            size: 18,
                            color: isSelected ? Colors.white : _C.darkText,
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
                    color: _C.darkText,
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

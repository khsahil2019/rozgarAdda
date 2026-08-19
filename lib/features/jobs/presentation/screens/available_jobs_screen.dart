import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';
import 'package:open_share_plus/open.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:rojgar/features/jobs/presentation/screens/job_detail.dart';
import 'package:rojgar/features/jobs/presentation/widgets/job_card_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/network_image_service.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/entities/available_job_entity.dart';
import '../../domain/entities/job_category.dart';
import '../../domain/entities/job_role_entity.dart';
import '../controller/jobs_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../bindings/jobs_binding.dart';

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
  int? _filterStateId;
  int? _filterDistrictId;
  int? _filterLocalityId;
  String? _filterStateName;
  String? _filterDistrictName;
  String? _filterLocalityName;
  // String _currentLocation = 'Fetching location...';
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



  // Future<void> _getCurrentLocation() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       setState(() {
  //         _currentLocation = 'Location services disabled';
  //       });
  //       return;
  //     }

  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         setState(() {
  //           _currentLocation = 'Location permission denied';
  //         });
  //         return;
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       setState(() {
  //         _currentLocation = 'Location permission permanently denied';
  //       });
  //       return;
  //     }

  //     Position position = await Geolocator.getCurrentPosition(
  //       locationSettings: const LocationSettings(
  //         accuracy: LocationAccuracy.low,
  //       ),
  //     );

  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );

  //     if (placemarks.isNotEmpty) {
  //       final placemark = placemarks.first;
  //       final locality = placemark.subLocality ?? placemark.locality ?? '';
  //       final subAdministrativeArea = placemark.subAdministrativeArea ?? '';
  //       final administrativeArea = placemark.administrativeArea ?? '';

  //       String formattedLocation = '';
  //       if (locality.isNotEmpty) {
  //         formattedLocation += locality;
  //       }
  //       if (subAdministrativeArea.isNotEmpty) {
  //         if (formattedLocation.isNotEmpty) formattedLocation += ', ';
  //         formattedLocation += subAdministrativeArea;
  //       } else if (administrativeArea.isNotEmpty) {
  //         if (formattedLocation.isNotEmpty) formattedLocation += ', ';
  //         formattedLocation += administrativeArea;
  //       }

  //       if (formattedLocation.isEmpty) {
  //         formattedLocation = 'Noida';
  //       }

  //       setState(() {
  //         _currentLocation = formattedLocation;
  //       });
  //     } else {
  //       setState(() {
  //         _currentLocation = 'Noida';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _currentLocation = 'Film City, Noida';
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<JobsController>()) {
      JobsBinding().dependencies();
    }
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Fetch available jobs
      controller.fetchAvailableJobs(widget.role.id);

      // Fetch current location
      // await _getCurrentLocation();
    });
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
      await controller.logCallAndChatApply(
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
      await controller.logCallAndChatApply(
        jobId: jobId,
        type: 'chat',
        phone: phone,
      );
    } catch (e) {
      debugPrint('Error logging chat application: $e');
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final message = "Hello, I am interested in your job posting: \"$title\".";
    Open.whatsApp(whatsAppNumber: cleanPhone, text: message);
  }

  Future<void> _shareJob(AvailableJob job) async {
    await Share.share('https://rozgaradda.com/job-details/${job.id}');
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

                  return true;
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  _buildFilterRow(categories),
                                  const SizedBox(height: 18),
                                  // _buildLocationRow(),
                                  // const SizedBox(height: 8),
                                  _buildCategoryHint(selectedCategoryName),
                                  const SizedBox(height: 18),
                                ],
                              ),
                            ),
                            if (filteredJobs.isEmpty)
                              _buildEmptyState(l10n)
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredJobs.isEmpty
                                    ? 0
                                    : filteredJobs.length +
                                        (filteredJobs.length - 1) ~/ 3,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 18),
                                itemBuilder: (context, index) {
                                  final isBanner = (index + 1) % 4 == 0;
                                  if (isBanner) {
                                    return Image.asset(
                                      'assets/icons/warning.png',
                                      width: double.infinity,
                                      fit: BoxFit.fitWidth,
                                    );
                                  }
                                  final jobIndex = index - (index ~/ 4);
                                  final job = filteredJobs[jobIndex];
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A),
                  size: 18,
                ),
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
                    roleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    l10n.text('jobs_available_title').isNotEmpty
                        ? l10n.text('jobs_available_title')
                        : 'Explore Active Job Openings',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF4F46E5),
                  size: 12,
                ),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 11,
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
            label: _selectedJobTypeIndex == 0
                ? 'Job Type'
                : _jobTypeOptions[_selectedJobTypeIndex],
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
            label: _filterLocalityName ??
                _filterDistrictName ??
                _filterStateName ??
                'Location',
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
          constraints: BoxConstraints(minWidth: 35.sp, maxWidth: 180.sp),
          padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 3.sp),
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
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _C.chipText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 1.w),
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

  // Widget _buildLocationRow() {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Expanded(
  //         child: Text.rich(
  //           TextSpan(
  //             children: [
  //               const TextSpan(
  //                 text: 'Jobs near ',
  //                 style: TextStyle(
  //                   color: _C.grey,
  //                   fontSize: 19,
  //                   fontWeight: FontWeight.w400,
  //                   height: 1.25,
  //                 ),
  //               ),
  //               TextSpan(
  //                 text: _currentLocation,
  //                 style: const TextStyle(
  //                   color: _C.primaryBlue,
  //                   fontSize: 19,
  //                   fontWeight: FontWeight.w800,
  //                   height: 1.25,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       const Padding(
  //         padding: EdgeInsets.only(top: 14),
  //         child: Icon(
  //           Icons.chevron_right_rounded,
  //           color: _C.primaryBlue,
  //           size: 34,
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
    return JobCardWidget(
      job: job,
      imageUrl: categoryImageUrl,
      onWhatsAppTap: () => _openWhatsApp(
        job.whatsappNumber ?? job.contactPhone,
        job.title,
        job.id,
      ),
      onCallTap: () => _makeCall(job.contactPhone, job.id),
      onShareTap: () => _shareJob(job),
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

        int? tempStateId = _filterStateId;
        int? tempDistrictId = _filterDistrictId;
        int? tempLocalityId = _filterLocalityId;
        String? tempStateName = _filterStateName;
        String? tempDistrictName = _filterDistrictName;
        String? tempLocalityName = _filterLocalityName;

        if (controller.states.isEmpty) {
          controller.fetchStates();
        }
        if (tempStateId != null && controller.districts.isEmpty) {
          controller.fetchDistricts(tempStateId);
        }
        if (tempDistrictId != null && controller.localities.isEmpty) {
          controller.fetchLocalities(tempDistrictId);
        }

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
                                        fontSize: 13.sp,
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
                                                        style: TextStyle(
                                                          fontSize: 13.sp,
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
                              ],
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
                                  activeSection = _FilterSection.category;
                                });
                                if (categories.isNotEmpty) {
                                  _changeCategory(categories.first);
                                }
                                controller.fetchAvailableJobs(widget.role.id);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: _C.primaryBlue,
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
                                  color: _C.darkText,
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
                                controller.fetchAvailableJobs(
                                  widget.role.id,
                                  stateId: _filterStateId,
                                  districtId: _filterDistrictId,
                                  localityId: _filterLocalityId,
                                );
                                Navigator.pop(context, true);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _C.primaryBlue,
                                foregroundColor: _C.darkText,
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
      _FilterSection.location => [],
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
      _FilterSection.location => 0,
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
        return;
    }
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _C.darkText),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.borderGrey, width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: currentStateId,
                  isExpanded: true,
                  hint: Text(
                    controller.isLoadingStates.value
                        ? 'Loading states...'
                        : 'Select State',
                    style: const TextStyle(color: _C.grey, fontSize: 14),
                  ),
                  dropdownColor: Colors.white,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Any State'),
                    ),
                    ...controller.states.map(
                      (state) => DropdownMenuItem<int?>(
                        value: state.id,
                        child: Text(state.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: controller.isLoadingStates.value
                      ? null
                      : (value) {
                          String? name;
                          if (value != null) {
                            name = controller.states.firstWhere((s) => s.id == value).name;
                          }
                          onStateChanged(value, name);
                          if (value != null) {
                            controller.fetchDistricts(value);
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _C.darkText),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.borderGrey, width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: currentStateId == null ? null : currentDistrictId,
                  isExpanded: true,
                  hint: Text(
                    currentStateId == null
                        ? 'Select state first'
                        : controller.isLoadingDistricts.value
                            ? 'Loading districts...'
                            : 'Select District',
                    style: const TextStyle(color: _C.grey, fontSize: 14),
                  ),
                  dropdownColor: Colors.white,
                  items: currentStateId == null
                      ? []
                      : [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Any District'),
                          ),
                          ...controller.districts.map(
                            (district) => DropdownMenuItem<int?>(
                              value: district.id,
                              child: Text(district.name, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                  onChanged: (currentStateId == null || controller.isLoadingDistricts.value)
                      ? null
                      : (value) {
                          String? name;
                          if (value != null) {
                            name = controller.districts.firstWhere((d) => d.id == value).name;
                          }
                          onDistrictChanged(value, name);
                          if (value != null) {
                            controller.fetchLocalities(value);
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _C.darkText),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.borderGrey, width: 1.2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: currentDistrictId == null ? null : currentLocalityId,
                  isExpanded: true,
                  hint: Text(
                    currentDistrictId == null
                        ? 'Select district first'
                        : controller.isLoadingLocalities.value
                            ? 'Loading localities...'
                            : 'Select Locality',
                    style: const TextStyle(color: _C.grey, fontSize: 14),
                  ),
                  dropdownColor: Colors.white,
                  items: currentDistrictId == null
                      ? []
                      : [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Any Locality'),
                          ),
                          ...controller.localities.map(
                            (locality) => DropdownMenuItem<int?>(
                              value: locality.id,
                              child: Text(locality.name, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                  onChanged: (currentDistrictId == null || controller.isLoadingLocalities.value)
                      ? null
                      : (value) {
                          String? name;
                          if (value != null) {
                            name = controller.localities.firstWhere((l) => l.id == value).name;
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

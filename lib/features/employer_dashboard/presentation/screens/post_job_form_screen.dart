import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../jobs/domain/entities/available_job_entity.dart';
import '../controllers/employer_dashboard_controller.dart';
import '../../../auth/data/data_source/model/dropdown_item.dart';

class PostJobFormScreen extends StatefulWidget {
  const PostJobFormScreen({super.key});

  @override
  State<PostJobFormScreen> createState() => _PostJobFormScreenState();
}

class _PostJobFormScreenState extends State<PostJobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EmployerDashboardController controller = Get.find();

  // Premium Modern Color Palette
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightGreyText = Color(0xFF94A3B8);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color fieldBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);

  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  // Wizard Step Control (0 to 3)
  int _currentStep = 0;
  static const int _totalSteps = 4;

  final List<String> _stepTitles = [
    'Role & Basics',
    'Salary & Location',
    'Qualifications',
    'Interview & Contact',
  ];

  // Form Field Controllers
  final _titleCtrl = TextEditingController();
  final _vacancyCtrl = TextEditingController(text: '1');
  final _addressCtrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _fixedSalaryCtrl = TextEditingController();
  final _minSalaryCtrl = TextEditingController();
  final _maxSalaryCtrl = TextEditingController();
  final _avgIncentiveCtrl = TextEditingController();
  final _estimatedIncentiveCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactWhatsappCtrl = TextEditingController();

  // Walk-in Controllers
  final _walkinDateCtrl = TextEditingController();
  final _walkinTimeCtrl = TextEditingController();
  final _walkinEndTimeCtrl = TextEditingController();
  final _walkinVenueCtrl = TextEditingController();

  final _languagesCtrl = TextEditingController(text: 'Hindi, English');
  final _perksCtrl = TextEditingController();

  // Dropdown / Selection Values
  String _jobType = 'full_time'; // 'full_time', 'part_time', 'both'
  String _workLocationType = 'office'; // 'office', 'home', 'field'
  String _payType = 'fixed'; // 'fixed', 'fixed_inc', 'inc_only'
  String _educationLevel = 'Graduate';
  String _englishLevel = 'none'; // 'none', 'basic', 'good'
  String _experienceLevel = 'fresher'; // 'fresher', '1', '2', '3', '5'
  String _selectedShift = 'day'; // 'day', 'night', 'rotational', 'flexible'
  bool _isWalkin = false;
  bool _isSubmitting = false;

  // Contact preferences options (Min 1, Max 2)
  bool _applyOnly = true;
  bool _enableCall = false;
  bool _enableChat = false;

  int get _selectedContactOptionsCount =>
      (_applyOnly ? 1 : 0) + (_enableCall ? 1 : 0) + (_enableChat ? 1 : 0);

  // Dynamic Category & Role
  List<dynamic> _categories = [];
  List<dynamic> _roles = [];
  int? _selectedCategoryId;
  int? _selectedRoleId;
  bool _isCategoriesLoading = false;
  bool _isRolesLoading = false;

  // Cascading Location
  List<DropdownItem> _states = [];
  List<DropdownItem> _districts = [];
  List<DropdownItem> _localities = [];
  int? _selectedStateId;
  int? _selectedDistrictId;
  int? _selectedLocalityId;
  bool _isStatesLoading = false;
  bool _isDistrictsLoading = false;
  bool _isLocalitiesLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchStates();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() => _isCategoriesLoading = true);
    try {
      final res = await ApiService.get(
        ApiRoutes.dashboard,
        queryParameters: {'lang': Get.locale?.languageCode ?? 'en'},
      );
      if ((res['status'] == true || res['success'] == true) &&
          res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        final rawList = data['categories'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _categories = rawList;
            if (_categories.isNotEmpty) {
              _selectedCategoryId = _categories.first['id'] as int?;
              if (_selectedCategoryId != null) {
                _fetchRoles(_selectedCategoryId!);
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      if (mounted) {
        setState(() => _isCategoriesLoading = false);
      }
    }
  }

  Future<void> _fetchRoles(int categoryId) async {
    if (!mounted) return;
    setState(() {
      _isRolesLoading = true;
      _roles = [];
      _selectedRoleId = null;
    });
    try {
      final res = await ApiService.post(
        ApiRoutes.jobRoles,
        body: {'category_id': categoryId},
      );
      if (res['status'] == true || res['success'] == true) {
        final List<dynamic> rawList = res['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _roles = rawList;
            if (_roles.isNotEmpty) {
              _selectedRoleId = _roles.first['id'] as int?;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching roles: $e');
    } finally {
      if (mounted) {
        setState(() => _isRolesLoading = false);
      }
    }
  }

  Future<void> _fetchStates() async {
    if (!mounted) return;
    setState(() => _isStatesLoading = true);
    try {
      final res = await ApiService.get('https://rozgaradda.com/api/states');
      if (res['statusCode'] == 200) {
        final List<dynamic> raw = res['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _states = raw
                .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    } finally {
      if (mounted) {
        setState(() => _isStatesLoading = false);
      }
    }
  }

  Future<void> _fetchDistricts(int stateId) async {
    if (!mounted) return;
    setState(() {
      _isDistrictsLoading = true;
      _districts = [];
      _localities = [];
      _selectedDistrictId = null;
      _selectedLocalityId = null;
    });
    try {
      final res = await ApiService.get(
        'https://rozgaradda.com/api/districts/$stateId',
      );
      if (res['statusCode'] == 200) {
        final List<dynamic> raw = res['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _districts = raw
                .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    } finally {
      if (mounted) {
        setState(() => _isDistrictsLoading = false);
      }
    }
  }

  Future<void> _fetchLocalities(int districtId) async {
    if (!mounted) return;
    setState(() {
      _isLocalitiesLoading = true;
      _localities = [];
      _selectedLocalityId = null;
    });
    try {
      final res = await ApiService.get(
        'https://rozgaradda.com/api/localities/$districtId',
      );
      if (res['statusCode'] == 200) {
        final List<dynamic> raw = res['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _localities = raw
                .map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching localities: $e');
    } finally {
      if (mounted) {
        setState(() => _isLocalitiesLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _walkinDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController ctrl,
  ) async {
    final localizations = MaterialLocalizations.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedTime = localizations.formatTimeOfDay(
        picked,
        alwaysUse24HourFormat: false,
      );
      setState(() {
        ctrl.text = formattedTime;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _vacancyCtrl.dispose();
    _addressCtrl.dispose();
    _address2Ctrl.dispose();
    _pincodeCtrl.dispose();
    _fixedSalaryCtrl.dispose();
    _minSalaryCtrl.dispose();
    _maxSalaryCtrl.dispose();
    _avgIncentiveCtrl.dispose();
    _estimatedIncentiveCtrl.dispose();
    _skillsCtrl.dispose();
    _descCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactWhatsappCtrl.dispose();
    _walkinDateCtrl.dispose();
    _walkinTimeCtrl.dispose();
    _walkinEndTimeCtrl.dispose();
    _walkinVenueCtrl.dispose();
    _languagesCtrl.dispose();
    _perksCtrl.dispose();
    super.dispose();
  }

  // ==========================================
  // STEP VALIDATION & NAVIGATION
  // ==========================================
  void _handleBackNavigation() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      _showDiscardConfirmation();
    }
  }

  void _showDiscardConfirmation() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: warningOrange, size: 22),
            SizedBox(width: 8),
            Text(
              'Discard Job Post?',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit? Any information you entered will not be saved.',
          style: TextStyle(color: greyText, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue Editing', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_titleCtrl.text.trim().isEmpty) {
        _showValidationToast('Please enter a job title');
        return false;
      }
      if (_selectedCategoryId == null) {
        _showValidationToast('Please select a Job Category');
        return false;
      }
      if (_selectedRoleId == null && _roles.isNotEmpty) {
        _showValidationToast('Please select a Job Role');
        return false;
      }
      if (int.tryParse(_vacancyCtrl.text.trim()) == null ||
          int.parse(_vacancyCtrl.text.trim()) < 1) {
        _showValidationToast('Please enter a valid number of openings');
        return false;
      }
      return true;
    } else if (_currentStep == 1) {
      if (_payType == 'fixed') {
        if (_minSalaryCtrl.text.trim().isEmpty || _maxSalaryCtrl.text.trim().isEmpty) {
          _showValidationToast('Please enter both minimum and maximum salary');
          return false;
        }
      } else if (_payType == 'fixed_inc') {
        if (_fixedSalaryCtrl.text.trim().isEmpty) {
          _showValidationToast('Please enter the fixed base salary');
          return false;
        }
      } else if (_payType == 'inc_only') {
        if (_estimatedIncentiveCtrl.text.trim().isEmpty) {
          _showValidationToast('Please enter estimated incentive');
          return false;
        }
      }

      if (_workLocationType != 'home') {
        if (_selectedStateId == null) {
          _showValidationToast('Please select a State');
          return false;
        }
        if (_selectedDistrictId == null && _districts.isNotEmpty) {
          _showValidationToast('Please select a District / City');
          return false;
        }
        if (_selectedLocalityId == null && _localities.isNotEmpty) {
          _showValidationToast('Please select a Locality / Area');
          return false;
        }
        if (_addressCtrl.text.trim().isEmpty) {
          _showValidationToast('Please enter office/workplace address');
          return false;
        }
        if (_pincodeCtrl.text.trim().length != 6) {
          _showValidationToast('Please enter a valid 6-digit pincode');
          return false;
        }
      }
      return true;
    } else if (_currentStep == 2) {
      if (_skillsCtrl.text.trim().isEmpty) {
        _showValidationToast('Please add at least one key skill');
        return false;
      }
      return true;
    }
    return true;
  }

  void _showValidationToast(String message) {
    Get.snackbar(
      'Required Information',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
      } else {
        _submit();
      }
    }
  }

  void _submit() async {
    if (!_validateCurrentStep()) return;

    if (_isWalkin) {
      if (_walkinDateCtrl.text.trim().isEmpty ||
          _walkinTimeCtrl.text.trim().isEmpty ||
          _walkinEndTimeCtrl.text.trim().isEmpty ||
          _walkinVenueCtrl.text.trim().isEmpty) {
        _showValidationToast('Please complete all walk-in interview fields');
        return;
      }
    }

    final selectedOptionsCount = _selectedContactOptionsCount;
    if (selectedOptionsCount == 0) {
      _showValidationToast('Please select at least 1 contact method for applicants');
      return;
    }
    if (selectedOptionsCount > 2) {
      _showValidationToast('You can select a maximum of 2 contact options');
      return;
    }
    if (_enableCall && _contactPhoneCtrl.text.trim().length != 10) {
      _showValidationToast('Please provide a valid 10-digit phone number for calls');
      return;
    }
    if (_enableChat && _contactWhatsappCtrl.text.trim().length != 10) {
      _showValidationToast('Please provide a valid 10-digit WhatsApp number');
      return;
    }

    final List<String> skillsList = _skillsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final List<String> languagesList = _languagesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final List<String> perksList = _perksCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String stateNameSelected = 'Rajasthan';
    for (var s in _states) {
      if (s.id == _selectedStateId) {
        stateNameSelected = s.name;
        break;
      }
    }

    final newJob = AvailableJob(
      id: 0,
      employerId: controller.employerId.value,
      categoryId: _selectedCategoryId ?? 1,
      roleId: _selectedRoleId ?? 1,
      title: _titleCtrl.text.trim(),
      jobType: _jobType,
      shifts: [_selectedShift],
      workLocationType: _workLocationType,
      stateName: stateNameSelected,
      addressLine1: _workLocationType != 'home' ? _addressCtrl.text.trim() : '',
      addressLine2:
          _workLocationType != 'home' ? _address2Ctrl.text.trim() : '',
      pincode: _workLocationType != 'home' ? _pincodeCtrl.text.trim() : '',
      payType: _payType,
      fixedSalary:
          _payType == 'fixed_inc' ? _fixedSalaryCtrl.text.trim() : null,
      minSalary: _payType == 'fixed' ? _minSalaryCtrl.text.trim() : null,
      maxSalary: _payType == 'fixed' ? _maxSalaryCtrl.text.trim() : null,
      avgIncentive:
          _payType == 'fixed_inc' ? _avgIncentiveCtrl.text.trim() : null,
      estimatedIncentive:
          _payType == 'inc_only' ? _estimatedIncentiveCtrl.text.trim() : null,
      perks: perksList,
      educationLevel: _educationLevel,
      englishLevel: _englishLevel,
      experienceLevel: _experienceLevel,
      additionalRequirements: const {},
      skills: skillsList,
      languages: languagesList,
      jobDescription: _descCtrl.text.trim(),
      vacancy: int.tryParse(_vacancyCtrl.text) ?? 1,
      isWalkin: _isWalkin,
      walkinDate: _isWalkin ? _walkinDateCtrl.text.trim() : null,
      walkinTime: _isWalkin ? _walkinTimeCtrl.text.trim() : null,
      walkinEndTime: _isWalkin ? _walkinEndTimeCtrl.text.trim() : null,
      walkinVenue: _isWalkin ? _walkinVenueCtrl.text.trim() : null,
      contactPreference: '',
      contactPerson: null,
      contactPhone: _enableCall ? _contactPhoneCtrl.text.trim() : null,
      contactEmail: null,
      viewsCount: 0,
      applicationsCount: 0,
      status: 'active',
      createdAt: DateTime.now(),
      stateId: _selectedStateId,
      districtId: _selectedDistrictId,
      localiteId: _selectedLocalityId,
      whatsappNumber: _enableChat ? _contactWhatsappCtrl.text.trim() : null,
      applyOnly: _applyOnly,
      enableCall: _enableCall,
      enableChat: _enableChat,
    );

    setState(() => _isSubmitting = true);

    try {
      await controller.postNewJob(newJob);
      Get.back();
      Get.snackbar(
        'Job Published Successfully',
        'Your job opening is now live for verified candidates to apply.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: successGreen,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } catch (error) {
      Get.snackbar(
        'Failed to Post Job',
        error is Failure ? error.message : error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: _handleBackNavigation,
              tooltip: _currentStep > 0 ? 'Previous Step' : 'Back',
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post a New Job',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Step ${_currentStep + 1} of $_totalSteps • ${_stepTitles[_currentStep]}',
                style: const TextStyle(
                  color: primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: borderGrey),
          ),
        ),
        bottomNavigationBar: _buildStepBottomBar(),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // Wizard Step Progress Bar
              _buildStepProgressHeader(),

              // Scrollable Step Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildCurrentStepView(),
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
  // WIZARD STEP HEADER
  // ==========================================
  Widget _buildStepProgressHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Allow navigating to previous steps directly
                    if (index < _currentStep) {
                      setState(() => _currentStep = index);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 6),
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? successGreen
                          : (isCurrent ? primary : borderGrey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP CONTENT DISPATCHER
  // ==========================================
  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1RoleAndBasics();
      case 1:
        return _buildStep2SalaryAndLocation();
      case 2:
        return _buildStep3Qualifications();
      case 3:
        return _buildStep4InterviewAndContact();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // STEP 1: ROLE & BASICS
  // ==========================================
  Widget _buildStep1RoleAndBasics() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardSection(
          icon: Icons.business_center_rounded,
          title: 'Role & Employment Basics',
          subtitle: 'Define role title, domain, employment type, and shift',
          children: [
            _buildLabel('Job Title *'),
            _buildTextInput(
              controller: _titleCtrl,
              hint: 'e.g. Sales Executive, Delivery Partner, Graphic Designer',
              prefixIcon: Icons.title_rounded,
            ),
            const SizedBox(height: 14),

            // Category
            _buildLabel('Job Category *'),
            if (_isCategoriesLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(color: primary)),
              )
            else
              _buildModalSelector(
                hint: 'Select Industry Category',
                valueText:
                    _categories.firstWhereOrNull(
                      (c) => c['id'] == _selectedCategoryId,
                    )?['name']?.toString() ?? '',
                icon: Icons.category_rounded,
                onTap: () {
                  final items = _categories
                      .map((c) => MapEntry(c['id'] as int, (c['name'] ?? '').toString()))
                      .toList();
                  _showSearchBottomSheet(
                    title: 'Select Job Category',
                    items: items,
                    selectedId: _selectedCategoryId,
                    onSelected: (val) {
                      setState(() => _selectedCategoryId = val);
                      _fetchRoles(val);
                    },
                  );
                },
              ),
            const SizedBox(height: 14),

            // Role Dropdown
            if (_isRolesLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(color: primary)),
              )
            else if (_roles.isNotEmpty) ...[
              _buildLabel('Job Role *'),
              _buildDropdown<int?>(
                value: _selectedRoleId,
                items: _roles.map((r) {
                  return DropdownMenuItem<int?>(
                    value: r['id'] as int?,
                    child: Text(
                      (r['name'] ?? '').toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRoleId = val);
                  }
                },
              ),
              const SizedBox(height: 14),
            ],

            // Job Type
            _buildLabel('Job Type'),
            _buildPillSelector<String>(
              options: const [
                MapEntry('full_time', 'Full Time'),
                MapEntry('part_time', 'Part Time'),
                MapEntry('both', 'Both (Full / Part)'),
              ],
              selectedValue: _jobType,
              onSelected: (val) => setState(() => _jobType = val),
            ),
            const SizedBox(height: 14),

            // Work Mode
            _buildLabel('Work Mode'),
            _buildPillSelector<String>(
              options: const [
                MapEntry('office', '🏢 In-Office'),
                MapEntry('home', '🏠 Work From Home'),
                MapEntry('field', '🛵 Field Job'),
              ],
              selectedValue: _workLocationType,
              onSelected: (val) => setState(() => _workLocationType = val),
            ),
            const SizedBox(height: 14),

            // Vacancies & Shift
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Total Openings *'),
                      _buildTextInput(
                        controller: _vacancyCtrl,
                        hint: 'e.g. 5',
                        prefixIcon: Icons.group_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Working Shift'),
                      _buildDropdown<String>(
                        value: _selectedShift,
                        items: const [
                          DropdownMenuItem(value: 'day', child: Text('☀️ Day Shift')),
                          DropdownMenuItem(value: 'night', child: Text('🌙 Night Shift')),
                          DropdownMenuItem(value: 'rotational', child: Text('🔄 Rotational')),
                          DropdownMenuItem(value: 'flexible', child: Text('⏰ Flexible')),
                        ],
                        onChanged: (val) => setState(() => _selectedShift = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: SALARY & LOCATION
  // ==========================================
  Widget _buildStep2SalaryAndLocation() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Salary Card
        _buildCardSection(
          icon: Icons.payments_rounded,
          title: 'Salary & Compensation',
          subtitle: 'Define monthly compensation model and candidate perks',
          children: [
            _buildLabel('Compensation Model'),
            _buildPillSelector<String>(
              options: const [
                MapEntry('fixed', 'Fixed Range (Min - Max)'),
                MapEntry('fixed_inc', 'Fixed + Incentives'),
                MapEntry('inc_only', 'Incentive Only'),
              ],
              selectedValue: _payType,
              onSelected: (val) => setState(() => _payType = val),
            ),
            const SizedBox(height: 14),

            if (_payType == 'fixed')
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Min Salary (₹/mo) *'),
                        _buildTextInput(
                          controller: _minSalaryCtrl,
                          hint: 'e.g. 15000',
                          prefixIcon: Icons.currency_rupee_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Max Salary (₹/mo) *'),
                        _buildTextInput(
                          controller: _maxSalaryCtrl,
                          hint: 'e.g. 25000',
                          prefixIcon: Icons.currency_rupee_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else if (_payType == 'fixed_inc')
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Fixed Salary (₹/mo) *'),
                        _buildTextInput(
                          controller: _fixedSalaryCtrl,
                          hint: 'e.g. 18000',
                          prefixIcon: Icons.currency_rupee_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Avg. Incentive (₹/mo)'),
                        _buildTextInput(
                          controller: _avgIncentiveCtrl,
                          hint: 'e.g. 5000',
                          prefixIcon: Icons.add_circle_outline_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else if (_payType == 'inc_only')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Estimated Incentive (₹/mo) *'),
                  _buildTextInput(
                    controller: _estimatedIncentiveCtrl,
                    hint: 'e.g. 20000',
                    prefixIcon: Icons.currency_rupee_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

            const SizedBox(height: 14),

            _buildLabel('Perks & Benefits (Optional)'),
            _buildTextInput(
              controller: _perksCtrl,
              hint: 'e.g. PF, ESIC, Health Insurance, Travel Allowance',
              prefixIcon: Icons.card_giftcard_rounded,
            ),
            const SizedBox(height: 6),
            _buildQuickChips(
              chips: const [
                'PF & ESIC',
                'Travel Allowance',
                'Performance Bonus',
                'Health Insurance',
                'Flexible Hours',
              ],
              onSelected: (chip) {
                final current = _perksCtrl.text.trim();
                if (current.isEmpty) {
                  _perksCtrl.text = chip;
                } else if (!current.contains(chip)) {
                  _perksCtrl.text = '$current, $chip';
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Location Card (if not home)
        if (_workLocationType != 'home')
          _buildCardSection(
            icon: Icons.location_on_rounded,
            title: 'Job Location',
            subtitle: 'Where the employee will report for work daily',
            children: [
              _buildLabel('State *'),
              if (_isStatesLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(color: primary)),
                )
              else
                _buildModalSelector(
                  hint: 'Select State',
                  valueText:
                      _states.firstWhereOrNull((s) => s.id == _selectedStateId)?.name ?? '',
                  icon: Icons.map_rounded,
                  onTap: () {
                    final items = _states.map((s) => MapEntry(s.id, s.name)).toList();
                    _showSearchBottomSheet(
                      title: 'Select State',
                      items: items,
                      selectedId: _selectedStateId,
                      onSelected: (val) {
                        setState(() => _selectedStateId = val);
                        _fetchDistricts(val);
                      },
                    );
                  },
                ),
              const SizedBox(height: 14),

              // District & Locality
              if (_isDistrictsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(color: primary)),
                )
              else if (_districts.isNotEmpty) ...[
                _buildLabel('District / City *'),
                _buildDropdown<int?>(
                  value: _selectedDistrictId,
                  items: _districts.map((d) {
                    return DropdownMenuItem<int?>(
                      value: d.id,
                      child: Text(d.name, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedDistrictId = val);
                      _fetchLocalities(val);
                    }
                  },
                ),
                const SizedBox(height: 14),
              ],

              if (_isLocalitiesLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(color: primary)),
                )
              else if (_localities.isNotEmpty) ...[
                _buildLabel('Locality / Area *'),
                _buildDropdown<int?>(
                  value: _selectedLocalityId,
                  items: _localities.map((l) {
                    return DropdownMenuItem<int?>(
                      value: l.id,
                      child: Text(l.name, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedLocalityId = val),
                ),
                const SizedBox(height: 14),
              ],

              // Address Line 1
              _buildLabel('Office Address *'),
              _buildTextInput(
                controller: _addressCtrl,
                hint: 'Building name, street, nearby landmark',
                prefixIcon: Icons.apartment_rounded,
              ),
              const SizedBox(height: 14),

              // Address Line 2 & Pincode
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Address Line 2 (Optional)'),
                        _buildTextInput(
                          controller: _address2Ctrl,
                          hint: 'Floor, Suite, Unit',
                          prefixIcon: Icons.door_front_door_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Pincode *'),
                        _buildTextInput(
                          controller: _pincodeCtrl,
                          hint: '6 Digits',
                          prefixIcon: Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  // ==========================================
  // STEP 3: QUALIFICATIONS & SKILLS
  // ==========================================
  Widget _buildStep3Qualifications() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardSection(
          icon: Icons.school_rounded,
          title: 'Candidate Qualifications',
          subtitle: 'Required education, experience, language skills, and duties',
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Min. Education'),
                      _buildDropdown<String>(
                        value: _educationLevel,
                        items: const [
                          DropdownMenuItem(value: 'Below 10th', child: Text('Below 10th')),
                          DropdownMenuItem(value: '10th Pass', child: Text('10th Pass')),
                          DropdownMenuItem(value: '12th Pass', child: Text('12th Pass')),
                          DropdownMenuItem(value: 'Graduate', child: Text('Graduate')),
                          DropdownMenuItem(value: 'Post Graduate', child: Text('Post Graduate')),
                        ],
                        onChanged: (val) => setState(() => _educationLevel = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Experience Required'),
                      _buildDropdown<String>(
                        value: _experienceLevel,
                        items: const [
                          DropdownMenuItem(value: 'fresher', child: Text('Fresher')),
                          DropdownMenuItem(value: '1', child: Text('1+ Years')),
                          DropdownMenuItem(value: '2', child: Text('2+ Years')),
                          DropdownMenuItem(value: '3', child: Text('3+ Years')),
                          DropdownMenuItem(value: '5', child: Text('5+ Years')),
                        ],
                        onChanged: (val) => setState(() => _experienceLevel = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildLabel('English Speaking Requirement'),
            _buildPillSelector<String>(
              options: const [
                MapEntry('none', 'No English Required'),
                MapEntry('basic', 'Basic English'),
                MapEntry('good', 'Good / Fluent English'),
              ],
              selectedValue: _englishLevel,
              onSelected: (val) => setState(() => _englishLevel = val),
            ),
            const SizedBox(height: 14),

            _buildLabel('Key Skills *'),
            _buildTextInput(
              controller: _skillsCtrl,
              hint: 'e.g. Sales, Telecalling, MS Excel, Driving License',
              prefixIcon: Icons.star_outline_rounded,
            ),
            const SizedBox(height: 6),
            _buildQuickChips(
              chips: const [
                'Communication',
                'Basic Computer',
                'Customer Service',
                'MS Excel',
                'Driving License',
                'Field Sales',
              ],
              onSelected: (chip) {
                final current = _skillsCtrl.text.trim();
                if (current.isEmpty) {
                  _skillsCtrl.text = chip;
                } else if (!current.contains(chip)) {
                  _skillsCtrl.text = '$current, $chip';
                }
              },
            ),
            const SizedBox(height: 14),

            _buildLabel('Languages Known'),
            _buildTextInput(
              controller: _languagesCtrl,
              hint: 'e.g. Hindi, English, Regional',
              prefixIcon: Icons.language_rounded,
            ),
            const SizedBox(height: 14),

            _buildLabel('Job Description / Responsibilities (Optional)'),
            _buildTextInput(
              controller: _descCtrl,
              hint: 'Describe daily roles, key tasks, work environment...',
              prefixIcon: Icons.description_outlined,
              maxLines: 4,
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // STEP 4: INTERVIEW & CONTACT
  // ==========================================
  Widget _buildStep4InterviewAndContact() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Walk-in Interview Card
        _buildCardSection(
          icon: Icons.directions_walk_rounded,
          title: 'Walk-in Interview (Optional)',
          subtitle: 'Direct in-person interview dates and venue location',
          children: [
            Container(
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderGrey),
              ),
              child: SwitchListTile(
                activeTrackColor: primary,
                activeThumbColor: Colors.white,
                title: const Text(
                  'Enable Direct Walk-in Interviews',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: const Text(
                  'Candidates are invited to your venue on specific interview dates',
                  style: TextStyle(color: greyText, fontSize: 11.5),
                ),
                value: _isWalkin,
                onChanged: (val) => setState(() => _isWalkin = val),
              ),
            ),

            if (_isWalkin) ...[
              const SizedBox(height: 14),
              _buildLabel('Walk-in Interview Date *'),
              _buildModalSelector(
                hint: 'Select Date',
                valueText: _walkinDateCtrl.text,
                icon: Icons.calendar_today_rounded,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Start Time *'),
                        _buildModalSelector(
                          hint: 'e.g. 10:00 AM',
                          valueText: _walkinTimeCtrl.text,
                          icon: Icons.access_time_rounded,
                          onTap: () => _selectTime(context, _walkinTimeCtrl),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('End Time *'),
                        _buildModalSelector(
                          hint: 'e.g. 05:00 PM',
                          valueText: _walkinEndTimeCtrl.text,
                          icon: Icons.access_time_filled_rounded,
                          onTap: () => _selectTime(context, _walkinEndTimeCtrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildLabel('Walk-in Venue Address *'),
              _buildTextInput(
                controller: _walkinVenueCtrl,
                hint: 'Complete office address with landmark for walk-in candidates',
                prefixIcon: Icons.place_rounded,
                maxLines: 2,
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Contact Channels Card
        _buildCardSection(
          icon: Icons.connect_without_contact_rounded,
          title: 'Applicant Contact Channels',
          subtitle: 'Choose how candidates can connect with you (Select 1 or 2 options)',
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: warningLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: warningOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: warningOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select between 1 and 2 contact methods for job seekers.',
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // In-App Applications
            _buildContactCard(
              title: 'In-App Applications',
              subtitle: 'Candidates submit profiles directly through Rozgar Adda portal.',
              icon: Icons.assignment_turned_in_rounded,
              value: _applyOnly,
              onChanged: (val) {
                if (val == null) return;
                final count = _selectedContactOptionsCount;
                if (val) {
                  if (count < 2) {
                    setState(() => _applyOnly = true);
                  } else {
                    _showMaxOptionsWarning();
                  }
                } else {
                  if (count > 1) {
                    setState(() => _applyOnly = false);
                  } else {
                    _showMinOptionsWarning();
                  }
                }
              },
            ),

            const SizedBox(height: 10),

            // Direct Phone Calls
            _buildContactCard(
              title: 'Direct Phone Calls',
              subtitle: 'Qualified candidates can call your recruitment contact number.',
              icon: Icons.phone_in_talk_rounded,
              value: _enableCall,
              onChanged: (val) {
                if (val == null) return;
                final count = _selectedContactOptionsCount;
                if (val) {
                  if (count < 2) {
                    setState(() => _enableCall = true);
                  } else {
                    _showMaxOptionsWarning();
                  }
                } else {
                  if (count > 1) {
                    setState(() => _enableCall = false);
                  } else {
                    _showMinOptionsWarning();
                  }
                }
              },
            ),

            if (_enableCall) ...[
              const SizedBox(height: 10),
              _buildLabel('HR / Recruitment Mobile Number *'),
              _buildTextInput(
                controller: _contactPhoneCtrl,
                hint: '10-digit mobile number',
                prefixIcon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
            ],

            const SizedBox(height: 10),

            // WhatsApp Chat
            _buildContactCard(
              title: 'WhatsApp Chat',
              subtitle: 'Candidates can message directly to your recruitment WhatsApp number.',
              icon: Icons.chat_rounded,
              value: _enableChat,
              onChanged: (val) {
                if (val == null) return;
                final count = _selectedContactOptionsCount;
                if (val) {
                  if (count < 2) {
                    setState(() => _enableChat = true);
                  } else {
                    _showMaxOptionsWarning();
                  }
                } else {
                  if (count > 1) {
                    setState(() => _enableChat = false);
                  } else {
                    _showMinOptionsWarning();
                  }
                }
              },
            ),

            if (_enableChat) ...[
              const SizedBox(height: 10),
              _buildLabel('WhatsApp Contact Number *'),
              _buildTextInput(
                controller: _contactWhatsappCtrl,
                hint: '10-digit WhatsApp number',
                prefixIcon: Icons.message_rounded,
                keyboardType: TextInputType.phone,
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ==========================================
  // STICKY BOTTOM ACTION BAR (BACK & NEXT)
  // ==========================================
  Widget _buildStepBottomBar() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: borderGrey, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back Button on Steps > 0
            if (_currentStep > 0) ...[
              OutlinedButton.icon(
                onPressed: _handleBackNavigation,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: darkText,
                  side: const BorderSide(color: borderGrey, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Next / Publish Button
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastStep ? successGreen : primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLastStep
                                  ? 'Publish Job Opening'
                                  : 'Continue to Step ${_currentStep + 2}',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLastStep
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UI HELPERS & COMPONENTS
  // ==========================================
  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: darkText,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: darkText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: lightGreyText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(prefixIcon, color: greyText, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildModalSelector({
    required String hint,
    required String valueText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasValue = valueText.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderGrey),
          ),
          child: Row(
            children: [
              Icon(icon, color: greyText, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasValue ? valueText : hint,
                  style: TextStyle(
                    color: hasValue ? darkText : lightGreyText,
                    fontSize: 14,
                    fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: greyText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: greyText,
            size: 20,
          ),
          style: const TextStyle(
            color: darkText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPillSelector<T>({
    required List<MapEntry<T, String>> options,
    required T selectedValue,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((entry) {
        final isSelected = entry.key == selectedValue;
        return InkWell(
          onTap: () => onSelected(entry.key),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary : fieldBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? primary : borderGrey),
            ),
            child: Text(
              entry.value,
              style: TextStyle(
                color: isSelected ? Colors.white : darkText,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickChips({
    required List<String> chips,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: chips.map((chip) {
        return InkWell(
          onTap: () => onSelected(chip),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 12, color: primary),
                const SizedBox(width: 3),
                Text(
                  chip,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value ? primary.withValues(alpha: 0.04) : fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? primary : borderGrey,
          width: value ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        activeColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(icon, color: value ? primary : greyText, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: value ? darkText : mediumText,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: greyText, fontSize: 11.5),
          ),
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  void _showMaxOptionsWarning() {
    Get.snackbar(
      'Maximum Options Selected',
      'You can select up to 2 contact options.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: warningOrange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showMinOptionsWarning() {
    Get.snackbar(
      'Minimum Option Required',
      'You must keep at least 1 contact method selected.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: warningOrange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showSearchBottomSheet({
    required String title,
    required List<MapEntry<int, String>> items,
    required int? selectedId,
    required ValueChanged<int> onSelected,
  }) {
    String searchQuery = '';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final filteredItems = items
              .where(
                (item) => item.value.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded, color: greyText),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: fieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderGrey),
                    ),
                    child: TextField(
                      autofocus: false,
                      onChanged: (val) {
                        setSheetState(() {
                          searchQuery = val;
                        });
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search items...',
                        hintStyle: TextStyle(color: lightGreyText, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: greyText, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No items match your search',
                            style: TextStyle(color: greyText, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final isSelected = item.key == selectedId;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: isSelected
                                    ? primary.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                title: Text(
                                  item.value,
                                  style: TextStyle(
                                    color: isSelected ? primary : darkText,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: primary,
                                        size: 20,
                                      )
                                    : null,
                                onTap: () {
                                  onSelected(item.key);
                                  Get.back();
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

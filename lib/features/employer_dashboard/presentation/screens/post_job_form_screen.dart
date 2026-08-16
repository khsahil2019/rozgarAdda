import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
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

  // Color constants matching modern design system
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color fieldBg = Color(0xFFF7F8FF);
  static const Color borderColor = Color(0xFFD0D5F5);

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
  final _contactPersonCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();

  // Walkin Controllers
  final _walkinDateCtrl = TextEditingController();
  final _walkinTimeCtrl = TextEditingController();
  final _walkinEndTimeCtrl = TextEditingController();
  final _walkinVenueCtrl = TextEditingController();

  final _languagesCtrl = TextEditingController(text: 'Hindi, English');
  final _perksCtrl = TextEditingController();

  // Dropdown / Selection Values
  String _jobType = 'full_time';
  String _workLocationType = 'office';
  String _payType = 'fixed';
  String _educationLevel = 'Graduate';
  String _englishLevel = 'none';
  String _experienceLevel = 'fresher';
  String _selectedShift = 'day';
  bool _isWalkin = false;

  // Contact preferences options
  bool _applyOnly = true;
  bool _enableCall = false;
  bool _enableChat = false;
  final _contactWhatsappCtrl = TextEditingController();

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
        // queryParameters: {'lang': Get.locale?.languageCode ?? 'en'},
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
      _selectedDistrictId = null;
      _localities = [];
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _walkinDateCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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
      initialTime: TimeOfDay.now(),
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
    _contactPersonCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactEmailCtrl.dispose();
    _walkinDateCtrl.dispose();
    _walkinTimeCtrl.dispose();
    _walkinEndTimeCtrl.dispose();
    _walkinVenueCtrl.dispose();
    _languagesCtrl.dispose();
    _perksCtrl.dispose();
    _contactWhatsappCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    if (_selectedCategoryId == null || _selectedRoleId == null) {
      Get.snackbar(
        l10n.text('post_job_error_title'),
        l10n.text('post_job_error_category_role'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (_workLocationType != 'home') {
      if (_selectedStateId == null ||
          _selectedDistrictId == null ||
          _selectedLocalityId == null) {
        Get.snackbar(
          l10n.text('post_job_error_title'),
          l10n.text('post_job_error_location'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
    }
    if (!_formKey.currentState!.validate()) return;

    final selectedOptionsCount = _selectedContactOptionsCount;
    if (selectedOptionsCount == 0) {
      Get.snackbar(
        l10n.text('post_job_error_title'),
        l10n.text('post_job_error_contact_min'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (selectedOptionsCount > 2) {
      Get.snackbar(
        l10n.text('post_job_error_title'),
        l10n.text('post_job_error_contact_max'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (_enableCall && _contactPhoneCtrl.text.trim().isEmpty) {
      Get.snackbar(
        l10n.text('post_job_error_title'),
        l10n.text('post_job_error_phone_required'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (_enableChat && _contactWhatsappCtrl.text.trim().isEmpty) {
      Get.snackbar(
        l10n.text('post_job_error_title'),
        l10n.text('post_job_error_whatsapp_required'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
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

    // Finding selected state name
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
      categoryId: _selectedCategoryId!,
      roleId: _selectedRoleId!,
      title: _titleCtrl.text.trim(),
      jobType: _jobType,
      shifts: [_selectedShift],
      workLocationType: _workLocationType,
      stateName: stateNameSelected,
      addressLine1: _workLocationType != 'home' ? _addressCtrl.text.trim() : '',
      addressLine2: _workLocationType != 'home'
          ? _address2Ctrl.text.trim()
          : '',
      pincode: _workLocationType != 'home' ? _pincodeCtrl.text.trim() : '',
      payType: _payType,
      fixedSalary: _payType == 'fixed_inc'
          ? _fixedSalaryCtrl.text.trim()
          : null,
      minSalary: _payType == 'fixed' ? _minSalaryCtrl.text.trim() : null,
      maxSalary: _payType == 'fixed' ? _maxSalaryCtrl.text.trim() : null,
      avgIncentive: _payType == 'fixed_inc'
          ? _avgIncentiveCtrl.text.trim()
          : null,
      estimatedIncentive: _payType == 'inc_only'
          ? _estimatedIncentiveCtrl.text.trim()
          : null,
      perks: perksList,
      educationLevel: _educationLevel,
      englishLevel: _englishLevel,
      experienceLevel: _experienceLevel.toString(),
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

    controller
        .postNewJob(newJob)
        .then((_) {
          Get.back();
          Get.snackbar(
            l10n.text('post_job_success_title'),
            l10n.text('post_job_success_message'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        })
        .catchError((error) {
          Get.snackbar(
            l10n.text('post_job_error_title'),
            error is Failure ? error.message : error.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.text('employer_dashboard_post_job'),
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.text('post_job_section_job_details')),
              _buildTextField(
                label: l10n.text('post_job_title_label'),
                hint: l10n.text('post_job_title_hint'),
                controller: _titleCtrl,
                validator: (val) =>
                    val!.trim().isEmpty ? l10n.text('post_job_title_error') : null,
              ),

              if (_isCategoriesLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                )
              else if (_categories.isNotEmpty)
                _buildSelectorField(
                  label: l10n.text('post_job_category_label'),
                  valueText:
                      _categories
                          .firstWhere(
                            (c) => c['id'] == _selectedCategoryId,
                            orElse: () => {'name': ''},
                          )['name']
                          ?.toString() ??
                      '',
                  onTap: () {
                    final items = _categories
                        .map(
                          (c) => MapEntry(
                            c['id'] as int,
                            (c['name'] ?? '').toString(),
                          ),
                        )
                        .toList();
                    _showSearchBottomSheet(
                      title: l10n.text('post_job_category_select'),
                      items: items,
                      selectedId: _selectedCategoryId,
                      onSelected: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                        _fetchRoles(val);
                      },
                    );
                  },
                ),

              if (_isRolesLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                )
              else if (_roles.isNotEmpty)
                _buildDropdownField<int?>(
                  label: l10n.text('post_job_role_label'),
                  value: _selectedRoleId,
                  items: _roles.map((r) {
                    return DropdownMenuItem<int?>(
                      value: r['id'] as int?,
                      child: Text((r['name'] ?? '').toString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRoleId = val;
                      });
                    }
                  },
                ),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: l10n.text('post_job_type_label'),
                      value: _jobType,
                      items: [
                        DropdownMenuItem(
                          value: 'full_time',
                          child: Text(l10n.text('post_job_type_full_time')),
                        ),
                        DropdownMenuItem(
                          value: 'part_time',
                          child: Text(l10n.text('post_job_type_part_time')),
                        ),
                        DropdownMenuItem(value: 'both', child: Text(l10n.text('post_job_type_both'))),
                      ],
                      onChanged: (val) => setState(() => _jobType = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: l10n.text('post_job_work_location_label'),
                      value: _workLocationType,
                      items: [
                        DropdownMenuItem(
                          value: 'office',
                          child: Text(l10n.text('post_job_work_location_office')),
                        ),
                        DropdownMenuItem(
                          value: 'home',
                          child: Text(l10n.text('post_job_work_location_home')),
                        ),
                        DropdownMenuItem(value: 'field', child: Text(l10n.text('post_job_work_location_field'))),
                      ],
                      onChanged: (val) =>
                          setState(() => _workLocationType = val!),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: l10n.text('post_job_vacancies_label'),
                      hint: l10n.text('post_job_vacancies_hint'),
                      controller: _vacancyCtrl,
                      keyboardType: TextInputType.number,
                      validator: (val) => int.tryParse(val ?? '') == null
                          ? l10n.text('post_job_vacancies_error')
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: l10n.text('post_job_shift_label'),
                      value: _selectedShift,
                      items: [
                        DropdownMenuItem(
                          value: 'day',
                          child: Text(l10n.text('post_job_shift_day')),
                        ),
                        DropdownMenuItem(
                          value: 'night',
                          child: Text(l10n.text('post_job_shift_night')),
                        ),
                        DropdownMenuItem(
                          value: 'rotational',
                          child: Text(l10n.text('post_job_shift_rotational')),
                        ),
                        DropdownMenuItem(
                          value: 'flexible',
                          child: Text(l10n.text('post_job_shift_flexible')),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedShift = val!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionTitle(l10n.text('post_job_section_salary')),
              _buildDropdownField<String>(
                label: l10n.text('post_job_salary_model_label'),
                value: _payType,
                items: [
                  DropdownMenuItem(
                    value: 'fixed',
                    child: Text(l10n.text('post_job_salary_fixed')),
                  ),
                  DropdownMenuItem(
                    value: 'fixed_inc',
                    child: Text(l10n.text('post_job_salary_fixed_inc')),
                  ),
                  DropdownMenuItem(
                    value: 'inc_only',
                    child: Text(l10n.text('post_job_salary_inc_only')),
                  ),
                ],
                onChanged: (val) => setState(() => _payType = val!),
              ),

              if (_payType == 'fixed')
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: l10n.text('post_job_min_salary_label'),
                        hint: l10n.text('post_job_min_salary_hint'),
                        controller: _minSalaryCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim().isEmpty ? l10n.text('post_job_min_salary_error') : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: l10n.text('post_job_max_salary_label'),
                        hint: l10n.text('post_job_max_salary_hint'),
                        controller: _maxSalaryCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim().isEmpty ? l10n.text('post_job_max_salary_error') : null,
                      ),
                    ),
                  ],
                )
              else if (_payType == 'fixed_inc')
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: l10n.text('post_job_fixed_salary_label'),
                        hint: l10n.text('post_job_fixed_salary_hint'),
                        controller: _fixedSalaryCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim().isEmpty ? l10n.text('post_job_fixed_salary_error') : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: l10n.text('post_job_avg_incentive_label'),
                        hint: l10n.text('post_job_avg_incentive_hint'),
                        controller: _avgIncentiveCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim().isEmpty ? l10n.text('post_job_avg_incentive_error') : null,
                      ),
                    ),
                  ],
                )
              else if (_payType == 'inc_only')
                _buildTextField(
                  label: l10n.text('post_job_estimated_incentive_label'),
                  hint: l10n.text('post_job_estimated_incentive_hint'),
                  controller: _estimatedIncentiveCtrl,
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val!.trim().isEmpty ? l10n.text('post_job_estimated_incentive_error') : null,
                ),

              if (_workLocationType != 'home') ...[
                const SizedBox(height: 20),
                _buildSectionTitle(
                  '${_workLocationType.toUpperCase()} ${l10n.text('post_job_section_location')}',
                ),

                if (_isStatesLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    ),
                  )
                else
                  _buildSelectorField(
                    label: l10n.text('post_job_state_label'),
                    valueText: _states
                        .firstWhere(
                          (s) => s.id == _selectedStateId,
                          orElse: () => const DropdownItem(id: 0, name: ''),
                        )
                        .name,
                    onTap: () {
                      final items = _states
                          .map((s) => MapEntry(s.id, s.name))
                          .toList();
                      _showSearchBottomSheet(
                        title: l10n.text('post_job_state_select'),
                        items: items,
                        selectedId: _selectedStateId,
                        onSelected: (val) {
                          setState(() {
                            _selectedStateId = val;
                          });
                          _fetchDistricts(val);
                        },
                      );
                    },
                  ),

                if (_isDistrictsLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    ),
                  )
                else if (_districts.isNotEmpty)
                  _buildDropdownField<int?>(
                    label: l10n.text('post_job_district_label'),
                    value: _selectedDistrictId,
                    items: _districts.map((d) {
                      return DropdownMenuItem<int?>(
                        value: d.id,
                        child: Text(d.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDistrictId = val;
                        });
                        _fetchLocalities(val);
                      }
                    },
                  ),

                if (_isLocalitiesLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    ),
                  )
                else if (_localities.isNotEmpty)
                  _buildDropdownField<int?>(
                    label: l10n.text('post_job_locality_label'),
                    value: _selectedLocalityId,
                    items: _localities.map((l) {
                      return DropdownMenuItem<int?>(
                        value: l.id,
                        child: Text(l.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedLocalityId = val;
                      });
                    },
                  ),

                _buildTextField(
                  label: l10n.text('post_job_address1_label'),
                  hint: l10n.text('post_job_address1_hint'),
                  controller: _addressCtrl,
                  validator: (val) =>
                      val!.trim().isEmpty ? l10n.text('post_job_address1_error') : null,
                ),
                _buildTextField(
                  label: l10n.text('post_job_address2_label'),
                  hint: l10n.text('post_job_address2_hint'),
                  controller: _address2Ctrl,
                ),
                _buildTextField(
                  label: l10n.text('post_job_pincode_label'),
                  hint: l10n.text('post_job_pincode_hint'),
                  controller: _pincodeCtrl,
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.trim().length != 6
                      ? l10n.text('post_job_pincode_error')
                      : null,
                ),
              ],

              const SizedBox(height: 20),
              _buildSectionTitle(l10n.text('post_job_section_requirements')),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: l10n.text('post_job_education_label'),
                      value: _educationLevel,
                      items: [
                        DropdownMenuItem(
                          value: 'Below 10th',
                          child: Text(l10n.text('post_job_education_below_10')),
                        ),
                        DropdownMenuItem(
                          value: '10th Pass',
                          child: Text(l10n.text('post_job_education_10_pass')),
                        ),
                        DropdownMenuItem(
                          value: '12th Pass',
                          child: Text(l10n.text('post_job_education_12_pass')),
                        ),
                        DropdownMenuItem(
                          value: 'Graduate',
                          child: Text(l10n.text('post_job_education_graduate')),
                        ),
                        DropdownMenuItem(
                          value: 'Post Graduate',
                          child: Text(l10n.text('post_job_education_post_graduate')),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _educationLevel = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: l10n.text('post_job_experience_label'),
                      value: _experienceLevel,
                      items: [
                        DropdownMenuItem(
                          value: 'fresher',
                          child: Text(l10n.text('post_job_experience_fresher')),
                        ),
                        DropdownMenuItem(value: '1', child: Text(l10n.text('post_job_experience_1'))),
                        DropdownMenuItem(value: '2', child: Text(l10n.text('post_job_experience_2'))),
                        DropdownMenuItem(value: '3', child: Text(l10n.text('post_job_experience_3'))),
                        DropdownMenuItem(value: '5', child: Text(l10n.text('post_job_experience_5plus'))),
                      ],
                      onChanged: (val) =>
                          setState(() => _experienceLevel = val!),
                    ),
                  ),
                ],
              ),
              _buildDropdownField<String>(
                label: l10n.text('post_job_english_label'),
                value: _englishLevel,
                items: [
                  DropdownMenuItem(
                    value: 'none',
                    child: Text(l10n.text('post_job_english_none')),
                  ),
                  DropdownMenuItem(
                    value: 'basic',
                    child: Text(l10n.text('post_job_english_basic')),
                  ),
                  DropdownMenuItem(
                    value: 'good',
                    child: Text(l10n.text('post_job_english_good')),
                  ),
                ],
                onChanged: (val) => setState(() => _englishLevel = val!),
              ),
              _buildTextField(
                label: l10n.text('post_job_skills_label'),
                hint: l10n.text('post_job_skills_hint'),
                controller: _skillsCtrl,
                validator: (val) =>
                    val!.trim().isEmpty ? l10n.text('post_job_skills_error') : null,
              ),
              _buildTextField(
                label: l10n.text('post_job_languages_label'),
                hint: l10n.text('post_job_languages_hint'),
                controller: _languagesCtrl,
              ),
              _buildTextField(
                label: l10n.text('post_job_perks_label'),
                hint: l10n.text('post_job_perks_hint'),
                controller: _perksCtrl,
              ),
              _buildTextField(
                label: l10n.text('post_job_description_label'),
                hint:
                    l10n.text('post_job_description_hint'),
                controller: _descCtrl,
                maxLines: 4,
              ),

              const SizedBox(height: 20),
              _buildSectionTitle(l10n.text('post_job_section_walkin')),
              Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: SwitchListTile(
                  activeThumbColor: primaryBlue,
                  title: Text(
                    l10n.text('post_job_walkin_switch'),
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _isWalkin,
                  onChanged: (val) => setState(() => _isWalkin = val),
                ),
              ),

              if (_isWalkin) ...[
                const SizedBox(height: 16),
                _buildTapToSelectField(
                  label: l10n.text('post_job_walkin_date_label'),
                  hint: l10n.text('post_job_walkin_date_hint'),
                  controller: _walkinDateCtrl,
                  onTap: () => _selectDate(context),
                  validator: (val) =>
                      val!.trim().isEmpty ? l10n.text('post_job_walkin_date_error') : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTapToSelectField(
                        label: l10n.text('post_job_walkin_start_label'),
                        hint: l10n.text('post_job_walkin_time_hint'),
                        controller: _walkinTimeCtrl,
                        onTap: () => _selectTime(context, _walkinTimeCtrl),
                        validator: (val) => val!.trim().isEmpty
                            ? l10n.text('post_job_walkin_start_error')
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTapToSelectField(
                        label: l10n.text('post_job_walkin_end_label'),
                        hint: l10n.text('post_job_walkin_time_hint'),
                        controller: _walkinEndTimeCtrl,
                        onTap: () => _selectTime(context, _walkinEndTimeCtrl),
                        validator: (val) =>
                            val!.trim().isEmpty ? l10n.text('post_job_walkin_end_error') : null,
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  label: l10n.text('post_job_walkin_venue_label'),
                  hint: l10n.text('post_job_walkin_venue_hint'),
                  controller: _walkinVenueCtrl,
                  maxLines: 2,
                  validator: (val) =>
                      val!.trim().isEmpty ? l10n.text('post_job_walkin_venue_error') : null,
                ),
              ],

              const SizedBox(height: 20),
              _buildSectionTitle(l10n.text('post_job_section_contact')),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.text('post_job_contact_instruction'),
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              _buildContactOptionTile(
                title: l10n.text('post_job_contact_apply_title'),
                subtitle: l10n.text('post_job_contact_apply_subtitle'),
                value: _applyOnly,
                onChanged: (val) {
                  if (val == null) return;
                  final currentCount = _selectedContactOptionsCount;
                  if (val) {
                    if (currentCount < 2) {
                      setState(() => _applyOnly = true);
                    } else {
                      _showMaxOptionsWarning();
                    }
                  } else {
                    if (currentCount > 1) {
                      setState(() => _applyOnly = false);
                    } else {
                      _showMinOptionsWarning();
                    }
                  }
                },
              ),
              const SizedBox(height: 10),

              _buildContactOptionTile(
                title: l10n.text('post_job_contact_call_title'),
                subtitle: l10n.text('post_job_contact_call_subtitle'),
                value: _enableCall,
                onChanged: (val) {
                  if (val == null) return;
                  final currentCount = _selectedContactOptionsCount;
                  if (val) {
                    if (currentCount < 2) {
                      setState(() => _enableCall = true);
                    } else {
                      _showMaxOptionsWarning();
                    }
                  } else {
                    if (currentCount > 1) {
                      setState(() => _enableCall = false);
                    } else {
                      _showMinOptionsWarning();
                    }
                  }
                },
              ),
              const SizedBox(height: 10),

              _buildContactOptionTile(
                title: l10n.text('post_job_contact_whatsapp_title'),
                subtitle: l10n.text('post_job_contact_whatsapp_subtitle'),
                value: _enableChat,
                onChanged: (val) {
                  if (val == null) return;
                  final currentCount = _selectedContactOptionsCount;
                  if (val) {
                    if (currentCount < 2) {
                      setState(() => _enableChat = true);
                    } else {
                      _showMaxOptionsWarning();
                    }
                  } else {
                    if (currentCount > 1) {
                      setState(() => _enableChat = false);
                    } else {
                      _showMinOptionsWarning();
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              if (_enableCall)
                _buildTextField(
                  label: l10n.text('post_job_contact_phone_label'),
                  hint: l10n.text('post_job_contact_phone_hint'),
                  controller: _contactPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (_enableCall) {
                      if (val == null || val.trim().length != 10) {
                        return l10n.text('post_job_contact_phone_error');
                      }
                    }
                    return null;
                  },
                ),

              if (_enableChat)
                _buildTextField(
                  label: l10n.text('post_job_whatsapp_label'),
                  hint: l10n.text('post_job_whatsapp_hint'),
                  controller: _contactWhatsappCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (_enableChat) {
                      if (val == null || val.trim().length != 10) {
                        return l10n.text('post_job_whatsapp_error');
                      }
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    l10n.text('post_job_submit_button'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Container(width: 40, height: 3, color: primaryBlue),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(color: darkText, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: greyText, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapToSelectField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              child: Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  style: const TextStyle(color: darkText, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: greyText, fontSize: 14),
                    suffixIcon: const Icon(
                      Icons.calendar_today_rounded,
                      color: primaryBlue,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                items: items,
                onChanged: onChanged,
                isExpanded: true,
                style: const TextStyle(color: darkText, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMaxOptionsWarning() {
    final l10n = context.l10n;
    Get.snackbar(
      l10n.text('post_job_limit_title'),
      l10n.text('post_job_limit_message'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showMinOptionsWarning() {
    final l10n = context.l10n;
    Get.snackbar(
      l10n.text('post_job_selection_title'),
      l10n.text('post_job_selection_message'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  Widget _buildContactOptionTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final count = _selectedContactOptionsCount;
    final bool isDisabled = (!value && count >= 2) || (value && count <= 1);

    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? primaryBlue : borderColor,
          width: value ? 2 : 1.5,
        ),
      ),
      child: CheckboxListTile(
        activeColor: primaryBlue,
        title: Text(
          title,
          style: TextStyle(
            color: isDisabled ? greyText : darkText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: greyText, fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildSelectorField({
    required String label,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueText.isNotEmpty
                        ? valueText
                        : 'Select ${label.replaceAll(' *', '')}',
                    style: TextStyle(
                      color: valueText.isNotEmpty ? darkText : greyText,
                      fontSize: 15,
                      fontWeight: valueText.isNotEmpty
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: greyText,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showSearchBottomSheet({
    required String title,
    required List<MapEntry<int, String>> items,
    required int? selectedId,
    required ValueChanged<int> onSelected,
  }) {
    final l10n = context.l10n;
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
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded, color: greyText),
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
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      autofocus: false,
                      onChanged: (val) {
                        setSheetState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: l10n.text('post_job_search_hint'),
                        hintStyle: const TextStyle(color: greyText),
                        prefixIcon: const Icon(Icons.search_rounded, color: greyText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            l10n.text('post_job_no_items'),
                            style: const TextStyle(color: greyText, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final isSelected = item.key == selectedId;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 8,
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                tileColor: isSelected
                                    ? const Color(0xFFEEEEFF)
                                    : Colors.transparent,
                                title: Text(
                                  item.value,
                                  style: TextStyle(
                                    color: isSelected ? primaryBlue : darkText,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: primaryBlue,
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

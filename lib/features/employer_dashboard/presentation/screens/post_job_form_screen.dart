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
  String _contactPreference = 'self';
  String _selectedShift = 'day';
  bool _isWalkin = false;

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
      final res = await ApiService.get(ApiRoutes.dashboard);
      if (res['status'] == true && res['data'] != null) {
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final localizations = MaterialLocalizations.of(context);
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
    super.dispose();
  }

  void _submit() {
    if (_selectedCategoryId == null || _selectedRoleId == null) {
      Get.snackbar(
        'Error',
        'Please select a Job Category and Job Role.',
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
          'Error',
          'Please select State, District and Locality.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
    }
    if (!_formKey.currentState!.validate()) return;

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
      contactPreference: _contactPreference,
      contactPerson: _contactPreference == 'other'
          ? _contactPersonCtrl.text.trim()
          : null,
      contactPhone: _contactPreference == 'other'
          ? _contactPhoneCtrl.text.trim()
          : null,
      contactEmail: _contactPreference == 'other'
          ? _contactEmailCtrl.text.trim()
          : null,
      viewsCount: 0,
      applicationsCount: 0,
      status: 'active',
      createdAt: DateTime.now(),
      stateId: _selectedStateId,
      districtId: _selectedDistrictId,
      localiteId: _selectedLocalityId,
    );

    controller
        .postNewJob(newJob)
        .then((_) {
          Get.back();
          Get.snackbar(
            'Success',
            'Job posted successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        })
        .catchError((error) {
          Get.snackbar(
            'Error',
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
              _buildSectionTitle('Job Details'),
              _buildTextField(
                label: 'Job Title *',
                hint: 'e.g. Delivery Executive, Telecaller',
                controller: _titleCtrl,
                validator: (val) =>
                    val!.trim().isEmpty ? 'Please enter job title' : null,
              ),

              if (_isCategoriesLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                )
              else if (_categories.isNotEmpty)
                _buildDropdownField<int?>(
                  label: 'Job Category *',
                  value: _selectedCategoryId,
                  items: _categories.map((c) {
                    return DropdownMenuItem<int?>(
                      value: c['id'] as int?,
                      child: Text((c['name'] ?? '').toString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                      _fetchRoles(val);
                    }
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
                  label: 'Job Role *',
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
                      label: 'Job Type *',
                      value: _jobType,
                      items: const [
                        DropdownMenuItem(
                          value: 'full_time',
                          child: Text('Full Time'),
                        ),
                        DropdownMenuItem(
                          value: 'part_time',
                          child: Text('Part Time'),
                        ),
                        DropdownMenuItem(value: 'both', child: Text('Both')),
                      ],
                      onChanged: (val) => setState(() => _jobType = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: 'Work Location *',
                      value: _workLocationType,
                      items: const [
                        DropdownMenuItem(
                          value: 'office',
                          child: Text('Office'),
                        ),
                        DropdownMenuItem(
                          value: 'home',
                          child: Text('Home / Remote'),
                        ),
                        DropdownMenuItem(value: 'field', child: Text('Field')),
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
                      label: 'Vacancies *',
                      hint: 'e.g. 5',
                      controller: _vacancyCtrl,
                      keyboardType: TextInputType.number,
                      validator: (val) => int.tryParse(val ?? '') == null
                          ? 'Enter valid number'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: 'Preferred Shift *',
                      value: _selectedShift,
                      items: const [
                        DropdownMenuItem(
                          value: 'day',
                          child: Text('Day Shift'),
                        ),
                        DropdownMenuItem(
                          value: 'night',
                          child: Text('Night Shift'),
                        ),
                        DropdownMenuItem(
                          value: 'rotational',
                          child: Text('Rotational Shift'),
                        ),
                        DropdownMenuItem(
                          value: 'flexible',
                          child: Text('Flexible Shift'),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedShift = val!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionTitle('Salary Details'),
              _buildDropdownField<String>(
                label: 'Salary Model *',
                value: _payType,
                items: const [
                  DropdownMenuItem(
                    value: 'fixed',
                    child: Text('Fixed Monthly Pay Range'),
                  ),
                  DropdownMenuItem(
                    value: 'fixed_inc',
                    child: Text('Fixed Monthly Pay + Incentives'),
                  ),
                  DropdownMenuItem(
                    value: 'inc_only',
                    child: Text('Incentives Only'),
                  ),
                ],
                onChanged: (val) => setState(() => _payType = val!),
              ),

              if (_payType == 'fixed')
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Min Salary (₹) *',
                        hint: 'e.g. 10000',
                        controller: _minSalaryCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim().isEmpty ? 'Enter min salary' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Max Salary (₹) *',
                        hint: 'e.g. 15000',
                        controller: _maxSalaryCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim().isEmpty ? 'Enter max salary' : null,
                      ),
                    ),
                  ],
                )
              else if (_payType == 'fixed_inc')
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Fixed Salary (₹) *',
                        hint: 'e.g. 15000',
                        controller: _fixedSalaryCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim().isEmpty ? 'Enter fixed salary' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Avg. Incentive (₹) *',
                        hint: 'e.g. 3000',
                        controller: _avgIncentiveCtrl,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val!.trim().isEmpty ? 'Enter avg incentive' : null,
                      ),
                    ),
                  ],
                )
              else if (_payType == 'inc_only')
                _buildTextField(
                  label: 'Estimated Incentive (₹) *',
                  hint: 'e.g. 12000',
                  controller: _estimatedIncentiveCtrl,
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Enter estimated incentive' : null,
                ),

              if (_workLocationType != 'home') ...[
                const SizedBox(height: 20),
                _buildSectionTitle(
                  '${_workLocationType.toUpperCase()} Location Address',
                ),

                if (_isStatesLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    ),
                  )
                else
                  _buildDropdownField<int?>(
                    label: 'State *',
                    value: _selectedStateId,
                    items: _states.map((s) {
                      return DropdownMenuItem<int?>(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStateId = val;
                        });
                        _fetchDistricts(val);
                      }
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
                    label: 'District *',
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
                    label: 'Locality / Area *',
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
                  label: 'Address Line 1 *',
                  hint: 'Building / Shop No / Lane Name',
                  controller: _addressCtrl,
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Address line 1 is required' : null,
                ),
                _buildTextField(
                  label: 'Address Line 2 (Optional)',
                  hint: 'Landmark / Area details',
                  controller: _address2Ctrl,
                ),
                _buildTextField(
                  label: 'Pin Code *',
                  hint: 'e.g. 302017',
                  controller: _pincodeCtrl,
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.trim().length != 6
                      ? 'Must be exactly 6 digits'
                      : null,
                ),
              ],

              const SizedBox(height: 20),
              _buildSectionTitle('Candidate Requirements'),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: 'Min Education *',
                      value: _educationLevel,
                      items: const [
                        DropdownMenuItem(
                          value: 'Below 10th',
                          child: Text('Below 10th'),
                        ),
                        DropdownMenuItem(
                          value: '10th Pass',
                          child: Text('10th Pass'),
                        ),
                        DropdownMenuItem(
                          value: '12th Pass',
                          child: Text('12th Pass'),
                        ),
                        DropdownMenuItem(
                          value: 'Graduate',
                          child: Text('Graduate'),
                        ),
                        DropdownMenuItem(
                          value: 'Post Graduate',
                          child: Text('Post Graduate'),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _educationLevel = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: 'Experience Required *',
                      value: _experienceLevel,
                      items: const [
                        DropdownMenuItem(
                          value: 'fresher',
                          child: Text('Fresher (0 Years)'),
                        ),
                        DropdownMenuItem(value: '1', child: Text('1 Year')),
                        DropdownMenuItem(value: '2', child: Text('2 Years')),
                        DropdownMenuItem(value: '3', child: Text('3 Years')),
                        DropdownMenuItem(value: '5', child: Text('5+ Years')),
                      ],
                      onChanged: (val) =>
                          setState(() => _experienceLevel = val!),
                    ),
                  ),
                ],
              ),
              _buildDropdownField<String>(
                label: 'English Requirements *',
                value: _englishLevel,
                items: const [
                  DropdownMenuItem(
                    value: 'none',
                    child: Text('No English required'),
                  ),
                  DropdownMenuItem(
                    value: 'basic',
                    child: Text('Basic English (Speak/Read)'),
                  ),
                  DropdownMenuItem(
                    value: 'good',
                    child: Text('Good English (Fluent)'),
                  ),
                ],
                onChanged: (val) => setState(() => _englishLevel = val!),
              ),
              _buildTextField(
                label: 'Key Skills (comma separated) *',
                hint: 'e.g. Driving License, Typing, MS Excel',
                controller: _skillsCtrl,
                validator: (val) =>
                    val!.trim().isEmpty ? 'Add at least one skill' : null,
              ),
              _buildTextField(
                label: 'Languages (comma separated)',
                hint: 'e.g. Hindi, English, Gujarati',
                controller: _languagesCtrl,
              ),
              _buildTextField(
                label: 'Perks / Benefits (comma separated)',
                hint: 'e.g. PF, ESI, Free Food, Petrol Allowance',
                controller: _perksCtrl,
              ),
              _buildTextField(
                label: 'Job Description',
                hint:
                    'Briefly describe roles, responsibilities, and benefits...',
                controller: _descCtrl,
                maxLines: 4,
              ),

              const SizedBox(height: 20),
              _buildSectionTitle('Walk-in Interview Details'),
              Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: SwitchListTile(
                  activeColor: primaryBlue,
                  title: const Text(
                    'Is this a Walk-in Interview?',
                    style: TextStyle(
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
                  label: 'Walk-in Date *',
                  hint: 'Select Date',
                  controller: _walkinDateCtrl,
                  onTap: () => _selectDate(context),
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Walk-in Date is required' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTapToSelectField(
                        label: 'Start Time *',
                        hint: 'Select Time',
                        controller: _walkinTimeCtrl,
                        onTap: () => _selectTime(context, _walkinTimeCtrl),
                        validator: (val) => val!.trim().isEmpty
                            ? 'Start Time is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTapToSelectField(
                        label: 'End Time *',
                        hint: 'Select Time',
                        controller: _walkinEndTimeCtrl,
                        onTap: () => _selectTime(context, _walkinEndTimeCtrl),
                        validator: (val) =>
                            val!.trim().isEmpty ? 'End Time is required' : null,
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  label: 'Walk-in Venue *',
                  hint: 'Enter full address of walk-in venue',
                  controller: _walkinVenueCtrl,
                  maxLines: 2,
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Venue is required' : null,
                ),
              ],

              const SizedBox(height: 20),
              _buildSectionTitle('Contact Details'),
              _buildDropdownField<String>(
                label: 'Candidate Contact Preference *',
                value: _contactPreference,
                items: const [
                  DropdownMenuItem(
                    value: 'self',
                    child: Text('Contact Me (Self)'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('Contact Someone Else (Other)'),
                  ),
                  DropdownMenuItem(
                    value: 'none',
                    child: Text('No Contact Preference (Direct Application)'),
                  ),
                ],
                onChanged: (val) => setState(() => _contactPreference = val!),
              ),

              if (_contactPreference == 'other') ...[
                _buildTextField(
                  label: 'Contact Person Name *',
                  hint: 'e.g. Raman Khanna',
                  controller: _contactPersonCtrl,
                  validator: (val) =>
                      val!.trim().isEmpty ? 'Required field' : null,
                ),
                _buildTextField(
                  label: 'Contact Phone Number *',
                  hint: '10-digit number',
                  controller: _contactPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      val!.trim().length != 10 ? 'Enter valid phone' : null,
                ),
                _buildTextField(
                  label: 'Contact Email Address',
                  hint: 'e.g. jobs@company.com',
                  controller: _contactEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],

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
                  child: const Text(
                    'Post Job Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}

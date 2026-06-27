import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rojgar/features/app/app_controller.dart';
import '../controller/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileController _ctrl;

  // text controllers pre-filled from AppController.user
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final _stateCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _idProofPath;
  String? _resumePath;
  String? _profilePhotoPath;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ProfileController>();
    final user = AppController.to.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _localityCtrl.dispose();
    _pincodeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String label, void Function(String) onPicked) async {
    final result = await FilePicker.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      onPicked(result.files.single.path!);
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final msg = await _ctrl.updateProfile(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      locality: _localityCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      idProofPath: _idProofPath,
      resumePath: _resumePath,
      profilePhotoPath: _profilePhotoPath,
    );
    if (msg != null && mounted) {
      Get.snackbar(
        'Success',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
      );
      // Refresh user data in AppController
      AppController.to.fetchAndSyncUserData();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF17181C),
            size: 20,
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF17181C),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.sp),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Profile photo picker ──────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () =>
                      _pickFile('Profile Photo', (p) => _profilePhotoPath = p),
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEEEEFF),
                          border: Border.all(
                            color: const Color(0xFF1400FF),
                            width: 2,
                          ),
                          image: _profilePhotoPath != null
                              ? DecorationImage(
                                  image: FileImage(File(_profilePhotoPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profilePhotoPath == null
                            ? const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF1400FF),
                                size: 44,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1400FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.sp),

              // ── Text fields ───────────────────────────────────────
              _SectionLabel('Personal Details'),
              SizedBox(height: 12.sp),
              _buildField(
                _nameCtrl,
                'Full Name',
                Icons.person_outline_rounded,
                required: true,
              ),
              _buildField(
                _emailCtrl,
                'Email',
                Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                required: true,
              ),
              _buildField(
                _phoneCtrl,
                'Phone',
                Icons.phone_outlined,
                keyboard: TextInputType.phone,
                required: true,
              ),

              SizedBox(height: 8.sp),
              _SectionLabel('Address Details'),
              SizedBox(height: 12.sp),
              _buildField(_stateCtrl, 'State', Icons.location_on_outlined),
              _buildField(_districtCtrl, 'District', Icons.map_outlined),
              _buildField(
                _localityCtrl,
                'Locality / Area',
                Icons.holiday_village_outlined,
              ),
              _buildField(
                _pincodeCtrl,
                'Pincode',
                Icons.pin_outlined,
                keyboard: TextInputType.number,
              ),
              _buildField(
                _addressCtrl,
                'Address',
                Icons.home_outlined,
                maxLines: 2,
              ),

              SizedBox(height: 8.sp),
              _SectionLabel('Documents'),
              SizedBox(height: 12.sp),
              _FilePicker(
                label: 'ID Proof',
                filePath: _idProofPath,
                icon: Icons.badge_outlined,
                onTap: () => _pickFile(
                  'ID Proof',
                  (p) => setState(() => _idProofPath = p),
                ),
              ),
              SizedBox(height: 10.sp),
              _FilePicker(
                label: 'Resume / CV',
                filePath: _resumePath,
                icon: Icons.description_outlined,
                onTap: () =>
                    _pickFile('Resume', (p) => setState(() => _resumePath = p)),
              ),
              SizedBox(height: 24.sp),

              // ── Submit ────────────────────────────────────────────
              Obx(
                () => ElevatedButton(
                  onPressed: _ctrl.isUpdatingProfile.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1400FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _ctrl.isUpdatingProfile.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: required
            ? (v) =>
                  (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF8A8FA3), size: 20),
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Color(0xFF8A8FA3)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1400FF), width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.sp,
            vertical: 14.sp,
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1400FF),
        letterSpacing: 0.3,
      ),
    );
  }
}

class _FilePicker extends StatelessWidget {
  final String label;
  final String? filePath;
  final IconData icon;
  final VoidCallback onTap;
  const _FilePicker({
    required this.label,
    required this.filePath,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final picked = filePath != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: picked ? const Color(0xFF1400FF) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: picked ? const Color(0xFF1400FF) : const Color(0xFF8A8FA3),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                picked ? filePath!.split('/').last : 'Choose $label',
                style: TextStyle(
                  fontSize: 14,
                  color: picked
                      ? const Color(0xFF17181C)
                      : const Color(0xFF8A8FA3),
                  fontWeight: picked ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              picked ? Icons.check_circle_rounded : Icons.upload_file_rounded,
              color: picked ? const Color(0xFF2E7D32) : const Color(0xFF8A8FA3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:rojgar/features/app/app_controller.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../controller/profile_controller.dart';

class _C {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color fieldBg = Color(0xFFF8FAFC);
  static const Color successGreen = Color(0xFF10B981);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileController _ctrl;
  final _imagePicker = ImagePicker();

  // Text controllers pre-filled from AppController.user
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _localityCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _addressCtrl;

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
    _stateCtrl = TextEditingController(text: user?.state ?? '');
    _districtCtrl = TextEditingController(text: user?.city ?? '');
    _localityCtrl = TextEditingController();
    _pincodeCtrl = TextEditingController(text: user?.zipCode ?? '');
    _addressCtrl = TextEditingController(text: user?.address ?? '');
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

  Future<void> _pickProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: _C.darkText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1400FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: _C.primary),
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w700, color: _C.darkText),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final xfile = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (xfile != null) {
                    setState(() => _profilePhotoPath = xfile.path);
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1400FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: _C.primary),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w700, color: _C.darkText),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final xfile = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (xfile != null) {
                    setState(() => _profilePhotoPath = xfile.path);
                  }
                },
              ),
              if (_profilePhotoPath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _profilePhotoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile(String label, void Function(String) onPicked) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
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
        'Profile Updated',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _C.successGreen,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
      );
      // Refresh user data in AppController
      AppController.to.fetchAndSyncUserData();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppController.to.user;
    final l10n = AppLocalizations.of(context);

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
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
            ),
          ),
          title: Text(
            l10n.text('profile_edit_profile'),
            style: const TextStyle(
              color: _C.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _C.borderGrey),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Profile Photo Hero Header ────────────────────────
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickProfilePhoto,
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1400FF).withValues(alpha: 0.08),
                                border: Border.all(
                                  color: _C.primary,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _C.primary.withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _profilePhotoPath != null
                                  ? Image.file(
                                      File(_profilePhotoPath!),
                                      fit: BoxFit.cover,
                                    )
                                  : (user?.profileImage != null && user!.profileImage.isNotEmpty
                                      ? Image.network(
                                          user.profileImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _buildAvatarFallback(user.name),
                                        )
                                      : _buildAvatarFallback(user?.name ?? '')),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _C.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
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
                      const SizedBox(height: 10),
                      Text(
                        user?.name.isNotEmpty == true ? user!.name : 'Your Name',
                        style: const TextStyle(
                          color: _C.darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Tap avatar to update photo',
                        style: const TextStyle(
                          color: _C.greyText,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Card 1: Personal Details ─────────────────────────
                _buildSectionCard(
                  title: 'Personal Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _FieldLabel('Full Name *'),
                    _buildField(
                      _nameCtrl,
                      'Enter your full name',
                      Icons.badge_outlined,
                      required: true,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Email Address *'),
                    _buildField(
                      _emailCtrl,
                      'Enter your email',
                      Icons.mail_outline_rounded,
                      keyboard: TextInputType.emailAddress,
                      required: true,
                      isEmail: true,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Phone Number *'),
                    _buildField(
                      _phoneCtrl,
                      'Enter 10-digit mobile number',
                      Icons.phone_iphone_rounded,
                      keyboard: TextInputType.phone,
                      required: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Card 2: Address & Location ───────────────────────
                _buildSectionCard(
                  title: 'Address & Location',
                  icon: Icons.location_on_outlined,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('State'),
                              _buildField(
                                _stateCtrl,
                                'e.g. Maharashtra',
                                Icons.location_city_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('District / City'),
                              _buildField(
                                _districtCtrl,
                                'e.g. Pune',
                                Icons.map_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Locality / Area'),
                              _buildField(
                                _localityCtrl,
                                'e.g. Kothrud',
                                Icons.holiday_village_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel('Pincode'),
                              _buildField(
                                _pincodeCtrl,
                                'e.g. 411038',
                                Icons.pin_outlined,
                                keyboard: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Street / House Address'),
                    _buildField(
                      _addressCtrl,
                      'Enter complete residential address',
                      Icons.home_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Card 3: Documents ────────────────────────────────
                _buildSectionCard(
                  title: 'Documents & Verification',
                  icon: Icons.folder_shared_outlined,
                  children: [
                    _FieldLabel('ID Proof (Aadhaar / Voter ID / PAN)'),
                    _FilePicker(
                      label: 'ID Proof',
                      filePath: _idProofPath,
                      icon: Icons.badge_outlined,
                      onTap: () => _pickFile(
                        'ID Proof',
                        (p) => setState(() => _idProofPath = p),
                      ),
                      onClear: _idProofPath != null
                          ? () => setState(() => _idProofPath = null)
                          : null,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Resume / CV (PDF, DOC)'),
                    _FilePicker(
                      label: 'Resume / CV',
                      filePath: _resumePath,
                      icon: Icons.description_outlined,
                      onTap: () => _pickFile(
                        'Resume',
                        (p) => setState(() => _resumePath = p),
                      ),
                      onClear: _resumePath != null
                          ? () => setState(() => _resumePath = null)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomSheet: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 14,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: _C.borderGrey, width: 1),
            ),
          ),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _ctrl.isUpdatingProfile.value ? null : _submit,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _ctrl.isUpdatingProfile.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'SAVE CHANGES',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join()
        : 'U';

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: _C.primary,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.borderGrey),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1400FF).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _C.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _C.darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
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

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool required = false,
    bool isEmail = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(
        color: _C.darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) {
          return 'This field is required';
        }
        if (isEmail && v != null && v.trim().isNotEmpty) {
          final emailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
          if (!emailValid) return 'Enter a valid email address';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _C.greyText,
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, color: _C.greyText, size: 18),
        filled: true,
        fillColor: _C.fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.borderGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _C.darkText,
        ),
      ),
    );
  }
}

class _FilePicker extends StatelessWidget {
  final String label;
  final String? filePath;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilePicker({
    required this.label,
    required this.filePath,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final picked = filePath != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: picked
              ? const Color(0xFF1400FF).withValues(alpha: 0.04)
              : _C.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: picked ? _C.primary : _C.borderGrey,
            width: picked ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: picked
                    ? _C.primary.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: picked ? _C.primary : _C.greyText,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    picked ? filePath!.split('/').last : 'Upload $label',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: picked ? _C.darkText : _C.greyText,
                      fontWeight: picked ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (picked)
                    const Text(
                      'Ready to update',
                      style: TextStyle(
                        fontSize: 11,
                        color: _C.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (picked && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _C.greyText.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 14, color: _C.greyText),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1400FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Browse',
                  style: TextStyle(
                    color: _C.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

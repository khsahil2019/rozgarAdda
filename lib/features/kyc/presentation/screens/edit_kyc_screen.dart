import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../dashboard_screen.dart';
import '../../../../localization/app_localizations.dart';
import '../bindings/kyc_binding.dart';
import '../controller/kyc_controller.dart';
import '../controller/uploaded_kyc_file.dart';

// ─────────────────────────────────────────────
// COLOR CONSTANTS
// ─────────────────────────────────────────────
class AC {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF111111);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFDDDDEE);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color pendingBg = Color(0xFFFFF8DC);
  static const Color iconBg = Color(0xFFE8EAFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sectionBlue = Color(0xFF1400FF);
  static const Color successGreen = Color(0xFF1E9E5E);
  static const Color successBg = Color(0xFFD6F5E8);
}

// ─────────────────────────────────────────────
// UPLOAD DOCUMENT TYPE
// ─────────────────────────────────────────────
enum UploadType { image, file }

// ─────────────────────────────────────────────
// EDIT KYC SCREEN
// ─────────────────────────────────────────────
class EditKycScreen extends GetView<KycController> {
  const EditKycScreen({super.key});

  @override
  KycController get controller {
    if (!Get.isRegistered<KycController>()) {
      KycBinding().dependencies();
    }
    return Get.find<KycController>();
  }

  void _showSnackbar(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message, softWrap: true)),
          ],
        ),
        backgroundColor: isSuccess ? AC.successGreen : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Bottom sheet: Camera vs Gallery ─────────
  Future<ImageSource?> _showImageSourceSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AC.lightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.text('kyc_image_source_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AC.darkText,
              ),
            ),
            const SizedBox(height: 16),
            _sourceOption(
              context: context,
              icon: Icons.camera_alt_rounded,
              label: context.l10n.text('kyc_source_camera'),
              color: AC.primaryBlue,
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _sourceOption(
              context: context,
              icon: Icons.photo_library_rounded,
              label: context.l10n.text('kyc_source_gallery'),
              color: AC.primaryBlue,
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
            _sourceOption(
              context: context,
              icon: Icons.close_rounded,
              label: context.l10n.text('cancel'),
              color: Colors.red,
              onTap: () => Navigator.pop(context, null),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color == Colors.red ? Colors.red : AC.darkText,
        ),
      ),
      onTap: onTap,
    );
  }

  // ── State Picker Bottom Sheet ────────────────
  void _showStateSelectionBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final searchRx = ''.obs;
        return Container(
          height: size.height * 0.7,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AC.lightGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.text('registration_select_state'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AC.darkText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AC.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AC.borderColor, width: 1),
                ),
                child: TextField(
                  onChanged: (val) => searchRx.value = val,
                  style: const TextStyle(color: AC.darkText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: context.l10n.text('select_state_search_hint'),
                    hintStyle: const TextStyle(color: AC.greyText, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AC.greyText),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final filtered = controller.states
                      .where((s) => s.name
                          .toLowerCase()
                          .contains(searchRx.value.toLowerCase().trim()))
                      .toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No states found',
                        style: TextStyle(color: AC.greyText, fontSize: 14),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AC.lightGrey),
                    itemBuilder: (context, idx) {
                      final state = filtered[idx];
                      return ListTile(
                        title: Text(
                          state.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AC.darkText,
                          ),
                        ),
                        onTap: () {
                          controller.onStateSelected(state);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── District Picker Bottom Sheet ─────────────
  void _showDistrictSelectionBottomSheet(BuildContext context) {
    if (controller.stateId.value == null) {
      _showSnackbar(context, 'Please select a state first');
      return;
    }
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final searchRx = ''.obs;
        return Container(
          height: size.height * 0.7,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AC.lightGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.text('kyc_field_district'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AC.darkText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AC.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AC.borderColor, width: 1),
                ),
                child: TextField(
                  onChanged: (val) => searchRx.value = val,
                  style: const TextStyle(color: AC.darkText, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search district...',
                    hintStyle: TextStyle(color: AC.greyText, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AC.greyText),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final filtered = controller.districts
                      .where((d) => d.name
                          .toLowerCase()
                          .contains(searchRx.value.toLowerCase().trim()))
                      .toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No districts found',
                        style: TextStyle(color: AC.greyText, fontSize: 14),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AC.lightGrey),
                    itemBuilder: (context, idx) {
                      final dist = filtered[idx];
                      return ListTile(
                        title: Text(
                          dist.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AC.darkText,
                          ),
                        ),
                        onTap: () {
                          controller.onDistrictSelected(dist);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onSubmitKyc(BuildContext context) async {
    final success = await controller.updateKyc();
    if (!context.mounted) return;
    if (success) {
      _showSnackbar(context, context.l10n.text('kyc_snack_updated'), isSuccess: true);
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAll(() => const HomeScreen());
    } else {
      final err = controller.errorMsg.value;
      if (err != null) {
        _showSnackbar(context, context.l10n.text(err));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<KycController>()) {
      KycBinding().dependencies();
    }
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.05;

    return Scaffold(
      backgroundColor: AC.scaffoldBg,
      body: Obx(() {
        final hasError = controller.errorMsg.value != null && controller.nameCtrl.text.isEmpty;
        final hasLoader = controller.isLoading.value && controller.nameCtrl.text.isEmpty;

        if (hasLoader) {
          return const Center(
            child: CircularProgressIndicator(color: AC.primaryBlue),
          );
        }

        if (hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.text(controller.errorMsg.value ?? 'kyc_snack_error'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      final id = controller.candidateId.value;
                      if (id != null) controller.fetchKycData(id);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AC.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // ── Blue AppBar ─────────────────────
            _buildAppBar(context),

            // ── Scrollable Body ─────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    // Status chip
                    _statusChip(context),

                    const SizedBox(height: 22),

                    // ── Personal Information ──────
                    _sectionHeader(context.l10n.text('kyc_section_personal')),
                    const SizedBox(height: 16),

                    _fieldLabel(context.l10n.text('kyc_field_full_name')),
                    const SizedBox(height: 6),
                    _inputField(controller: controller.nameCtrl),

                    const SizedBox(height: 14),

                    _fieldLabel(context.l10n.text('kyc_field_phone')),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: controller.phoneCtrl,
                      keyboard: TextInputType.phone,
                    ),

                    const SizedBox(height: 14),

                    _fieldLabel(context.l10n.text('kyc_field_email')),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: controller.emailCtrl,
                      hint: 'email@example.com',
                      keyboard: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 26),

                    // ── Address Information ───────
                    _sectionHeader(context.l10n.text('kyc_section_address')),
                    const SizedBox(height: 16),

                    // State + District
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel(context.l10n.text('kyc_field_state')),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _showStateSelectionBottomSheet(context),
                                child: AbsorbPointer(
                                  child: _inputField(
                                    controller: controller.stateCtrl,
                                    hint: context.l10n.text('kyc_field_state'),
                                    suffixIcon: const Icon(Icons.arrow_drop_down, color: AC.greyText),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel(context.l10n.text('kyc_field_district')),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _showDistrictSelectionBottomSheet(context),
                                child: AbsorbPointer(
                                  child: _inputField(
                                    controller: controller.districtCtrl,
                                    hint: context.l10n.text('kyc_field_district'),
                                    suffixIcon: const Icon(Icons.arrow_drop_down, color: AC.greyText),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Locality + Pincode
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel(context.l10n.text('kyc_field_locality')),
                              const SizedBox(height: 6),
                              _inputField(
                                controller: controller.localityCtrl,
                                hint: context.l10n.text('kyc_field_locality'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel(context.l10n.text('kyc_field_pincode')),
                              const SizedBox(height: 6),
                              _inputField(
                                controller: controller.pincodeCtrl,
                                keyboard: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _fieldLabel(context.l10n.text('kyc_field_address')),
                    const SizedBox(height: 6),
                    _multilineField(
                      controller: controller.addressCtrl,
                      hint: context.l10n.text('kyc_address_hint'),
                    ),

                    const SizedBox(height: 28),

                    // ── Documents Upload ──────────
                    _sectionHeader(context.l10n.text('kyc_section_documents')),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.text('kyc_docs_hint'),
                      style: const TextStyle(color: AC.greyText, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Identity Proof
                    _UploadCard(
                      slotId: 'identity',
                      icon: Icons.badge_outlined,
                      title: context.l10n.text('kyc_identity_title'),
                      subtitle: context.l10n.text('kyc_identity_subtitle'),
                      uploadType: UploadType.file,
                      uploaded: controller.uploads['identity'],
                      onUpload: () => controller.pickFile('identity'),
                      onPickImage: () async {
                        final source = await _showImageSourceSheet(context);
                        if (source == null) return;
                        await controller.pickImage('identity', source);
                        if (context.mounted) {
                          _showSnackbar(context, context.l10n.text('kyc_snack_doc_uploaded'), isSuccess: true);
                        }
                      },
                      onRemove: () {
                        controller.removeUpload('identity');
                        _showSnackbar(context, context.l10n.text('kyc_snack_file_removed'));
                      },
                    ),

                    const SizedBox(height: 12),

                    // Resume / CV
                    _UploadCard(
                      slotId: 'resume',
                      icon: Icons.description_outlined,
                      title: context.l10n.text('kyc_resume_title'),
                      subtitle: context.l10n.text('kyc_resume_subtitle'),
                      uploadType: UploadType.file,
                      uploaded: controller.uploads['resume'],
                      onUpload: () => controller.pickFile('resume'),
                      onPickImage: () {}, // no image upload option for resume
                      onRemove: () {
                        controller.removeUpload('resume');
                        _showSnackbar(context, context.l10n.text('kyc_snack_file_removed'));
                      },
                    ),

                    const SizedBox(height: 12),

                    // Profile Photo
                    _UploadCard(
                      slotId: 'photo',
                      icon: Icons.person_outline_rounded,
                      title: context.l10n.text('kyc_photo_title'),
                      subtitle: context.l10n.text('kyc_photo_subtitle'),
                      uploadType: UploadType.image,
                      uploaded: controller.uploads['photo'],
                      onUpload: () => controller.pickFile('photo'),
                      onPickImage: () async {
                        final source = await _showImageSourceSheet(context);
                        if (source == null) return;
                        await controller.pickImage('photo', source);
                        if (context.mounted) {
                          _showSnackbar(context, context.l10n.text('kyc_snack_photo_uploaded'), isSuccess: true);
                        }
                      },
                      onRemove: () {
                        controller.removeUpload('photo');
                        _showSnackbar(context, context.l10n.text('kyc_snack_file_removed'));
                      },
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Update KYC Button ───────────────
            _buildBottomButton(hPad, context),
          ],
        );
      }),
    );
  }

  // ── Blue AppBar ──────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AC.primaryBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16,
        right: 16,
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.text('kyc_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            controller.candidateId.value == null
                ? context.l10n.text('kyc_subtitle')
                : '${context.l10n.text('kyc_subtitle_id')}${controller.candidateId.value}',
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Status chip ──────────────────────────────
  Widget _statusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AC.pendingBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFDD88), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AC.yellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.text('kyc_status_pending'),
            style: const TextStyle(
              color: Color(0xFF886600),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: AC.sectionBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AC.sectionBlue,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AC.darkText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget _inputField({
    TextEditingController? controller,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AC.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: AC.darkText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AC.greyText, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  static Widget _multilineField({
    TextEditingController? controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AC.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AC.borderColor, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(color: AC.darkText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AC.greyText, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ── Bottom button ────────────────────────────
  Widget _buildBottomButton(double hPad, BuildContext context) {
    return Container(
      color: AC.scaffoldBg,
      padding: EdgeInsets.fromLTRB(
        hPad,
        12,
        hPad,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: GestureDetector(
        onTap: controller.isLoading.value ? null : () => _onSubmitKyc(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: controller.isLoading.value
                ? AC.primaryBlue.withValues(alpha: 0.65)
                : AC.primaryBlue,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AC.primaryBlue.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    context.l10n.text('kyc_update_button'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPLOAD CARD WIDGET
// ─────────────────────────────────────────────
class _UploadCard extends StatelessWidget {
  final String slotId;
  final IconData icon;
  final String title;
  final String subtitle;
  final UploadType uploadType;
  final UploadedKycFile? uploaded;
  final VoidCallback onUpload;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;

  const _UploadCard({
    required this.slotId,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.uploadType,
    required this.uploaded,
    required this.onUpload,
    required this.onPickImage,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = uploaded != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AC.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFile
              ? AC.successGreen.withValues(alpha: 0.5)
              : AC.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasFile ? AC.successBg : AC.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle_rounded : icon,
                    color: hasFile ? AC.successGreen : AC.primaryBlue,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AC.darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasFile ? uploaded!.name : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasFile ? AC.successGreen : AC.greyText,
                          fontSize: 12,
                          fontWeight: hasFile
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (hasFile && uploaded!.sizeLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          uploaded!.sizeLabel,
                          style: const TextStyle(
                            color: AC.greyText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action buttons
                if (!hasFile)
                  _ActionButtons(
                    uploadType: uploadType,
                    onUpload: onUpload,
                    onPickImage: onPickImage,
                  )
                else
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Preview (if image uploaded) ────────
          if (hasFile && uploaded!.isImage && uploaded!.path.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(uploaded!.path),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: AC.lightGrey,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AC.greyText,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── PDF / Doc preview badge ────────────
          if (hasFile && !uploaded!.isImage) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.red,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          uploaded!.name.split('.').last.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      uploaded!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AC.darkText, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final UploadType uploadType;
  final VoidCallback onUpload;
  final VoidCallback onPickImage;

  const _ActionButtons({
    required this.uploadType,
    required this.onUpload,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    if (uploadType == UploadType.image) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconBtn(icon: Icons.camera_alt_rounded, onTap: onPickImage),
          const SizedBox(width: 6),
          _iconBtn(icon: Icons.photo_library_rounded, onTap: onUpload),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconBtn(icon: Icons.camera_alt_rounded, onTap: onPickImage),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onUpload,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AC.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'UPLOAD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AC.iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AC.primaryBlue, size: 19),
      ),
    );
  }
}

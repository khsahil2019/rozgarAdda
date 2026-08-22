import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../dashboard_screen.dart';
import '../../../../localization/app_localizations.dart';
import '../bindings/kyc_binding.dart';
import '../controller/kyc_controller.dart';
import '../controller/uploaded_kyc_file.dart';

// ─────────────────────────────────────────────
// UPLOAD DOCUMENT TYPE
// ─────────────────────────────────────────────
enum UploadType { image, file }

// ─────────────────────────────────────────────
// EDIT KYC SCREEN
// ─────────────────────────────────────────────
class EditKycScreen extends GetView<KycController> {
  const EditKycScreen({super.key});

  // Enterprise Brand Design System Colors
  static const Color primary = Color(0xFF1400FF);
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFF0F172A);
  static const Color mediumText = Color(0xFF334155);
  static const Color greyText = Color(0xFF64748B);
  static const Color lightGreyText = Color(0xFF94A3B8);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color fieldBg = Color(0xFFF8FAFC);
  static const Color borderGrey = Color(0xFFE2E8F0);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF0284C7);

  @override
  KycController get controller {
    if (!Get.isRegistered<KycController>()) {
      KycBinding().dependencies();
    }
    return Get.find<KycController>();
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
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
        backgroundColor: isSuccess ? successGreen : dangerRed,
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
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: borderGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              context.l10n.text('kyc_image_source_title'),
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: darkText,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            _sourceOption(
              context: context,
              icon: Icons.camera_alt_rounded,
              label: context.l10n.text('kyc_source_camera'),
              color: primary,
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const Divider(height: 1, color: borderGrey),
            _sourceOption(
              context: context,
              icon: Icons.photo_library_rounded,
              label: context.l10n.text('kyc_source_gallery'),
              color: primary,
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
            _sourceOption(
              context: context,
              icon: Icons.close_rounded,
              label: context.l10n.text('cancel'),
              color: dangerRed,
              onTap: () => Navigator.pop(context, null),
            ),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: color == dangerRed ? dangerRed : darkText,
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
      backgroundColor: Colors.transparent,
      builder: (_) {
        final searchRx = ''.obs;
        return Container(
          height: size.height * 0.72,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: borderGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    context.l10n.text('registration_select_state'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: darkText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: greyText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderGrey),
                ),
                child: TextField(
                  onChanged: (val) => searchRx.value = val,
                  style: const TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: context.l10n.text('select_state_search_hint'),
                    hintStyle: const TextStyle(color: lightGreyText, fontSize: 13.5),
                    prefixIcon: const Icon(Icons.search_rounded, color: primary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final filtered = controller.states
                      .where((s) => s.name
                          .toLowerCase()
                          .contains(searchRx.value.toLowerCase().trim()))
                      .toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No states found',
                        style: TextStyle(color: greyText, fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: borderGrey),
                    itemBuilder: (context, idx) {
                      final state = filtered[idx];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        title: Text(
                          state.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: greyText, size: 18),
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
      backgroundColor: Colors.transparent,
      builder: (_) {
        final searchRx = ''.obs;
        return Container(
          height: size.height * 0.72,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: borderGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    context.l10n.text('kyc_field_district'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: darkText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: greyText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderGrey),
                ),
                child: TextField(
                  onChanged: (val) => searchRx.value = val,
                  style: const TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Search district...',
                    hintStyle: TextStyle(color: lightGreyText, fontSize: 13.5),
                    prefixIcon: Icon(Icons.search_rounded, color: primary, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final filtered = controller.districts
                      .where((d) => d.name
                          .toLowerCase()
                          .contains(searchRx.value.toLowerCase().trim()))
                      .toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No districts found',
                        style: TextStyle(color: greyText, fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: borderGrey),
                    itemBuilder: (context, idx) {
                      final dist = filtered[idx];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        title: Text(
                          dist.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: greyText, size: 18),
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Get.back(),
              tooltip: 'Back',
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.text('kyc_title'),
                style: const TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
              ),
              Obx(() => Text(
                    controller.candidateId.value == null
                        ? context.l10n.text('kyc_subtitle')
                        : '${context.l10n.text('kyc_subtitle_id')}${controller.candidateId.value}',
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: borderGrey),
          ),
        ),
        body: Obx(() {
          final hasError = controller.errorMsg.value != null && controller.nameCtrl.text.isEmpty;
          final hasLoader = controller.isLoading.value && controller.nameCtrl.text.isEmpty;

          if (hasLoader) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dangerRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded, color: dangerRed, size: 44),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.text(controller.errorMsg.value ?? 'kyc_snack_error'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: darkText, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        final id = controller.candidateId.value;
                        if (id != null) controller.fetchKycData(id);
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Status Banner
                      _buildStatusBanner(context),
                      const SizedBox(height: 16),

                      // 2. Personal Information Card
                      _buildFormCard(
                        title: context.l10n.text('kyc_section_personal'),
                        icon: Icons.person_outline_rounded,
                        children: [
                          _fieldLabel(context.l10n.text('kyc_field_full_name')),
                          const SizedBox(height: 6),
                          _inputField(controller: controller.nameCtrl, hint: 'e.g. Rahul Sharma'),
                          const SizedBox(height: 14),

                          _fieldLabel(context.l10n.text('kyc_field_phone')),
                          const SizedBox(height: 6),
                          _inputField(
                            controller: controller.phoneCtrl,
                            keyboard: TextInputType.phone,
                            hint: 'e.g. 9876543210',
                          ),
                          const SizedBox(height: 14),

                          _fieldLabel(context.l10n.text('kyc_field_email')),
                          const SizedBox(height: 6),
                          _inputField(
                            controller: controller.emailCtrl,
                            hint: 'e.g. rahul@example.com',
                            keyboard: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Address Information Card
                      _buildFormCard(
                        title: context.l10n.text('kyc_section_address'),
                        icon: Icons.location_on_outlined,
                        children: [
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
                                          suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: primary),
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
                                          suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: primary),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

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
                                      hint: 'e.g. 110001',
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Documents Upload Card
                      _buildFormCard(
                        title: context.l10n.text('kyc_section_documents'),
                        icon: Icons.upload_file_rounded,
                        children: [
                          Text(
                            context.l10n.text('kyc_docs_hint'),
                            style: const TextStyle(color: greyText, fontSize: 12.5, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 14),

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
                            onPickImage: () {},
                            onRemove: () {
                              controller.removeUpload('resume');
                              _showSnackbar(context, context.l10n.text('kyc_snack_file_removed'));
                            },
                          ),
                          const SizedBox(height: 12),

                          // Profile Photo
                          _UploadCard(
                            slotId: 'photo',
                            icon: Icons.account_circle_outlined,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Sticky Bottom Submit Button
              _buildBottomActionBar(context),
            ],
          );
        }),
      ),
    );
  }

  // ── Status Banner ────────────────────────────
  Widget _buildStatusBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warningOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warningOrange.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: warningOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: warningOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.text('kyc_status_pending'),
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Submit your details & documents to get verified.',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 12,
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

  // ── Reusable Form Card Container ─────────────
  Widget _buildFormCard({
    required String title,
    required IconData icon,
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
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
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

  static Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: mediumText,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
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
        color: fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey, width: 1.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: lightGreyText, fontSize: 13.5),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
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
        color: fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGrey, width: 1.0),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        style: const TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: lightGreyText, fontSize: 13.5),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // ── Bottom Action Bar ────────────────────────
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderGrey)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : () => _onSubmitKyc(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  context.l10n.text('kyc_update_button'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: EditKycScreen.fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFile
              ? EditKycScreen.successGreen.withValues(alpha: 0.5)
              : EditKycScreen.borderGrey,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasFile
                        ? EditKycScreen.successGreen.withValues(alpha: 0.1)
                        : EditKycScreen.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle_rounded : icon,
                    color: hasFile ? EditKycScreen.successGreen : EditKycScreen.primary,
                    size: 20,
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
                          color: EditKycScreen.darkText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasFile ? uploaded!.name : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasFile ? EditKycScreen.successGreen : EditKycScreen.greyText,
                          fontSize: 11.5,
                          fontWeight: hasFile ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (hasFile && uploaded!.sizeLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          uploaded!.sizeLabel,
                          style: const TextStyle(
                            color: EditKycScreen.greyText,
                            fontSize: 10.5,
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
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: EditKycScreen.dangerRed,
                      size: 20,
                    ),
                    tooltip: 'Remove',
                  ),
              ],
            ),
          ),

          // ── Preview (if image uploaded) ────────
          if (hasFile && uploaded!.isImage && uploaded!.path.isNotEmpty) ...[
            const Divider(height: 1, color: EditKycScreen.borderGrey),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(uploaded!.path),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 70,
                    color: EditKycScreen.borderGrey,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: EditKycScreen.greyText,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── PDF / Doc preview badge ────────────
          if (hasFile && !uploaded!.isImage) ...[
            const Divider(height: 1, color: EditKycScreen.borderGrey),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: EditKycScreen.dangerRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: EditKycScreen.dangerRed,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          uploaded!.name.split('.').last.toUpperCase(),
                          style: const TextStyle(
                            color: EditKycScreen.dangerRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      uploaded!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: EditKycScreen.darkText, fontSize: 11.5, fontWeight: FontWeight.w600),
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
        InkWell(
          onTap: onUpload,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: EditKycScreen.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'UPLOAD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: EditKycScreen.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: EditKycScreen.primary, size: 17),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import '../controller/missing_person_controller.dart';

class _C {
  static const Color primary = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color fieldBg = Color(0xFFF8FAFC);
  static const Color dangerRed = Color(0xFFEF4444);
}

class PostMissingPersonScreen extends GetView<MissingPersonController> {
  const PostMissingPersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Missing Person',
                style: TextStyle(
                  color: _C.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Community Alert & Verification',
                style: TextStyle(
                  color: _C.greyText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          centerTitle: false,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _C.borderGrey),
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Notice Banner ──────────────────────────────
                      _buildNoticeBanner(),
                      const SizedBox(height: 16),

                      // ── Section 1: Missing Person Details ───────────
                      _buildSectionCard(
                        icon: Icons.person_pin_rounded,
                        iconColor: _C.primary,
                        title: 'Missing Person Details',
                        subtitle: 'Basic identity & primary contact',
                        children: [
                          _buildTextField(
                            controller: controller.nameCtrl,
                            label: 'Full Name *',
                            hint: 'Enter missing person name',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: controller.relationInfoCtrl,
                            label: 'Guardian Relation (S/O, W/O, D/O, C/O)',
                            hint: 'e.g., S/O Ramesh Kumar',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.ageCtrl,
                                  label: 'Age (Years) *',
                                  hint: 'e.g. 24',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'Gender *',
                                  value: controller.postGender,
                                  options: const ['Male', 'Female', 'Other'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.mobileCtrl,
                                  label: 'Contact Number *',
                                  hint: '10-digit number',
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.pincodeCtrl,
                                  label: 'Pincode',
                                  hint: '6-digit pincode',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Section 2: Location & Address ───────────────
                      _buildSectionCard(
                        icon: Icons.location_on_rounded,
                        iconColor: const Color(0xFF10B981),
                        title: 'Location & Address',
                        subtitle: 'Last known place & residence details',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.stateCtrl,
                                  label: 'State *',
                                  hint: 'e.g., Maharashtra',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.districtCtrl,
                                  label: 'District *',
                                  hint: 'e.g., Pune',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.localityCtrl,
                                  label: 'Locality / City',
                                  hint: 'City or area',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.villageCtrl,
                                  label: 'Village / Mohalla',
                                  hint: 'Village or sector',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Section 3: Physical Attributes & Incident ───
                      _buildSectionCard(
                        icon: Icons.info_outline_rounded,
                        iconColor: const Color(0xFF6366F1),
                        title: 'Incident & Physical Attributes',
                        subtitle: 'Appearance and missing timeline',
                        children: [
                          _buildDateTimePickerField(context),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.heightFromCtrl,
                                  label: 'Height From',
                                  hint: 'e.g. 5\'2"',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.heightToCtrl,
                                  label: 'Height To',
                                  hint: 'e.g. 5\'6"',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: controller.mentalStatusCtrl,
                            label: 'Mental Condition',
                            hint: 'e.g., Normal, Memory Loss, Speech Impaired',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: controller.probableReasonCtrl,
                            label: 'Probable Reason of Missing',
                            hint: 'Details regarding why/how they went missing...',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: controller.clothesWornCtrl,
                            label: 'Clothes & Accessories Worn',
                            hint: 'Color and type of shirt, pants, footwear, etc.',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: controller.identityMarkCtrl,
                            label: 'Visible Identification Marks',
                            hint: 'Birthmarks, scars, tattoos, distinctive marks...',
                            maxLines: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Section 4: Photo Uploads ───────────────────
                      _buildSectionCard(
                        icon: Icons.add_a_photo_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Recent Photographs *',
                        subtitle: 'Upload clear front and profile photos',
                        children: [
                          _buildPhotoPickerCard(
                            context: context,
                            title: 'Front View Photo *',
                            filePath: controller.postImage1Path.value,
                            onPick: () => _showImageSourceModal(context, 1),
                            onRemove: () => controller.postImage1Path.value = '',
                          ),
                          const SizedBox(height: 12),
                          _buildPhotoPickerCard(
                            context: context,
                            title: 'Side / Alternate Photo',
                            filePath: controller.postImage2Path.value,
                            onPick: () => _showImageSourceModal(context, 2),
                            onRemove: () => controller.postImage2Path.value = '',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Section 5: Police & FIR Details ────────────
                      _buildSectionCard(
                        icon: Icons.local_police_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        title: 'Police & FIR Details',
                        subtitle: 'Registered complaint or station information',
                        children: [
                          _buildTextField(
                            controller: controller.firNumberCtrl,
                            label: 'FIR / Complaint Number',
                            hint: 'Enter FIR registration number',
                          ),
                          const SizedBox(height: 12),
                          _buildFirPickerCard(
                            context: context,
                            filePath: controller.postFirCopyPath.value,
                            onPick: () => controller.pickFirCopy(),
                            onRemove: () => controller.postFirCopyPath.value = '',
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: _C.borderGrey),
                          const SizedBox(height: 14),
                          const Text(
                            'Police Station Contacts',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _C.darkText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: controller.policeStationNoCtrl,
                            label: 'Police Station Contact No.',
                            hint: 'Phone number of local station',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.subInspectorCtrl,
                                  label: 'Assigned SI Name',
                                  hint: 'Sub-Inspector name',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.shoNoCtrl,
                                  label: 'SHO Contact No.',
                                  hint: 'SHO phone number',
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Section 6: Complainant Details ─────────────
                      _buildSectionCard(
                        icon: Icons.contact_phone_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Complainant / Reporter Info',
                        subtitle: 'Person submitting this report',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.complaintNameCtrl,
                                  label: 'Reporter Name *',
                                  hint: 'Your full name',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: controller.complaintMobileCtrl,
                                  label: 'Reporter Mobile *',
                                  hint: 'Your phone number',
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: controller.relationTypeCtrl,
                            label: 'Relation with Missing Person',
                            hint: 'e.g. Father, Mother, Brother, Friend',
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: controller.relativeAddressCtrl,
                            label: 'Complainant Address',
                            hint: 'Full residential address',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: controller.complaintReasonCtrl,
                            label: 'Reason of Lodging Report',
                            hint: 'Any additional remarks or incident context...',
                            maxLines: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Submit Button ──────────────────────────────
                      _buildSubmitButton(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Submitting Overlay
                if (controller.isSubmitting.value)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: _C.primary),
                              SizedBox(height: 16),
                              Text(
                                'Submitting Report...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: _C.darkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.privacy_tip_outlined, color: _C.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please provide accurate information, recent photographs, and contact details to assist community search and rapid verification.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF1E40AF),
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.borderGrey, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _C.darkText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: _C.greyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _C.borderGrey),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: _C.darkText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: _C.darkText, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _C.greyText, fontSize: 13, fontWeight: FontWeight.w400),
            fillColor: _C.fieldBg,
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required RxString value,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: _C.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: _C.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.borderGrey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value,
              isExpanded: true,
              isDense: false,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _C.greyText, size: 20),
              style: const TextStyle(color: _C.darkText, fontSize: 13.5, fontWeight: FontWeight.w600),
              onChanged: (newValue) {
                if (newValue != null) {
                  value.value = newValue;
                }
              },
              items: options.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePickerField(BuildContext context) {
    final dateStr = controller.postMissingDatetime.value != null
        ? DateFormat('dd-MMM-yyyy, hh:mm a').format(controller.postMissingDatetime.value!)
        : 'Select Missing Date & Time *';

    final hasValue = controller.postMissingDatetime.value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Missing Date & Time *',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: _C.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.pickDateTime(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _C.fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasValue ? _C.primary.withValues(alpha: 0.3) : _C.borderGrey,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: hasValue ? _C.primary : _C.greyText,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: TextStyle(
                        color: hasValue ? _C.darkText : _C.greyText,
                        fontSize: 13.5,
                        fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _C.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PICK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _C.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPickerCard({
    required BuildContext context,
    required String title,
    required String filePath,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final hasFile = filePath.isNotEmpty && File(filePath).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: _C.darkText,
          ),
        ),
        const SizedBox(height: 6),
        if (hasFile)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _C.fieldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(filePath),
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filePath.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Photo attached successfully',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: _C.dangerRed, size: 20),
                  onPressed: onRemove,
                  tooltip: 'Remove photo',
                ),
              ],
            ),
          )
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: _C.fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _C.borderGrey,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: _C.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Upload Photo (Camera / Gallery)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFirPickerCard({
    required BuildContext context,
    required String filePath,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final hasFile = filePath.isNotEmpty;
    final fileName = hasFile ? filePath.split('/').last : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FIR Document / Receipt Copy',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: _C.darkText,
          ),
        ),
        const SizedBox(height: 6),
        if (hasFile)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _C.fieldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_outlined, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Document attached',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: _C.dangerRed, size: 20),
                  onPressed: onRemove,
                  tooltip: 'Remove file',
                ),
              ],
            ),
          )
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: _C.fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.borderGrey),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file_rounded, color: _C.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Attach FIR PDF / Image',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        onPressed: () async {
          final isSuccess = await controller.submitMissingPersonForm();
          if (isSuccess && context.mounted) {
            Navigator.maybePop(context);
          }
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Submit Missing Person Report',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceModal(BuildContext context, int imageIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Photo Source',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: _C.darkText,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _C.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: _C.primary, size: 22),
                  ),
                  title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  onTap: () {
                    Navigator.pop(modalCtx);
                    controller.pickImage(imageIndex, ImageSource.camera);
                  },
                ),
                const SizedBox(height: 4),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB), size: 22),
                  ),
                  title: const Text('Choose from Photo Gallery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  onTap: () {
                    Navigator.pop(modalCtx);
                    controller.pickImage(imageIndex, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

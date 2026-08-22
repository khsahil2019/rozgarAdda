import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import '../controller/missing_person_controller.dart';

class _PMPC {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color navy = Color(0xFF0F172A);
  static const Color accentBlue = Color(0xFF1400FF);
  static const Color grey = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
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
        backgroundColor: _PMPC.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Missing Person Form',
            style: TextStyle(
              color: _PMPC.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          leading: Center(
            child: AppBackButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: 'Back',
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _PMPC.borderColor),
          ),
        ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Missing Person Details
                    _buildSectionHeader('Missing Person Details'),
                    _buildMissingPersonCard(context),
                    const SizedBox(height: 20),

                    // Section 2: Photos Upload
                    _buildSectionHeader('Photos Upload'),
                    _buildPhotosUploadCard(context),
                    const SizedBox(height: 20),

                    // Section 3: Complaint Person Details
                    _buildSectionHeader('Complaint Person Details'),
                    _buildComplaintPersonCard(context),
                    const SizedBox(height: 20),

                    // Section 4: FIR & Police Station Details
                    _buildSectionHeader('Police FIR Details'),
                    _buildPoliceDetailsCard(context),
                    const SizedBox(height: 30),

                    // Submit Button
                    _buildSubmitButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (controller.isSubmitting.value)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: _PMPC.accentBlue),
                  ),
                ),
            ],
          );
        }),
      ),
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: _PMPC.navy,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── Card container helper ──────────────────────────────────────────────────
  Widget _buildFormContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Cards Components ───────────────────────────────────────────────────────
  Widget _buildMissingPersonCard(BuildContext context) {
    return _buildFormContainer(
      child: Column(
        children: [
          _buildTextField(controller: controller.nameCtrl, label: 'Name', hint: 'Full Name'),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.relationInfoCtrl, label: 'Relation (S/O, W/O, D/O, C/O)', hint: 'e.g., S/O Rajesh Kumar'),
          const SizedBox(height: 14),

          // State and District Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(controller: controller.stateCtrl, label: 'State', hint: 'State'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(controller: controller.districtCtrl, label: 'District', hint: 'District'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Locality and Village Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(controller: controller.localityCtrl, label: 'Locality / City', hint: 'Locality'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(controller: controller.villageCtrl, label: 'Village / Mohalla', hint: 'Village'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Mobile and Pincode Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.mobileCtrl,
                  label: 'Mobile',
                  hint: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: controller.pincodeCtrl,
                  label: 'Pincode',
                  hint: '6-Digit Pincode',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Age and Gender Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.ageCtrl,
                  label: 'Age',
                  hint: 'Age in years',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Gender',
                  value: controller.postGender,
                  options: const ['Male', 'Female', 'Other'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Height Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(controller: controller.heightFromCtrl, label: 'Height From', hint: 'e.g., 5 feet'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(controller: controller.heightToCtrl, label: 'Height To', hint: 'e.g., 5.5 feet'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildTextField(controller: controller.mentalStatusCtrl, label: 'Mental Status', hint: 'e.g., Normal, Mentally Unsound'),
          const SizedBox(height: 14),

          // Missing Date/Time Picker
          _buildDateTimePickerField(context),
          const SizedBox(height: 14),

          _buildTextField(controller: controller.probableReasonCtrl, label: 'Probable Reason', hint: 'Reason for going missing...', maxLines: 2),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.clothesWornCtrl, label: 'Clothes Worn', hint: 'Details of clothing...', maxLines: 2),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.identityMarkCtrl, label: 'Identity Mark', hint: 'Any visible birthmarks, tattoos...', maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildPhotosUploadCard(BuildContext context) {
    return _buildFormContainer(
      child: Column(
        children: [
          _buildFilePickerTile(
            label: 'Image 1 (Front Photo)',
            filePath: controller.postImage1Path.value,
            onTap: () => _showImageSourceDialog(context, 1),
          ),
          const SizedBox(height: 14),
          _buildFilePickerTile(
            label: 'Image 2 (Side/Profile Photo)',
            filePath: controller.postImage2Path.value,
            onTap: () => _showImageSourceDialog(context, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintPersonCard(BuildContext context) {
    return _buildFormContainer(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(controller: controller.complaintNameCtrl, label: 'Name', hint: 'Complainant Name'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: controller.complaintMobileCtrl,
                  label: 'Mobile',
                  hint: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.relationTypeCtrl, label: 'Relation Type', hint: 'e.g., Father, Mother, Brother'),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.relativeAddressCtrl, label: 'Address', hint: 'Complainant Address', maxLines: 2),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.complaintReasonCtrl, label: 'Complaint Reason', hint: 'Why are you lodging the complaint...', maxLines: 2),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.complaintIdentityMarkCtrl, label: 'Identity Mark (Complaint)', hint: 'Complainant Identity Mark', maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildPoliceDetailsCard(BuildContext context) {
    return _buildFormContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(controller: controller.firNumberCtrl, label: 'FIR Number', hint: 'FIR Number (if registered)'),
          const SizedBox(height: 14),

          // FIR Copy
          _buildFilePickerTile(
            label: 'FIR Copy Upload',
            filePath: controller.postFirCopyPath.value,
            onTap: () => controller.pickFirCopy(),
          ),
          const SizedBox(height: 18),

          const Divider(height: 1, color: _PMPC.borderColor),
          const SizedBox(height: 16),
          const Text(
            'Police Station Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _PMPC.navy),
          ),
          const SizedBox(height: 14),

          _buildTextField(controller: controller.policeStationNoCtrl, label: 'Police Station No', hint: 'Station Phone number'),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.subInspectorCtrl, label: 'Sub Inspector', hint: 'Assigned SI Name'),
          const SizedBox(height: 14),
          _buildTextField(controller: controller.shoNoCtrl, label: 'SHO No', hint: 'SHO Phone number'),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _PMPC.navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        onPressed: () async {
          final isSuccess = await controller.submitMissingPersonForm();
          if (isSuccess && context.mounted) {
            Navigator.maybePop(context);
          }
        },
        child: const Text(
          'Submit Request',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Custom Field Builders ──────────────────────────────────────────────────

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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _PMPC.navy),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: _PMPC.navy),
          decoration: InputDecoration(
            hintText: hint,
            fillColor: Colors.white,
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _PMPC.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _PMPC.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _PMPC.navy, width: 1.5),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _PMPC.navy),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _PMPC.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _PMPC.grey, size: 22),
              style: const TextStyle(color: _PMPC.navy, fontSize: 14),
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
        ? DateFormat('dd-MM-yyyy, hh:mm a').format(controller.postMissingDatetime.value!)
        : 'dd-mm-yyyy --:--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Missing Date/Time',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _PMPC.navy),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => controller.pickDateTime(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _PMPC.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      color: controller.postMissingDatetime.value != null ? _PMPC.navy : _PMPC.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month_outlined, color: _PMPC.grey, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerTile({
    required String label,
    required String filePath,
    required VoidCallback onTap,
  }) {
    final fileName = filePath.isNotEmpty ? filePath.split('/').last : 'No file chosen';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _PMPC.navy),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _PMPC.borderColor),
          ),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F1F6),
                  foregroundColor: _PMPC.navy,
                  elevation: 0,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onTap,
                child: const Text(
                  'Choose File',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  fileName,
                  style: TextStyle(
                    color: filePath.isNotEmpty ? _PMPC.navy : _PMPC.grey,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Image Source Selector Dialog ──────────────────────────────────────────
  void _showImageSourceDialog(BuildContext context, int imageIndex) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Select Image Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: _PMPC.navy),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(dialogCtx);
                  controller.pickImage(imageIndex, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: _PMPC.navy),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(dialogCtx);
                  controller.pickImage(imageIndex, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../controller/create_news_controller.dart';

class _CNC {
  static const Color bg = Color(0xFFF4F5F9);
  static const Color navy = Color(0xFF1A1E3C);
  static const Color accent = Color(0xFF1E38FC);
  static const Color grey = Color(0xFF8A8FA3);
  static const Color border = Color(0xFFE2E4EB);
}

class CreateNewsScreen extends GetView<CreateNewsController> {
  const CreateNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _CNC.bg,
      appBar: AppBar(
        backgroundColor: _CNC.navy,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          l10n.text('news_form_title'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingOptions.value) {
            return const Center(
              child: CircularProgressIndicator(color: _CNC.accent),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (controller.errorMessage.isNotEmpty) ...[
                      _buildErrorBanner(controller.errorMessage.value),
                      const SizedBox(height: 16),
                    ],
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCategoryField(context, l10n),
                          const SizedBox(height: 14),
                          _buildStateField(context, l10n),
                          const SizedBox(height: 14),
                          _buildTextField(
                            textController: controller.titleCtrl,
                            label: l10n.text('news_form_headline'),
                            hint: l10n.text('news_form_headline_hint'),
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            textController: controller.descriptionCtrl,
                            label: l10n.text('news_form_description'),
                            hint: l10n.text('news_form_description_hint'),
                            maxLines: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(child: _buildImagePicker(context, l10n)),
                    const SizedBox(height: 28),
                    _buildSubmitButton(context, l10n),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              if (controller.isSubmitting.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: _CNC.accent),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 12.5),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
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

  Widget _buildCategoryField(BuildContext context, AppLocalizations l10n) {
    return _buildLabeled(
      label: l10n.text('news_form_category'),
      child: Obx(() {
        final categories = controller.categories;
        final selectedId = controller.selectedCategoryId.value;
        final validValue =
            (selectedId != null && categories.any((c) => c.id == selectedId))
            ? selectedId
            : null;
        return DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: validValue,
            isExpanded: true,
            isDense: true,
            hint: Text(
              l10n.text('news_form_category'),
              style: const TextStyle(color: _CNC.grey, fontSize: 14),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _CNC.grey,
            ),
            style: const TextStyle(color: _CNC.navy, fontSize: 14),
            onChanged: (value) => controller.selectedCategoryId.value = value,
            items: categories
                .map(
                  (category) => DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }

  Widget _buildStateField(BuildContext context, AppLocalizations l10n) {
    return _buildLabeled(
      label: l10n.text('news_form_state'),
      child: Obx(() {
        final states = controller.states;
        final selectedId = controller.selectedStateId.value;
        final validValue =
            (selectedId != null && states.any((s) => s.id == selectedId))
            ? selectedId
            : null;
        return DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: validValue,
            isExpanded: true,
            isDense: true,
            hint: Text(
              l10n.text('news_form_state'),
              style: const TextStyle(color: _CNC.grey, fontSize: 14),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _CNC.grey,
            ),
            style: const TextStyle(color: _CNC.navy, fontSize: 14),
            onChanged: (value) => controller.selectedStateId.value = value,
            items: states
                .map(
                  (state) => DropdownMenuItem<int>(
                    value: state.id,
                    child: Text(state.name),
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }

  Widget _buildLabeled({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: _CNC.navy,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _CNC.border),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: _CNC.navy,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: textController,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 14, color: _CNC.navy),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _CNC.grey, fontSize: 13),
            fillColor: Colors.white,
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _CNC.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _CNC.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _CNC.navy, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(BuildContext context, AppLocalizations l10n) {
    return Obx(() {
      final path = controller.imagePath.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.text('news_form_image'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: _CNC.navy,
            ),
          ),
          const SizedBox(height: 10),
          if (path.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(File(path), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F1F6),
                  foregroundColor: _CNC.navy,
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showImageSourceDialog(context, l10n),
                icon: const Icon(Icons.image_outlined, size: 18),
                label: Text(
                  l10n.text('news_form_choose_image'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  path.isEmpty
                      ? l10n.text('news_form_no_image')
                      : path.split(Platform.pathSeparator).last,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: path.isEmpty ? _CNC.grey : _CNC.navy,
                    fontSize: 12.5,
                  ),
                ),
              ),
              if (path.isNotEmpty)
                IconButton(
                  onPressed: controller.clearImage,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _CNC.grey,
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _CNC.navy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      onPressed: () => _submit(context, l10n),
      child: Text(
        l10n.text('news_form_submit'),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _submit(BuildContext context, AppLocalizations l10n) async {
    final validationKey = controller.validate();
    if (validationKey != null) {
      Get.snackbar(
        l10n.text('news_error_title'),
        l10n.text(validationKey),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    final error = await controller.submit();
    if (error != null) {
      Get.snackbar(
        l10n.text('news_error_title'),
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      l10n.text('news_success_title'),
      l10n.text('news_form_success'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
    );
    if (context.mounted) Navigator.maybePop(context);
  }

  void _showImageSourceDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            l10n.text('kyc_image_source_title'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: _CNC.navy,
                ),
                title: Text(l10n.text('kyc_source_camera')),
                onTap: () {
                  Navigator.pop(dialogCtx);
                  controller.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: _CNC.navy,
                ),
                title: Text(l10n.text('kyc_source_gallery')),
                onTap: () {
                  Navigator.pop(dialogCtx);
                  controller.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

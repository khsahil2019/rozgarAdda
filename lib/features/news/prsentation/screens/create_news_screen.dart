import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rojgar/core/widgets/app_back_button.dart';
import 'package:rojgar/localization/app_localizations.dart';
import '../controller/create_news_controller.dart';

class _CNC {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color navy = Color(0xFF0F172A);
  static const Color accent = Color(0xFF1400FF);
  static const Color grey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
}

class CreateNewsScreen extends GetView<CreateNewsController> {
  const CreateNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: _CNC.bg,
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
            l10n.text('news_form_title'),
            style: const TextStyle(
              color: _CNC.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _CNC.border),
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoadingOptions.value) {
              return const Center(
                child: CircularProgressIndicator(color: _CNC.accent),
              );
            }

            final isVideo = controller.isPostTypeVideo.value;

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (controller.errorMessage.isNotEmpty) ...[
                        _buildErrorBanner(controller.errorMessage.value),
                        const SizedBox(height: 16),
                      ],

                      // ── Post Type Toggle Bar (Text News vs Video News) ──
                      _buildPostTypeToggle(),

                      const SizedBox(height: 16),

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
                            if (isVideo) ...[
                              _buildTextField(
                                textController: controller.subjectCtrl,
                                label: 'News Subject',
                                hint: 'Enter video news subject...',
                              ),
                              const SizedBox(height: 14),
                            ],
                            _buildTextField(
                              textController: controller.descriptionCtrl,
                              label: isVideo
                                  ? 'Video Description'
                                  : l10n.text('news_form_description'),
                              hint: isVideo
                                  ? 'Enter news description / summary...'
                                  : l10n.text('news_form_description_hint'),
                              maxLines: isVideo ? 3 : 5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildCard(
                        child: isVideo
                            ? _buildVideoPicker(context, l10n)
                            : _buildImagePicker(context, l10n),
                      ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(context, l10n),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                if (controller.isSubmitting.value)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black38,
                      child: const Center(
                        child: CircularProgressIndicator(color: _CNC.accent),
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

  Widget _buildPostTypeToggle() {
    return Obx(() {
      final isVideo = controller.isPostTypeVideo.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _CNC.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.isPostTypeVideo.value = false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !isVideo ? _CNC.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_rounded,
                        size: 18,
                        color: !isVideo ? Colors.white : _CNC.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Text / Image News',
                        style: TextStyle(
                          color: !isVideo ? Colors.white : _CNC.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.isPostTypeVideo.value = true,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isVideo ? _CNC.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_rounded,
                        size: 18,
                        color: isVideo ? Colors.white : _CNC.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Video News',
                        style: TextStyle(
                          color: isVideo ? Colors.white : _CNC.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFEF4444),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _CNC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            style: const TextStyle(
              color: _CNC.navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
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
            style: const TextStyle(
              color: _CNC.navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
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
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: _CNC.navy,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
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
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: _CNC.navy,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: textController,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            fontSize: 14,
            color: _CNC.navy,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _CNC.grey, fontSize: 13),
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _CNC.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _CNC.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _CNC.accent, width: 1.5),
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
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: _CNC.navy,
            ),
          ),
          const SizedBox(height: 10),
          if (path.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
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
                  backgroundColor: _CNC.accent.withValues(alpha: 0.08),
                  foregroundColor: _CNC.accent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showImageSourceDialog(context, l10n),
                icon: const Icon(Icons.image_outlined, size: 18),
                label: Text(
                  l10n.text('news_form_choose_image'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w600,
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

  Widget _buildVideoPicker(BuildContext context, AppLocalizations l10n) {
    return Obx(() {
      final path = controller.videoPath.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'News Video File',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: _CNC.navy,
            ),
          ),
          const SizedBox(height: 10),
          if (path.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _CNC.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _CNC.accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_library_rounded, color: _CNC.accent, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      path.split(Platform.pathSeparator).last,
                      style: const TextStyle(
                        color: _CNC.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.clearVideo,
                    icon: const Icon(Icons.close_rounded, color: _CNC.grey, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _CNC.accent.withValues(alpha: 0.08),
                  foregroundColor: _CNC.accent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => controller.pickVideo(ImageSource.gallery),
                icon: const Icon(Icons.videocam_outlined, size: 18),
                label: const Text(
                  'Choose Video File',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  path.isEmpty
                      ? 'No video selected'
                      : path.split(Platform.pathSeparator).last,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: path.isEmpty ? _CNC.grey : _CNC.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _CNC.accent,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _submit(context, l10n),
        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        label: Text(
          l10n.text('news_form_submit'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, AppLocalizations l10n) async {
    final validationKey = controller.validate();
    if (validationKey != null) {
      Get.snackbar(
        l10n.text('news_error_title'),
        validationKey.contains('_') ? l10n.text(validationKey) : validationKey,
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
      controller.isPostTypeVideo.value
          ? 'Video news posted successfully!'
          : l10n.text('news_form_success'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  color: _CNC.accent,
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
                  color: _CNC.accent,
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

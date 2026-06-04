import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../localization/app_localizations.dart';
import '../controller/sell_product_controller.dart';
import 'sell_product_review_screen.dart';

class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFDDDDEE);
  static const Color uploadBg = Color(0xFFF0F0FF);
}

class SellProductFormScreen extends GetView<SellProductController> {
  const SellProductFormScreen({super.key});

  void _showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? _C.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    // Clear form when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetForm();
    });

    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: Column(
        children: [
          const _TopBar(),
          const _StepIndicator(currentStep: 3),
          Expanded(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Banner
                    Obx(() {
                      final catIdx = controller.selectedCategoryIndex.value;
                      final subCatIdx = controller.selectedSubCategoryIndex.value;

                      if (catIdx == null || subCatIdx == null) return const SizedBox.shrink();

                      final catName = controller.categories[catIdx].name;
                      final subCatName = controller.subCategories[subCatIdx].name;

                      return _CategoryBanner(
                        categoryName: catName,
                        subCategoryName: subCatName,
                      );
                    }),
                    const SizedBox(height: 20),

                    // Product Title
                    _FieldLabel(context.l10n.text('sell_product_title')),
                    _InputField(
                      controller: controller.titleCtrl,
                      hint: context.l10n.text('sell_title_hint'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.text('sell_required') : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _FieldLabel(context.l10n.text('sell_description')),
                    _InputField(
                      controller: controller.descCtrl,
                      hint: context.l10n.text('sell_desc_hint'),
                      maxLines: 5,
                      validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.text('sell_required') : null,
                    ),
                    const SizedBox(height: 16),

                    // Features
                    _FieldLabel(context.l10n.text('sell_features')),
                    _InputField(
                      controller: controller.featuresCtrl,
                      hint: context.l10n.text('sell_features_hint'),
                    ),
                    const SizedBox(height: 16),

                    // Main Product Image
                    _FieldLabel(context.l10n.text('sell_main_image')),
                    Obx(() {
                      final mainImg = controller.mainImage.value;
                      return _ImagePickerTile(
                        label: mainImg == null
                            ? context.l10n.text('sell_no_file')
                            : mainImg.name,
                        onTap: controller.pickMainImage,
                        previewFile: mainImg != null ? File(mainImg.path) : null,
                        chooseFileText: context.l10n.text('sell_choose_file'),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Gallery Images
                    _FieldLabel(context.l10n.text('sell_gallery_images')),
                    Obx(() {
                      return _GalleryPickerTile(
                        images: controller.galleryImages.toList(),
                        onPickTap: controller.pickGalleryImages,
                        onRemove: controller.removeGalleryImage,
                        maxImagesText: context.l10n.text('sell_max_images'),
                        chooseFileText: context.l10n.text('sell_choose_file'),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Price & Discount row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(context.l10n.text('sell_price')),
                              _InputField(
                                controller: controller.priceCtrl,
                                hint: '0.00',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                onChanged: (_) => controller.priceCtrl.text = controller.priceCtrl.text,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(context.l10n.text('sell_discount')),
                              _InputField(
                                controller: controller.discountCtrl,
                                hint: '0',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) => controller.discountCtrl.text = controller.discountCtrl.text,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total Cost
                    _FieldLabel(context.l10n.text('sell_total_cost')),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: _C.fieldBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _C.borderColor, width: 1),
                      ),
                      child: Obx(() {
                        final total = controller.totalCostObx.value;
                        return Text(
                          controller.priceCtrl.text.isEmpty
                              ? 'Calculated total'
                              : '₹ ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: controller.priceCtrl.text.isEmpty ? _C.greyText : _C.darkText,
                            fontSize: 14,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Capacity & Warranty row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(context.l10n.text('sell_capacity')),
                              _InputField(
                                controller: controller.capacityCtrl,
                                hint: 'e.g. 5 Seater',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(context.l10n.text('sell_warranty')),
                              _InputField(
                                controller: controller.warrantyCtrl,
                                hint: 'e.g. 3 Years',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Active Product toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E8C0), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility_rounded, color: _C.primaryBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.l10n.text('sell_active_product'),
                              style: const TextStyle(
                                color: _C.darkText,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Obx(() {
                            return Switch(
                              value: controller.isActive.value,
                              onChanged: (v) => controller.isActive.value = v,
                              activeThumbColor: Colors.white,
                              activeTrackColor: _C.primaryBlue,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFFCCCCCC),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Obx(() {
        return _BottomActions(
          isSaving: controller.isSaving.value,
          cancelText: context.l10n.text('cancel'),
          saveProductText: context.l10n.text('sell_save_product'),
          onCancel: () => Get.back(),
          onSave: () async {
            if (!formKey.currentState!.validate()) return;
            if (controller.mainImage.value == null) {
              _showSnackBar(
                context,
                context.l10n.text('sell_select_main_image'),
                backgroundColor: Colors.red,
              );
              return;
            }

            final l10n = context.l10n;
            final messenger = ScaffoldMessenger.of(context);
            final success = await controller.saveProduct();
            if (success) {
              Get.off(() => const SellProductReviewScreen());
            } else {
              final errMsg = controller.savingError.value ?? l10n.text('sell_error_saving');
              messenger.showSnackBar(
                SnackBar(
                  content: Text(errMsg),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
        );
      }),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.primaryBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          Expanded(
            child: Text(
              context.l10n.text('sell_post_ad'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final bool isReviewStep = currentStep >= 4;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          _StepCircle(number: 1, label: context.l10n.text('sell_category'), state: _StepState.done),
          const _StepLine(active: true),
          _StepCircle(number: 2, label: 'Sub-Cat', state: _StepState.done),
          const _StepLine(active: true),
          _StepCircle(
            number: 3,
            label: context.l10n.text('sell_details'),
            state: isReviewStep ? _StepState.done : _StepState.active,
          ),
          _StepLine(active: isReviewStep),
          _StepCircle(
            number: 4,
            label: context.l10n.text('sell_review'),
            state: isReviewStep ? _StepState.active : _StepState.inactive,
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, active, inactive }

class _StepCircle extends StatelessWidget {
  final int number;
  final String label;
  final _StepState state;

  const _StepCircle({
    required this.number,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = state == _StepState.done;
    final bool isActive = state == _StepState.active;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDone || isActive) ? _C.primaryBlue : const Color(0xFFE8E8F0),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text(
                  '$number',
                  style: TextStyle(
                    color: isActive ? Colors.white : _C.greyText,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: (isDone || isActive) ? _C.primaryBlue : _C.greyText,
            fontSize: 9,
            fontWeight: (isDone || isActive) ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? _C.primaryBlue : const Color(0xFFDDDDEE),
      ),
    );
  }
}

class _CategoryBanner extends StatelessWidget {
  final String categoryName;
  final String subCategoryName;

  const _CategoryBanner({
    required this.categoryName,
    required this.subCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _C.uploadBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCCCCFF), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car_rounded, color: _C.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category: $categoryName',
                  style: const TextStyle(
                    color: _C.darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Sub Category: $subCategoryName',
                  style: const TextStyle(
                    color: _C.greyText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _C.darkText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: _C.darkText, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _C.greyText, fontSize: 14),
        filled: true,
        fillColor: _C.fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final File? previewFile;
  final String chooseFileText;

  const _ImagePickerTile({
    required this.label,
    required this.onTap,
    required this.chooseFileText,
    this.previewFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _C.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.borderColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.image_outlined, color: _C.greyText, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: _C.greyText, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chooseFileText,
                    style: const TextStyle(
                      color: _C.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (previewFile != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              previewFile!,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}

class _GalleryPickerTile extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPickTap;
  final void Function(int) onRemove;
  final String maxImagesText;
  final String chooseFileText;

  const _GalleryPickerTile({
    required this.images,
    required this.onPickTap,
    required this.onRemove,
    required this.maxImagesText,
    required this.chooseFileText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _C.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _C.borderColor,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.photo_library_outlined, color: _C.greyText, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  images.isEmpty
                      ? maxImagesText
                      : '${images.length} image${images.length > 1 ? 's' : ''} selected',
                  style: const TextStyle(color: _C.greyText, fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: onPickTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chooseFileText,
                    style: const TextStyle(
                      color: _C.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(images[i].path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool isSaving;
  final String cancelText;
  final String saveProductText;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _BottomActions({
    required this.isSaving,
    required this.cancelText,
    required this.saveProductText,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onCancel,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFDDDDEE), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  cancelText.toUpperCase(),
                  style: const TextStyle(
                    color: _C.darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: isSaving ? null : onSave,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: _C.primaryBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        saveProductText.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

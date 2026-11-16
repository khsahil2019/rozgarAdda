import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../localization/app_localizations.dart';
import '../bindings/sell_product_binding.dart';
import '../controller/sell_product_controller.dart';
import '../widgets/sell_product_step_indicator.dart';
import '../../../buy_product/presentation/theme/buy_product_theme.dart';
import 'ad_posting_plan_screen.dart';

class _C {
  static const Color primaryBlue = BuyProductTheme.primaryMaroon;
  static const Color darkText = Color(0xFF0F172A);
  static const Color greyText = Color(0xFF64748B);
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color fieldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class SellProductFormScreen extends StatefulWidget {
  const SellProductFormScreen({super.key});

  @override
  State<SellProductFormScreen> createState() => _SellProductFormScreenState();
}

class _SellProductFormScreenState extends State<SellProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final SellProductController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SellProductController>()) {
      SellProductBinding().dependencies();
    }
    controller = Get.find<SellProductController>();
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: backgroundColor ?? _C.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleProceedToPayment(BuildContext context, AppLocalizations l10n) {
    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        context,
        'Please fill all required fields correctly.',
        backgroundColor: const Color(0xFFEF4444),
      );
      return;
    }

    if (controller.mainImage.value == null) {
      _showSnackBar(
        context,
        l10n.text('sell_select_main_image'),
        backgroundColor: const Color(0xFFEF4444),
      );
      return;
    }

    // Open Ad Posting Plans & PayU Payment Gateway
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdPostingPlanScreen(),
      ),
    );
  }

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
        backgroundColor: _C.scaffoldBg,
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
          title: Text(
            l10n.text('sell_post_ad'),
            style: const TextStyle(
              color: _C.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: 'Cancel',
              icon: const Icon(Icons.close_rounded, color: _C.greyText, size: 22),
              onPressed: () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 4),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: _C.borderGrey),
          ),
        ),
        body: Column(
          children: [
            const SellProductStepIndicator(currentStep: 3),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Subcategory Summary
                      Obx(() {
                        final catIdx = controller.selectedCategoryIndex.value;
                        final subCatIdx = controller.selectedSubCategoryIndex.value;

                        if (catIdx == null || subCatIdx == null) {
                          return const SizedBox.shrink();
                        }

                        final catName = controller.categories[catIdx].name;
                        final subCatName = controller.subCategories[subCatIdx].name;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: BuyProductTheme.lightMaroonBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: BuyProductTheme.borderMaroon.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: BuyProductTheme.chipMaroonBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.sell_outlined, color: _C.primaryBlue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$catName  •  $subCatName',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _C.darkText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.text('sell_change_by_back'),
                                      style: const TextStyle(color: _C.greyText, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Card 1: Basic Information
                      _buildSectionCard(
                        title: 'Product Information',
                        icon: Icons.info_outline_rounded,
                        children: [
                          _FieldLabel(l10n.text('sell_product_title')),
                          _InputField(
                            controller: controller.titleCtrl,
                            hint: l10n.text('sell_title_hint'),
                            prefixIcon: Icons.title_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? l10n.text('sell_required')
                                : null,
                          ),
                          const SizedBox(height: 14),

                          _FieldLabel(l10n.text('sell_description')),
                          _InputField(
                            controller: controller.descCtrl,
                            hint: l10n.text('sell_desc_hint'),
                            prefixIcon: Icons.notes_rounded,
                            maxLines: 4,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? l10n.text('sell_required')
                                : null,
                          ),
                          const SizedBox(height: 14),

                          _FieldLabel(l10n.text('sell_features')),
                          _InputField(
                            controller: controller.featuresCtrl,
                            hint: l10n.text('sell_features_hint'),
                            prefixIcon: Icons.star_border_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card 2: Photos & Media
                      _buildSectionCard(
                        title: 'Product Images',
                        icon: Icons.photo_camera_rounded,
                        children: [
                          _FieldLabel(l10n.text('sell_main_image')),
                          Obx(() {
                            final mainImg = controller.mainImage.value;
                            return _MainImagePickerTile(
                              label: mainImg == null
                                  ? l10n.text('sell_no_file')
                                  : mainImg.name,
                              onTap: () => _showImageSourceDialog(
                                context,
                                onCamera: () => controller.pickMainImage(source: ImageSource.camera),
                                onGallery: () => controller.pickMainImage(source: ImageSource.gallery),
                              ),
                              previewFile: mainImg != null ? File(mainImg.path) : null,
                              chooseFileText: l10n.text('sell_choose_file'),
                            );
                          }),
                          const SizedBox(height: 16),

                          _FieldLabel(l10n.text('sell_gallery_images')),
                          Obx(() {
                            return _GalleryPickerTile(
                              images: controller.galleryImages.toList(),
                              onPickTap: () => _showImageSourceDialog(
                                context,
                                onCamera: () => controller.pickGalleryImages(source: ImageSource.camera),
                                onGallery: () => controller.pickGalleryImages(source: ImageSource.gallery),
                              ),
                              onRemove: controller.removeGalleryImage,
                              maxImagesText: l10n.text('sell_max_images'),
                              chooseFileText: l10n.text('sell_choose_file'),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card 3: Pricing & Inventory
                      _buildSectionCard(
                        title: 'Pricing & Details',
                        icon: Icons.currency_rupee_rounded,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(l10n.text('sell_price')),
                                    _InputField(
                                      controller: controller.priceCtrl,
                                      hint: '0.00',
                                      prefixText: '₹ ',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(l10n.text('sell_discount')),
                                    _InputField(
                                      controller: controller.discountCtrl,
                                      hint: '0',
                                      suffixText: '%',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Total Cost banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: BuyProductTheme.lightMaroonBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: BuyProductTheme.borderMaroon.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.receipt_long_outlined, color: _C.primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${l10n.text('sell_total_cost')}: ',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _C.greyText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Obx(() {
                                  final total = controller.totalCostObx.value;
                                  return Flexible(
                                    child: Text(
                                      controller.priceCtrl.text.isEmpty
                                          ? '₹ 0.00'
                                          : '₹ ${total.toStringAsFixed(2)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _C.primaryBlue,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(l10n.text('sell_capacity')),
                                    _InputField(
                                      controller: controller.capacityCtrl,
                                      hint: 'e.g. 5 Seater',
                                      prefixIcon: Icons.aspect_ratio_rounded,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(l10n.text('sell_warranty')),
                                    _InputField(
                                      controller: controller.warrantyCtrl,
                                      hint: 'e.g. 1 Year',
                                      prefixIcon: Icons.verified_user_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Active Product Switch
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _C.borderGrey),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.visibility_outlined, color: _C.primaryBlue, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.text('sell_active_product'),
                                        style: const TextStyle(
                                          color: _C.darkText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Text(
                                        'Show this listing publicly',
                                        style: TextStyle(color: _C.greyText, fontSize: 11.5),
                                      ),
                                    ],
                                  ),
                                ),
                                Obx(() {
                                  return Switch(
                                    value: controller.isActive.value,
                                    onChanged: (v) => controller.isActive.value = v,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: _C.primaryBlue,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: const Color(0xFFCBD5E1),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.primaryBlue,
                    side: BorderSide(
                      color: BuyProductTheme.borderMaroon.withValues(alpha: 0.6),
                      width: 1.4,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () => Get.back(),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.text('cancel'),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: BuyProductTheme.headerGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: BuyProductTheme.primaryMaroon.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () => _handleProceedToPayment(context, l10n),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payment_rounded, size: 17),
                        SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Proceed to Payment',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BuyProductTheme.borderMaroon.withValues(alpha: 0.3),
          width: 1.2,
        ),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BuyProductTheme.chipMaroonBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _C.primaryBlue, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  void _showImageSourceDialog(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Photo Source',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _C.darkText,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: BuyProductTheme.chipMaroonBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: _C.primaryBlue, size: 22),
                  ),
                  title: const Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _C.darkText),
                  ),
                  subtitle: const Text(
                    'Capture product image directly',
                    style: TextStyle(fontSize: 12, color: _C.greyText),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onCamera();
                  },
                ),
                const SizedBox(height: 6),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: BuyProductTheme.chipMaroonBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: _C.primaryBlue, size: 22),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _C.darkText),
                  ),
                  subtitle: const Text(
                    'Select photos from your device',
                    style: TextStyle(fontSize: 12, color: _C.greyText),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onGallery();
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
          color: _C.darkText,
          fontSize: 13,
          fontWeight: FontWeight.w700,
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
  final IconData? prefixIcon;
  final String? prefixText;
  final String? suffixText;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.prefixIcon,
    this.prefixText,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        color: _C.darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _C.greyText, fontSize: 13.5, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: _C.fieldBg,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: _C.greyText, size: 18)
            : null,
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: _C.darkText, fontSize: 14, fontWeight: FontWeight.w800),
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: _C.greyText, fontSize: 14, fontWeight: FontWeight.w700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: BuyProductTheme.borderMaroon.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: BuyProductTheme.borderMaroon.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.primaryBlue, width: 1.8),
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

class _MainImagePickerTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final File? previewFile;
  final String chooseFileText;

  const _MainImagePickerTile({
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: _C.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BuyProductTheme.borderMaroon.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.camera_alt_rounded, color: _C.primaryBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.darkText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: BuyProductTheme.chipMaroonBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: BuyProductTheme.borderMaroon.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    chooseFileText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (previewFile != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              previewFile!,
              height: 130,
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
        GestureDetector(
          onTap: onPickTap,
          child: Container(
            decoration: BoxDecoration(
              color: _C.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BuyProductTheme.borderMaroon.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.photo_camera_back_rounded, color: _C.primaryBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    images.isEmpty
                        ? maxImagesText
                        : '${images.length} images selected',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.darkText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: BuyProductTheme.chipMaroonBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: BuyProductTheme.borderMaroon.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    chooseFileText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _C.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(images[i].path),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

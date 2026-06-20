import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../localization/app_localizations.dart';
import '../controller/sell_product_controller.dart';
import 'sell_product_form_screen.dart';

class _C {
  static const Color primaryBlue = Color(0xFF1400FF);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color greyText = Color(0xFF8A8FA3);
  static const Color scaffoldBg = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class SellProductSubCategoryScreen extends GetView<SellProductController> {
  const SellProductSubCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.scaffoldBg,
      body: Column(
        children: [
          const _TopBar(),
          const _StepIndicator(),
          Expanded(
            child: Obx(() {
              if (controller.selectedCategoryIndex.value == null) {
                return Center(
                  child: Text(
                    context.l10n.text('sell_error_categories'),
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final category = controller
                  .categories[controller.selectedCategoryIndex.value!];

              if (controller.isLoadingSubCategories.value) {
                return const Center(
                  child: CircularProgressIndicator(color: _C.primaryBlue),
                );
              }

              if (controller.subCategoriesError.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.text('sell_error_subcategories'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              controller.fetchSubCategories(category.id),
                          icon: const Icon(Icons.refresh),
                          label: Text(context.l10n.text('sell_retry')),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BACK
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chevron_left_rounded,
                              color: _C.primaryBlue,
                              size: 22,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              context.l10n.text('sell_back'),
                              style: const TextStyle(
                                color: _C.primaryBlue,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Title
                    Text(
                      context.l10n.text('sell_select_subcategory'),
                      style: const TextStyle(
                        color: _C.darkText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Selected category banner
                    _SelectedCategoryBanner(
                      categoryName: category.name,
                      onChangeTap: () => Get.back(),
                    ),
                    const SizedBox(height: 20),

                    // Grid or empty info
                    if (controller.subCategories.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.subCategories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemBuilder: (context, i) {
                          final subCat = controller.subCategories[i];
                          return Obx(() {
                            final isSelected =
                                controller.selectedSubCategoryIndex.value == i;

                            return GestureDetector(
                              onTap: () => controller.selectSubCategory(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: _C.cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? _C.primaryBlue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            subCat.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  color: const Color(
                                                    0xFFEEEEF8,
                                                  ),
                                                  child: const Icon(
                                                    Icons.image_rounded,
                                                    color: Color(0xFFAAAAAA),
                                                    size: 40,
                                                  ),
                                                ),
                                            loadingBuilder: (_, child, progress) {
                                              if (progress == null)
                                                return child;
                                              return Container(
                                                color: const Color(0xFFEEEEF8),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: _C.primaryBlue,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subCat.name,
                                              style: TextStyle(
                                                color: _C.darkText,
                                                fontSize: 14,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: isSelected
                                                ? _C.primaryBlue
                                                : _C.greyText,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      ),

                    if (controller.subCategories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          context.l10n.text('sell_no_subcategories'),
                          style: const TextStyle(
                            color: _C.greyText,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Hint
                    Center(
                      child: Text(
                        context.l10n.text('sell_subcategory_hint'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _C.greyText,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      bottomSheet: Obx(() {
        final hasSelection = controller.selectedSubCategoryIndex.value != null;
        return _NextButton(
          enabled: hasSelection,
          onTap: hasSelection
              ? () => Get.to(() => const SellProductFormScreen())
              : null,
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
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _StepCircle(
            number: 1,
            label: context.l10n.text('sell_category'),
            state: _StepState.done,
          ),
          const _StepLine(active: true),
          _StepCircle(
            number: 2,
            label: context.l10n.text('sell_sub_category'),
            state: _StepState.active,
          ),
          const _StepLine(active: false),
          _StepCircle(
            number: 3,
            label: context.l10n.text('sell_details'),
            state: _StepState.inactive,
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDone || isActive)
                ? _C.primaryBlue
                : const Color(0xFFE8E8F0),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : Text(
                  '$number',
                  style: TextStyle(
                    color: isActive ? Colors.white : _C.greyText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: (isDone || isActive) ? _C.primaryBlue : _C.greyText,
            fontSize: 9,
            fontWeight: (isDone || isActive)
                ? FontWeight.w700
                : FontWeight.w500,
            letterSpacing: 0.5,
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

class _SelectedCategoryBanner extends StatelessWidget {
  final String categoryName;
  final VoidCallback onChangeTap;

  const _SelectedCategoryBanner({
    required this.categoryName,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDDDEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.text('sell_selected_category')}$categoryName',
                  style: const TextStyle(
                    color: _C.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.text('sell_change_by_back'),
                  style: const TextStyle(color: _C.greyText, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onChangeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _C.darkText,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.text('sell_change'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;

  const _NextButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: enabled
                ? _C.primaryBlue
                : const Color.fromARGB(255, 169, 161, 252),
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            context.l10n.text('sell_next'),
            style: const TextStyle(
              color: _C.darkText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

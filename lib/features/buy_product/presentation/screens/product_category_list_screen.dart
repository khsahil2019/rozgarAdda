import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/buy_product_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import 'product_list_screen.dart';

class ProductCategoryListScreen extends GetView<BuyProductController> {
  const ProductCategoryListScreen({super.key});

  static const Color _primary = Color(0xFF1400FF);
  static const Color _scaffoldBg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Category & Sub Category',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categoriesError.value != null) {
          return _buildErrorState(
            controller.categoriesError.value!,
            controller.fetchCategories,
          );
        }

        if (controller.categories.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Obx(() {
              final isExpanded =
                  controller.expandedCategoryId.value == category.id;
              final isSelected =
                  controller.selectedCategoryId.value == category.id;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryTile(
                    category: category,
                    isSelected: isSelected,
                    isExpanded: isExpanded,
                    onTap: () => controller.toggleCategoryExpansion(category),
                  ),
                  if (isExpanded) _buildSubCategorySection(context, category.id),
                ],
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildSubCategorySection(BuildContext context, int categoryId) {
    return Obx(() {
      if (controller.isLoadingSubCategories.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        );
      }

      if (controller.subCategoriesError.value != null) {
        return Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 12),
          child: _buildErrorState(
            controller.subCategoriesError.value!,
            () => controller.fetchSubCategories(categoryId),
            compact: true,
          ),
        );
      }

      if (controller.subCategories.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 12),
          child: Text(
            'No subcategories available.',
            style: TextStyle(color: Color(0xFF8A8FA3), fontSize: 13),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(left: 20, top: 4, bottom: 12),
        child: Column(
          children: controller.subCategories.map((sub) {
            final isSelected = controller.selectedSubCategoryId.value == sub.id;
            return _SubCategoryTile(
              subCategory: sub,
              isSelected: isSelected,
              onTap: () {
                controller.selectedSubCategoryId.value = sub.id;
                Get.to(
                  () => ProductListScreen(
                    title: sub.name,
                    categoryId: categoryId,
                    subcategoryId: sub.id,
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildErrorState(
    String message,
    VoidCallback onRetry, {
    bool compact = false,
  }) {
    if (compact) {
      return Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: Color(0xFF8A8FA3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8A8FA3), fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY TILE
// ─────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final BuyProductCategory category;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8EAFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1400FF)
                : const Color(0xFFE5E7F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: category.imageUrl.isNotEmpty
                  ? Image.network(
                      category.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackIcon(isSelected),
                    )
                  : _fallbackIcon(isSelected),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: isSelected
                  ? const Color(0xFF1400FF)
                  : const Color(0xFF8A8FA3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon(bool isSelected) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1400FF).withValues(alpha: 0.12)
            : const Color(0xFFF1F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.category_rounded,
        color: isSelected ? const Color(0xFF1400FF) : const Color(0xFF4B5563),
        size: 26,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUBCATEGORY TILE
// ─────────────────────────────────────────────
class _SubCategoryTile extends StatelessWidget {
  final BuyProductSubCategory subCategory;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryTile({
    required this.subCategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1400FF).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1400FF)
                : const Color(0xFFE5E7F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: subCategory.imageUrl.isNotEmpty
                  ? Image.network(
                      subCategory.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _fallbackSubIcon(isSelected),
                    )
                  : _fallbackSubIcon(isSelected),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subCategory.name,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1400FF)
                      : const Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isSelected
                  ? const Color(0xFF1400FF)
                  : const Color(0xFF8A8FA3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackSubIcon(bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1400FF).withValues(alpha: 0.1)
            : const Color(0xFFF1F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.subdirectory_arrow_right_rounded,
        size: 20,
        color: isSelected ? const Color(0xFF1400FF) : const Color(0xFF8A8FA3),
      ),
    );
  }
}

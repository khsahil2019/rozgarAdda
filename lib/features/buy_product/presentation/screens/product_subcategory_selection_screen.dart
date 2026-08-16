import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/buy_product_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import 'product_list_screen.dart';

class ProductSubCategorySelectionScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductSubCategorySelectionScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductSubCategorySelectionScreen> createState() =>
      _ProductSubCategorySelectionScreenState();
}

class _ProductSubCategorySelectionScreenState
    extends State<ProductSubCategorySelectionScreen> {
  final BuyProductController controller = Get.find<BuyProductController>();

  static const Color _primary = Color(0xFF1400FF);
  static const Color _scaffoldBg = Color(0xFFF5F6FA);
  static const Color _darkText = Color(0xFF1A1A2E);
  static const Color _greyText = Color(0xFF8A8FA3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSubCategories(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: _darkText,
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingSubCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.subCategoriesError.value != null) {
          return _buildErrorState(
            controller.subCategoriesError.value!,
            () => controller.fetchSubCategories(widget.categoryId),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSubCategories(widget.categoryId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎫 "View All Products" Card
                _buildViewAllCard(),
                const SizedBox(height: 24),

                // 🏷️ Subcategories Header
                if (controller.subCategories.isNotEmpty) ...[
                  const Text(
                    'Select Subcategory',
                    style: TextStyle(
                      color: _darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🎛️ Subcategories Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.subCategories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                    itemBuilder: (context, index) {
                      final subCategory = controller.subCategories[index];
                      return _SubCategoryGridItem(
                        subCategory: subCategory,
                        onTap: () {
                          Get.to(
                            () => ProductListScreen(
                              title: widget.categoryName,
                              categoryId: widget.categoryId,
                              subcategoryId: subCategory.id,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No subcategories found for this category.',
                        style: TextStyle(color: _greyText, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildViewAllCard() {
    return InkWell(
      onTap: () {
        Get.to(
          () => ProductListScreen(
            title: widget.categoryName,
            categoryId: widget.categoryId,
            subcategoryId: null,
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1400FF), Color(0xFF5356FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A1400FF),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View All Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Explore everything in this category',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: _greyText),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _greyText, fontSize: 15),
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

// SubCategory Grid Item
class _SubCategoryGridItem extends StatelessWidget {
  final BuyProductSubCategory subCategory;
  final VoidCallback onTap;

  const _SubCategoryGridItem({required this.subCategory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            // padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(color: const Color(0xFFECEEF5), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: subCategory.imageUrl.isNotEmpty
                  ? Image.network(
                      subCategory.imageUrl,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.subdirectory_arrow_right_rounded,
                        color: Color(0xFF1400FF),
                        size: 28,
                      ),
                    )
                  : const Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      color: Color(0xFF1400FF),
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              subCategory.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

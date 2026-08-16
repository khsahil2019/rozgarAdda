import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/buy_product_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import 'product_list_screen.dart';
import 'product_subcategory_selection_screen.dart';

class ProductCategoryListScreen extends GetView<BuyProductController> {
  const ProductCategoryListScreen({super.key});

  static const Color _primary = Color(0xFF1400FF);
  static const Color _scaffoldBg = Color(0xFFF5F6FA);
  static const Color _darkText = Color(0xFF1A1A2E);
  static const Color _greyText = Color(0xFF8A8FA3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: _darkText,
        title: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: _primary, size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Explore Products',
                style: TextStyle(
                  color: _darkText,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
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

        return RefreshIndicator(
          onRefresh: controller.fetchCategories,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search Bar (OLX Style)
                _buildSearchBar(),
                const SizedBox(height: 16),

                // 🎁 Promo Banner
                _buildPromoBanner(),
                const SizedBox(height: 24),

                // 🏷️ Section Title
                const Text(
                  'Browse Categories',
                  style: TextStyle(
                    color: _darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),

                // 🎛️ Category Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return _CategoryGridItem(
                      category: category,
                      onTap: () {
                        // Navigate to ProductSubCategorySelectionScreen passing categoryId and categoryName
                        Get.to(
                          () => ProductSubCategorySelectionScreen(
                            categoryName: category.name,
                            categoryId: category.id,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Search cars, mobiles, jobs...',
          hintStyle: const TextStyle(color: _greyText, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _greyText),
          suffixIcon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic_none_rounded, color: _greyText),
              SizedBox(width: 12),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onTap: () {
          // Visual/Decorative search action or visual highlight
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1400FF), Color(0xFF007BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x201400FF),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'PROMO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Buy Directly\nfrom Verified Owners',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '100% Genuine Products',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Visual element in banner representing an owner/badge
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
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

// Category Grid Item
class _CategoryGridItem extends StatelessWidget {
  final BuyProductCategory category;
  final VoidCallback onTap;

  const _CategoryGridItem({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            padding: const EdgeInsets.all(0),
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
              child: category.imageUrl.isNotEmpty
                  ? Image.network(
                      category.imageUrl,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.category_rounded,
                        color: Color(0xFF1400FF),
                        size: 28,
                      ),
                    )
                  : const Icon(
                      Icons.category_rounded,
                      color: Color(0xFF1400FF),
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              category.name,
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

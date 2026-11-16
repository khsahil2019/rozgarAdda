import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/widgets/network_image_service.dart';
import '../controller/buy_product_controller.dart';
import '../../domain/entities/buy_product_entities.dart';
import '../theme/buy_product_theme.dart';
import '../widgets/marketplace_search_bar.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSubCategories(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BuyProductTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 58,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 7, bottom: 7),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BuyProductTheme.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BuyProductTheme.subtleBorder, width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: BuyProductTheme.darkText,
                  size: 17,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.categoryName,
              style: const TextStyle(
                color: BuyProductTheme.darkText,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Obx(() => Text(
                  '${controller.subCategories.length} Subcategories',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: BuyProductTheme.greyText,
                  ),
                )),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: BuyProductTheme.subtleBorder, height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingSubCategories.value && controller.subCategories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: BuyProductTheme.primaryMaroon),
          );
        }

        if (controller.subCategoriesError.value != null && controller.subCategories.isEmpty) {
          return _buildErrorState(
            controller.subCategoriesError.value!,
            () => controller.fetchSubCategories(widget.categoryId),
          );
        }

        final filteredSubCats = controller.subCategories.where((sub) {
          return sub.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return RefreshIndicator(
          onRefresh: () => controller.fetchSubCategories(widget.categoryId),
          color: BuyProductTheme.primaryMaroon,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Live Search Bar with 4-Side Reddish Border
                MarketplaceSearchBar(
                  controller: _searchController,
                  hintText: 'Search subcategories...',
                  searchQuery: _searchQuery,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
                const SizedBox(height: 14),

                // 🎫 "View All Products" Card
                _buildViewAllCard(),
                const SizedBox(height: 18),

                // 🏷️ Subcategories Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Subcategory',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: BuyProductTheme.darkText,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BuyProductTheme.chipMaroonBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredSubCats.length} Options',
                        style: const TextStyle(
                          color: BuyProductTheme.primaryMaroon,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 🎛️ Subcategories Grid (EXACTLY 3 ITEMS PER ROW)
                if (filteredSubCats.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No subcategories matching "$_searchQuery"'
                            : 'No subcategories found for this category.',
                        style: const TextStyle(
                          color: BuyProductTheme.greyText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSubCats.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 84,
                    ),
                    itemBuilder: (context, index) {
                      final subCategory = filteredSubCats[index];
                      return _SubCategoryGridItem(
                        subCategory: subCategory,
                        onTap: () {
                          Get.to(
                            () => ProductListScreen(
                              title: '${widget.categoryName} • ${subCategory.name}',
                              categoryId: widget.categoryId,
                              subcategoryId: subCategory.id,
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

  Widget _buildViewAllCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: BuyProductTheme.headerGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: BuyProductTheme.primaryMaroon.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(
              () => ProductListScreen(
                title: widget.categoryName,
                categoryId: widget.categoryId,
                subcategoryId: null,
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'ALL ITEMS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'View All ${widget.categoryName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Explore all products in this category',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
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
            const Icon(Icons.wifi_off_rounded, size: 48, color: BuyProductTheme.lightGreyText),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BuyProductTheme.greyText, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BuyProductTheme.primaryMaroon,
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
// COMPACT SUBCATEGORY GRID ITEM (4 PER ROW WITH BOLD MAROON BORDER)
// ─────────────────────────────────────────────
class _SubCategoryGridItem extends StatelessWidget {
  final BuyProductSubCategory subCategory;
  final VoidCallback onTap;

  const _SubCategoryGridItem({
    required this.subCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: BuyProductTheme.primaryMaroon.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: BuyProductTheme.borderMaroon,
            width: 1.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image / Icon
            Expanded(
              child: Container(
                color: BuyProductTheme.lightMaroonBg,
                child: subCategory.imageUrl.isNotEmpty
                    ? NetworkImageService(
                        imageUrl: ApiRoutes.absoluteUrl(subCategory.imageUrl),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: _buildFallbackIcon(),
                      )
                    : _buildFallbackIcon(),
              ),
            ),

            // Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              color: Colors.white,
              child: Text(
                subCategory.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: BuyProductTheme.darkText,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      decoration: const BoxDecoration(
        gradient: BuyProductTheme.categoryCardGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.category_outlined,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

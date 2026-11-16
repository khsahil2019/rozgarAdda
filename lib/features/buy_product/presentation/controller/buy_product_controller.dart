import 'package:get/get.dart';
import '../../domain/entities/buy_product_entities.dart';
import '../../domain/repository/buy_product_repository.dart';

class BuyProductController extends GetxController {
  final BuyProductRepository repository;

  BuyProductController({required this.repository});

  // ── Categories & Subcategories State ─────────────────
  final RxList<BuyProductCategory> categories = <BuyProductCategory>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxnString categoriesError = RxnString();

  final RxnInt expandedCategoryId = RxnInt();
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedSubCategoryId = RxnInt();

  // Cache & reactive state for active subcategory
  final Map<int, List<BuyProductSubCategory>> _subCategoryCache = {};
  final RxList<BuyProductSubCategory> subCategories =
      <BuyProductSubCategory>[].obs;
  final RxBool isLoadingSubCategories = false.obs;
  final RxnString subCategoriesError = RxnString();

  // ── Products List State ─────────────────────────────
  final RxList<BuyProduct> products = <BuyProduct>[].obs;
  final RxBool isLoadingProducts = false.obs;
  final RxnString productsError = RxnString();

  // ── Recommended Products State ──────────────────────
  final RxList<BuyProduct> recommendedProducts = <BuyProduct>[].obs;
  final RxBool isLoadingRecommended = false.obs;
  final RxnString recommendedError = RxnString();
  bool _hasLoadedRecommended = false;
  Future<void>? _recommendedLoadFuture;

  // ── Product Details State ───────────────────────────
  final Rxn<BuyProduct> productDetail = Rxn<BuyProduct>();
  final RxList<BuyProduct> relatedProducts = <BuyProduct>[].obs;
  final RxBool isLoadingDetail = false.obs;
  final RxnString detailError = RxnString();
  final RxInt selectedImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initHomeData();
  }

  Future<void> _initHomeData() async {
    await fetchCategories();
    await fetchRecommendedProducts();
  }

  // Fetch Categories
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      categoriesError.value = null;
      final lang = Get.locale?.languageCode ?? 'en';
      final result = await repository.getCategories(lang);

      result.fold(
        (failure) => categoriesError.value = failure.message,
        (data) => categories.assignAll(data),
      );
    } catch (e) {
      categoriesError.value = 'Failed to load categories';
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Fetch Subcategories (with cache logic)
  Future<void> fetchSubCategories(int categoryId) async {
    if (_subCategoryCache.containsKey(categoryId)) {
      subCategories.assignAll(_subCategoryCache[categoryId]!);
      subCategoriesError.value = null;
      return;
    }

    try {
      isLoadingSubCategories.value = true;
      subCategoriesError.value = null;
      subCategories.clear();

      final lang = Get.locale?.languageCode ?? 'en';
      final result = await repository.getSubCategories(categoryId, lang);

      result.fold((failure) => subCategoriesError.value = failure.message, (
        data,
      ) {
        _subCategoryCache[categoryId] = data;
        subCategories.assignAll(data);
      });
    } catch (e) {
      subCategoriesError.value = 'Failed to load sub-categories';
    } finally {
      isLoadingSubCategories.value = false;
    }
  }

  // Toggle category expansion
  void toggleCategoryExpansion(BuyProductCategory category) {
    if (expandedCategoryId.value == category.id) {
      expandedCategoryId.value = null;
    } else {
      expandedCategoryId.value = category.id;
      selectedCategoryId.value = category.id;
      selectedSubCategoryId.value = null;
      fetchSubCategories(category.id);
    }
  }

  // Fetch products across all categories/subcategories for "Recommended Items" & global search
  Future<void> fetchRecommendedProducts({bool forceRefresh = false}) async {
    if (_recommendedLoadFuture != null && !forceRefresh) {
      return _recommendedLoadFuture;
    }
    if (_hasLoadedRecommended && recommendedProducts.isNotEmpty && !forceRefresh) {
      return;
    }

    final future = _loadRecommendedProductsInternal(forceRefresh: forceRefresh);
    _recommendedLoadFuture = future;
    try {
      await future;
    } finally {
      if (identical(_recommendedLoadFuture, future)) {
        _recommendedLoadFuture = null;
      }
    }
  }

  Future<void> _fetchSubCategoryBatchProducts(
    List<int> subIds,
    String lang,
    Map<int, BuyProduct> collected, {
    void Function(List<BuyProduct> sorted)? onBatch,
  }) async {
    const prodBatchSize = 6;
    for (var j = 0; j < subIds.length; j += prodBatchSize) {
      final subSlice = subIds.skip(j).take(prodBatchSize).toList();
      final prodLists = await Future.wait(
        subSlice.map((subId) async {
          final res = await repository.getProducts(
            subcategoryId: subId,
            lang: lang,
          );
          return res.fold((_) => <BuyProduct>[], (list) => list);
        }),
      );

      bool updated = false;
      for (final list in prodLists) {
        for (final product in list) {
          collected[product.id] = product;
          updated = true;
        }
      }
      if (updated && onBatch != null) {
        final sorted = collected.values.toList()
          ..sort((a, b) => b.id.compareTo(a.id));
        onBatch(sorted);
      }
    }
  }

  Future<void> _loadRecommendedProductsInternal({required bool forceRefresh}) async {
    try {
      isLoadingRecommended.value = true;
      recommendedError.value = null;
      final lang = Get.locale?.languageCode ?? 'en';

      if (categories.isEmpty) {
        await fetchCategories();
      }
      if (categories.isEmpty) {
        recommendedError.value = categoriesError.value ?? 'Failed to load items';
        return;
      }

      final Map<int, BuyProduct> collected = {};
      if (!forceRefresh) {
        for (final p in recommendedProducts) {
          collected[p.id] = p;
        }
      }

      // Fetch subcategories for all categories in parallel batches
      const catBatchSize = 5;
      for (var i = 0; i < categories.length; i += catBatchSize) {
        final catBatch = categories.skip(i).take(catBatchSize).toList();
        final subLists = await Future.wait(
          catBatch.map((cat) async {
            if (_subCategoryCache.containsKey(cat.id)) {
              return _subCategoryCache[cat.id]!;
            }
            final res = await repository.getSubCategories(cat.id, lang);
            return res.fold((_) => <BuyProductSubCategory>[], (list) {
              _subCategoryCache[cat.id] = list;
              return list;
            });
          }),
        );

        final batchSubIds = subLists.expand((l) => l).map((s) => s.id).toList();
        if (batchSubIds.isEmpty) continue;

        await _fetchSubCategoryBatchProducts(
          batchSubIds,
          lang,
          collected,
          onBatch: (sorted) => recommendedProducts.assignAll(sorted),
        );
      }

      _hasLoadedRecommended = true;
    } catch (e) {
      if (recommendedProducts.isEmpty) {
        recommendedError.value = 'Failed to load recommended items';
      }
    } finally {
      isLoadingRecommended.value = false;
    }
  }

  // Fetch products by category / subcategory (or all products when both are null)
  Future<void> fetchProducts(int? categoryId, int? subcategoryId) async {
    try {
      isLoadingProducts.value = true;
      productsError.value = null;
      products.clear();
      final lang = Get.locale?.languageCode ?? 'en';

      if (subcategoryId != null) {
        final result = await repository.getProducts(
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          lang: lang,
        );
        result.fold(
          (failure) => productsError.value = failure.message,
          (data) => products.assignAll(data),
        );
        return;
      }

      if (categoryId != null) {
        List<BuyProductSubCategory> subs = _subCategoryCache[categoryId] ?? [];
        if (subs.isEmpty) {
          final subRes = await repository.getSubCategories(categoryId, lang);
          subs = subRes.fold((_) => [], (list) {
            _subCategoryCache[categoryId] = list;
            return list;
          });
          subCategories.assignAll(subs);
        }

        if (subs.isEmpty) {
          final result = await repository.getProducts(
            categoryId: categoryId,
            lang: lang,
          );
          result.fold(
            (failure) => productsError.value = failure.message,
            (data) => products.assignAll(data),
          );
          return;
        }

        final Map<int, BuyProduct> collected = {};
        await _fetchSubCategoryBatchProducts(
          subs.map((s) => s.id).toList(),
          lang,
          collected,
          onBatch: (sorted) => products.assignAll(sorted),
        );
        return;
      }

      // Global search / "All Products": reuse or fetch recommended products
      if (recommendedProducts.isNotEmpty) {
        products.assignAll(recommendedProducts);
        isLoadingProducts.value = false;
      }
      await fetchRecommendedProducts(forceRefresh: recommendedProducts.isEmpty);
      if (recommendedProducts.isNotEmpty) {
        products.assignAll(recommendedProducts);
      } else if (recommendedError.value != null) {
        productsError.value = recommendedError.value;
      }
    } catch (e) {
      productsError.value = 'Failed to load products';
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // Fetch product details & related products
  Future<void> fetchProductDetails(int productId) async {
    try {
      isLoadingDetail.value = true;
      detailError.value = null;
      productDetail.value = null;
      relatedProducts.clear();
      selectedImageIndex.value = 0;
      final lang = Get.locale?.languageCode ?? 'en';

      final result = await repository.getProductDetails(productId, lang);

      result.fold((failure) => detailError.value = failure.message, (data) {
        productDetail.value = data.product;
        relatedProducts.assignAll(data.relatedProducts);
      });
    } catch (e) {
      detailError.value = 'Failed to load product details';
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // Set selected image index
  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  // Select subcategory filter and fetch products
  void selectSubCategoryFilter(int? categoryId, int? subcategoryId) {
    selectedSubCategoryId.value = subcategoryId;
    fetchProducts(categoryId, subcategoryId);
  }
}

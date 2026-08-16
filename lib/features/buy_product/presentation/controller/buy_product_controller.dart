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

  // ── Product Details State ───────────────────────────
  final Rxn<BuyProduct> productDetail = Rxn<BuyProduct>();
  final RxList<BuyProduct> relatedProducts = <BuyProduct>[].obs;
  final RxBool isLoadingDetail = false.obs;
  final RxnString detailError = RxnString();
  final RxInt selectedImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
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

  // Fetch products by category / subcategory
  Future<void> fetchProducts(int? categoryId, int? subcategoryId) async {
    try {
      isLoadingProducts.value = true;
      productsError.value = null;
      products.clear();
      final lang = Get.locale?.languageCode ?? 'en';

      final result = await repository.getProducts(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        lang: lang,
      );

      result.fold(
        (failure) => productsError.value = failure.message,
        (data) => products.assignAll(data),
      );
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

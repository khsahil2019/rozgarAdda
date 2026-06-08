import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../domain/entities/buy_product_entities.dart';
import '../model/buy_product_dtos.dart';

abstract class BuyProductRemoteDataSource {
  Future<List<BuyProductCategoryModel>> getCategories(String lang);

  Future<List<BuyProductSubCategoryModel>> getSubCategories(
    int categoryId,
    String lang,
  );

  Future<List<BuyProductModel>> getProducts({
    int? categoryId,
    int? subcategoryId,
    required String lang,
  });

  Future<BuyProductDetailResponse> getProductDetails(
    int productId,
    String lang,
  );
}

class BuyProductRemoteDataSourceImpl implements BuyProductRemoteDataSource {
  @override
  Future<List<BuyProductCategoryModel>> getCategories(String lang) async {
    try {
      final res = await ApiService.request(
        method: 'GET',
        url: ApiRoutes.categories,
        queryParameters: {'lang': lang},
      );
      if (res['statusCode'] == 200 && res['success'] == true) {
        final List<dynamic> data = res['data'] ?? [];
        return data
            .map((json) =>
                BuyProductCategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to load categories. Please check your connection.');
    }
  }

  @override
  Future<List<BuyProductSubCategoryModel>> getSubCategories(
    int categoryId,
    String lang,
  ) async {
    try {
      final res = await ApiService.request(
        method: 'GET',
        url: '${ApiRoutes.subcategories}/$categoryId',
        queryParameters: {'lang': lang},
      );
      if (res['statusCode'] == 200 && res['success'] == true) {
        final List<dynamic> data = res['data'] ?? [];
        return data
            .map((json) => BuyProductSubCategoryModel.fromJson(
                json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to load sub-categories');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(
          'Failed to load sub-categories. Please check your connection.');
    }
  }

  @override
  Future<List<BuyProductModel>> getProducts({
    int? categoryId,
    int? subcategoryId,
    required String lang,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (subcategoryId != null) {
        body['category_id'] = subcategoryId;
      } else if (categoryId != null) {
        body['category_id'] = categoryId;
      }

      final res = await ApiService.request(
        method: 'POST',
        url: ApiRoutes.getProducts,
        body: body,
      );
      if (res['statusCode'] == 200 && res['success'] == true) {
        final List<dynamic> data = res['data'] ?? [];
        return data
            .map((json) => BuyProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to load products. Please check your connection.');
    }
  }

  @override
  Future<BuyProductDetailResponse> getProductDetails(
    int productId,
    String lang,
  ) async {
    try {
      final res = await ApiService.request(
        method: 'GET',
        url: ApiRoutes.productDetails(productId),
      );
      if (res['statusCode'] == 200 && res['success'] == true) {
        final productData = res['data'];
        if (productData == null) {
          throw Failure('Product not found');
        }
        final product =
            BuyProductModel.fromJson(productData as Map<String, dynamic>);

        final rawRelated = res['related_products'];
        final List<BuyProductModel> related = rawRelated is List
            ? rawRelated
                .map((e) =>
                    BuyProductModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : [];
        return BuyProductDetailResponse(
          product: product,
          relatedProducts: related,
        );
      } else {
        throw Failure(res['message'] ?? 'Failed to load product details');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure(
          'Failed to load product details. Please check your connection.');
    }
  }
}

import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../../../services/storage_service.dart';
import '../../domain/entities/sell_product_entities.dart';
import '../model/sell_product_dtos.dart';

abstract class SellProductRemoteDataSource {
  Future<List<SellProductCategoryModel>> getCategories(String lang);
  Future<List<SellProductSubCategoryModel>> getSubCategories(
    int categoryId,
    String lang,
  );
  Future<String> saveProduct(SellProductRequest request);
}

class SellProductRemoteDataSourceImpl implements SellProductRemoteDataSource {
  @override
  Future<List<SellProductCategoryModel>> getCategories(String lang) async {
    try {
      final res = await ApiService.request(
        method: 'GET',
        url: ApiRoutes.categories,
        queryParameters: {'lang': lang},
      );
      if (res['statusCode'] == 200 && res['success'] == true) {
        final List<dynamic> data = res['data'] ?? [];
        return data
            .map((json) => SellProductCategoryModel.fromJson(json as Map<String, dynamic>))
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
  Future<List<SellProductSubCategoryModel>> getSubCategories(
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
            .map((json) => SellProductSubCategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure(res['message'] ?? 'Failed to load sub-categories');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to load sub-categories. Please check your connection.');
    }
  }

  @override
  Future<String> saveProduct(SellProductRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageService.keyAccessToken) ??
          '1|y1EzlPQqrGADDxsCP3upGTTFT0cTIlfIB1bAMEZNb65f5911';

      final dioInstance = dio.Dio();
      final formData = dio.FormData.fromMap({
        'category_id': request.categoryId.toString(),
        'subcategory_id': request.subCategoryId.toString(),
        'title': request.title,
        'description': request.description,
        'price': request.price.toString(),
        'discount': request.discount.toString(),
        'features': request.features,
        'capacity': request.capacity,
        'warranty': request.warranty,
        'status': request.isActive ? '1' : '0',
      });

      if (request.mainImagePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'meta_image',
            await dio.MultipartFile.fromFile(
              request.mainImagePath,
              filename: request.mainImagePath.split('/').last,
            ),
          ),
        );
      }

      for (final path in request.galleryImagePaths) {
        if (path.isNotEmpty) {
          formData.files.add(
            MapEntry(
              'gallery_images[]',
              await dio.MultipartFile.fromFile(
                path,
                filename: path.split('/').last,
              ),
            ),
          );
        }
      }

      final response = await dioInstance.post(
        ApiRoutes.addProduct,
        data: formData,
        options: dio.Options(
          headers: {
            HttpHeaders.acceptHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map<String, dynamic> && resData['status'] == false) {
          throw Failure(resData['message'] ?? 'Failed to save product');
        }
        if (resData is Map<String, dynamic> && resData['success'] == false) {
          throw Failure(resData['message'] ?? 'Failed to save product');
        }
        return (resData is Map<String, dynamic> ? resData['message']?.toString() : null) ??
            'Product saved successfully.';
      } else {
        throw Failure(
          'Failed to save product. Server returned status code ${response.statusCode}.',
        );
      }
    } catch (e) {
      if (e is Failure) rethrow;
      if (e is dio.DioException) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          throw Failure(data['message'].toString());
        }
      }
      throw Failure('Something went wrong while saving the product.');
    }
  }
}

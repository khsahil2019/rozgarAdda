import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../../../services/storage_service.dart';
import '../../../buy_product/domain/entities/buy_product_entities.dart';
import '../model/wishlist_model.dart';

abstract class WishlistDataSource {
  Future<List<WishlistItemModel>> getWishlist();
  Future<bool> toggleWishlist(BuyProduct product);
  Future<bool> removeFromWishlist(int productId);
  Future<void> clearWishlist();
  Future<List<WishlistItemModel>> getCachedWishlist();
}

class WishlistDataSourceImpl implements WishlistDataSource {
  static const String _cacheKey = 'rozgar_user_wishlist_cache_v1';

  Future<String?> _getCandidateToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageService.keyAccessToken) ??
          prefs.getString('access_token') ??
          prefs.getString('candidate_token');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WishlistItemModel>> getCachedWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return [];

      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => WishlistItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[WishlistCache] Error reading cache: $e');
      return [];
    }
  }

  Future<void> _saveToCache(List<WishlistItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_cacheKey, jsonString);
    } catch (e) {
      debugPrint('[WishlistCache] Error writing cache: $e');
    }
  }

  /// Extracts the list of items from diverse backend response envelopes
  List<dynamic> _extractItemsList(dynamic response) {
    if (response == null) return [];
    if (response is List) return response;
    if (response is Map<String, dynamic>) {
      if (response['data'] is List) return response['data'] as List<dynamic>;
      if (response['data'] is Map && response['data']['data'] is List) {
        return response['data']['data'] as List<dynamic>;
      }
      if (response['wishlist'] is List) {
        return response['wishlist'] as List<dynamic>;
      }
      if (response['wishlist'] is Map && response['wishlist']['data'] is List) {
        return response['wishlist']['data'] as List<dynamic>;
      }
      if (response['products'] is List) {
        return response['products'] as List<dynamic>;
      }
    }
    return [];
  }

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    // 1. Retrieve local cache so items are never lost on slow/offline connections
    final localItems = await getCachedWishlist();

    // 2. Fetch from candidate wishlist API
    try {
      final token = await _getCandidateToken();
      debugPrint('[WishlistAPI] Fetching candidate wishlist from: ${ApiRoutes.wishlist}');
      debugPrint('[WishlistAPI] Token present: ${token != null && token.isNotEmpty}');

      final res = await ApiService.get(
        ApiRoutes.wishlist,
        accessToken: token,
      );

      debugPrint('[WishlistAPI] Status code: ${res['statusCode']}');

      final isSuccess = res['statusCode'] == 200 &&
          (res['success'] == true || res['status'] == true);

      final rawList = _extractItemsList(res);

      if (isSuccess || rawList.isNotEmpty) {
        final List<WishlistItemModel> remoteItems = [];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            try {
              remoteItems.add(WishlistItemModel.fromJson(item));
            } catch (err) {
              debugPrint('[WishlistAPI] Warning parsing item: $err');
            }
          }
        }

        // Update local cache with remote source of truth
        await _saveToCache(remoteItems);
        debugPrint('[WishlistAPI] Succeeded with ${remoteItems.length} items');
        return remoteItems;
      }
    } catch (e) {
      debugPrint('[WishlistAPI] Remote fetch note: $e. Using local cache.');
    }

    // 3. Graceful fallback to local cache
    return localItems;
  }

  @override
  Future<bool> toggleWishlist(BuyProduct product) async {
    final items = await getCachedWishlist();
    final index = items.indexWhere((item) => item.productId == product.id);

    bool nowWishlisted = false;
    if (index >= 0) {
      // Remove from list
      items.removeAt(index);
      nowWishlisted = false;
    } else {
      // Add to list
      items.insert(0, WishlistItemModel.fromProduct(product));
      nowWishlisted = true;
    }

    // Persist immediately locally
    await _saveToCache(items);

    // Call candidate wishlist toggle API
    try {
      final token = await _getCandidateToken();
      debugPrint('[WishlistAPI] Toggling item ${product.id} on: ${ApiRoutes.toggleWishlist}');

      final res = await ApiService.post(
        ApiRoutes.toggleWishlist,
        accessToken: token,
        body: {
          'product_id': product.id,
          'id': product.id,
        },
      );

      debugPrint('[WishlistAPI] Toggle response: $res');
      if (res['is_wishlist'] is bool) {
        return res['is_wishlist'] as bool;
      }
      if (res['is_favorite'] is bool) {
        return res['is_favorite'] as bool;
      }
    } catch (e) {
      debugPrint('[WishlistAPI] Remote toggle sync note: $e (local cache safely preserved)');
    }

    return nowWishlisted;
  }

  @override
  Future<bool> removeFromWishlist(int productId) async {
    final items = await getCachedWishlist();
    items.removeWhere((item) => item.productId == productId);
    await _saveToCache(items);

    final token = await _getCandidateToken();

    try {
      debugPrint('[WishlistAPI] Removing item $productId on: ${ApiRoutes.removeWishlist}');
      final res = await ApiService.post(
        ApiRoutes.removeWishlist,
        accessToken: token,
        body: {
          'product_id': productId,
          'id': productId,
        },
      );
      debugPrint('[WishlistAPI] Remove response: $res');
    } catch (e) {
      debugPrint('[WishlistAPI] Remove endpoint notice: $e. Falling back to toggle...');
      try {
        await ApiService.post(
          ApiRoutes.toggleWishlist,
          accessToken: token,
          body: {
            'product_id': productId,
            'id': productId,
          },
        );
      } catch (_) {}
    }

    return true;
  }

  @override
  Future<void> clearWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}

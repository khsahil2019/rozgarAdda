import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../buy_product/domain/entities/buy_product_entities.dart';
import '../../domain/repository/wishlist_repository.dart';
import '../data_source/wishlist_datasource.dart';
import '../model/wishlist_model.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistDataSource dataSource;

  WishlistRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<WishlistItemModel>>> getWishlist() async {
    try {
      final items = await dataSource.getWishlist();
      return Right(items);
    } catch (e) {
      // Fallback to local cache if anything unexpected throws
      final cached = await dataSource.getCachedWishlist();
      return Right(cached);
    }
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist(BuyProduct product) async {
    try {
      final result = await dataSource.toggleWishlist(product);
      return Right(result);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromWishlist(int productId) async {
    try {
      final result = await dataSource.removeFromWishlist(productId);
      return Right(result);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearWishlist() async {
    try {
      await dataSource.clearWishlist();
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}


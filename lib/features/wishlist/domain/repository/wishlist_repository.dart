import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../buy_product/domain/entities/buy_product_entities.dart';
import '../../data/model/wishlist_model.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<WishlistItemModel>>> getWishlist();
  Future<Either<Failure, bool>> toggleWishlist(BuyProduct product);
  Future<Either<Failure, bool>> removeFromWishlist(int productId);
  Future<Either<Failure, void>> clearWishlist();
}


import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../entities/buy_product_entities.dart';

abstract class BuyProductRepository {
  Future<Either<Failure, List<BuyProductCategory>>> getCategories(String lang);

  Future<Either<Failure, List<BuyProductSubCategory>>> getSubCategories(
    int categoryId,
    String lang,
  );

  Future<Either<Failure, List<BuyProduct>>> getProducts({
    int? categoryId,
    int? subcategoryId,
    required String lang,
  });

  Future<Either<Failure, BuyProductDetailResponse>> getProductDetails(
    int productId,
    String lang,
  );
}

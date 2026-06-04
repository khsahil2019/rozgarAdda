import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../entities/sell_product_entities.dart';

abstract class SellProductRepository {
  Future<Either<Failure, List<SellProductCategory>>> getCategories(String lang);
  
  Future<Either<Failure, List<SellProductSubCategory>>> getSubCategories(
    int categoryId,
    String lang,
  );

  Future<Either<Failure, String>> saveProduct(SellProductRequest request);
}

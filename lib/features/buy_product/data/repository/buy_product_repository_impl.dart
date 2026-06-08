import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../domain/entities/buy_product_entities.dart';
import '../../domain/repository/buy_product_repository.dart';
import '../data_source/buy_product_remote_datasource.dart';

class BuyProductRepositoryImpl implements BuyProductRepository {
  final BuyProductRemoteDataSource remoteDataSource;

  BuyProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BuyProductCategory>>> getCategories(
    String lang,
  ) async {
    try {
      final models = await remoteDataSource.getCategories(lang);
      return Right(models);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BuyProductSubCategory>>> getSubCategories(
    int categoryId,
    String lang,
  ) async {
    try {
      final models = await remoteDataSource.getSubCategories(categoryId, lang);
      return Right(models);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BuyProduct>>> getProducts({
    int? categoryId,
    int? subcategoryId,
    required String lang,
  }) async {
    try {
      final models = await remoteDataSource.getProducts(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        lang: lang,
      );
      return Right(models);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BuyProductDetailResponse>> getProductDetails(
    int productId,
    String lang,
  ) async {
    try {
      final response =
          await remoteDataSource.getProductDetails(productId, lang);
      return Right(response);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

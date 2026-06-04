import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../domain/entities/sell_product_entities.dart';
import '../../domain/repository/sell_product_repository.dart';
import '../data_source/sell_product_remote_datasource.dart';

class SellProductRepositoryImpl implements SellProductRepository {
  final SellProductRemoteDataSource remoteDataSource;

  SellProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SellProductCategory>>> getCategories(
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
  Future<Either<Failure, List<SellProductSubCategory>>> getSubCategories(
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
  Future<Either<Failure, String>> saveProduct(
    SellProductRequest request,
  ) async {
    try {
      final message = await remoteDataSource.saveProduct(request);
      return Right(message);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

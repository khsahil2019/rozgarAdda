import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../domain/entities/state_entity.dart';
import '../../domain/repository/state_repository.dart';
import '../data_source/state_remote_datasource.dart';

class StateRepositoryImpl implements StateRepository {
  final StateRemoteDataSource remoteDataSource;

  StateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StateEntity>>> getStatesImages() async {
    try {
      final models = await remoteDataSource.getStatesImages();
      return Right(models);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../domain/entities/missing_person.dart';
import '../../domain/repository/missing_person_repository.dart';
import '../data_source/missing_person_remote_datasource.dart';

class MissingPersonRepositoryImpl implements MissingPersonRepository {
  final MissingPersonRemoteDataSource remoteDataSource;

  MissingPersonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MissingPerson>>> getMissingPersons() async {
    try {
      final models = await remoteDataSource.getMissingPersons();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

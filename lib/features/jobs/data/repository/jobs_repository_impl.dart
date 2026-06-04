import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../domain/entities/available_job_entity.dart';
import '../../domain/entities/job_category.dart';
import '../../domain/entities/job_role_entity.dart';
import '../../domain/repository/jobs_repository.dart';
import '../data_source/jobs_remote_datasource.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource remoteDataSource;

  JobsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<JobCategory>>> getCategories() async {
    try {
      final models = await remoteDataSource.getCategories();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JobRoleEntity>>> getJobRoles(int categoryId) async {
    try {
      final models = await remoteDataSource.getJobRoles(categoryId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AvailableJob>>> getAvailableJobs(int roleId) async {
    try {
      final models = await remoteDataSource.getAvailableJobs(roleId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}


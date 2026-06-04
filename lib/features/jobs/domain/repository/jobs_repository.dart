import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/job_category.dart';
import '../entities/job_role_entity.dart';

abstract class JobsRepository {
  Future<Either<Failure, List<JobCategory>>> getCategories();
  Future<Either<Failure, List<JobRoleEntity>>> getJobRoles(int categoryId);
}

import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/available_job_entity.dart';
import '../entities/job_category.dart';
import '../entities/job_role_entity.dart';

abstract class JobsRepository {
  Future<Either<Failure, List<JobCategory>>> getCategories();
  Future<Either<Failure, List<JobRoleEntity>>> getJobRoles(int categoryId);
  Future<Either<Failure, List<AvailableJob>>> getAvailableJobs(int roleId);
  Future<Either<Failure, List<AvailableJob>>> getLatestJobs();
  Future<Either<Failure, bool>> applyJob({
    required int jobId,
    required String fullName,
    required String email,
    required String phone,
    required String experienceYears,
    required String experienceMonths,
    required String expectedSalary,
    required String noticePeriod,
    required String educationLevel,
    required String educationDetails,
    required String keySkills,
    required String resumePath,
  });
  Future<Either<Failure, bool>> logCallAndChatApply({
    required int jobId,
    required String type,
    required String phone
  });
}

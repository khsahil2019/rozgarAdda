import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/storage_service.dart';
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

  @override
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
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageService.keyAccessToken);
      if (token == null || token.isEmpty) {
        return Left(Failure('Login token not found. Please login again.'));
      }

      final fields = {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'experience_years': experienceYears,
        'experience_months': experienceMonths,
        'expected_salary': expectedSalary,
        'notice_period': noticePeriod,
        'education_level': educationLevel,
        'education_details': educationDetails,
        'key_skills': keySkills,
      };

      final result = await remoteDataSource.applyJob(
        jobId: jobId,
        token: token,
        fields: fields,
        resumePath: resumePath,
      );
      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}


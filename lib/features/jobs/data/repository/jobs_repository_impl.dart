import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/storage_service.dart';
import '../../domain/entities/available_job_entity.dart';
import '../../domain/entities/job_category.dart';
import '../../domain/entities/job_role_entity.dart';
import '../../domain/repository/jobs_repository.dart';
import 'package:rojgar/features/employer_dashboard/data/models/mock_employer_database.dart';
import 'package:rojgar/features/employer_dashboard/domain/entities/job_application_entity.dart';
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
  Future<Either<Failure, List<JobRoleEntity>>> getJobRoles(
    int categoryId,
  ) async {
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
  Future<Either<Failure, List<AvailableJob>>> getAvailableJobs(
    int roleId,
  ) async {
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
  Future<Either<Failure, List<AvailableJob>>> getLatestJobs() async {
    try {
      final models = await remoteDataSource.getLatestJobs();
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

      // Local bridge to sync candidate application with local employer database
      try {
        final mockDb = MockEmployerDatabase();
        await mockDb.applyToJob(
          JobApplication(
            id: 0,
            jobId: jobId,
            candidateName: fullName,
            email: email,
            phone: phone,
            experienceYears: experienceYears,
            experienceMonths: experienceMonths,
            educationLevel: educationLevel,
            educationDetails: educationDetails,
            keySkills: keySkills,
            resumePath: resumePath,
            status: 'pending',
            appliedAt: DateTime.now(),
          ),
        );
      } catch (_) {
        // Ignore mock database errors to not block candidates
      }

      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logCallAndChatApply({
    required int jobId,
    required String type,
    required String phone,
  }) async {
    try {
      final result = await remoteDataSource.logCallAndChatApply(
        jobId: jobId,
        type: type,
        phoneNo: phone
      );
      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

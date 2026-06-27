import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_source/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ApplicationEntity>>> getApplications() async {
    try {
      final models = await remoteDataSource.getApplications();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> editProfile({
    required String fullName,
    required String email,
    required String phone,
    required String state,
    required String district,
    required String locality,
    required String pincode,
    required String address,
    String? idProofPath,
    String? resumePath,
    String? profilePhotoPath,
  }) async {
    try {
      final fields = {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'state': state,
        'district': district,
        'locality': locality,
        'pincode': pincode,
        'address': address,
      };
      final files = <String, String>{};
      if (idProofPath != null && idProofPath.isNotEmpty) {
        files['id_proof'] = idProofPath;
      }
      if (resumePath != null && resumePath.isNotEmpty) {
        files['resume'] = resumePath;
      }
      if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
        files['profile_photo'] = profilePhotoPath;
      }
      final msg = await remoteDataSource.editProfile(fields: fields, files: files);
      return Right(msg);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final msg = await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return Right(msg);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> submitInquiry({
    required String name,
    required String mobile,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final msg = await remoteDataSource.submitInquiry(
        name: name,
        mobile: mobile,
        email: email,
        subject: subject,
        message: message,
      );
      return Right(msg);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

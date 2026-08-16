import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/application_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<ApplicationEntity>>> getApplications();

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
  });

  Future<Either<Failure, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  Future<Either<Failure, String>> submitInquiry({
    required String name,
    required String mobile,
    required String email,
    required String subject,
    required String message,
  });
}

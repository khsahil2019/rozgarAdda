import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/kyc_models.dart';

abstract class KycRepository {
  Future<Either<Failure, KycDataResponse>> getKycData(int candidateId);

  Future<Either<Failure, Unit>> updateKyc({
    required int id,
    required String fullName,
    required String phone,
    required String email,
    required int stateId,
    required int districtId,
    required String locality,
    required String pincode,
    required String address,
    String? idProofPath,
    String? resumePath,
    String? profilePhotoPath,
  });
}

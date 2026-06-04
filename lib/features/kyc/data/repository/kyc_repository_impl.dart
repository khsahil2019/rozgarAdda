import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../domain/entities/kyc_models.dart';
import '../../domain/repository/kyc_repository.dart';
import '../data_source/kyc_remote_datasource.dart';

class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource remoteDataSource;

  KycRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, KycDataResponse>> getKycData(int candidateId) async {
    try {
      final model = await remoteDataSource.getKycData(candidateId);
      return Right(model.toEntity());
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      await remoteDataSource.updateKyc(
        id: id,
        fullName: fullName,
        phone: phone,
        email: email,
        stateId: stateId,
        districtId: districtId,
        locality: locality,
        pincode: pincode,
        address: address,
        idProofPath: idProofPath,
        resumePath: resumePath,
        profilePhotoPath: profilePhotoPath,
      );
      return const Right(unit);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

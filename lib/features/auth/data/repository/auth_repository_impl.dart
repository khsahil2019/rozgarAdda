import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';
import 'package:rojgar/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthResponse>> login(
    String email,
    String password,
  ) async {
    try {
      final result = await remoteDataSource.login(email, password);
      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String fullName,
    required String phone,
    required String email,
    required String username,
    required String password,
    required String state,
    required String district,
    required String locality,
    required String pincode,
    required String address,
    String? identityProofPath,
    String? termsAccepted,
  }) async {
    try {
      final result = await remoteDataSource.register(
        fullName: fullName,
        phone: phone,
        email: email,
        username: username,
        password: password,
        state: state,
        district: district,
        locality: locality,
        pincode: pincode,
        address: address,
        identityProofPath: identityProofPath,
        termsAccepted: termsAccepted ?? '0',
      );
      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownItem>>> getStates() async {
    try {
      final result = await remoteDataSource.getStates();
      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DropdownItem>>> getDistricts(int stateId) async {
    try {
      final result = await remoteDataSource.getDistricts(stateId);
      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendOtp(String phone) async {
    try {
      await remoteDataSource.sendOtp(phone);
      return Right(unit);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp(String phone, String otp) async {
    try {
      await remoteDataSource.verifyOtp(phone, otp);
      return Right(unit);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

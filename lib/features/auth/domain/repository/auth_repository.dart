import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(String email, String password);
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
  });
  Future<Either<Failure, List<DropdownItem>>> getStates();
  Future<Either<Failure, List<DropdownItem>>> getDistricts(int stateId);

  /// Sends OTP to [phone].
  Future<Either<Failure, Unit>> sendOtp(String phone);

  /// Verifies [otp] for [phone].
  Future<Either<Failure, Unit>> verifyOtp(String phone, String otp);
}

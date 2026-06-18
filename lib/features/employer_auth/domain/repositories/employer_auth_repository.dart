import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../entities/employer_entity.dart';

abstract class EmployerAuthRepository {
  Future<Either<Failure, Employer>> login(String email, String password);
  Future<Either<Failure, Employer>> register({
    required String companyName,
    required String email,
    required String phone,
    required String contactPerson,
    required String password,
    required String address,
  });
  Future<bool> checkLoggedIn();
  Future<void> logout();
}

import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/network/api_services.dart';
import '../../domain/entities/employer_entity.dart';
import '../../domain/repositories/employer_auth_repository.dart';
import '../models/employer_model.dart';

class EmployerAuthRepositoryImpl implements EmployerAuthRepository {
  static const String _keySessionId = 'employer_id';
  static const String _keySessionToken = 'employer_token';

  @override
  Future<Either<Failure, Employer>> login(String email, String password) async {
    try {
      final res = await ApiService.post(
        ApiRoutes.employerLogin,
        body: {
          "email": email.trim(),
          "password": password,
        },
      );

      if ((res['statusCode'] == 200 || res['statusCode'] == 201) &&
          res['status'] == true) {
        final employer = EmployerModel.fromApiResponse(res);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_keySessionId, employer.id);
        await prefs.setString(_keySessionToken, employer.token);
        await prefs.setString('access_token', employer.token);
        
        // Clear candidate session to avoid conflict
        await prefs.remove('candidate_id');

        return Right(employer);
      } else {
        return Left(Failure(res['message'] ?? res['error'] ?? 'Login failed'));
      }
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Employer>> register({
    required String companyName,
    required String email,
    required String phone,
    required String contactPerson,
    required String password,
    required String address,
    String? identityProofPath,
  }) async {
    try {
      final username = contactPerson.replaceAll(' ', '').toLowerCase();
      final fields = {
        'patient_name': companyName,
        'phone': phone,
        'state': '1',
        'city': '3',
        'locality': 'lucknow',
        'pincode': '255301',
        'email': email,
        'address': address,
        'username': username.isNotEmpty ? username : email.split('@').first,
        'password': password,
      };

      final res = await ApiService.uploadFiles(
        method: 'POST',
        url: ApiRoutes.employerRegister,
        fields: fields,
        files: identityProofPath != null && identityProofPath.isNotEmpty
            ? {'id_proof': identityProofPath}
            : {},
      );

      if ((res['statusCode'] == 200 || res['statusCode'] == 201) &&
          res['status'] == true) {
        final employer = EmployerModel.fromApiResponse(res);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_keySessionId, employer.id);
        await prefs.setString(_keySessionToken, employer.token);
        await prefs.setString('access_token', employer.token);

        // Clear candidate session to avoid conflict
        await prefs.remove('candidate_id');

        return Right(employer);
      } else {
        return Left(Failure(res['message'] ?? res['error'] ?? 'Registration failed'));
      }
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<bool> checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySessionId) != null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionId);
    await prefs.remove(_keySessionToken);
    await prefs.remove('access_token');
  }
}

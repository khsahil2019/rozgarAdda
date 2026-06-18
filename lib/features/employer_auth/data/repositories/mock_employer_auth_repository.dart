import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../domain/entities/employer_entity.dart';
import '../../domain/repositories/employer_auth_repository.dart';
import '../models/employer_model.dart';

class MockEmployerAuthRepository implements EmployerAuthRepository {
  static const String _keyEmployers = 'mock_employer_list';
  static const String _keySessionId = 'employer_id';
  static const String _keySessionToken = 'employer_token';

  // Seed default employer
  EmployerModel _defaultEmployer() {
    return const EmployerModel(
      id: 2001,
      companyName: 'Tech Solutions Ltd',
      email: 'hr@techsolutions.com',
      phone: '9876543210',
      contactPerson: 'Raman Khanna',
      address: '45 Blue Plaza, Malviya Nagar, Jaipur',
      token: 'mock_jwt_token_employer_2001',
    );
  }

  Future<List<EmployerModel>> _loadAllEmployers() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = prefs.getString(_keyEmployers);
    if (listJson == null || listJson.isEmpty) {
      final defaultList = [_defaultEmployer()];
      await prefs.setString(_keyEmployers, jsonEncode(defaultList.map((e) => e.toJson()).toList()));
      return defaultList;
    }
    try {
      final List<dynamic> decoded = jsonDecode(listJson);
      return decoded.map((e) => EmployerModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [_defaultEmployer()];
    }
  }

  Future<void> _saveEmployer(EmployerModel emp) async {
    final list = await _loadAllEmployers();
    list.removeWhere((e) => e.email.toLowerCase() == emp.email.toLowerCase());
    list.add(emp);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmployers, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  @override
  Future<Either<Failure, Employer>> login(String email, String password) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600)); // Simulate delay
      
      final list = await _loadAllEmployers();
      final index = list.indexWhere((e) => e.email.toLowerCase() == email.trim().toLowerCase());
      
      if (index == -1) {
        return Left(Failure('Invalid email or password.'));
      }

      final employer = list[index];
      // For mock purposes, any password matching length > 4 is accepted, or let's just accept 'password' or any password if they registered
      if (password.length < 4) {
        return Left(Failure('Password must be at least 4 characters.'));
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keySessionId, employer.id);
      await prefs.setString(_keySessionToken, employer.token);
      
      // Also clear candidate session to avoid conflict
      await prefs.remove('candidate_id');

      return Right(employer);
    } catch (e) {
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
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600)); // Simulate delay

      if (companyName.trim().isEmpty || email.trim().isEmpty || phone.trim().isEmpty) {
        return Left(Failure('Please fill in all required fields.'));
      }

      final list = await _loadAllEmployers();
      final exists = list.any((e) => e.email.toLowerCase() == email.trim().toLowerCase());
      if (exists) {
        return Left(Failure('An employer with this email is already registered.'));
      }

      final newId = list.isEmpty ? 2001 : list.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      final newEmployer = EmployerModel(
        id: newId,
        companyName: companyName,
        email: email,
        phone: phone,
        contactPerson: contactPerson,
        address: address,
        token: 'mock_jwt_token_employer_$newId',
      );

      await _saveEmployer(newEmployer);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keySessionId, newEmployer.id);
      await prefs.setString(_keySessionToken, newEmployer.token);
      
      // Clear candidate session to avoid conflict
      await prefs.remove('candidate_id');

      return Right(newEmployer);
    } catch (e) {
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
  }
}

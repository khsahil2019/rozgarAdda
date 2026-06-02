import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register({
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
  });
  Future<List<DropdownItem>> getStates();
  Future<List<DropdownItem>> getDistricts(int stateId);
}

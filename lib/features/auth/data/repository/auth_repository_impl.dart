import 'package:rojgar/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:rojgar/features/auth/data/data_source/model/auth_response.dart';
import 'package:rojgar/features/auth/data/data_source/model/dropdown_item.dart';
import 'package:rojgar/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
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
  }) {
    return remoteDataSource.register(
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
    );
  }

  @override
  Future<List<DropdownItem>> getStates() {
    return remoteDataSource.getStates();
  }

  @override
  Future<List<DropdownItem>> getDistricts(int stateId) {
    return remoteDataSource.getDistricts(stateId);
  }
}

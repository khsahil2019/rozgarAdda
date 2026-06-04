import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_services.dart';
import '../model/kyc_dtos.dart';

abstract class KycRemoteDataSource {
  Future<KycDataResponseModel> getKycData(int candidateId);

  Future<void> updateKyc({
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

class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  @override
  Future<KycDataResponseModel> getKycData(int candidateId) async {
    try {
      final res = await ApiService.get(
        'https://rozgaradda.com/api/candidate/kyc?id=$candidateId',
      );
      if (res['statusCode'] == 200 && res['status'] == true) {
        return KycDataResponseModel.fromJson(res);
      } else {
        throw Failure(res['message'] ?? 'Failed to load KYC data');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to load KYC data. Please check your connection.');
    }
  }

  @override
  Future<void> updateKyc({
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
      final fields = {
        'id': id.toString(),
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'state': stateId.toString(),
        'district': districtId.toString(),
        'locality': locality,
        'pincode': pincode,
        'address': address,
      };

      final files = <String, String>{};
      if (idProofPath != null && idProofPath.isNotEmpty) {
        files['id_proof'] = idProofPath;
      }
      if (resumePath != null && resumePath.isNotEmpty) {
        files['resume'] = resumePath;
      }
      if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
        files['profile_photo'] = profilePhotoPath;
      }

      final res = await ApiService.uploadFiles(
        method: 'POST',
        url: 'https://rozgaradda.com/api/candidate/kyc-update',
        fields: fields,
        files: files,
      );

      if (res['statusCode'] == 200) {
        final status = res['status'] == true;
        if (!status) {
          throw Failure(res['message'] ?? 'Failed to update KYC');
        }
      } else {
        throw Failure(
          res['message'] ??
              'Failed to update KYC (status code ${res['statusCode']})',
        );
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Failed to update KYC. Please check your connection.');
    }
  }
}

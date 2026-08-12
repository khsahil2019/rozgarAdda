import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import 'package:rojgar/core/network/api_services.dart';
import 'package:rojgar/features/auth/data/data_source/auth_remote_datasource.dart';

class MockAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      return handler!(options);
    }
    return ResponseBody.fromString('{}', 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockAdapter mockAdapter;

  setUp(() {
    mockAdapter = MockAdapter();
    ApiService.configure(adapter: mockAdapter);
    dataSource = AuthRemoteDataSourceImpl();
  });

  group('login', () {
    const tEmail = 'demo2';
    const tPassword = 'demo23456';

    test(
      'should return AuthResponse when status code is 200 and status is true',
      () async {
        // Arrange
        final responseData = {
          'status': true,
          'token': 'mock-jwt-token',
          'id': 1,
          'data': {
            'id': 1,
            'username': 'testcandidate',
            'name': 'Test Candidate',
            'email': tEmail,
            'phone': '1234567890',
            'address': 'Test Address',
            'city': 'Test City',
            'state': 'Test State',
            'country': 'Test Country',
            'zip_code': '123456',
            'profile_image': 'http://image.jpg',
          },
        };

        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            json.encode(responseData),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        // Act
        final result = await dataSource.login(tEmail, tPassword);

        // Assert
        expect(result.token, 'mock-jwt-token');
        expect(result.id, 1);
        expect(result.user.email, tEmail);
        expect(result.user.name, 'Test Candidate');
      },
    );

    test(
      'should throw Failure when status code is 200 but status is false',
      () async {
        // Arrange
        final responseData = {
          'status': false,
          'message': 'Invalid credentials',
        };

        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            json.encode(responseData),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        // Act & Assert
        expect(
          () => dataSource.login(tEmail, tPassword),
          throwsA(
            isA<Failure>().having(
              (f) => f.message,
              'message',
              'Invalid credentials',
            ),
          ),
        );
      },
    );

    test(
      'should throw Failure when HTTP request returns non-2xx status code',
      () async {
        // Arrange
        final responseData = {'message': 'Internal Server Error'};

        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            json.encode(responseData),
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        // Act & Assert
        expect(
          () => dataSource.login(tEmail, tPassword),
          throwsA(isA<Failure>()),
        );
      },
    );
  });

  group('register', () {
    const tFullName = 'John Doe';
    const tPhone = '9876543210';
    const tEmail = 'john@example.com';
    const tUsername = 'johndoe';
    const tPassword = 'password123';
    const tState = '1';
    const tDistrict = '2';
    const tLocality = 'Locality';
    const tPincode = '110001';
    const tAddress = 'Address';

    test(
      'should return AuthResponse when register is successful (status: true)',
      () async {
        // Arrange
        final responseData = {
          'status': true,
          'token': 'mock-register-token',
          'candidate_id': 42,
          'data': {
            'id': 42,
            'username': tUsername,
            'name': tFullName,
            'email': tEmail,
            'phone': tPhone,
            'address': tAddress,
            'city': 'City',
            'state': tState,
            'country': 'Country',
            'zip_code': tPincode,
            'profile_image': '',
          },
        };

        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            json.encode(responseData),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        // Act
        final result = await dataSource.register(
          fullName: tFullName,
          phone: tPhone,
          email: tEmail,
          username: tUsername,
          password: tPassword,
          state: tState,
          district: tDistrict,
          locality: tLocality,
          pincode: tPincode,
          address: tAddress,
          otp: '123456',
        );

        // Assert
        expect(result.token, 'mock-register-token');
        expect(result.id, 42);
        expect(result.user.email, tEmail);
      },
    );

    test(
      'should throw Failure when register returns status: false',
      () async {
        // Arrange
        final responseData = {
          'status': false,
          'message': 'Username already exists',
        };

        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            json.encode(responseData),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        // Act & Assert
        expect(
          () => dataSource.register(
            fullName: tFullName,
            phone: tPhone,
            email: tEmail,
            username: tUsername,
            password: tPassword,
            state: tState,
            district: tDistrict,
            locality: tLocality,
            pincode: tPincode,
            address: tAddress,
            otp: '123456',
          ),
          throwsA(
            isA<Failure>().having(
              (f) => f.message,
              'message',
              'Username already exists',
            ),
          ),
        );
      },
    );
  });
}

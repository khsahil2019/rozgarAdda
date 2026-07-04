import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../../domain/repository/employer_dashboard_repository.dart';
import '../data_source/employer_dashboard_remote_datasource.dart';

class EmployerDashboardRepositoryImpl implements EmployerDashboardRepository {
  final EmployerDashboardRemoteDataSource remoteDataSource;

  EmployerDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> changeApplicationStatus({
    required int applicationId,
    required String status,
    String? comments,
  }) async {
    try {
      await remoteDataSource.changeApplicationStatus(
        applicationId: applicationId,
        status: status,
        comments: comments,
      );
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(Failure(e.toString()));
    }
  }
}

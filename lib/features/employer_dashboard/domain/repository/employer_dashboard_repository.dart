import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';

abstract class EmployerDashboardRepository {
  Future<Either<Failure, void>> changeApplicationStatus({
    required int applicationId,
    required String status,
    String? comments,
  });
}

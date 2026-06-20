import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/missing_person.dart';

abstract class MissingPersonRepository {
  Future<Either<Failure, List<MissingPerson>>> getMissingPersons();
  Future<Either<Failure, String>> addMissingPerson({
    required Map<String, String> fields,
    required Map<String, String> files,
  });
}

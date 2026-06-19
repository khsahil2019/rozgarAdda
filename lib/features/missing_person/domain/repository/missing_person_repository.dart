import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/missing_person.dart';

abstract class MissingPersonRepository {
  Future<Either<Failure, List<MissingPerson>>> getMissingPersons();
}

import 'package:fpdart/fpdart.dart';
import 'package:rojgar/core/exceptions/exceptions.dart';
import '../entities/state_entity.dart';

abstract class StateRepository {
  Future<Either<Failure, List<StateEntity>>> getStatesImages();
}

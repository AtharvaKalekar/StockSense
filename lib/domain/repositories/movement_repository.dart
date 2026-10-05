import '../models/movement_log_model.dart';

abstract class MovementRepository {
  Future<List<MovementLogModel>> getMovements({String? skuId, MovementType? type});
  Future<void> recordMovement(MovementLogModel log);
}

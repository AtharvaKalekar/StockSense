import '../models/movement_log_model.dart';

abstract class AuditRepository {
  Future<List<MovementLogModel>> getAuditLogs({
    String? searchQuery,
    String? movementType,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> addAuditLog(MovementLogModel log);
}

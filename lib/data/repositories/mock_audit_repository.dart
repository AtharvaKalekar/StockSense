import 'dart:async';
import '../../domain/repositories/audit_repository.dart';
import '../../domain/models/movement_log_model.dart';
import '../mock/mock_database.dart';

class MockAuditRepository implements AuditRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<MovementLogModel>> getAuditLogs({
    String? searchQuery,
    String? movementType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = List<MovementLogModel>.from(_db.auditLogs);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((m) =>
        m.skuCode.toLowerCase().contains(q) ||
        m.skuName.toLowerCase().contains(q) ||
        m.performedBy.toLowerCase().contains(q) ||
        m.referenceNumber.toLowerCase().contains(q)
      ).toList();
    }

    return list;
  }

  @override
  Future<void> addAuditLog(MovementLogModel log) async {
    _db.auditLogs.insert(0, log);
  }
}

import 'dart:async';
import '../../domain/repositories/movement_repository.dart';
import '../../domain/models/movement_log_model.dart';
import '../mock/mock_database.dart';

class MockMovementRepository implements MovementRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<MovementLogModel>> getMovements({String? skuId, MovementType? type}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    var list = List<MovementLogModel>.from(_db.auditLogs);
    if (skuId != null) {
      list = list.where((m) => m.skuId == skuId).toList();
    }
    if (type != null) {
      list = list.where((m) => m.type == type).toList();
    }
    return list;
  }

  @override
  Future<void> recordMovement(MovementLogModel log) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.auditLogs.insert(0, log);
  }
}

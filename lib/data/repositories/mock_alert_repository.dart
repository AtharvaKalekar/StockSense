import 'dart:async';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/models/alert_model.dart';
import '../mock/mock_database.dart';

class MockAlertRepository implements AlertRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<AlertModel>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<AlertModel>.from(_db.alerts);
  }

  @override
  Future<void> markAsRead(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _db.alerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      _db.alerts[idx] = _db.alerts[idx].copyWith(isRead: true);
    }
  }

  @override
  Future<void> addAlert(AlertModel alert) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _db.alerts.insert(0, alert);
  }

  @override
  Future<void> clearAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.alerts.clear();
  }
}

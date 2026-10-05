import '../models/alert_model.dart';

abstract class AlertRepository {
  Future<List<AlertModel>> getAlerts();
  Future<void> markAsRead(String alertId);
  Future<void> addAlert(AlertModel alert);
  Future<void> clearAll();
}

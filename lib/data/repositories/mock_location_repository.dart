import 'dart:async';
import '../../domain/repositories/location_repository.dart';
import '../../domain/models/warehouse_zone_model.dart';
import '../mock/mock_database.dart';

class MockLocationRepository implements LocationRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<WarehouseZoneModel>> getZones() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List<WarehouseZoneModel>.from(_db.zones);
  }

  @override
  Future<WarehouseZoneModel?> getZoneByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 250));
    try {
      return _db.zones.firstWhere((z) => z.code.toLowerCase() == code.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}

import '../models/warehouse_zone_model.dart';

abstract class LocationRepository {
  Future<List<WarehouseZoneModel>> getZones();
  Future<WarehouseZoneModel?> getZoneByCode(String code);
}

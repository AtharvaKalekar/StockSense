class RackModel {
  final String id;
  final String code;
  final int capacity;
  final int currentItems;
  final List<String> skuIds;

  const RackModel({
    required this.id,
    required this.code,
    required this.capacity,
    required this.currentItems,
    required this.skuIds,
  });

  double get occupancyRatio => (currentItems / capacity).clamp(0.0, 1.0);
}

class WarehouseZoneModel {
  final String id;
  final String name;
  final String code;
  final int totalCapacity;
  final int currentOccupancy;
  final List<RackModel> racks;
  final double x;
  final double y;
  final double width;
  final double height;

  const WarehouseZoneModel({
    required this.id,
    required this.name,
    required this.code,
    required this.totalCapacity,
    required this.currentOccupancy,
    required this.racks,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get occupancyPercentage => (currentOccupancy / totalCapacity * 100).clamp(0.0, 100.0);
}

import '../../domain/models/user_model.dart';
import '../../domain/models/sku_model.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/warehouse_zone_model.dart';
import '../../domain/models/movement_log_model.dart';
import '../../domain/models/alert_model.dart';
import '../../domain/engine/stock_movement_engine.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/movement_repository.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/repositories/user_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/mock_inventory_repository.dart';
import '../../data/repositories/mock_order_repository.dart';
import '../../data/repositories/mock_location_repository.dart';
import '../../data/repositories/mock_movement_repository.dart';
import '../../data/repositories/mock_audit_repository.dart';
import '../../data/repositories/mock_alert_repository.dart';
import '../../data/repositories/mock_user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (Firebase.apps.isNotEmpty) {
    return FirebaseAuthRepository();
  }
  return MockAuthRepository();
});
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) => MockInventoryRepository());
final skuRepositoryProvider = inventoryRepositoryProvider;
final orderRepositoryProvider = Provider<OrderRepository>((ref) => MockOrderRepository());
final locationRepositoryProvider = Provider<LocationRepository>((ref) => MockLocationRepository());
final movementRepositoryProvider = Provider<MovementRepository>((ref) => MockMovementRepository());
final auditRepositoryProvider = Provider<AuditRepository>((ref) => MockAuditRepository());
final alertRepositoryProvider = Provider<AlertRepository>((ref) => MockAlertRepository());
final userRepositoryProvider = Provider<UserRepository>((ref) => MockUserRepository());

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(AppConstants.keyThemeMode) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyThemeMode, newMode == ThemeMode.dark);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class RoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() {
    _loadRole();
    return UserRole.admin;
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.keyUserRole) ?? 'admin';
    state = UserRoleExtension.fromCode(code);
  }

  Future<void> setRole(UserRole role) async {
    state = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, role.code);
  }
}

final currentRoleProvider = NotifierProvider<RoleNotifier, UserRole>(RoleNotifier.new);
final userRoleProvider = currentRoleProvider;

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
});

final inventoryListProvider = FutureProvider<List<SkuModel>>((ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getSkus();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final dashboardMetricsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final skus = await ref.watch(inventoryRepositoryProvider).getSkus();
  final orders = await ref.watch(orderRepositoryProvider).getOrders();

  int totalQty = skus.fold(0, (sum, item) => sum + item.quantity);
  int lowStock = skus.where((s) => s.stockStatus == 'Low Stock' || s.stockStatus == 'Critical').length;
  int pendingInbound = orders.where((o) => o.status == OrderStatus.pending).length;
  int pendingOutbound = orders.where((o) => o.status == OrderStatus.picking || o.status == OrderStatus.packed).length;

  return {
    'totalSkus': skus.length,
    'totalQuantity': totalQty,
    'lowStockCount': lowStock,
    'pendingInbound': pendingInbound,
    'pendingOutbound': pendingOutbound,
    'warehouseCapacity': 78.4,
  };
});

final ordersListProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrders();
});

final warehouseZonesProvider = FutureProvider<List<WarehouseZoneModel>>((ref) async {
  final repo = ref.watch(locationRepositoryProvider);
  return repo.getZones();
});

final alertsListProvider = FutureProvider<List<AlertModel>>((ref) async {
  final repo = ref.watch(alertRepositoryProvider);
  return repo.getAlerts();
});

final userListProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUsers();
});

final auditLogsProvider = FutureProvider<List<MovementLogModel>>((ref) async {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.getAuditLogs();
});

final stockMovementEngineProvider = Provider<StockMovementEngine>((ref) => StockMovementEngine());

final liveActivityTickerProvider = StreamProvider.autoDispose<MovementLogModel>((ref) async* {
  final random = Random();
  final skus = await ref.read(inventoryRepositoryProvider).getSkus();
  final locations = ['Zone A-01-R1-B1', 'Zone B-04-R2-B3', 'Zone C-02-R3-B4'];

  while (true) {
    await Future.delayed(const Duration(seconds: 4));
    if (skus.isEmpty) continue;

    final sku = skus[random.nextInt(skus.length)];
    final type = MovementType.values[random.nextInt(MovementType.values.length)];
    final qty = 1 + random.nextInt(15);

    yield MovementLogModel(
      id: 'TICK-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: type,
      skuId: sku.id,
      skuCode: sku.skuCode,
      skuName: sku.name,
      quantity: qty,
      beforeQty: sku.quantity,
      afterQty: sku.quantity + qty,
      fromLocation: sku.fullLocation,
      toLocation: locations[random.nextInt(locations.length)],
      performedBy: 'Automated AGV Robot #${1 + random.nextInt(5)}',
      referenceNumber: 'AUTO-${random.nextInt(8999) + 1000}',
      device: 'RFID Gate 0${1 + random.nextInt(3)}',
    );
  }
});

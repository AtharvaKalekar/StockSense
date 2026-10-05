import 'dart:async';
import '../../domain/repositories/order_repository.dart';
import '../../domain/models/order_model.dart';
import '../mock/mock_database.dart';

class MockOrderRepository implements OrderRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<OrderModel>> getOrders({OrderStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (status != null) {
      return _db.orders.where((o) => o.status == status).toList();
    }
    return List<OrderModel>.from(_db.orders);
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _db.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _db.orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _db.orders[idx] = _db.orders[idx].copyWith(status: status);
    }
  }

  @override
  Future<void> updatePickedQuantity(String orderId, String skuId, int pickedQty) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final oIdx = _db.orders.indexWhere((o) => o.id == orderId);
    if (oIdx != -1) {
      final order = _db.orders[oIdx];
      final newItems = order.items.map((item) {
        if (item.skuId == skuId) {
          return item.copyWith(
            pickedQty: pickedQty,
            isConfirmed: pickedQty >= item.expectedQty,
          );
        }
        return item;
      }).toList();

      final isAllPicked = newItems.every((i) => i.pickedQty >= i.expectedQty);
      _db.orders[oIdx] = order.copyWith(
        items: newItems,
        status: isAllPicked ? OrderStatus.packed : OrderStatus.picking,
      );
    }
  }

  @override
  Future<void> assignDispatchDetails(String orderId, String courier, String tracking, String vehicle) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final idx = _db.orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _db.orders[idx] = _db.orders[idx].copyWith(
        status: OrderStatus.dispatched,
        courierName: courier,
        trackingNumber: tracking,
        vehicleNumber: vehicle,
      );
    }
  }
}

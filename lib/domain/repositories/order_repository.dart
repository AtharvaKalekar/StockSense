import '../models/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders({OrderStatus? status});
  Future<OrderModel?> getOrderById(String id);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> updatePickedQuantity(String orderId, String skuId, int pickedQty);
  Future<void> assignDispatchDetails(String orderId, String courier, String tracking, String vehicle);
}

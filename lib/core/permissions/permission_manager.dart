import '../../domain/models/user_model.dart';

class PermissionManager {
  static bool canViewAnalytics(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseManager;
  }

  static bool canManageUsers(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canReorder(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseManager;
  }

  static bool canModifyStock(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseManager;
  }

  static bool canInwardOutward(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseManager;
  }

  static bool canPerformPicking(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseManager ||
        role == UserRole.picker;
  }

  static bool canPerformDispatch(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseManager ||
        role == UserRole.dispatcher;
  }

  static bool isReadOnly(UserRole role) {
    return role == UserRole.viewer;
  }

  static bool canPerformInward(UserRole role) => canInwardOutward(role);
  static bool canPerformOutward(UserRole role) => canInwardOutward(role);
  static bool canPickOrders(UserRole role) => canPerformPicking(role);
  static bool canAdjustStock(UserRole role) => canModifyStock(role);
}

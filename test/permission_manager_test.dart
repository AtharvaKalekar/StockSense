import 'package:flutter_test/flutter_test.dart';
import 'package:stocksense/core/permissions/permission_manager.dart';
import 'package:stocksense/domain/models/user_model.dart';

void main() {
  group('PermissionManager Unit Tests', () {
    test('Viewer role has read-only access', () {
      expect(PermissionManager.canAdjustStock(UserRole.viewer), false);
      expect(PermissionManager.canPerformInward(UserRole.viewer), false);
      expect(PermissionManager.canViewAnalytics(UserRole.viewer), false);
      expect(PermissionManager.canManageUsers(UserRole.viewer), false);
      expect(PermissionManager.canReorder(UserRole.viewer), false);
    });

    test('Picker role can pick orders but cannot reorder or manage users', () {
      expect(PermissionManager.canPickOrders(UserRole.picker), true);
      expect(PermissionManager.canReorder(UserRole.picker), false);
      expect(PermissionManager.canPerformDispatch(UserRole.picker), false);
      expect(PermissionManager.canManageUsers(UserRole.picker), false);
    });

    test('Dispatcher role can dispatch orders but cannot reorder or manage users', () {
      expect(PermissionManager.canPerformDispatch(UserRole.dispatcher), true);
      expect(PermissionManager.canReorder(UserRole.dispatcher), false);
      expect(PermissionManager.canPickOrders(UserRole.dispatcher), false);
      expect(PermissionManager.canManageUsers(UserRole.dispatcher), false);
    });

    test('Warehouse Manager role can reorder, inward, outward, pick and dispatch but cannot manage users', () {
      expect(PermissionManager.canReorder(UserRole.warehouseManager), true);
      expect(PermissionManager.canPerformInward(UserRole.warehouseManager), true);
      expect(PermissionManager.canPerformOutward(UserRole.warehouseManager), true);
      expect(PermissionManager.canPickOrders(UserRole.warehouseManager), true);
      expect(PermissionManager.canPerformDispatch(UserRole.warehouseManager), true);
      expect(PermissionManager.canManageUsers(UserRole.warehouseManager), false);
    });

    test('Admin role has full administrative access', () {
      expect(PermissionManager.canManageUsers(UserRole.admin), true);
      expect(PermissionManager.canViewAnalytics(UserRole.admin), true);
      expect(PermissionManager.canAdjustStock(UserRole.admin), true);
      expect(PermissionManager.canReorder(UserRole.admin), true);
    });
  });
}

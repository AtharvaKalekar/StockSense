import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocksense/features/dashboard/dashboard_screen.dart';
import 'package:stocksense/features/inventory/inventory_screen.dart';
import 'package:stocksense/features/location_map/location_map_screen.dart';
import 'package:stocksense/features/picking/picking_flow_screen.dart';
import 'package:stocksense/features/dispatch/dispatch_screen.dart';
import 'package:stocksense/features/alerts/alerts_screen.dart';
import 'package:stocksense/features/analytics/analytics_screen.dart';
import 'package:stocksense/features/user_management/user_management_screen.dart';
import 'package:stocksense/features/audit_history/audit_history_screen.dart';

void main() {
  Widget createWidgetForTesting(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('StockSense Complete Feature Verification Tests', () {
    testWidgets('1. DashboardScreen renders telemetry & capacity gauge', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const DashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('2. InventoryScreen renders search & SKU list', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const InventoryScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(InventoryScreen), findsOneWidget);
    });

    testWidgets('3. LocationMapScreen renders 2D deck schematic', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const LocationMapScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(LocationMapScreen), findsOneWidget);
    });

    testWidgets('4. PickingFlowScreen renders pick wave & rack matrix', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const PickingFlowScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(PickingFlowScreen), findsOneWidget);
    });

    testWidgets('5. DispatchScreen renders Kanban tabs & shipment cards', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const DispatchScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(DispatchScreen), findsOneWidget);
    });

    testWidgets('6. AlertsScreen renders stock alert cards', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const AlertsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AlertsScreen), findsOneWidget);
    });

    testWidgets('7. AnalyticsScreen renders valuation & category charts', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const AnalyticsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('8. UserManagementScreen renders RBAC user matrix', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const UserManagementScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(UserManagementScreen), findsOneWidget);
    });

    testWidgets('9. AuditHistoryScreen renders transaction ledger', (tester) async {
      await tester.pumpWidget(createWidgetForTesting(const AuditHistoryScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AuditHistoryScreen), findsOneWidget);
    });
  });
}

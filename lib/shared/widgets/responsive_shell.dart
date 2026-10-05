import 'user_profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/permissions/permission_manager.dart';
import '../../domain/models/user_model.dart';
import '../providers/app_providers.dart';
import '../providers/offline_sync_provider.dart';
import 'offline_banner.dart';

class ResponsiveShell extends ConsumerWidget {
  final Widget child;

  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final isOffline = ref.watch(isOfflineSimulatedProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          if (isWide) {
            return Row(
              children: [
                _buildNavigationRail(context, ref, userRole),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Scaffold(
                    body: Column(
                      children: [
                        if (isOffline) const OfflineBanner(),
                        Expanded(child: child),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Scaffold(
              body: Column(
                children: [
                  if (isOffline) const OfflineBanner(),
                  Expanded(child: child),
                ],
              ),
              bottomNavigationBar: _buildStitchBottomNavigationBar(context),
            );
          }
        },
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, WidgetRef ref, UserRole userRole) {
    final location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    if (location.startsWith('/inventory')) selectedIndex = 1;
    if (location.startsWith('/scanner')) selectedIndex = 2;
    if (location.startsWith('/location-map')) selectedIndex = 3;
    if (location.startsWith('/picking')) selectedIndex = 4;
    if (location.startsWith('/dispatch')) selectedIndex = 5;
    if (location.startsWith('/analytics')) selectedIndex = 6;
    if (location.startsWith('/audit-history')) selectedIndex = 7;
    if (location.startsWith('/settings')) selectedIndex = 8;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/inventory');
            break;
          case 2:
            context.go('/scanner');
            break;
          case 3:
            context.go('/location-map');
            break;
          case 4:
            context.go('/picking');
            break;
          case 5:
            context.go('/dispatch');
            break;
          case 6:
            context.go('/analytics');
            break;
          case 7:
            context.go('/audit-history');
            break;
          case 8:
            context.go('/settings');
            break;
        }
      },
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hub_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Text(
              'StockSense',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              tooltip: 'Logout Session',
              onPressed: () => UserProfileMenu.showLogoutConfirmation(context, ref),
            ),
          ),
        ),
      ),
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text('Control Room'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2_rounded),
          label: Text('Inventory'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.qr_code_scanner_outlined),
          selectedIcon: Icon(Icons.qr_code_scanner_rounded),
          label: Text('Scanner'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map_rounded),
          label: Text('Floor Map'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.checklist_rtl_outlined),
          selectedIcon: const Icon(Icons.checklist_rtl_rounded),
          label: const Text('Order Picking'),
          disabled: !PermissionManager.canPickOrders(userRole),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.local_shipping_outlined),
          selectedIcon: const Icon(Icons.local_shipping_rounded),
          label: const Text('Dispatch Board'),
          disabled: !PermissionManager.canPerformOutward(userRole),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.analytics_outlined),
          selectedIcon: const Icon(Icons.analytics_rounded),
          label: const Text('Analytics'),
          disabled: !PermissionManager.canViewAnalytics(userRole),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: Text('Audit Ledger'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: Text('Settings'),
        ),
      ],
    );
  }

  Widget _buildStitchBottomNavigationBar(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.grid_view_rounded, 'Home', location == '/dashboard', () => context.go('/dashboard')),
          _navItem(context, Icons.inventory_2_outlined, 'Inventory', location.startsWith('/inventory'), () => context.go('/inventory')),
          
          GestureDetector(
            onTap: () => context.go('/scanner'),
            child: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 26),
            ),
          ),

          _navItem(context, Icons.map_outlined, 'Floor Map', location.startsWith('/location-map'), () => context.go('/location-map')),
          _navItem(context, Icons.local_shipping_outlined, 'Dispatch', location.startsWith('/dispatch'), () => context.go('/dispatch')),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    final color = isActive ? const Color(0xFF4F46E5) : const Color(0xFF64748B);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

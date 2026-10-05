import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash_onboarding/splash_screen.dart';
import '../../features/splash_onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/inventory/product_detail_screen.dart';
import '../../features/scanner/scanner_screen.dart';
import '../../features/location_map/location_map_screen.dart';
import '../../features/picking/order_picking_list_screen.dart';
import '../../features/picking/picking_flow_screen.dart';
import '../../features/dispatch/dispatch_screen.dart';
import '../../features/movement/inward_screen.dart';
import '../../features/movement/outward_screen.dart';
import '../../features/alerts/alerts_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/user_management/user_management_screen.dart';
import '../../features/audit_history/audit_history_screen.dart';
import '../../features/pricing/pricing_plans_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/command_palette/command_palette_dialog.dart';
import '../../shared/widgets/responsive_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => const DashboardScreen(),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ResponsiveShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) => '/dashboard',
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return ProductDetailScreen(skuId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/scanner',
            builder: (context, state) => const ScannerScreen(),
          ),
          GoRoute(
            path: '/location-map',
            builder: (context, state) => const LocationMapScreen(),
          ),
          GoRoute(
            path: '/picking',
            builder: (context, state) => const OrderPickingListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return PickingFlowScreen(orderId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/dispatch',
            builder: (context, state) => const DispatchScreen(),
            routes: [
              GoRoute(
                path: 'ship',
                builder: (context, state) => const DispatchScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/inward',
            builder: (context, state) => const InwardScreen(),
          ),
          GoRoute(
            path: '/outward',
            builder: (context, state) => const OutwardScreen(),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/user-management',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: '/audit-history',
            builder: (context, state) => const AuditHistoryScreen(),
          ),
          GoRoute(
            path: '/pricing',
            builder: (context, state) => const PricingPlansScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/command-palette',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CommandPaletteDialog(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
  );
}

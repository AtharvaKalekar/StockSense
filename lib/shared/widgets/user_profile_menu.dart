import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';

class UserProfileMenu extends ConsumerWidget {
  const UserProfileMenu({super.key});

  static Future<void> showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Logout Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to end your current StockSense WMS session?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(authRepositoryProvider).logout();
              ref.invalidate(currentUserProvider);
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static void showProfileSheet(BuildContext context, WidgetRef ref) {
    final userAsync = ref.read(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final email = userAsync.value?.email ?? 'admin@stocksense.io';
        final role = userAsync.value?.role.name.toUpperCase() ?? 'SUPER ADMIN';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF4F46E5), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                role,
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontFamily: 'JetBrains Mono'),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('• Online', style: TextStyle(fontSize: 11, color: Color(0xFF059669))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Color(0xFF4F46E5)),
                title: const Text('Account & System Settings'),
                subtitle: const Text('Manage preferences, theme & security'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined, color: Color(0xFF4F46E5)),
                title: const Text('User Management & RBAC'),
                subtitle: const Text('Control roles, permissions & access'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/user-management');
                },
              ),
              const Divider(height: 16),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                title: const Text('Logout Session', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                subtitle: const Text('Sign out of StockSense WMS'),
                onTap: () {
                  Navigator.pop(ctx);
                  showLogoutConfirmation(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => showProfileSheet(context, ref),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 18, color: Color(0xFF4F46E5)),
        ),
      ),
    );
  }
}

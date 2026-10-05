import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/models/user_model.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/offline_sync_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final userRole = ref.watch(userRoleProvider);
    final isOffline = ref.watch(isOfflineSimulatedProvider);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Control Center & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: isDarkTheme ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryTeal,
                child: Icon(Icons.person, color: Colors.black),
              ),
              title: const Text('Logged in User: Demo Admin'),
              subtitle: Text('Current Role: ${userRole.name.toUpperCase()}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  userRole.name.toUpperCase(),
                  style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('System Preferences', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Control Room Dark Theme'),
            subtitle: const Text('Toggle between Light Glass and Dark Cyberpunk theme'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          SwitchListTile(
            title: const Text('Simulate Offline Mode'),
            subtitle: const Text('Queue barcode scans locally to test offline sync replay'),
            secondary: const Icon(Icons.wifi_off_rounded),
            value: isOffline,
            onChanged: (val) => ref.read(isOfflineSimulatedProvider.notifier).toggleOffline(val),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Text('B.Tech Panel Role Switcher (Demo Only)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserRole>(
            value: userRole,
            decoration: const InputDecoration(labelText: 'Simulate User Role Access', border: OutlineInputBorder()),
            items: UserRole.values
                .map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase())))
                .toList(),
            onChanged: (role) {
              if (role != null) {
                ref.read(currentRoleProvider.notifier).setRole(role);
              }
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined),
            title: const Text('Pricing & Enterprise Calculator'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => context.push('/pricing'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About StockSense WMS v1.0.0'),
            subtitle: Text('B.Tech CSE Cross Platform Capstone Project'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout Session'),
          ),
        ],
      ),
    );
  }
}

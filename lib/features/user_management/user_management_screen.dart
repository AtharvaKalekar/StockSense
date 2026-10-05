import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/permissions/permission_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/shimmer_loader.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final usersAsync = ref.watch(userListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!PermissionManager.canManageUsers(userRole)) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Management')),
        body: const Center(
          child: Text('Access Denied: User Management is restricted to Admin role.'),
        ),
      );
    }

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
        title: const Text('User & Staff Role Management'),
      ),
      body: usersAsync.when(
        loading: () => const ShimmerList(height: 80, itemCount: 5),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (users) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Staff Roster (${users.length} Users)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryTeal,
                          child: Text(user.name[0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${user.email} | Role: ${user.role.name.toUpperCase()}'),
                        trailing: Switch(
                          value: user.isActive,
                          onChanged: (val) async {
                            final repo = ref.read(userRepositoryProvider);
                            await repo.updateUserStatus(user.id, val);
                            ref.invalidate(userListProvider);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

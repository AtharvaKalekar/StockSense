import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/offline_sync_provider.dart';
import '../../core/constants/app_colors.dart';

class OfflineBanner extends ConsumerWidget {
  final VoidCallback? onSyncTap;

  const OfflineBanner({super.key, this.onSyncTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineSimulatedProvider);
    final queue = ref.watch(offlineQueueProvider);

    if (!isOffline && queue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: isOffline ? AppColors.warning : AppColors.info,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.cloud_upload_outlined,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isOffline
                    ? 'SIMULATED OFFLINE MODE - Scans queued locally (${queue.length})'
                    : 'Syncing local queue with cloud (${queue.length} pending)...',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (queue.isNotEmpty)
              InkWell(
                onTap: onSyncTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Sync (${queue.length})',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

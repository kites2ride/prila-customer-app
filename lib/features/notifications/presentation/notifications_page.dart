import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer/core/widgets/empty_error_states.dart';
import 'package:customer/core/widgets/prila_card.dart';
import 'package:customer/features/push/data/devices_repository.dart';
import 'package:customer/l10n/app_localizations.dart';

final notificationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(devicesRepositoryProvider).notifications();
});

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: async.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(notificationsProvider)),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(message: l10n.noNotifications, icon: Icons.notifications_none_rounded);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = items[i];
                final id = n['id'] as String?;
                return PrilaCard(
                  onTap: id == null
                      ? null
                      : () async {
                          await ref.read(devicesRepositoryProvider).markRead(id);
                          ref.invalidate(notificationsProvider);
                        },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(n['body']?.toString() ?? ''),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

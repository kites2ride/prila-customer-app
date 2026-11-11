import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/widgets/empty_error_states.dart';
import 'package:customer/core/widgets/prila_card.dart';
import 'package:customer/features/rides/data/ride_repository.dart';
import 'package:customer/l10n/app_localizations.dart';

final rideHistoryProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(rideRepositoryProvider).history();
});

class RideHistoryTab extends ConsumerWidget {
  const RideHistoryTab({super.key});

  String _inr(int? paise) => '₹${((paise ?? 0) / 100).toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(rideHistoryProvider);

    return SafeArea(
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(rideHistoryProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(message: l10n.noRidesYet);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(rideHistoryProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = items[i];
                final id = r['id'] as String? ?? '';
                return PrilaCard(
                  onTap: () => context.push('/ride/$id'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            (r['serviceType'] as String? ?? '').toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(r['status']?.toString() ?? ''),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text((r['pickup'] as Map?)?['name']?.toString() ?? '—'),
                      Text('→ ${(r['drop'] as Map?)?['name']?.toString() ?? '—'}'),
                      const SizedBox(height: 8),
                      Text(_inr((r['fareTotalPaise'] as num?)?.toInt())),
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

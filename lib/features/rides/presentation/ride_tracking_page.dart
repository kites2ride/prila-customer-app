import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/errors/app_failure.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/fare_chip.dart';
import 'package:customer/core/widgets/location_pair_tile.dart';
import 'package:customer/core/widgets/pilot_info_card.dart';
import 'package:customer/core/widgets/prila_card.dart';
import 'package:customer/core/widgets/prila_gradient_button.dart';
import 'package:customer/core/widgets/radar_search_animation.dart';
import 'package:customer/core/widgets/status_checklist.dart';
import 'package:customer/features/push/data/devices_repository.dart';
import 'package:customer/features/rides/application/ride_session.dart';
import 'package:customer/features/rides/data/ride_repository.dart';
import 'package:customer/features/rides/domain/ride_view.dart';
import 'package:customer/features/rides/presentation/ride_map.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class RideTrackingPage extends ConsumerStatefulWidget {
  const RideTrackingPage({super.key, required this.rideId});
  final String rideId;

  @override
  ConsumerState<RideTrackingPage> createState() => _RideTrackingPageState();
}

class _RideTrackingPageState extends ConsumerState<RideTrackingPage> {
  var _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rideSessionProvider.notifier).watch(widget.rideId);
    });
  }

  Future<void> _cancel() async {
    setState(() => _busy = true);
    try {
      await ref.read(rideRepositoryProvider).cancel(widget.rideId, 'changed_mind');
      await ref.read(rideSessionProvider.notifier).refreshActive();
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is AppFailure ? e.message : e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _statusLabel(AppLocalizations l10n, String? status) {
    switch (status) {
      case 'requested':
      case 'searching':
        return l10n.statusSearching;
      case 'pilot_assigned':
      case 'pilot_arriving':
        return l10n.statusPilotComing;
      case 'pilot_arrived':
        return l10n.statusPilotArrived;
      case 'in_progress':
        return l10n.statusInProgress;
      case 'completed':
      case 'paid':
        return l10n.statusCompleted;
      case 'no_pilot_found':
        return l10n.statusNoPilot;
      default:
        if (status?.startsWith('cancelled') == true) return l10n.statusCancelled;
        return status ?? '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final async = ref.watch(rideSessionProvider);
    final ride = async.valueOrNull;
    final status = ride?['status'] as String?;
    final otp = ride?['startOtp'] as String?;
    final fare = (ride?['fare'] as Map?)?.cast<String, dynamic>();
    final terminal = const {
      'completed',
      'paid',
      'cancelled_by_rider',
      'cancelled_by_pilot',
      'cancelled_by_system',
      'no_pilot_found',
    }.contains(status);
    final canCancel = !terminal && status != 'in_progress';
    final isSearching = status == 'searching' || status == 'requested';
    final reassigned = isReassignedSearch(ride);
    final pilot = (ride?['pilot'] as Map?)?.cast<String, dynamic>();
    final payAt = ride?['serviceType'] == 'parcel' ? PayAt.fromJson(ride?['payAt']) : null;
    final fareText = '₹${(((fare?['totalPaise'] as num?) ?? 0) / 100).round()}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.yourRide),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (!isSearching && !terminal)
            IconButton(
              tooltip: l10n.shareTrip,
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () async {
                final share = await ref.read(devicesRepositoryProvider).createShare(widget.rideId);
                final path = share?['path']?.toString();
                if (path != null && context.mounted) {
                  await Clipboard.setData(ClipboardData(text: path));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.shareTripCopied)),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) {
          final etaSec = (ride?['pickupEtaSec'] as num?)?.toInt();
          final showEta = etaSec != null && (status == 'pilot_assigned' || status == 'pilot_arriving');
          final list = ListView(
            padding: const EdgeInsets.all(20),
            children: [
              PrilaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reassigned)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.autorenew_rounded, color: colors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.pilotCancelledFinding,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(_statusLabel(l10n, status), style: Theme.of(context).textTheme.titleLarge),
                    if (showEta)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.pilotEtaMin('${(etaSec / 60).ceil().clamp(1, 99)}'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    if (isSearching) ...[
                      const SizedBox(height: 16),
                      Center(child: RadarSearchAnimation(size: 140)),
                      const SizedBox(height: 12),
                      Text(l10n.searchingPilots, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      StatusChecklist(
                        steps: [
                          l10n.searchingPilots,
                          l10n.statusPilotComing,
                          l10n.statusPilotArrived,
                          l10n.statusInProgress,
                        ],
                        activeIndex: 0,
                      ),
                    ],
                    if (otp != null && otp.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(l10n.shareOtp, style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        otp,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 8,
                              color: colors.primary,
                            ),
                      ),
                    ],
                    if (fare != null) ...[
                      const SizedBox(height: 12),
                      FareChip(
                        label: l10n.fare,
                        amountPaise: (fare['totalPaise'] as num?)?.toInt() ?? 0,
                      ),
                      if (payAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(Icons.payments_rounded, size: 18, color: colors.pickup),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  payAt == PayAt.pickup ? l10n.payAtPickupLine(fareText) : l10n.payAtDropLine(fareText),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (ride?['shakti'] == true)
                      Chip(label: Text(l10n.prilaShakti), avatar: const Icon(Icons.shield_outlined, size: 16)),
                  ],
                ),
              ),
              if (pilot != null && !isSearching && !terminal) ...[
                const SizedBox(height: 16),
                PilotInfoCard(pilot: pilot),
              ],
              const SizedBox(height: 16),
              PrilaCard(
                child: LocationPairTile(
                  pickupLabel: l10n.pickup,
                  dropLabel: l10n.drop,
                  pickup: (ride?['pickup'] as Map?)?['name']?.toString() ?? '—',
                  drop: (ride?['drop'] as Map?)?['name']?.toString() ?? '—',
                ),
              ),
              const SizedBox(height: 24),
              if (status == 'completed' || status == 'paid')
                PrilaGradientButton(
                  label: l10n.rateRide,
                  onPressed: () => context.push('/ride/${widget.rideId}/rate'),
                ),
              if (canCancel) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _busy ? null : _cancel,
                  style: OutlinedButton.styleFrom(foregroundColor: colors.danger),
                  child: Text(l10n.cancelRide),
                ),
              ],
              if (status == 'no_pilot_found')
                PrilaGradientButton(
                  label: l10n.backHome,
                  onPressed: () => context.go('/home'),
                ),
            ],
          );
          if (ride == null) return list;
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.42,
                child: RideMap(ride: ride),
              ),
              Expanded(child: list),
            ],
          );
        },
      ),
    );
  }
}

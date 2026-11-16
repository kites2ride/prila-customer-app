import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customer/features/rides/domain/ride_view.dart';
import 'package:customer/core/config/bootstrap_provider.dart';
import 'package:customer/core/errors/app_failure.dart';
import 'package:customer/core/maps/geo.dart';
import 'package:customer/core/maps/map_markers.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/out_of_service_state.dart';
import 'package:customer/core/widgets/prila_gradient_button.dart';
import 'package:customer/core/widgets/prila_map.dart';
import 'package:customer/core/widgets/service_icon.dart';
import 'package:customer/features/booking/application/booking_draft.dart';
import 'package:customer/features/booking/domain/fare_reasons.dart';
import 'package:customer/features/places/data/places_repository.dart';
import 'package:customer/features/rides/application/ride_session.dart';
import 'package:customer/features/rides/data/ride_repository.dart';
import 'package:customer/l10n/app_localizations.dart';

/// quote_ready: route on the map + server fare + one "Book" button.
/// Fare and route always come from the server (never computed in the app).
class ConfirmRidePage extends ConsumerStatefulWidget {
  const ConfirmRidePage({super.key});

  @override
  ConsumerState<ConfirmRidePage> createState() => _ConfirmRidePageState();
}

sealed class _QuoteState {
  const _QuoteState();
}

class _Loading extends _QuoteState {
  const _Loading();
}

class _Ready extends _QuoteState {
  const _Ready(this.quote);
  final Map<String, dynamic> quote;
}

class _OutOfArea extends _QuoteState {
  const _OutOfArea(this.message);
  final String message;
}

class _Failed extends _QuoteState {
  const _Failed(this.message, {this.offline = false});
  final String message;
  final bool offline;
}

class _ConfirmRidePageState extends ConsumerState<ConfirmRidePage> {
  static const _sheetHeight = 340.0;

  GoogleMapController? _map;
  _QuoteState _state = const _Loading();
  var _booking = false;
  var _shakti = false;
  var _payAt = PayAt.parcelDefault;
  final _couponCtrl = TextEditingController();
  var _req = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _estimate());
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _estimate() async {
    final d = ref.read(bookingDraftProvider);
    if (!d.routeReady) {
      if (mounted) context.pop();
      return;
    }
    final req = ++_req;
    setState(() => _state = const _Loading());
    try {
      final q = await ref.read(rideRepositoryProvider).estimate(
            serviceType: d.serviceType,
            pickupLat: d.pickup!.lat,
            pickupLng: d.pickup!.lng,
            pickupName: d.pickup!.name,
            dropLat: d.drop!.lat,
            dropLng: d.drop!.lng,
            dropName: d.drop!.name,
            couponCode: _couponCtrl.text.trim().isEmpty ? null : _couponCtrl.text.trim(),
            shakti: _shakti,
          );
      if (!mounted || req != _req) return; // a newer estimate (service switch) is in flight
      setState(() => _state = _Ready(q));
      _fit();
    } catch (e) {
      if (!mounted || req != _req) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _state = e is AppFailure && e.code == OutOfServiceState.code
            ? _OutOfArea(e.message)
            : _Failed(
                e is NetworkFailure ? l10n.noInternet : (e is AppFailure ? e.message : l10n.errorGeneric),
                offline: e is NetworkFailure,
              );
      });
    }
  }

  Future<void> _book() async {
    final s = _state;
    if (s is! _Ready || _booking) return;
    final quoteId = s.quote['quoteId'] as String?;
    if (quoteId == null) return;
    setState(() => _booking = true);
    try {
      final ride = await ref.read(rideRepositoryProvider).book(
            quoteId: quoteId,
            // One key per quote: double taps / retries can never create two rides.
            idempotencyKey: 'book-$quoteId',
            payAt: ref.read(bookingDraftProvider).serviceType == 'parcel' ? _payAt.json : null,
          );
      final id = ride['id'] as String?;
      await ref.read(rideSessionProvider.notifier).refreshActive();
      ref.invalidate(myPlacesProvider);
      if (id != null && mounted) context.go('/ride/$id');
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (e is AppFailure && e.code == OutOfServiceState.code) {
        setState(() => _state = _OutOfArea(e.message));
      } else if (e is AppFailure && (e.code == 'QUOTE_EXPIRED' || e.code == 'QUOTE_USED')) {
        await _estimate(); // fare may have changed — show the fresh one, rider taps again
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is NetworkFailure ? l10n.noInternet : (e is AppFailure ? e.message : l10n.errorGeneric))),
        );
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  List<LatLng> _routePoints() {
    final d = ref.read(bookingDraftProvider);
    final s = _state;
    final poly = s is _Ready ? ((s.quote['route'] as Map?)?['polyline'] as String?) : null;
    final pts = poly != null && poly.isNotEmpty ? Geo.decodePolyline(poly) : const <LatLng>[];
    if (pts.length >= 2) return pts;
    return [if (d.pickup != null) d.pickup!.latLng, if (d.drop != null) d.drop!.latLng];
  }

  Future<void> _fit() async {
    final pts = _routePoints();
    if (_map == null || pts.length < 2) return;
    await Future<void>.delayed(const Duration(milliseconds: 60));
    try {
      await _map!.animateCamera(CameraUpdate.newLatLngBounds(Geo.bounds(pts), 56));
    } catch (_) {
      // map not laid out yet — onMapCreated will fit again
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final d = ref.watch(bookingDraftProvider);
    final cfg = ref.watch(bootstrapProvider).valueOrNull;
    final services = [...(cfg?.services ?? const [])]..sort((a, b) => a.order.compareTo(b.order));
    final icons = ref
        .watch(mapMarkerIconsProvider(MarkerPalette(
          dpr: MediaQuery.devicePixelRatioOf(context),
          pickup: colors.pickup,
          drop: colors.drop,
          pilot: colors.primary,
        )))
        .valueOrNull;

    final route = _routePoints();
    final s = _state;
    final googleRoute = s is _Ready && ((s.quote['route'] as Map?)?['polyline'] as String?)?.isNotEmpty == true;

    final markers = <Marker>{
      if (d.pickup != null && icons != null)
        Marker(markerId: const MarkerId('pickup'), position: d.pickup!.latLng, icon: icons.pickup, anchor: const Offset(0.5, 0.95)),
      if (d.drop != null && icons != null)
        Marker(markerId: const MarkerId('drop'), position: d.drop!.latLng, icon: icons.drop, anchor: const Offset(0.5, 0.95)),
    };
    final polylines = <Polyline>{
      if (route.length >= 2)
        Polyline(
          polylineId: const PolylineId('route'),
          points: route,
          width: 5,
          color: colors.primary,
          // Straight dashed line = estimate only (Google route unavailable).
          patterns: googleRoute ? const [] : [PatternItem.dash(18), PatternItem.gap(10)],
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
    };

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            bottom: _sheetHeight - 24,
            child: PrilaMap(
              initialTarget: d.pickup?.latLng ?? kLaunchCityCenter,
              initialZoom: 14,
              markers: markers,
              polylines: polylines,
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
              onMapCreated: (c) {
                _map = c;
                _fit();
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: colors.surface,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: Colors.black26,
                child: IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: colors.surface,
              elevation: 16,
              shadowColor: Colors.black26,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: _sheetHeight - 40,
                    maxHeight: MediaQuery.sizeOf(context).height * 0.7,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RouteSummary(
                          pickup: d.pickup?.name ?? '',
                          drop: d.drop?.name ?? '',
                          onEdit: () => context.pop(),
                        ),
                        const SizedBox(height: 14),
                        if (services.length > 1) ...[
                          SizedBox(
                            height: 76,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: services.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 10),
                              itemBuilder: (_, i) {
                                final svc = services[i];
                                final selected = svc.type == d.serviceType;
                                return _ServiceOption(
                                  icon: serviceIcon(svc.type),
                                  label: svc.name,
                                  selected: selected,
                                  onTap: selected
                                      ? null
                                      : () {
                                          ref.read(bookingDraftProvider.notifier).setService(svc.type, svc.name);
                                          _estimate();
                                        },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        _body(context, l10n, d, cfg?.flags ?? const {}),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, BookingDraft d, Map<String, bool> flags) {
    final text = Theme.of(context).textTheme;
    final colors = context.prilaColors;
    return switch (_state) {
      _Loading() => Column(
          children: [
            const SizedBox(height: 8),
            _FareSkeleton(color: colors.border),
            const SizedBox(height: 20),
            PrilaGradientButton(label: l10n.bookService(d.serviceName), onPressed: null),
          ],
        ),
      _OutOfArea(:final message) => OutOfServiceState(
          title: l10n.notHereYetTitle,
          message: message,
          actionLabel: l10n.notHereYetAction,
          onAction: () => context.pop(),
        ),
      _Failed(:final message, :final offline) => Column(
          children: [
            Icon(offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded, color: colors.danger, size: 32),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: text.bodyLarge),
            const SizedBox(height: 16),
            PrilaGradientButton(label: l10n.retry, onPressed: _estimate),
          ],
        ),
      _Ready(:final quote) => _readyBody(context, l10n, d, quote, flags),
    };
  }

  Widget _readyBody(BuildContext context, AppLocalizations l10n, BookingDraft d, Map<String, dynamic> quote, Map<String, bool> flags) {
    final text = Theme.of(context).textTheme;
    final colors = context.prilaColors;
    final fare = (quote['fare'] as Map?)?.cast<String, dynamic>() ?? const {};
    final total = (fare['totalPaise'] as num?)?.toInt() ?? 0;
    final discount = (fare['discountPaise'] as num?)?.toInt() ?? 0;
    final km = ((quote['distanceM'] as num?)?.toDouble() ?? 0) / 1000;
    final min = max(1, (((quote['durationSec'] as num?)?.toInt() ?? 0) / 60).round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${(total / 100).round()}',
                    style: text.displaySmall?.copyWith(fontWeight: FontWeight.w700, height: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.tripSummary(km.toStringAsFixed(1), '$min'),
                    style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.pickup.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payments_rounded, size: 18, color: colors.pickup),
                  const SizedBox(width: 6),
                  Text(l10n.cash, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        _FareReasons(fare: fare),
        if (discount > 0) ...[
          const SizedBox(height: 4),
          Text('${l10n.discount}: −₹${(discount / 100).round()}', style: TextStyle(color: colors.pickup)),
        ],
        if (flags['coupons'] == true) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _couponCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: l10n.couponCode,
              suffixIcon: TextButton(onPressed: _estimate, child: Text(l10n.apply)),
            ),
          ),
        ],
        if (d.serviceType == 'parcel') ...[
          const SizedBox(height: 16),
          Text(l10n.whoPays, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PayOption(
                  icon: Icons.outbox_rounded,
                  title: l10n.payAtPickup,
                  hint: l10n.payAtPickupHint,
                  selected: _payAt == PayAt.pickup,
                  onTap: () => setState(() => _payAt = PayAt.pickup),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PayOption(
                  icon: Icons.move_to_inbox_rounded,
                  title: l10n.payAtDrop,
                  hint: l10n.payAtDropHint,
                  selected: _payAt == PayAt.drop,
                  onTap: () => setState(() => _payAt = PayAt.drop),
                ),
              ),
            ],
          ),
        ],
        if (flags['prila_shakti'] == true)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.prilaShakti),
            subtitle: Text(l10n.prilaShaktiHint),
            value: _shakti,
            onChanged: (v) {
              setState(() => _shakti = v);
              _estimate();
            },
          ),
        const SizedBox(height: 16),
        PrilaGradientButton(label: l10n.bookService(d.serviceName), onPressed: _book, loading: _booking),
      ],
    );
  }
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.pickup, required this.drop, required this.onEdit});
  final String pickup;
  final String drop;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Column(
              children: [
                TripDot(color: colors.pickup, size: 11),
                Container(width: 2, height: 18, margin: const EdgeInsets.symmetric(vertical: 3), color: colors.border),
                TripDot(color: colors.drop, size: 11, square: true),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pickup, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
                  const SizedBox(height: 14),
                  Text(drop, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 20, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  const _ServiceOption({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 96,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary.withValues(alpha: 0.08) : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? colors.primary : colors.border, width: selected ? 2 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: selected ? colors.primary : Theme.of(context).colorScheme.onSurface),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FareSkeleton extends StatelessWidget {
  const _FareSkeleton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [bar(110, 38), const SizedBox(height: 8), bar(140, 14)]),
        const Spacer(),
        bar(80, 34),
      ],
    );
  }
}

/// Big, two-line choice card (icon + title + one-line explanation). Radio semantics.
class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.icon,
    required this.title,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    final text = Theme.of(context).textTheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected ? colors.primary.withValues(alpha: 0.08) : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? colors.primary : colors.border, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 22, color: selected ? colors.primary : Theme.of(context).hintColor),
                      const Spacer(),
                      Icon(
                        selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        size: 20,
                        color: selected ? colors.primary : Theme.of(context).hintColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(hint, style: text.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Why this price is above normal (night, rush hour, high demand, traffic).
/// Server sends the reasons with the quote; the price is locked once booked.
class _FareReasons extends StatelessWidget {
  const _FareReasons({required this.fare});

  final Map<String, dynamic> fare;

  @override
  Widget build(BuildContext context) {
    final reasons = fareReasonsFrom(fare);
    if (reasons.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final text = Theme.of(context).textTheme;
    final times = formatMultiplier(fare['priceMultiplier'] as num?);

    (IconData, String) info(FareReason r) => switch (r) {
          FareReason.night => (Icons.nightlight_round, l10n.fareNight),
          FareReason.rushHour => (Icons.schedule_rounded, l10n.fareRushHour),
          FareReason.highDemand => (Icons.trending_up_rounded, l10n.fareHighDemand),
          FareReason.traffic => (Icons.traffic_rounded, l10n.fareTraffic),
        };
    final labels = [for (final r in reasons) info(r).$2];
    final timesText = times == null ? null : l10n.fareTimesNormal(times);

    return Semantics(
      container: true,
      label: [...labels, ?timesText].join(', '),
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final r in reasons)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.danger.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(info(r).$1, size: 16, color: colors.danger),
                          const SizedBox(width: 4),
                          Text(info(r).$2, style: text.labelMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                ],
              ),
              if (timesText != null) ...[
                const SizedBox(height: 4),
                Text(timesText, style: text.bodySmall?.copyWith(color: Theme.of(context).hintColor, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

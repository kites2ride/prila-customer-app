import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customer/core/location/location_service.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/prila_gradient_button.dart';
import 'package:customer/core/widgets/prila_map.dart';
import 'package:customer/features/booking/application/booking_draft.dart';
import 'package:customer/features/places/data/places_repository.dart';
import 'package:customer/features/places/domain/place.dart';
import 'package:customer/l10n/app_localizations.dart';

/// "Set on map": the map moves under a fixed centre pin. One reverse-geocode per
/// settle (debounced; backend caches ~11 m cells) — never while the finger is moving.
class PinPickerPage extends ConsumerStatefulWidget {
  const PinPickerPage({super.key, required this.end});
  final TripEnd end;

  @override
  ConsumerState<PinPickerPage> createState() => _PinPickerPageState();
}

enum _AddrState { idle, loading, ok, failed }

class _PinPickerPageState extends ConsumerState<PinPickerPage> {
  static const _settleDelay = Duration(milliseconds: 450);

  GoogleMapController? _map;
  late LatLng _target;
  var _moving = false;
  Timer? _settle;
  CancelToken? _inflight;
  String? _address;
  var _addr = _AddrState.idle;

  @override
  void initState() {
    super.initState();
    final d = ref.read(bookingDraftProvider);
    final existing = widget.end == TripEnd.pickup ? d.pickup : d.drop;
    _target = existing?.latLng ?? d.pickup?.latLng ?? kLaunchCityCenter;
    if (existing != null) {
      _address = existing.address.isNotEmpty ? existing.address : existing.name;
      _addr = _AddrState.ok;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup());
    }
  }

  @override
  void dispose() {
    _settle?.cancel();
    _inflight?.cancel();
    super.dispose();
  }

  void _onMoveStarted() {
    _settle?.cancel();
    _inflight?.cancel();
    setState(() {
      _moving = true;
      _addr = _AddrState.loading;
    });
  }

  void _onIdle() {
    setState(() => _moving = false);
    _settle?.cancel();
    _settle = Timer(_settleDelay, _lookup);
  }

  Future<void> _lookup() async {
    _inflight?.cancel();
    final token = CancelToken();
    _inflight = token;
    setState(() => _addr = _AddrState.loading);
    try {
      final a = await ref.read(placesRepositoryProvider).reverse(_target.latitude, _target.longitude, cancelToken: token);
      if (!mounted || token.isCancelled) return;
      setState(() {
        _address = a;
        _addr = a == null ? _AddrState.failed : _AddrState.ok;
      });
    } catch (_) {
      if (!mounted || token.isCancelled) return;
      setState(() {
        _address = null;
        _addr = _AddrState.failed;
      });
    }
  }

  Future<void> _goToMyLocation() async {
    final loc = await ref.read(locationServiceProvider).current();
    if (!mounted) return;
    if (loc is LocationOk) {
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(loc.position, 17));
    } else {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.locationNeeded)));
    }
  }

  void _confirm() {
    final l10n = AppLocalizations.of(context);
    final addr = _address ?? '';
    // Name = first part of the address ("Nayeem Nagar, Hanamkonda" → "Nayeem Nagar").
    final name = addr.isNotEmpty ? addr.split(',').first.trim() : l10n.pinnedLocation;
    ref.read(bookingDraftProvider.notifier).setPoint(
          widget.end,
          PlacePoint(name: name, address: addr, lat: _target.latitude, lng: _target.longitude),
        );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final isPickup = widget.end == TripEnd.pickup;
    final pinColor = isPickup ? colors.pickup : colors.drop;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PrilaMap(
              initialTarget: _target,
              initialZoom: 17,
              myLocationEnabled: true,
              padding: const EdgeInsets.only(bottom: 200),
              onMapCreated: (c) => _map = c,
              onCameraMoveStarted: _onMoveStarted,
              onCameraMove: (p) => _target = p.target,
              onCameraIdle: _onIdle,
            ),
          ),
          // Fixed centre pin (lifts while dragging). Bottom padding keeps it above the sheet.
          Positioned.fill(
            bottom: 200,
            child: IgnorePointer(
              child: Center(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  offset: Offset(0, _moving ? -0.62 : -0.5),
                  child: _CenterPin(color: pinColor),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _RoundButton(
                icon: Icons.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onTap: () => context.pop(false),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 216,
            child: _RoundButton(
              icon: Icons.my_location_rounded,
              tooltip: l10n.myLocation,
              onTap: _goToMyLocation,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: colors.surface,
              elevation: 12,
              shadowColor: Colors.black26,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isPickup ? l10n.setPickupTitle : l10n.setDropTitle, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(Icons.place_rounded, color: pinColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: switch (_addr) {
                                _AddrState.loading || _AddrState.idle => Text(l10n.findingAddress, style: text.bodyLarge?.copyWith(color: Theme.of(context).hintColor)),
                                _AddrState.ok => Text(_address ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodyLarge),
                                _AddrState.failed => Text(l10n.addressUnavailable, maxLines: 2, style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PrilaGradientButton(
                        label: isPickup ? l10n.confirmPickup : l10n.confirmDrop,
                        onPressed: _moving ? null : _confirm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterPin extends StatelessWidget {
  const _CenterPin({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: const Center(child: CircleAvatar(radius: 5, backgroundColor: Colors.white)),
        ),
        Container(width: 3, height: 16, color: color),
        Container(
          width: 10,
          height: 4,
          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: IconButton(
        tooltip: tooltip,
        iconSize: 24,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(icon),
        onPressed: onTap,
      ),
    );
  }
}

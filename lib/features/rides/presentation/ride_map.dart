import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customer/core/maps/geo.dart';
import 'package:customer/core/maps/map_markers.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/prila_map.dart';
import 'package:customer/l10n/app_localizations.dart';

/// Live ride map. Uses only data already in the ride (route from the estimate,
/// pilot position from our servers) — zero Google API calls while riding.
class RideMap extends ConsumerStatefulWidget {
  const RideMap({super.key, required this.ride});
  final Map<String, dynamic> ride;

  @override
  ConsumerState<RideMap> createState() => _RideMapState();
}

LatLng? _point(Object? geo) {
  final c = (geo as Map?)?['coordinates'];
  if (c is List && c.length == 2 && c[0] is num && c[1] is num) {
    return LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble());
  }
  return null;
}

class _RideMapState extends ConsumerState<RideMap> with SingleTickerProviderStateMixin {
  /// Slightly shorter than the 2 s refresh so the marker never lags behind.
  static const _glide = Duration(milliseconds: 1800);

  GoogleMapController? _map;
  late final AnimationController _anim = AnimationController(vsync: this, duration: _glide)
    ..addListener(_onTick);

  LatLng? _from;
  LatLng? _to;
  LatLng? _shown;
  double _headingFrom = 0;
  double _headingTo = 0;
  double _heading = 0;
  int _lastFrameMs = 0;

  var _programmaticMove = false;
  var _userMoved = false;
  String? _fittedFor;

  Map<String, dynamic> get _ride => widget.ride;
  String? get _status => _ride['status'] as String?;
  static bool _searching(String? s) => s == 'searching' || s == 'requested';
  LatLng? get _pickup => _point((_ride['pickup'] as Map?)?['location']);
  LatLng? get _drop => _point((_ride['drop'] as Map?)?['location']);

  List<LatLng> get _route {
    final enc = _ride['routePolyline'] as String?;
    final pts = enc != null && enc.isNotEmpty ? Geo.decodePolyline(enc) : const <LatLng>[];
    if (pts.length >= 2) return pts;
    return [?_pickup, ?_drop];
  }

  @override
  void initState() {
    super.initState();
    final p = _point(_ride['lastPilotLocation']);
    _shown = p;
    _to = p;
  }

  @override
  void didUpdateWidget(covariant RideMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _point(_ride['lastPilotLocation']);
    // Pilot cancelled → ride is searching again: drop the old pilot arrow at once.
    if (_ride['pilotId'] == null || _searching(_status)) {
      _anim.stop();
      _shown = null;
      _to = null;
      _from = null;
    } else if (next != null && (_to == null || Geo.distanceM(_to!, next) > 0.5)) {
      _from = _shown ?? next;
      _to = next;
      _headingFrom = _heading;
      // Only turn when the pilot actually moved (GPS jitter would spin the arrow).
      if (Geo.distanceM(_from!, next) > 3) _headingTo = Geo.bearing(_from!, next);
      _anim.forward(from: 0);
    }
    if (_status != oldWidget.ride['status']) _fit(force: true);
  }

  void _onTick() {
    // ~25 fps is smooth for a map marker and keeps platform-channel traffic low.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastFrameMs < 40 && _anim.value < 1) return;
    _lastFrameMs = now;
    final t = Curves.easeInOut.transform(_anim.value);
    setState(() {
      _shown = Geo.lerp(_from!, _to!, t);
      _heading = Geo.lerpAngle(_headingFrom, _headingTo, t);
    });
    if (_anim.value >= 1 && _fittedFor == null) _fit();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  /// What the rider cares about now: pilot → pickup before the trip, pilot → drop during it.
  List<LatLng> _focusPoints() {
    final s = _status;
    final pilot = _shown;
    if (s == 'in_progress') return [?pilot, ?_drop];
    if (s == 'pilot_assigned' || s == 'pilot_arriving' || s == 'pilot_arrived') return [?pilot, ?_pickup];
    return _route;
  }

  Future<void> _fit({bool force = false}) async {
    if (_map == null || (_userMoved && !force)) return;
    final pts = _focusPoints();
    if (pts.isEmpty) return;
    _fittedFor = _status;
    _programmaticMove = true;
    try {
      await _map!.animateCamera(
        pts.length == 1 ? CameraUpdate.newLatLngZoom(pts.first, 16) : CameraUpdate.newLatLngBounds(Geo.bounds(pts), 64),
      );
    } catch (_) {
      // not laid out yet
    } finally {
      _programmaticMove = false;
    }
    if (force && mounted) setState(() => _userMoved = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final icons = ref
        .watch(mapMarkerIconsProvider(MarkerPalette(
          dpr: MediaQuery.devicePixelRatioOf(context),
          pickup: colors.pickup,
          drop: colors.drop,
          pilot: colors.primary,
        )))
        .valueOrNull;
    final s = _status;
    final showPilot = _shown != null && !_searching(s) && s != 'completed' && s != 'paid' && !(s?.startsWith('cancelled') ?? false);
    final route = _route;
    final googleRoute = (_ride['routePolyline'] as String?)?.isNotEmpty == true;

    final markers = <Marker>{
      if (icons != null && _pickup != null && s != 'in_progress')
        Marker(markerId: const MarkerId('pickup'), position: _pickup!, icon: icons.pickup, anchor: const Offset(0.5, 0.95)),
      if (icons != null && _drop != null)
        Marker(markerId: const MarkerId('drop'), position: _drop!, icon: icons.drop, anchor: const Offset(0.5, 0.95)),
      if (icons != null && showPilot)
        Marker(
          markerId: const MarkerId('pilot'),
          position: _shown!,
          icon: icons.pilot,
          rotation: _heading,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 3,
        ),
    };

    return Stack(
      children: [
        Positioned.fill(
          child: PrilaMap(
            initialTarget: _shown ?? _pickup ?? kLaunchCityCenter,
            initialZoom: 15,
            markers: markers,
            polylines: {
              if (route.length >= 2)
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: route,
                  width: 5,
                  color: colors.primary.withValues(alpha: s == 'in_progress' ? 1 : 0.55),
                  patterns: googleRoute ? const [] : [PatternItem.dash(18), PatternItem.gap(10)],
                  jointType: JointType.round,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                ),
            },
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            onMapCreated: (c) {
              _map = c;
              _fit(force: true);
            },
            onCameraMoveStarted: () {
              if (!_programmaticMove && !_userMoved) setState(() => _userMoved = true);
            },
          ),
        ),
        if (_userMoved)
          Positioned(
            right: 12,
            bottom: 12,
            child: Material(
              color: colors.surface,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: Colors.black26,
              child: IconButton(
                tooltip: l10n.recenter,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.center_focus_strong_rounded),
                onPressed: () => _fit(force: true),
              ),
            ),
          ),
      ],
    );
  }
}

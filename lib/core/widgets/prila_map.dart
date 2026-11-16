import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/empty_error_states.dart';
import 'package:customer/l10n/app_localizations.dart';

/// Map style JSON (bundled, no Google cost) — loaded once.
final mapStylesProvider = FutureProvider<({String light, String dark})>((ref) async {
  final light = await rootBundle.loadString('assets/map_styles/light.json');
  final dark = await rootBundle.loadString('assets/map_styles/dark.json');
  return (light: light, dark: dark);
});

/// Default camera: Warangal / Hanamkonda / Kazipet tri-city.
const kLaunchCityCenter = LatLng(17.9925, 79.5600);

/// Themed Google map used by every map screen. Follows light/dark theme and shows a
/// retryable error state if the native map does not come up (bad key, no Play services).
class PrilaMap extends ConsumerStatefulWidget {
  const PrilaMap({
    super.key,
    this.initialTarget = kLaunchCityCenter,
    this.initialZoom = 15,
    this.markers = const {},
    this.polylines = const {},
    this.padding = EdgeInsets.zero,
    this.myLocationEnabled = false,
    this.gesturesEnabled = true,
    this.onMapCreated,
    this.onCameraMoveStarted,
    this.onCameraMove,
    this.onCameraIdle,
  });

  final LatLng initialTarget;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final EdgeInsets padding;
  final bool myLocationEnabled;
  final bool gesturesEnabled;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final VoidCallback? onCameraMoveStarted;
  final ValueChanged<CameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;

  @override
  ConsumerState<PrilaMap> createState() => _PrilaMapState();
}

class _PrilaMapState extends ConsumerState<PrilaMap> {
  static const _loadTimeout = Duration(seconds: 12);
  Timer? _watchdog;
  var _created = false;
  var _failed = false;
  var _attempt = 0;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  void _arm() {
    _watchdog?.cancel();
    _watchdog = Timer(_loadTimeout, () {
      if (mounted && !_created) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final styles = ref.watch(mapStylesProvider).valueOrNull;

    if (_failed) {
      return ColoredBox(
        color: colors.surface,
        child: ErrorState(
          message: l10n.mapLoadFailed,
          onRetry: () => setState(() {
            _failed = false;
            _created = false;
            _attempt++;
            _arm();
          }),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          key: ValueKey('map-$_attempt'),
          initialCameraPosition: CameraPosition(target: widget.initialTarget, zoom: widget.initialZoom),
          style: styles == null ? null : (dark ? styles.dark : styles.light),
          markers: widget.markers,
          polylines: widget.polylines,
          padding: widget.padding,
          myLocationEnabled: widget.myLocationEnabled,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          buildingsEnabled: false,
          indoorViewEnabled: false,
          trafficEnabled: false,
          scrollGesturesEnabled: widget.gesturesEnabled,
          zoomGesturesEnabled: widget.gesturesEnabled,
          onMapCreated: (c) {
            _created = true;
            _watchdog?.cancel();
            widget.onMapCreated?.call(c);
          },
          onCameraMoveStarted: widget.onCameraMoveStarted,
          onCameraMove: widget.onCameraMove,
          onCameraIdle: widget.onCameraIdle,
        ),
        // Cover the brief white flash before the native map paints.
        if (!_created) Positioned.fill(child: IgnorePointer(child: ColoredBox(color: colors.background))),
      ],
    );
  }
}

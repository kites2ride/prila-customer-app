import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Map marker icons drawn in code (crisp at any density, no image assets).
/// Pickup = green, drop = pink — the same colours everywhere in the app.
class MapMarkerIcons {
  const MapMarkerIcons({required this.pickup, required this.drop, required this.pilot});
  final BitmapDescriptor pickup;
  final BitmapDescriptor drop;
  final BitmapDescriptor pilot;

  static Future<MapMarkerIcons> build({
    required double dpr,
    required Color pickupColor,
    required Color dropColor,
    required Color pilotColor,
  }) async {
    final results = await Future.wait([
      _pin(dpr, pickupColor),
      _pin(dpr, dropColor),
      _pilotArrow(dpr, pilotColor),
    ]);
    return MapMarkerIcons(pickup: results[0], drop: results[1], pilot: results[2]);
  }

  /// Teardrop pin, 36×46 logical px, anchor at the tip.
  static Future<BitmapDescriptor> _pin(double dpr, Color color) async {
    const w = 36.0, h = 46.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec)..scale(dpr);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    c.drawOval(const Rect.fromLTWH(w / 2 - 6, h - 6, 12, 5), shadow);
    final path = Path()
      ..moveTo(w / 2, h - 3)
      ..cubicTo(w / 2 - 4, h - 14, 2, h - 22, 2, 17)
      ..arcToPoint(const Offset(w - 2, 17), radius: const Radius.circular(16))
      ..cubicTo(w - 2, h - 22, w / 2 + 4, h - 14, w / 2, h - 3)
      ..close();
    c.drawPath(path, Paint()..color = color);
    c.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    c.drawCircle(const Offset(w / 2, 17), 6, Paint()..color = Colors.white);
    return _toDescriptor(rec, w, h, dpr);
  }

  /// White disc with a brand-coloured arrow; rotated on the map by heading.
  static Future<BitmapDescriptor> _pilotArrow(double dpr, Color color) async {
    const s = 44.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec)..scale(dpr);
    c.drawCircle(
      const Offset(s / 2, s / 2 + 1),
      18,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    c.drawCircle(const Offset(s / 2, s / 2), 18, Paint()..color = Colors.white);
    c.drawCircle(const Offset(s / 2, s / 2), 13, Paint()..color = color);
    final arrow = Path()
      ..moveTo(s / 2, s / 2 - 8)
      ..lineTo(s / 2 + 6, s / 2 + 7)
      ..lineTo(s / 2, s / 2 + 3.5)
      ..lineTo(s / 2 - 6, s / 2 + 7)
      ..close();
    c.drawPath(arrow, Paint()..color = Colors.white);
    return _toDescriptor(rec, s, s, dpr);
  }

  static Future<BitmapDescriptor> _toDescriptor(ui.PictureRecorder rec, double w, double h, double dpr) async {
    final img = await rec.endRecording().toImage((w * dpr).ceil(), (h * dpr).ceil());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return BitmapDescriptor.bytes(data!.buffer.asUint8List(), width: w, height: h);
  }
}

/// Built once per device pixel ratio + palette.
final mapMarkerIconsProvider = FutureProvider.family<MapMarkerIcons, MarkerPalette>((ref, p) {
  return MapMarkerIcons.build(
    dpr: math.max(1, p.dpr),
    pickupColor: p.pickup,
    dropColor: p.drop,
    pilotColor: p.pilot,
  );
});

@immutable
class MarkerPalette {
  const MarkerPalette({required this.dpr, required this.pickup, required this.drop, required this.pilot});
  final double dpr;
  final Color pickup;
  final Color drop;
  final Color pilot;

  @override
  bool operator ==(Object other) =>
      other is MarkerPalette &&
      other.dpr == dpr &&
      other.pickup == pickup &&
      other.drop == drop &&
      other.pilot == pilot;

  @override
  int get hashCode => Object.hash(dpr, pickup, drop, pilot);
}

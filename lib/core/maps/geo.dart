import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Pure geo helpers (no Google calls).
abstract final class Geo {
  /// Decodes a Google encoded polyline (Routes API `encodedPolyline`).
  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;
    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int b;
      do {
        if (index >= encoded.length) return points; // malformed tail: keep what we have
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      shift = 0;
      result = 0;
      do {
        if (index >= encoded.length) return points;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  static double distanceM(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(a.latitude)) * math.cos(_rad(b.latitude)) * math.pow(math.sin(dLng / 2), 2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  /// Compass bearing a → b in degrees (0 = north, clockwise).
  static double bearing(LatLng a, LatLng b) {
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (_deg(math.atan2(y, x)) + 360) % 360;
  }

  static LatLng lerp(LatLng a, LatLng b, double t) => LatLng(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      );

  /// Shortest-path angle interpolation (359° → 1° turns 2°, not 358°).
  static double lerpAngle(double a, double b, double t) {
    final diff = ((b - a + 540) % 360) - 180;
    return (a + diff * t + 360) % 360;
  }

  static LatLngBounds bounds(Iterable<LatLng> pts) {
    var s = 90.0, w = 180.0, n = -90.0, e = -180.0;
    for (final p in pts) {
      s = math.min(s, p.latitude);
      n = math.max(n, p.latitude);
      w = math.min(w, p.longitude);
      e = math.max(e, p.longitude);
    }
    // Avoid a zero-size box (same pickup/drop) which makes the camera zoom to max.
    if ((n - s).abs() < 0.002) {
      s -= 0.002;
      n += 0.002;
    }
    if ((e - w).abs() < 0.002) {
      w -= 0.002;
      e += 0.002;
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }

  static double _rad(double d) => d * math.pi / 180;
  static double _deg(double r) => r * 180 / math.pi;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Explicit outcomes so every screen handles each case (no silent fallbacks).
sealed class LocationResult {
  const LocationResult();
}

class LocationOk extends LocationResult {
  const LocationOk(this.position);
  final LatLng position;
}

/// GPS switched off in system settings.
class LocationServiceOff extends LocationResult {
  const LocationServiceOff();
}

/// User said no (can ask again).
class LocationDenied extends LocationResult {
  const LocationDenied();
}

/// "Don't ask again" — only app settings can fix it.
class LocationDeniedForever extends LocationResult {
  const LocationDeniedForever();
}

/// GPS on and allowed, but no fix in time (indoors, weak signal).
class LocationUnavailable extends LocationResult {
  const LocationUnavailable();
}

final locationServiceProvider = Provider<LocationService>((_) => const LocationService());

class LocationService {
  const LocationService();

  Future<LocationResult> current({bool request = true}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return const LocationServiceOff();
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied && request) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return const LocationDeniedForever();
      if (perm == LocationPermission.denied || perm == LocationPermission.unableToDetermine) {
        return const LocationDenied();
      }
      // A recent fix is good enough for a pickup and avoids waiting for GPS.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && DateTime.now().difference(last.timestamp) < const Duration(minutes: 2)) {
        return LocationOk(LatLng(last.latitude, last.longitude));
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationOk(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      return const LocationUnavailable();
    }
  }

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}

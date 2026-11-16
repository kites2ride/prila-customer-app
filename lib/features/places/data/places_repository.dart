import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer/core/network/api_client.dart';
import 'package:customer/features/places/domain/place.dart';

final placesRepositoryProvider = Provider<PlacesRepository>(
  (ref) => PlacesRepository(ref.watch(dioProvider)),
);

/// Saved + recent places (free, from our DB). Refresh after saving or completing a ride.
final myPlacesProvider = FutureProvider.autoDispose<MyPlaces>((ref) {
  return ref.watch(placesRepositoryProvider).mine();
});

/// All Google lookups go through our backend (`/maps/*`) — the app never holds the server key.
class PlacesRepository {
  PlacesRepository(this._dio);
  final Dio _dio;

  /// New session token per search session (UUID v4). Ends with [place].
  static String newSessionToken() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  Future<List<PlaceSuggestion>> autocomplete({
    required String query,
    required String sessionToken,
    double? lat,
    double? lng,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/maps/autocomplete',
        queryParameters: {
          'q': query,
          'sessionToken': sessionToken,
          if (lat != null && lng != null) ...{'lat': lat, 'lng': lng},
        },
        cancelToken: cancelToken,
      );
      final items = res.data?['suggestions'] as List? ?? const [];
      return items.whereType<Map>().map((e) => PlaceSuggestion.fromJson(e.cast<String, dynamic>())).toList();
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Resolves a Google suggestion. [name] comes from the suggestion (we don't pay for displayName).
  Future<PlacePoint> place({required String placeId, required String name, String? sessionToken}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/maps/place',
        queryParameters: {'placeId': placeId, 'sessionToken': ?sessionToken},
      );
      final d = res.data ?? const {};
      return PlacePoint(
        name: name,
        address: d['address'] as String? ?? '',
        lat: (d['lat'] as num).toDouble(),
        lng: (d['lng'] as num).toDouble(),
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }

  /// Address for a map point; null address when Google has nothing there.
  Future<String?> reverse(double lat, double lng, {CancelToken? cancelToken}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/maps/reverse',
        queryParameters: {'lat': lat, 'lng': lng},
        cancelToken: cancelToken,
      );
      return res.data?['address'] as String?;
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<MyPlaces> mine() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/places/mine');
      final d = res.data ?? const {};
      final saved = (d['saved'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => SavedPlace.fromJson(e.cast<String, dynamic>()))
          .whereType<SavedPlace>()
          .toList();
      final recents = (d['recents'] as List? ?? const [])
          .whereType<Map>()
          .where((e) => e['lat'] != null && e['lng'] != null)
          .map((e) => PlacePoint.fromJson(e.cast<String, dynamic>()))
          .toList();
      return MyPlaces(saved: saved, recents: recents);
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> save(SavedLabel label, PlacePoint p) async {
    try {
      await _dio.put<Map<String, dynamic>>('/places/saved/${label.name}', data: p.toJson());
    } catch (e) {
      throw mapDioError(e);
    }
  }
}

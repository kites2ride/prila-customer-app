import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A resolved point the rider can be picked up from / dropped at.
class PlacePoint {
  const PlacePoint({required this.name, required this.address, required this.lat, required this.lng});

  final String name;
  final String address;
  final double lat;
  final double lng;

  LatLng get latLng => LatLng(lat, lng);

  /// Same spot (~11 m grid) — used to de-duplicate recents/saved.
  bool sameSpot(PlacePoint o) =>
      (lat * 1e4).round() == (o.lat * 1e4).round() && (lng * 1e4).round() == (o.lng * 1e4).round();

  factory PlacePoint.fromJson(Map<String, dynamic> j) => PlacePoint(
        name: (j['name'] as String?)?.trim().isNotEmpty == true ? j['name'] as String : (j['address'] as String? ?? ''),
        address: j['address'] as String? ?? '',
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'name': name, 'address': address, 'lat': lat, 'lng': lng};
}

enum SavedLabel { home, work }

class SavedPlace {
  const SavedPlace({required this.label, required this.place});
  final SavedLabel label;
  final PlacePoint place;

  static SavedPlace? fromJson(Map<String, dynamic> j) {
    final label = switch (j['label']) {
      'home' => SavedLabel.home,
      'work' => SavedLabel.work,
      _ => null,
    };
    if (label == null || j['lat'] == null || j['lng'] == null) return null;
    return SavedPlace(label: label, place: PlacePoint.fromJson(j));
  }
}

class MyPlaces {
  const MyPlaces({this.saved = const [], this.recents = const []});
  final List<SavedPlace> saved;
  final List<PlacePoint> recents;

  SavedPlace? savedFor(SavedLabel l) {
    for (final s in saved) {
      if (s.label == l) return s;
    }
    return null;
  }
}

enum SuggestionSource { landmark, google }

/// Search result. Landmarks carry coordinates; Google results need a /maps/place lookup.
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.source,
    required this.mainText,
    required this.secondaryText,
    this.placeId,
    this.lat,
    this.lng,
  });

  final SuggestionSource source;
  final String mainText;
  final String secondaryText;
  final String? placeId;
  final double? lat;
  final double? lng;

  bool get isResolved => lat != null && lng != null;

  PlacePoint? get resolved =>
      isResolved ? PlacePoint(name: mainText, address: secondaryText, lat: lat!, lng: lng!) : null;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> j) => PlaceSuggestion(
        source: j['source'] == 'landmark' ? SuggestionSource.landmark : SuggestionSource.google,
        mainText: j['mainText'] as String? ?? '',
        secondaryText: j['secondaryText'] as String? ?? '',
        placeId: j['placeId'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
      );
}

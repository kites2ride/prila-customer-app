import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customer/core/config/bootstrap_models.dart';
import 'package:customer/core/maps/geo.dart';
import 'package:customer/features/places/data/places_repository.dart';
import 'package:customer/features/places/domain/place.dart';

void main() {
  group('Geo.decodePolyline', () {
    test('decodes Google\'s documented example', () {
      final pts = Geo.decodePolyline(r'_p~iF~ps|U_ulLnnqC_mqNvxq`@');
      expect(pts, hasLength(3));
      expect(pts[0].latitude, closeTo(38.5, 1e-5));
      expect(pts[0].longitude, closeTo(-120.2, 1e-5));
      expect(pts[1].latitude, closeTo(40.7, 1e-5));
      expect(pts[1].longitude, closeTo(-120.95, 1e-5));
      expect(pts[2].latitude, closeTo(43.252, 1e-5));
      expect(pts[2].longitude, closeTo(-126.453, 1e-5));
    });

    test('malformed / empty input never throws', () {
      expect(Geo.decodePolyline(''), isEmpty);
      expect(() => Geo.decodePolyline('_p~iF~ps|U_ulL'), returnsNormally);
    });
  });

  group('Geo bearings', () {
    const a = LatLng(17.99, 79.55);
    test('north / east', () {
      expect(Geo.bearing(a, const LatLng(18.0, 79.55)), closeTo(0, 0.5));
      expect(Geo.bearing(a, const LatLng(17.99, 79.56)), closeTo(90, 0.5));
    });
    test('lerpAngle takes the short way round', () {
      expect(Geo.lerpAngle(350, 10, 0.5), closeTo(0, 1e-9));
      expect(Geo.lerpAngle(10, 350, 0.5), closeTo(0, 1e-9));
    });
    test('bounds never collapse to a point', () {
      final b = Geo.bounds([a, a]);
      expect(b.northeast.latitude - b.southwest.latitude, greaterThan(0.003));
    });
  });

  test('session token is a UUID v4 the backend accepts', () {
    final t = PlacesRepository.newSessionToken();
    expect(t, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(RegExp(r'^[A-Za-z0-9_-]{8,36}$').hasMatch(t), isTrue);
    expect(PlacesRepository.newSessionToken(), isNot(t));
  });

  group('PlaceSuggestion', () {
    test('landmarks are resolved locally (no Place Details call)', () {
      final s = PlaceSuggestion.fromJson({
        'source': 'landmark',
        'placeId': null,
        'mainText': 'Kazipet Junction',
        'secondaryText': 'Kazipet',
        'lat': 17.97,
        'lng': 79.5,
      });
      expect(s.source, SuggestionSource.landmark);
      expect(s.resolved?.latLng, const LatLng(17.97, 79.5));
    });
    test('google results need a lookup', () {
      final s = PlaceSuggestion.fromJson({'source': 'google', 'placeId': 'abc', 'mainText': 'X', 'secondaryText': 'Y'});
      expect(s.isResolved, isFalse);
      expect(s.placeId, 'abc');
    });
  });

  group('BootstrapConfig maps + service area', () {
    test('reads server-driven search hints', () {
      final c = BootstrapConfig.fromJson({
        'maps': {'autocompleteMinChars': 4, 'autocompleteDebounceMs': 500},
        'serviceArea': {'enforced': true, 'inService': false, 'message': 'Not here yet'},
      });
      expect(c.searchMinChars, 4);
      expect(c.searchDebounceMs, 500);
      expect(c.inServiceArea, isFalse);
      expect(c.serviceAreaMessage, 'Not here yet');
    });
    test('safe defaults when missing or out of range', () {
      final c = BootstrapConfig.fromJson({
        'maps': {'autocompleteDebounceMs': 5},
        'serviceArea': {'enforced': false, 'inService': true},
      });
      expect(c.searchMinChars, 3);
      expect(c.searchDebounceMs, 150);
      expect(c.inServiceArea, isNull, reason: 'not enforced → no banner');
    });
  });
}

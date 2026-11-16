import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer/core/config/bootstrap_models.dart';
import 'package:customer/core/config/bootstrap_provider.dart';
import 'package:customer/core/location/location_service.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/features/booking/application/booking_draft.dart';
import 'package:customer/features/booking/presentation/search_place_page.dart';
import 'package:customer/features/places/data/places_repository.dart';
import 'package:customer/features/places/domain/place.dart';
import 'package:customer/l10n/app_localizations.dart';

class _FakeBootstrap extends BootstrapController {
  _FakeBootstrap(super.ref);

  @override
  Future<void> refresh({double? lat, double? lng}) async {
    state = AsyncValue.data(BootstrapConfig.safeDefaults());
  }
}

class _DeniedLocation extends LocationService {
  const _DeniedLocation();
  @override
  Future<LocationResult> current({bool request = true}) async => const LocationDenied();
}

class _FakePlaces extends PlacesRepository {
  _FakePlaces() : super(Dio());
  final queries = <String>[];
  final tokens = <String>{};

  @override
  Future<List<PlaceSuggestion>> autocomplete({
    required String query,
    required String sessionToken,
    double? lat,
    double? lng,
    CancelToken? cancelToken,
  }) async {
    queries.add(query);
    tokens.add(sessionToken);
    return const [
      PlaceSuggestion(
        source: SuggestionSource.landmark,
        mainText: 'Kazipet Junction',
        secondaryText: 'Kazipet, Hanamkonda',
        lat: 17.9757,
        lng: 79.5133,
      ),
    ];
  }

  @override
  Future<MyPlaces> mine() async => const MyPlaces(
        recents: [PlacePoint(name: 'MGM Hospital', address: 'Warangal', lat: 17.97, lng: 79.59)],
      );
}

void main() {
  testWidgets('search: free sources first, debounced landmark search, picks drop', (tester) async {
    final places = _FakePlaces();
    final container = ProviderContainer(overrides: [
      bootstrapProvider.overrideWith((ref) => _FakeBootstrap(ref)),
      locationServiceProvider.overrideWithValue(const _DeniedLocation()),
      placesRepositoryProvider.overrideWithValue(places),
    ]);
    addTearDown(container.dispose);
    container.read(bookingDraftProvider.notifier).start(serviceType: 'bike', serviceName: 'Bike Ride');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: PrilaTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SearchPlacePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Free sources visible without typing; location denied explains what to do.
    expect(find.text('Set location on map'), findsOneWidget);
    expect(find.text('MGM Hospital'), findsOneWidget);
    expect(find.text('Allow'), findsOneWidget);

    // Below the minimum characters → no server call.
    final drop = find.byType(TextField).last;
    await tester.enterText(drop, 'ka');
    await tester.pump(const Duration(milliseconds: 600));
    expect(places.queries, isEmpty);

    // Debounced: fast typing produces one request.
    await tester.enterText(drop, 'kaz');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(drop, 'kazi');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(places.queries, ['kazi']);
    expect(find.text('Kazipet Junction'), findsOneWidget);

    // Landmark carries coordinates → chosen without a Place Details call.
    await tester.tap(find.text('Kazipet Junction'));
    await tester.pumpAndSettle();
    final draft = container.read(bookingDraftProvider);
    expect(draft.drop?.name, 'Kazipet Junction');
    expect(draft.drop?.lat, 17.9757);
  });
}

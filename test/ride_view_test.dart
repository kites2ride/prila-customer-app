import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/pilot_info_card.dart';
import 'package:customer/features/rides/domain/ride_view.dart';
import 'package:customer/l10n/app_localizations.dart';

void main() {
  group('formatVehicleNumber', () {
    test('spaces Indian plates for easy matching', () {
      expect(formatVehicleNumber('TS03AB1234'), 'TS 03 AB 1234');
      expect(formatVehicleNumber('ts-03-ab-1234'), 'TS 03 AB 1234');
      expect(formatVehicleNumber('TS3A123'), 'TS 3 A 123');
      expect(formatVehicleNumber('TS031234'), 'TS 03 1234');
      expect(formatVehicleNumber('22BH1234AA'), '22 BH 1234 AA');
    });
    test('unknown shapes / empty never crash', () {
      expect(formatVehicleNumber(null), '');
      expect(formatVehicleNumber('hello'), 'HELLO');
    });
  });

  group('PayAt (parcels)', () {
    test('defaults to pay at pickup and round-trips the API value', () {
      expect(PayAt.parcelDefault, PayAt.pickup);
      expect(PayAt.fromJson('drop'), PayAt.drop);
      expect(PayAt.fromJson(PayAt.pickup.json), PayAt.pickup);
      expect(PayAt.fromJson(null), isNull);
      expect(PayAt.fromJson('weird'), isNull);
    });
  });

  group('isReassignedSearch', () {
    test('only while searching again after a pilot cancelled', () {
      expect(isReassignedSearch({'status': 'searching', 'reassigned': true}), isTrue);
      expect(isReassignedSearch({'status': 'requested', 'reassigned': true}), isTrue);
      expect(isReassignedSearch({'status': 'searching', 'reassigned': false}), isFalse);
      expect(isReassignedSearch({'status': 'pilot_arriving', 'reassigned': true}), isFalse, reason: 'new pilot found');
      expect(isReassignedSearch(null), isFalse);
    });
  });

  test('photoIdentity ignores the changing signature', () {
    const a = 'https://r2.example/prila/kyc/p1/selfie.jpg?X-Amz-Signature=aaa&X-Amz-Date=1';
    const b = 'https://r2.example/prila/kyc/p1/selfie.jpg?X-Amz-Signature=bbb&X-Amz-Date=2';
    expect(photoIdentity(a), photoIdentity(b));
    expect(photoIdentity(null), isNull);
  });

  testWidgets('pilot card shows name, rating, vehicle and the plate — never a phone', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PrilaTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: PilotInfoCard(
            pilot: {
              'name': 'Ravi',
              'vehicleType': 'bike',
              'vehicleNumber': 'TS03AB1234',
              'rating': 4.8,
              'ratingCount': 120,
              'photoUrl': null,
            },
          ),
        ),
      ),
    );
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('Bike'), findsOneWidget);
    expect(find.text('TS 03 AB 1234'), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget); // no photo → neutral icon
    expect(find.byIcon(Icons.phone_rounded), findsNothing);
  });
}

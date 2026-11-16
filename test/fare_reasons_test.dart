import 'package:customer/features/booking/domain/fare_reasons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps server order and drops unknown codes', () {
    expect(
      fareReasonsFrom({'reasons': ['night', 'weather', 'rush_hour', 'high_demand', 'traffic']}),
      [FareReason.night, FareReason.rushHour, FareReason.highDemand, FareReason.traffic],
    );
    expect(fareReasonsFrom({'reasons': ['traffic', 'night']}), [FareReason.traffic, FareReason.night]);
  });

  test('missing / null / wrong type is safe', () {
    expect(fareReasonsFrom(null), isEmpty);
    expect(fareReasonsFrom({}), isEmpty);
    expect(fareReasonsFrom({'reasons': null}), isEmpty);
    expect(fareReasonsFrom({'reasons': 'night'}), isEmpty);
    expect(fareReasonsFrom({'reasons': [null, 3]}), isEmpty);
  });

  test('multiplier formatting', () {
    expect(formatMultiplier(1.2), '1.2');
    expect(formatMultiplier(1.35), '1.35');
    expect(formatMultiplier(1.5), '1.5');
    expect(formatMultiplier(1), isNull);
    expect(formatMultiplier(null), isNull);
    expect(formatMultiplier(0.9), isNull);
  });
}

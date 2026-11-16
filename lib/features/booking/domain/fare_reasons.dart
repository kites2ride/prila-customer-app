/// Why a quote costs more than normal (server `fare.reasons`), in server order.
enum FareReason { night, rushHour, highDemand, traffic }

const _codes = {
  'night': FareReason.night,
  'rush_hour': FareReason.rushHour,
  'high_demand': FareReason.highDemand,
  'traffic': FareReason.traffic,
};

/// Known reasons from `fare.reasons`; unknown codes are dropped, order is kept.
List<FareReason> fareReasonsFrom(Map<dynamic, dynamic>? fare) {
  final raw = fare?['reasons'];
  if (raw is! List) return const [];
  final out = <FareReason>[];
  for (final c in raw) {
    final r = _codes[c?.toString()];
    if (r != null && !out.contains(r)) out.add(r);
  }
  return out;
}

/// "1.2", "1.35" — null when the price is normal (≤ 1) or missing.
String? formatMultiplier(num? m) {
  if (m == null || m <= 1) return null;
  var s = m.toStringAsFixed(2);
  s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return s;
}

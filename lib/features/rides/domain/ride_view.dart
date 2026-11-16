/// Pure helpers for the ride screens (no Flutter, easy to test).
library;

/// Parcels: who pays the pilot. Rides (bike / auto) always pay at the end.
enum PayAt {
  pickup,
  drop;

  /// Default for parcels: the sender pays at pickup (money first, fewer disputes).
  static const parcelDefault = PayAt.pickup;

  static PayAt? fromJson(Object? v) => switch (v) {
        'pickup' => PayAt.pickup,
        'drop' => PayAt.drop,
        _ => null,
      };

  String get json => name;
}

/// True while we are looking for a pilot again because the first one cancelled.
bool isReassignedSearch(Map<String, dynamic>? ride) {
  if (ride == null) return false;
  final status = ride['status'];
  return ride['reassigned'] == true && (status == 'searching' || status == 'requested');
}

/// "TS03AB1234" → "TS 03 AB 1234" (easy to match against the number plate).
/// Unknown shapes are returned upper-cased, unchanged otherwise.
String formatVehicleNumber(String? raw) {
  if (raw == null) return '';
  final v = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final bh = RegExp(r'^(\d{2})(BH)(\d{4})([A-Z]{1,2})$').firstMatch(v);
  if (bh != null) return '${bh[1]} ${bh[2]} ${bh[3]} ${bh[4]}';
  final m = RegExp(r'^([A-Z]{2})(\d{1,2})([A-Z]{0,3})(\d{1,4})$').firstMatch(v);
  if (m == null) return v;
  return [m[1], m[2], if ((m[3] ?? '').isNotEmpty) m[3], m[4]].join(' ');
}

/// Signed photo links change on every poll (new signature). Key the image by the path
/// only so the same photo is not re-downloaded / flickered every 2 seconds.
String? photoIdentity(String? url) {
  if (url == null || url.isEmpty) return null;
  final u = Uri.tryParse(url);
  if (u == null) return url;
  return '${u.host}${u.path}';
}

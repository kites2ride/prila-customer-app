import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer/features/rides/data/ride_repository.dart';

/// Facade: REST is source of truth; polling keeps UI in sync (socket optional later).
final rideSessionProvider =
    StateNotifierProvider<RideSessionController, AsyncValue<Map<String, dynamic>?>>(
  (ref) => RideSessionController(ref),
);

class RideSessionController extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  RideSessionController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  Timer? _poll;

  RideRepository get _repo => _ref.read(rideRepositoryProvider);

  Future<void> refreshActive() async {
    try {
      final ride = await _repo.active();
      state = AsyncValue.data(ride);
      _managePoll(ride);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> watch(String rideId) async {
    _poll?.cancel();
    Future<void> tick() async {
      try {
        final ride = await _repo.get(rideId);
        state = AsyncValue.data(ride);
        final status = ride['status'] as String?;
        if (status == null ||
            const {
              'completed',
              'paid',
              'cancelled_by_rider',
              'cancelled_by_pilot',
              'cancelled_by_system',
              'no_pilot_found',
            }.contains(status)) {
          _poll?.cancel();
        }
      } catch (_) {}
    }

    await tick();
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => tick());
  }

  void _managePoll(Map<String, dynamic>? ride) {
    _poll?.cancel();
    if (ride == null) return;
    final id = ride['id'] as String?;
    if (id != null) watch(id);
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}

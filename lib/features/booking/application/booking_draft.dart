import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer/features/places/domain/place.dart';

/// Which end of the trip the rider is choosing.
enum TripEnd { pickup, drop }

/// Rider booking UI machine (see .cursor/rules/50-ux-rapido-ax.mdc):
/// idle_home → pick_service → set_route → quote_ready → finding_pilot → tracking.
/// This draft covers pick_service + set_route; the quote lives on the confirm screen,
/// everything after booking is server state (ride status).
class BookingDraft {
  const BookingDraft({
    this.serviceType = 'bike',
    this.serviceName = '',
    this.pickup,
    this.drop,
    this.pickupIsCurrentLocation = false,
  });

  final String serviceType;
  final String serviceName;
  final PlacePoint? pickup;
  final PlacePoint? drop;
  final bool pickupIsCurrentLocation;

  bool get routeReady => pickup != null && drop != null;

  BookingDraft copyWith({
    String? serviceType,
    String? serviceName,
    PlacePoint? pickup,
    PlacePoint? drop,
    bool? pickupIsCurrentLocation,
    bool clearDrop = false,
  }) =>
      BookingDraft(
        serviceType: serviceType ?? this.serviceType,
        serviceName: serviceName ?? this.serviceName,
        pickup: pickup ?? this.pickup,
        drop: clearDrop ? null : (drop ?? this.drop),
        pickupIsCurrentLocation: pickupIsCurrentLocation ?? this.pickupIsCurrentLocation,
      );
}

final bookingDraftProvider = StateNotifierProvider<BookingDraftController, BookingDraft>(
  (ref) => BookingDraftController(),
);

class BookingDraftController extends StateNotifier<BookingDraft> {
  BookingDraftController() : super(const BookingDraft());

  /// Home → service tile / "Where to?". Keeps the last pickup, clears the drop.
  void start({required String serviceType, required String serviceName, PlacePoint? drop}) {
    state = BookingDraft(
      serviceType: serviceType,
      serviceName: serviceName,
      pickup: state.pickup,
      pickupIsCurrentLocation: state.pickupIsCurrentLocation,
      drop: drop,
    );
  }

  void setService(String type, String name) => state = state.copyWith(serviceType: type, serviceName: name);

  void setPoint(TripEnd end, PlacePoint p, {bool isCurrentLocation = false}) {
    state = end == TripEnd.pickup
        ? state.copyWith(pickup: p, pickupIsCurrentLocation: isCurrentLocation)
        : state.copyWith(drop: p);
  }

  void swap() {
    final p = state.pickup;
    final d = state.drop;
    if (p == null || d == null) return;
    state = BookingDraft(
      serviceType: state.serviceType,
      serviceName: state.serviceName,
      pickup: d,
      drop: p,
    );
  }

  void reset() => state = BookingDraft(serviceType: state.serviceType, serviceName: state.serviceName);
}

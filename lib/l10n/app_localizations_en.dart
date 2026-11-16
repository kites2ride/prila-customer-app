// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Prila';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get continueCta => 'Continue';

  @override
  String get phoneLoginTitle => 'Enter your phone number';

  @override
  String get phoneLoginSubtitle => 'We\'ll send a one-time password';

  @override
  String get phoneHint => '10-digit mobile number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get otpTitle => 'Enter OTP';

  @override
  String otpSubtitle(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get verifyOtp => 'Verify';

  @override
  String get permissionsTitle => 'Allow location & notifications';

  @override
  String get permissionsBody =>
      'Prila needs your location to find nearby pilots and send trip updates.';

  @override
  String get allowPermissions => 'Allow access';

  @override
  String get skipForNow => 'Not now';

  @override
  String get maintenanceTitle => 'We\'ll be right back';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateOptionalTitle => 'Update available';

  @override
  String get updateNow => 'Update now';

  @override
  String get later => 'Later';

  @override
  String get homeTitle => 'Home';

  @override
  String get myRides => 'My Rides';

  @override
  String get wallet => 'Wallet';

  @override
  String get account => 'Account';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get logOut => 'Log Out';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get emptyGeneric => 'Nothing here yet';

  @override
  String get bikeRide => 'Bike Ride';

  @override
  String get autoRide => 'Auto Ride';

  @override
  String get parcelLogistics => 'Parcel / Logistics';

  @override
  String get findRide => 'Find Ride';

  @override
  String get profileSetupTitle => 'Complete your profile';

  @override
  String get nameHint => 'Your name';

  @override
  String get save => 'Save';

  @override
  String get notifications => 'Notifications';

  @override
  String get support => 'Support';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get pickup => 'Pickup';

  @override
  String get drop => 'Drop';

  @override
  String get pickupHint => 'Pickup location';

  @override
  String get dropHint => 'Where to?';

  @override
  String get couponCode => 'Coupon code';

  @override
  String get prilaShakti => 'Prila Shakti';

  @override
  String get prilaShaktiHint => 'Match with female pilots only';

  @override
  String get fareEstimate => 'Fare estimate';

  @override
  String get discount => 'Discount';

  @override
  String get cashOnly => 'Pay cash to pilot';

  @override
  String get getEstimate => 'Get estimate';

  @override
  String get refreshEstimate => 'Refresh estimate';

  @override
  String get yourRide => 'Your ride';

  @override
  String get statusSearching => 'Finding a pilot…';

  @override
  String get statusPilotComing => 'Pilot on the way';

  @override
  String get statusPilotArrived => 'Pilot arrived';

  @override
  String get statusInProgress => 'Trip in progress';

  @override
  String get statusCompleted => 'Trip completed';

  @override
  String get statusNoPilot => 'No pilots nearby';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get searchingPilots => 'Looking for nearby pilots';

  @override
  String get shareOtp => 'Share this OTP with your pilot to start';

  @override
  String get fare => 'Fare';

  @override
  String get rateRide => 'Rate ride';

  @override
  String get cancelRide => 'Cancel ride';

  @override
  String get backHome => 'Back to home';

  @override
  String get howWasRide => 'How was your ride?';

  @override
  String get submitRating => 'Submit rating';

  @override
  String get noRidesYet => 'No rides yet — book your first trip';

  @override
  String get activeRideBanner => 'Active ride';

  @override
  String get couponsOn => 'Coupons available';

  @override
  String get studentCoupon => 'Student offer';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get shareTrip => 'Share trip';

  @override
  String get shareTripCopied => 'Share link ready';

  @override
  String get sos => 'SOS';

  @override
  String get sosSent => 'Help alert sent';

  @override
  String get notHereYetTitle => 'We\'re not here yet';

  @override
  String get notHereYetAction => 'Try another location';

  @override
  String get whereTo => 'Where to?';

  @override
  String get searchPickupHint => 'Pickup location';

  @override
  String get searchDropHint => 'Where are you going?';

  @override
  String get currentLocation => 'Current location';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get setOnMap => 'Set location on map';

  @override
  String get savedHome => 'Home';

  @override
  String get savedWork => 'Work';

  @override
  String get saveAsHome => 'Save as Home';

  @override
  String get saveAsWork => 'Save as Work';

  @override
  String get savedPlaceDone => 'Saved';

  @override
  String get recentPlaces => 'Recent places';

  @override
  String get noPlacesFound =>
      'No places found. Try another name or set it on the map.';

  @override
  String get searchUnavailable =>
      'Search isn\'t working right now. You can set the place on the map.';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get locationOffTitle => 'Your phone\'s location is off';

  @override
  String get turnOnLocation => 'Turn on';

  @override
  String get allowLocation => 'Allow';

  @override
  String get openSettings => 'Settings';

  @override
  String get locationNeeded =>
      'Allow location so we can pick you up from where you are.';

  @override
  String get swapPlaces => 'Swap pickup and drop';

  @override
  String get poweredByGoogle => 'Powered by Google';

  @override
  String get setPickupTitle => 'Set your pickup point';

  @override
  String get setDropTitle => 'Set your drop point';

  @override
  String get confirmPickup => 'Confirm pickup';

  @override
  String get confirmDrop => 'Confirm drop';

  @override
  String get pinnedLocation => 'Pinned location';

  @override
  String get findingAddress => 'Finding address…';

  @override
  String get addressUnavailable =>
      'Couldn\'t get the address. You can still confirm this spot.';

  @override
  String get myLocation => 'My location';

  @override
  String bookService(String service) {
    return 'Book $service';
  }

  @override
  String tripSummary(String km, String min) {
    return '$km km · $min min';
  }

  @override
  String get cash => 'Cash';

  @override
  String get apply => 'Apply';

  @override
  String get recenter => 'Show pilot';

  @override
  String pilotEtaMin(String min) {
    return 'Arriving in $min min';
  }

  @override
  String get mapLoadFailed =>
      'The map couldn\'t load. Check your internet and try again.';

  @override
  String get pilotCancelledFinding =>
      'Your pilot cancelled. Finding you another pilot…';

  @override
  String get yourPilot => 'Your pilot';

  @override
  String get whoPays => 'Who pays?';

  @override
  String get payAtPickup => 'Pay at pickup';

  @override
  String get payAtPickupHint => 'Sender pays the pilot at pickup';

  @override
  String get payAtDrop => 'Pay at drop';

  @override
  String get payAtDropHint => 'Receiver pays the pilot at drop';

  @override
  String payAtPickupLine(String amount) {
    return 'Pay $amount to the pilot at pickup';
  }

  @override
  String payAtDropLine(String amount) {
    return 'Receiver pays $amount to the pilot at drop';
  }

  @override
  String get vehicleBike => 'Bike';

  @override
  String get vehicleAuto => 'Auto';

  @override
  String get vehicleParcel => 'Parcel';

  @override
  String get vehicleLogistics => 'Logistics';

  @override
  String get fareNight => 'Night fare';

  @override
  String get fareRushHour => 'Rush hour';

  @override
  String get fareHighDemand => 'High demand';

  @override
  String get fareTraffic => 'Heavy traffic';

  @override
  String fareTimesNormal(String x) {
    return '$x× the normal fare';
  }
}

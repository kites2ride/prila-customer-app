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
}

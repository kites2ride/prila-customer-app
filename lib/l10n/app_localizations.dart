import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Prila'**
  String get appName;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String hello(String name);

  /// No description provided for @continueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCta;

  /// No description provided for @phoneLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneLoginTitle;

  /// No description provided for @phoneLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a one-time password'**
  String get phoneLoginSubtitle;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get phoneHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow location & notifications'**
  String get permissionsTitle;

  /// No description provided for @permissionsBody.
  ///
  /// In en, this message translates to:
  /// **'Prila needs your location to find nearby pilots and send trip updates.'**
  String get permissionsBody;

  /// No description provided for @allowPermissions.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get allowPermissions;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get skipForNow;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll be right back'**
  String get maintenanceTitle;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// No description provided for @updateOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateOptionalTitle;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @myRides.
  ///
  /// In en, this message translates to:
  /// **'My Rides'**
  String get myRides;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @emptyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyGeneric;

  /// No description provided for @bikeRide.
  ///
  /// In en, this message translates to:
  /// **'Bike Ride'**
  String get bikeRide;

  /// No description provided for @autoRide.
  ///
  /// In en, this message translates to:
  /// **'Auto Ride'**
  String get autoRide;

  /// No description provided for @parcelLogistics.
  ///
  /// In en, this message translates to:
  /// **'Parcel / Logistics'**
  String get parcelLogistics;

  /// No description provided for @findRide.
  ///
  /// In en, this message translates to:
  /// **'Find Ride'**
  String get findRide;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get profileSetupTitle;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// No description provided for @pickupHint.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupHint;

  /// No description provided for @dropHint.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get dropHint;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon code'**
  String get couponCode;

  /// No description provided for @prilaShakti.
  ///
  /// In en, this message translates to:
  /// **'Prila Shakti'**
  String get prilaShakti;

  /// No description provided for @prilaShaktiHint.
  ///
  /// In en, this message translates to:
  /// **'Match with female pilots only'**
  String get prilaShaktiHint;

  /// No description provided for @fareEstimate.
  ///
  /// In en, this message translates to:
  /// **'Fare estimate'**
  String get fareEstimate;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @cashOnly.
  ///
  /// In en, this message translates to:
  /// **'Pay cash to pilot'**
  String get cashOnly;

  /// No description provided for @getEstimate.
  ///
  /// In en, this message translates to:
  /// **'Get estimate'**
  String get getEstimate;

  /// No description provided for @refreshEstimate.
  ///
  /// In en, this message translates to:
  /// **'Refresh estimate'**
  String get refreshEstimate;

  /// No description provided for @yourRide.
  ///
  /// In en, this message translates to:
  /// **'Your ride'**
  String get yourRide;

  /// No description provided for @statusSearching.
  ///
  /// In en, this message translates to:
  /// **'Finding a pilot…'**
  String get statusSearching;

  /// No description provided for @statusPilotComing.
  ///
  /// In en, this message translates to:
  /// **'Pilot on the way'**
  String get statusPilotComing;

  /// No description provided for @statusPilotArrived.
  ///
  /// In en, this message translates to:
  /// **'Pilot arrived'**
  String get statusPilotArrived;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get statusCompleted;

  /// No description provided for @statusNoPilot.
  ///
  /// In en, this message translates to:
  /// **'No pilots nearby'**
  String get statusNoPilot;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @searchingPilots.
  ///
  /// In en, this message translates to:
  /// **'Looking for nearby pilots'**
  String get searchingPilots;

  /// No description provided for @shareOtp.
  ///
  /// In en, this message translates to:
  /// **'Share this OTP with your pilot to start'**
  String get shareOtp;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @rateRide.
  ///
  /// In en, this message translates to:
  /// **'Rate ride'**
  String get rateRide;

  /// No description provided for @cancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get cancelRide;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @howWasRide.
  ///
  /// In en, this message translates to:
  /// **'How was your ride?'**
  String get howWasRide;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get submitRating;

  /// No description provided for @noRidesYet.
  ///
  /// In en, this message translates to:
  /// **'No rides yet — book your first trip'**
  String get noRidesYet;

  /// No description provided for @activeRideBanner.
  ///
  /// In en, this message translates to:
  /// **'Active ride'**
  String get activeRideBanner;

  /// No description provided for @couponsOn.
  ///
  /// In en, this message translates to:
  /// **'Coupons available'**
  String get couponsOn;

  /// No description provided for @studentCoupon.
  ///
  /// In en, this message translates to:
  /// **'Student offer'**
  String get studentCoupon;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @shareTrip.
  ///
  /// In en, this message translates to:
  /// **'Share trip'**
  String get shareTrip;

  /// No description provided for @shareTripCopied.
  ///
  /// In en, this message translates to:
  /// **'Share link ready'**
  String get shareTripCopied;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @sosSent.
  ///
  /// In en, this message translates to:
  /// **'Help alert sent'**
  String get sosSent;

  /// Title when pickup/drop is outside the service area. The explanation text comes from the server.
  ///
  /// In en, this message translates to:
  /// **'We\'re not here yet'**
  String get notHereYetTitle;

  /// No description provided for @notHereYetAction.
  ///
  /// In en, this message translates to:
  /// **'Try another location'**
  String get notHereYetAction;

  /// No description provided for @whereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// No description provided for @searchPickupHint.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get searchPickupHint;

  /// No description provided for @searchDropHint.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get searchDropHint;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @setOnMap.
  ///
  /// In en, this message translates to:
  /// **'Set location on map'**
  String get setOnMap;

  /// No description provided for @savedHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get savedHome;

  /// No description provided for @savedWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get savedWork;

  /// No description provided for @saveAsHome.
  ///
  /// In en, this message translates to:
  /// **'Save as Home'**
  String get saveAsHome;

  /// No description provided for @saveAsWork.
  ///
  /// In en, this message translates to:
  /// **'Save as Work'**
  String get saveAsWork;

  /// No description provided for @savedPlaceDone.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedPlaceDone;

  /// No description provided for @recentPlaces.
  ///
  /// In en, this message translates to:
  /// **'Recent places'**
  String get recentPlaces;

  /// No description provided for @noPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No places found. Try another name or set it on the map.'**
  String get noPlacesFound;

  /// No description provided for @searchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Search isn\'t working right now. You can set the place on the map.'**
  String get searchUnavailable;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @locationOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s location is off'**
  String get locationOffTitle;

  /// No description provided for @turnOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOnLocation;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allowLocation;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// No description provided for @locationNeeded.
  ///
  /// In en, this message translates to:
  /// **'Allow location so we can pick you up from where you are.'**
  String get locationNeeded;

  /// No description provided for @swapPlaces.
  ///
  /// In en, this message translates to:
  /// **'Swap pickup and drop'**
  String get swapPlaces;

  /// No description provided for @poweredByGoogle.
  ///
  /// In en, this message translates to:
  /// **'Powered by Google'**
  String get poweredByGoogle;

  /// No description provided for @setPickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your pickup point'**
  String get setPickupTitle;

  /// No description provided for @setDropTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your drop point'**
  String get setDropTitle;

  /// No description provided for @confirmPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm pickup'**
  String get confirmPickup;

  /// No description provided for @confirmDrop.
  ///
  /// In en, this message translates to:
  /// **'Confirm drop'**
  String get confirmDrop;

  /// No description provided for @pinnedLocation.
  ///
  /// In en, this message translates to:
  /// **'Pinned location'**
  String get pinnedLocation;

  /// No description provided for @findingAddress.
  ///
  /// In en, this message translates to:
  /// **'Finding address…'**
  String get findingAddress;

  /// No description provided for @addressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get the address. You can still confirm this spot.'**
  String get addressUnavailable;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book {service}'**
  String bookService(String service);

  /// No description provided for @tripSummary.
  ///
  /// In en, this message translates to:
  /// **'{km} km · {min} min'**
  String tripSummary(String km, String min);

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @recenter.
  ///
  /// In en, this message translates to:
  /// **'Show pilot'**
  String get recenter;

  /// No description provided for @pilotEtaMin.
  ///
  /// In en, this message translates to:
  /// **'Arriving in {min} min'**
  String pilotEtaMin(String min);

  /// No description provided for @mapLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The map couldn\'t load. Check your internet and try again.'**
  String get mapLoadFailed;

  /// No description provided for @pilotCancelledFinding.
  ///
  /// In en, this message translates to:
  /// **'Your pilot cancelled. Finding you another pilot…'**
  String get pilotCancelledFinding;

  /// No description provided for @yourPilot.
  ///
  /// In en, this message translates to:
  /// **'Your pilot'**
  String get yourPilot;

  /// No description provided for @whoPays.
  ///
  /// In en, this message translates to:
  /// **'Who pays?'**
  String get whoPays;

  /// No description provided for @payAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Pay at pickup'**
  String get payAtPickup;

  /// No description provided for @payAtPickupHint.
  ///
  /// In en, this message translates to:
  /// **'Sender pays the pilot at pickup'**
  String get payAtPickupHint;

  /// No description provided for @payAtDrop.
  ///
  /// In en, this message translates to:
  /// **'Pay at drop'**
  String get payAtDrop;

  /// No description provided for @payAtDropHint.
  ///
  /// In en, this message translates to:
  /// **'Receiver pays the pilot at drop'**
  String get payAtDropHint;

  /// No description provided for @payAtPickupLine.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} to the pilot at pickup'**
  String payAtPickupLine(String amount);

  /// No description provided for @payAtDropLine.
  ///
  /// In en, this message translates to:
  /// **'Receiver pays {amount} to the pilot at drop'**
  String payAtDropLine(String amount);

  /// No description provided for @vehicleBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get vehicleBike;

  /// No description provided for @vehicleAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get vehicleAuto;

  /// No description provided for @vehicleParcel.
  ///
  /// In en, this message translates to:
  /// **'Parcel'**
  String get vehicleParcel;

  /// No description provided for @vehicleLogistics.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get vehicleLogistics;

  /// No description provided for @fareNight.
  ///
  /// In en, this message translates to:
  /// **'Night fare'**
  String get fareNight;

  /// No description provided for @fareRushHour.
  ///
  /// In en, this message translates to:
  /// **'Rush hour'**
  String get fareRushHour;

  /// No description provided for @fareHighDemand.
  ///
  /// In en, this message translates to:
  /// **'High demand'**
  String get fareHighDemand;

  /// No description provided for @fareTraffic.
  ///
  /// In en, this message translates to:
  /// **'Heavy traffic'**
  String get fareTraffic;

  /// No description provided for @fareTimesNormal.
  ///
  /// In en, this message translates to:
  /// **'{x}× the normal fare'**
  String fareTimesNormal(String x);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'Prila';

  @override
  String hello(String name) {
    return 'నమస్కారం, $name';
  }

  @override
  String get continueCta => 'కొనసాగించండి';

  @override
  String get phoneLoginTitle => 'మీ ఫోన్ నంబర్ ఇవ్వండి';

  @override
  String get phoneLoginSubtitle => 'మేము ఒక OTP పంపుతాము';

  @override
  String get phoneHint => '10 అంకెల మొబైల్ నంబర్';

  @override
  String get sendOtp => 'OTP పంపండి';

  @override
  String get otpTitle => 'OTP నమోదు చేయండి';

  @override
  String otpSubtitle(String phone) {
    return '$phone కు కోడ్ పంపబడింది';
  }

  @override
  String get verifyOtp => 'నిర్ధారించండి';

  @override
  String get permissionsTitle => 'లొకేషన్ & నోటిఫికేషన్లు అనుమతించండి';

  @override
  String get permissionsBody =>
      'సమీప పైలట్లను కనుగొనడానికి మరియు ట్రిప్ అప్‌డేట్ల కోసం Prila కి లొకేషన్ అవసరం.';

  @override
  String get allowPermissions => 'అనుమతించండి';

  @override
  String get skipForNow => 'ఇప్పుడు కాదు';

  @override
  String get maintenanceTitle => 'త్వరలో తిరిగి వస్తాము';

  @override
  String get updateRequiredTitle => 'అప్‌డేట్ అవసరం';

  @override
  String get updateOptionalTitle => 'అప్‌డేట్ అందుబాటులో ఉంది';

  @override
  String get updateNow => 'ఇప్పుడు అప్‌డేట్ చేయండి';

  @override
  String get later => 'తర్వాత';

  @override
  String get homeTitle => 'హోమ్';

  @override
  String get myRides => 'నా రైడ్స్';

  @override
  String get wallet => 'వాలెట్';

  @override
  String get account => 'అకౌంట్';

  @override
  String get darkMode => 'డార్క్ మోడ్';

  @override
  String get language => 'భాష';

  @override
  String get logOut => 'లాగ్ అవుట్';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get errorGeneric => 'ఏదో తప్పు జరిగింది';

  @override
  String get emptyGeneric => 'ఇంకా ఏమీ లేదు';

  @override
  String get bikeRide => 'బైక్ రైడ్';

  @override
  String get autoRide => 'ఆటో రైడ్';

  @override
  String get parcelLogistics => 'పార్సెల్ / లాజిస్టిక్స్';

  @override
  String get findRide => 'రైడ్ కనుగొనండి';

  @override
  String get profileSetupTitle => 'ప్రొఫైల్ పూర్తి చేయండి';

  @override
  String get nameHint => 'మీ పేరు';

  @override
  String get save => 'సేవ్';

  @override
  String get notifications => 'నోటిఫికేషన్లు';

  @override
  String get support => 'సపోర్ట్';

  @override
  String versionLabel(String version) {
    return 'వెర్షన్ $version';
  }

  @override
  String get pickup => 'పికప్';

  @override
  String get drop => 'డ్రాప్';

  @override
  String get pickupHint => 'పికప్ స్థలం';

  @override
  String get dropHint => 'ఎక్కడికి?';

  @override
  String get couponCode => 'కూపన్ కోడ్';

  @override
  String get prilaShakti => 'Prila Shakti';

  @override
  String get prilaShaktiHint => 'మహిళా పైలట్లతో మాత్రమే మ్యాచ్';

  @override
  String get fareEstimate => 'ఛార్జీ అంచనా';

  @override
  String get discount => 'డిస్కౌంట్';

  @override
  String get cashOnly => 'పైలట్‌కు క్యాష్ చెల్లించండి';

  @override
  String get getEstimate => 'అంచనా తీసుకోండి';

  @override
  String get refreshEstimate => 'అంచనా రిఫ్రెష్';

  @override
  String get yourRide => 'మీ రైడ్';

  @override
  String get statusSearching => 'పైలట్ వెతుకుతున్నాం…';

  @override
  String get statusPilotComing => 'పైలట్ వస్తున్నారు';

  @override
  String get statusPilotArrived => 'పైలట్ వచ్చారు';

  @override
  String get statusInProgress => 'ట్రిప్ నడుస్తోంది';

  @override
  String get statusCompleted => 'ట్రిప్ పూర్తి';

  @override
  String get statusNoPilot => 'సమీపంలో పైలట్లు లేరు';

  @override
  String get statusCancelled => 'రద్దు';

  @override
  String get searchingPilots => 'సమీప పైలట్లను వెతుకుతున్నాం';

  @override
  String get shareOtp => 'ప్రారంభించడానికి ఈ OTP ని పైలట్‌తో పంచుకోండి';

  @override
  String get fare => 'ఛార్జీ';

  @override
  String get rateRide => 'రైడ్ రేట్ చేయండి';

  @override
  String get cancelRide => 'రైడ్ రద్దు';

  @override
  String get backHome => 'హోమ్‌కు తిరిగి';

  @override
  String get howWasRide => 'మీ రైడ్ ఎలా ఉంది?';

  @override
  String get submitRating => 'రేటింగ్ సమర్పించండి';

  @override
  String get noRidesYet => 'ఇంకా రైడ్స్ లేవు — మొదటి ట్రిప్ బుక్ చేయండి';

  @override
  String get activeRideBanner => 'యాక్టివ్ రైడ్';

  @override
  String get couponsOn => 'కూపన్లు అందుబాటులో';

  @override
  String get studentCoupon => 'స్టూడెంట్ ఆఫర్';

  @override
  String get notificationsTitle => 'నోటిఫికేషన్లు';

  @override
  String get noNotifications => 'ఇంకా నోటిఫికేషన్లు లేవు';

  @override
  String get shareTrip => 'ట్రిప్ షేర్ చేయండి';

  @override
  String get shareTripCopied => 'షేర్ లింక్ సిద్ధం';

  @override
  String get sos => 'SOS';

  @override
  String get sosSent => 'సహాయ హెచ్చరిక పంపబడింది';

  @override
  String get notHereYetTitle => 'మేము ఇంకా ఇక్కడ లేము';

  @override
  String get notHereYetAction => 'వేరే స్థలం ప్రయత్నించండి';

  @override
  String get whereTo => 'ఎక్కడికి వెళ్లాలి?';

  @override
  String get searchPickupHint => 'పికప్ స్థలం';

  @override
  String get searchDropHint => 'మీరు ఎక్కడికి వెళ్తున్నారు?';

  @override
  String get currentLocation => 'ప్రస్తుత స్థలం';

  @override
  String get useCurrentLocation => 'ప్రస్తుత స్థలాన్ని వాడండి';

  @override
  String get setOnMap => 'మ్యాప్‌లో స్థలం ఎంచుకోండి';

  @override
  String get savedHome => 'ఇల్లు';

  @override
  String get savedWork => 'ఆఫీసు';

  @override
  String get saveAsHome => 'ఇల్లుగా సేవ్ చేయండి';

  @override
  String get saveAsWork => 'ఆఫీసుగా సేవ్ చేయండి';

  @override
  String get savedPlaceDone => 'సేవ్ అయింది';

  @override
  String get recentPlaces => 'ఇటీవలి స్థలాలు';

  @override
  String get noPlacesFound =>
      'స్థలాలు దొరకలేదు. వేరే పేరు ప్రయత్నించండి లేదా మ్యాప్‌లో ఎంచుకోండి.';

  @override
  String get searchUnavailable =>
      'ఇప్పుడు వెతకడం పని చేయడం లేదు. మ్యాప్‌లో స్థలం ఎంచుకోవచ్చు.';

  @override
  String get noInternet => 'ఇంటర్నెట్ కనెక్షన్ లేదు';

  @override
  String get locationOffTitle => 'మీ ఫోన్ లొకేషన్ ఆఫ్‌లో ఉంది';

  @override
  String get turnOnLocation => 'ఆన్ చేయండి';

  @override
  String get allowLocation => 'అనుమతించండి';

  @override
  String get openSettings => 'సెట్టింగ్స్';

  @override
  String get locationNeeded =>
      'మీరు ఉన్న చోటు నుండే పికప్ చేయడానికి లొకేషన్ అనుమతించండి.';

  @override
  String get swapPlaces => 'పికప్, డ్రాప్ మార్చండి';

  @override
  String get poweredByGoogle => 'Powered by Google';

  @override
  String get setPickupTitle => 'మీ పికప్ స్థలం ఎంచుకోండి';

  @override
  String get setDropTitle => 'మీ డ్రాప్ స్థలం ఎంచుకోండి';

  @override
  String get confirmPickup => 'పికప్ నిర్ధారించండి';

  @override
  String get confirmDrop => 'డ్రాప్ నిర్ధారించండి';

  @override
  String get pinnedLocation => 'ఎంచుకున్న స్థలం';

  @override
  String get findingAddress => 'చిరునామా వెతుకుతోంది…';

  @override
  String get addressUnavailable =>
      'చిరునామా దొరకలేదు. అయినా ఈ స్థలాన్ని నిర్ధారించవచ్చు.';

  @override
  String get myLocation => 'నా స్థలం';

  @override
  String bookService(String service) {
    return '$service బుక్ చేయండి';
  }

  @override
  String tripSummary(String km, String min) {
    return '$km కి.మీ · $min నిమి';
  }

  @override
  String get cash => 'నగదు';

  @override
  String get apply => 'వర్తింపజేయండి';

  @override
  String get recenter => 'పైలట్‌ను చూపించు';

  @override
  String pilotEtaMin(String min) {
    return '$min నిమిషాల్లో వస్తున్నారు';
  }

  @override
  String get mapLoadFailed =>
      'మ్యాప్ లోడ్ కాలేదు. ఇంటర్నెట్ చూసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get pilotCancelledFinding =>
      'మీ పైలట్ రద్దు చేశారు. మీకు మరో పైలట్‌ను వెతుకుతున్నాం…';

  @override
  String get yourPilot => 'మీ పైలట్';

  @override
  String get whoPays => 'ఎవరు చెల్లిస్తారు?';

  @override
  String get payAtPickup => 'పికప్ వద్ద చెల్లింపు';

  @override
  String get payAtPickupHint => 'పంపేవారు పికప్ వద్ద పైలట్‌కు చెల్లిస్తారు';

  @override
  String get payAtDrop => 'డ్రాప్ వద్ద చెల్లింపు';

  @override
  String get payAtDropHint => 'అందుకునేవారు డ్రాప్ వద్ద పైలట్‌కు చెల్లిస్తారు';

  @override
  String payAtPickupLine(String amount) {
    return 'పికప్ వద్ద పైలట్‌కు $amount చెల్లించండి';
  }

  @override
  String payAtDropLine(String amount) {
    return 'అందుకునేవారు డ్రాప్ వద్ద పైలట్‌కు $amount చెల్లిస్తారు';
  }

  @override
  String get vehicleBike => 'బైక్';

  @override
  String get vehicleAuto => 'ఆటో';

  @override
  String get vehicleParcel => 'పార్సెల్';

  @override
  String get vehicleLogistics => 'లాజిస్టిక్స్';

  @override
  String get fareNight => 'రాత్రి ఛార్జీ';

  @override
  String get fareRushHour => 'రద్దీ సమయం';

  @override
  String get fareHighDemand => 'ఎక్కువ డిమాండ్';

  @override
  String get fareTraffic => 'భారీ ట్రాఫిక్';

  @override
  String fareTimesNormal(String x) {
    return 'సాధారణ ఛార్జీకి $x రెట్లు';
  }
}

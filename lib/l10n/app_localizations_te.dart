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
}

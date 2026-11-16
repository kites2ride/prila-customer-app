import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:customer/core/config/bootstrap_provider.dart';
import 'package:customer/core/storage/secure_store.dart';
import 'package:customer/features/auth/data/auth_repository.dart';
import 'package:customer/features/auth/presentation/otp_page.dart';
import 'package:customer/features/auth/presentation/phone_login_page.dart';
import 'package:customer/features/gates/presentation/maintenance_page.dart';
import 'package:customer/features/gates/presentation/update_page.dart';
import 'package:customer/features/home/presentation/home_shell.dart';
import 'package:customer/features/notifications/presentation/notifications_page.dart';
import 'package:customer/features/onboarding/presentation/permissions_page.dart';
import 'package:customer/features/booking/application/booking_draft.dart';
import 'package:customer/features/booking/presentation/confirm_ride_page.dart';
import 'package:customer/features/booking/presentation/pin_picker_page.dart';
import 'package:customer/features/booking/presentation/search_place_page.dart';
import 'package:customer/features/rides/presentation/rate_ride_page.dart';
import 'package:customer/features/rides/presentation/ride_tracking_page.dart';
import 'package:customer/features/splash/presentation/splash_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authSessionProvider, (_, __) => refresh.value++);
  ref.listen(bootstrapProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/permissions', builder: (_, __) => const PermissionsPage()),
      GoRoute(path: '/login', builder: (_, __) => const PhoneLoginPage()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpPage(
            phone: extra['phone'] as String? ?? '',
            debugCode: extra['debugCode'] as String?,
          );
        },
      ),
      GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
      // Booking: search (set_route) → optional map pin → confirm (quote_ready).
      GoRoute(
        path: '/book',
        builder: (_, state) => SearchPlacePage(
          focus: state.uri.queryParameters['focus'] == 'pickup' ? TripEnd.pickup : TripEnd.drop,
        ),
      ),
      GoRoute(
        path: '/book/map',
        builder: (_, state) => PinPickerPage(
          end: state.uri.queryParameters['end'] == 'pickup' ? TripEnd.pickup : TripEnd.drop,
        ),
      ),
      GoRoute(path: '/book/confirm', builder: (_, _) => const ConfirmRidePage()),
      GoRoute(
        path: '/ride/:id',
        builder: (_, state) => RideTrackingPage(rideId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ride/:id/rate',
        builder: (_, state) => RateRidePage(rideId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/maintenance', builder: (_, __) => const MaintenancePage()),
      GoRoute(
        path: '/update',
        builder: (_, state) => UpdatePage(requiredUpdate: state.uri.queryParameters['required'] == '1'),
      ),
    ],
    redirect: (context, state) async {
      final loc = state.matchedLocation;
      if (loc == '/splash') return null;

      final boot = ref.read(bootstrapProvider);
      final cfg = boot.valueOrNull;
      if (cfg != null && cfg.maintenanceEnabled && loc != '/maintenance') {
        return '/maintenance';
      }
      if (loc == '/maintenance' && (cfg == null || !cfg.maintenanceEnabled)) {
        return '/home';
      }

      if (cfg != null) {
        final info = await PackageInfo.fromPlatform();
        final build = int.tryParse(info.buildNumber) ?? 0;
        if (cfg.updateMode == 'required' && loc != '/update') {
          return '/update?required=1';
        }
        if (cfg.updateMode == 'optional' &&
            loc == '/home' &&
            cfg.latestBuild > 0 &&
            build < cfg.latestBuild) {
          // optional gate once — handled lightly: allow home, no hard redirect
        }
      }

      final store = ref.read(secureStoreProvider);
      final perms = await store.read(SecureStore.permissionsDoneKey);
      final authed = await ref.read(authRepositoryProvider).hasSession();

      if (perms != '1' && loc != '/permissions') return '/permissions';
      if (perms == '1' && !authed && loc != '/login' && loc != '/otp') return '/login';
      if (authed && (loc == '/login' || loc == '/otp' || loc == '/permissions')) return '/home';
      return null;
    },
  );
});

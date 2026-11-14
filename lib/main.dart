import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customer/core/firebase/crashlytics_bootstrap.dart';
import 'package:customer/core/router/app_router.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/theme/theme_mode_controller.dart';
import 'package:customer/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapCrashlytics();
  runApp(const ProviderScope(child: PrilaCustomerApp()));
}

class PrilaCustomerApp extends ConsumerWidget {
  const PrilaCustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Prila',
      theme: PrilaTheme.light(),
      darkTheme: PrilaTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
    );
  }
}

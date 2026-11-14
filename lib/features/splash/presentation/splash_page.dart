import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/config/bootstrap_provider.dart';
import 'package:customer/core/theme/prila_colors.dart';
import 'package:customer/core/widgets/prila_brand.dart';
import 'package:customer/features/analytics/data/analytics_repository.dart';
import 'package:customer/features/auth/data/auth_repository.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await ref.read(bootstrapProvider.notifier).refresh();
    ref.read(analyticsRepositoryProvider).track(name: 'app_open');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final authed = await ref.read(authRepositoryProvider).hasSession();
    if (!mounted) return;
    context.go(authed ? '/home' : '/permissions');
  }

  @override
  Widget build(BuildContext context) {
    // Splash always uses the dark brand canvas (matches launcher icon and
    // native launch screen), regardless of the app theme.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: PrilaColors.dark.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PrilaMark(size: 120),
              const SizedBox(height: 28),
              const PrilaLockup(width: 240),
            ],
          ),
        ),
      ),
    );
  }
}

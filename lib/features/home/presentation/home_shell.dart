import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/config/bootstrap_provider.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/theme/theme_mode_controller.dart';
import 'package:customer/core/widgets/prila_app_header.dart';
import 'package:customer/core/widgets/prila_bottom_nav.dart';
import 'package:customer/core/widgets/prila_card.dart';
import 'package:customer/core/widgets/settings_tile.dart';
import 'package:customer/features/auth/data/auth_repository.dart';
import 'package:customer/features/push/data/devices_repository.dart';
import 'package:customer/features/push/push_bootstrap.dart';
import 'package:customer/features/rides/application/ride_session.dart';
import 'package:customer/features/rides/presentation/ride_history_tab.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(rideSessionProvider.notifier).refreshActive();
      await bootstrapPush(ref);
      final loc = await Permission.locationWhenInUse.status;
      final notif = await Permission.notification.status;
      await ref.read(devicesRepositoryProvider).syncPermissions(
            locationPermission: loc.isGranted
                ? 'whileInUse'
                : loc.isPermanentlyDenied
                    ? 'denied'
                    : 'unknown',
            notificationPermission: notif.isGranted ? 'granted' : notif.isDenied ? 'denied' : 'unknown',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      const _HomeTab(),
      const RideHistoryTab(),
      Center(child: Text(l10n.wallet)),
      const _AccountTab(),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: PrilaBottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
        labels: [l10n.homeTitle, l10n.myRides, l10n.wallet, l10n.account],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final cfg = ref.watch(bootstrapProvider).valueOrNull;
    final services = [...(cfg?.services ?? [])]..sort((a, b) => a.order.compareTo(b.order));
    final active = ref.watch(rideSessionProvider).valueOrNull;
    final flags = cfg?.flags ?? {};

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PrilaAppHeader(
            greeting: l10n.hello('Rider'),
            onBell: () => context.push('/notifications'),
          ),
          const SizedBox(height: 4),
          if (cfg?.cityName != null)
            Text(cfg!.cityName!, style: Theme.of(context).textTheme.bodySmall),
          if (cfg?.promoEnabled == true) ...[
            const SizedBox(height: 12),
            PrilaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cfg!.promoTitle ?? 'Prila',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (cfg.promoBody != null) ...[
                    const SizedBox(height: 4),
                    Text(cfg.promoBody!),
                  ],
                ],
              ),
            ),
          ],
          if (active != null) ...[
            const SizedBox(height: 12),
            PrilaCard(
              onTap: () {
                final id = active['id'] as String?;
                if (id != null) context.push('/ride/$id');
              },
              child: Row(
                children: [
                  Icon(Icons.two_wheeler_rounded, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.activeRideBanner, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(active['status']?.toString() ?? ''),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
          if (flags['coupons'] == true || flags['student_coupon'] == true || flags['prila_shakti'] == true) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (flags['coupons'] == true) Chip(label: Text(l10n.couponsOn)),
                if (flags['student_coupon'] == true) Chip(label: Text(l10n.studentCoupon)),
                if (flags['prila_shakti'] == true) Chip(label: Text(l10n.prilaShakti)),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final s in services)
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 52) / 2,
                  child: PrilaCard(
                    onTap: () => context.push(
                      '/book?type=${Uri.encodeComponent(s.type)}&name=${Uri.encodeComponent(s.name)}',
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          s.type == 'auto'
                              ? Icons.airport_shuttle_rounded
                              : s.type == 'bike'
                                  ? Icons.two_wheeler_rounded
                                  : Icons.inventory_2_rounded,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountTab extends ConsumerWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeProvider);
    return SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(l10n.account, style: Theme.of(context).textTheme.headlineSmall),
          ),
          SettingsTile(
            label: l10n.darkMode,
            leading: const Icon(Icons.dark_mode_outlined),
            trailing: Switch(
              value: mode == ThemeMode.dark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
            ),
            onTap: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          SettingsTile(label: l10n.language, leading: const Icon(Icons.language)),
          SettingsTile(
            label: l10n.support,
            leading: const Icon(Icons.support_agent),
            onTap: () {
              final phone = ref.read(bootstrapProvider).valueOrNull?.supportPhone;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(phone ?? l10n.support)),
              );
            },
          ),
          SettingsTile(
            label: l10n.sos,
            leading: Icon(Icons.emergency_rounded, color: context.prilaColors.danger),
            danger: true,
            onTap: () async {
              try {
                await ref.read(devicesRepositoryProvider).triggerSos();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sosSent)));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
          ),
          SettingsTile(
            label: l10n.logOut,
            leading: Icon(Icons.logout, color: context.prilaColors.danger),
            danger: true,
            onTap: () async {
              await ref.read(authRepositoryProvider).logout();
              ref.invalidate(authSessionProvider);
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

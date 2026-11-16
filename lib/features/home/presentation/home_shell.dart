import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/config/bootstrap_models.dart';
import 'package:customer/core/config/bootstrap_provider.dart';
import 'package:customer/core/location/location_service.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/theme/theme_mode_controller.dart';
import 'package:customer/core/widgets/prila_app_header.dart';
import 'package:customer/core/widgets/prila_bottom_nav.dart';
import 'package:customer/core/widgets/prila_card.dart';
import 'package:customer/core/widgets/service_icon.dart';
import 'package:customer/features/booking/application/booking_draft.dart';
import 'package:customer/features/places/data/places_repository.dart';
import 'package:customer/features/places/domain/place.dart';
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

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  @override
  void initState() {
    super.initState();
    // Ask the server whether the rider is inside the service area (display hint only).
    // No permission prompt here: onboarding already asked; search asks again if needed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = await ref.read(locationServiceProvider).current(request: false);
      if (loc is LocationOk && mounted) {
        await ref.read(bootstrapProvider.notifier).refresh(lat: loc.position.latitude, lng: loc.position.longitude);
      }
    });
  }

  List<ServiceTile> _services(BootstrapConfig? cfg) =>
      [...(cfg?.services ?? const <ServiceTile>[])]..sort((a, b) => a.order.compareTo(b.order));

  void _book(ServiceTile? service, {PlacePoint? drop}) {
    if (service == null) return;
    ref.read(bookingDraftProvider.notifier).start(serviceType: service.type, serviceName: service.name, drop: drop);
    context.push('/book');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final text = Theme.of(context).textTheme;
    final cfg = ref.watch(bootstrapProvider).valueOrNull;
    final services = _services(cfg);
    final primary = services.isEmpty ? null : services.first;
    final big = services.take(2).toList();
    final rest = services.skip(2).toList();
    final active = ref.watch(rideSessionProvider).valueOrNull;
    final mine = ref.watch(myPlacesProvider).valueOrNull ?? const MyPlaces();
    final flags = cfg?.flags ?? {};

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myPlacesProvider);
          await ref.read(rideSessionProvider.notifier).refreshActive();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            PrilaAppHeader(
              greeting: l10n.hello('Rider'),
              onBell: () => context.push('/notifications'),
            ),
            if (active != null) ...[
              const SizedBox(height: 16),
              _ActiveRideCard(
                serviceType: active['serviceType']?.toString() ?? 'bike',
                onTap: () {
                  final id = active['id'] as String?;
                  if (id != null) context.push('/ride/$id');
                },
              ),
            ],
            if (cfg?.inServiceArea == false && cfg?.serviceAreaMessage != null) ...[
              const SizedBox(height: 16),
              _Notice(icon: Icons.wrong_location_outlined, text: cfg!.serviceAreaMessage!),
            ],
            const SizedBox(height: 20),
            _WhereToBar(label: l10n.whereTo, onTap: () => _book(primary)),
            const SizedBox(height: 20),
            Row(
              children: [
                for (var i = 0; i < big.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: _ServiceTileCard(
                      icon: serviceIcon(big[i].type),
                      label: big[i].name,
                      tall: true,
                      onTap: () => _book(big[i]),
                    ),
                  ),
                ],
              ],
            ),
            for (final s in rest) ...[
              const SizedBox(height: 12),
              _ServiceTileCard(icon: serviceIcon(s.type), label: s.name, onTap: () => _book(s)),
            ],
            if (mine.saved.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  for (var i = 0; i < mine.saved.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _SavedChip(
                        icon: mine.saved[i].label == SavedLabel.home ? Icons.home_rounded : Icons.work_rounded,
                        label: mine.saved[i].label == SavedLabel.home ? l10n.savedHome : l10n.savedWork,
                        subtitle: mine.saved[i].place.name,
                        onTap: () => _book(primary, drop: mine.saved[i].place),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (mine.recents.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(l10n.recentPlaces, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              for (final r in mine.recents.take(3))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 60,
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.border.withValues(alpha: 0.6),
                    child: Icon(Icons.history_rounded, size: 20, color: text.bodyLarge?.color),
                  ),
                  title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: r.address.isEmpty ? null : Text(r.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _book(primary, drop: r),
                ),
            ],
            if (cfg?.promoEnabled == true) ...[
              const SizedBox(height: 20),
              PrilaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cfg!.promoTitle ?? 'Prila', style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (cfg.promoBody != null) ...[const SizedBox(height: 4), Text(cfg.promoBody!)],
                  ],
                ),
              ),
            ],
            if (flags['coupons'] == true || flags['student_coupon'] == true || flags['prila_shakti'] == true) ...[
              const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}

class _WhereToBar extends StatelessWidget {
  const _WhereToBar({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                TripDot(color: colors.drop, square: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(Icons.search_rounded, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceTileCard extends StatelessWidget {
  const _ServiceTileCard({required this.icon, required this.label, required this.onTap, this.tall = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    final iconBox = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 30, color: colors.primary),
    );
    final name = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: tall ? 120 : 76,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: tall
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [iconBox, name],
                )
              : Row(
                  children: [
                    iconBox,
                    const SizedBox(width: 14),
                    Expanded(child: name),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SavedChip extends StatelessWidget {
  const _SavedChip({required this.icon, required this.label, required this.subtitle, required this.onTap});
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveRideCard extends StatelessWidget {
  const _ActiveRideCard({required this.serviceType, required this.onTap});
  final String serviceType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(serviceIcon(serviceType), color: Colors.white, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.activeRideBanner,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
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

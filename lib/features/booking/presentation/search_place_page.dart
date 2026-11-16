import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/config/bootstrap_provider.dart';
import 'package:customer/core/errors/app_failure.dart';
import 'package:customer/core/location/location_service.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/service_icon.dart';
import 'package:customer/features/booking/application/booking_draft.dart';
import 'package:customer/features/places/data/places_repository.dart';
import 'package:customer/features/places/domain/place.dart';
import 'package:customer/l10n/app_localizations.dart';

/// set_route: choose pickup + drop. Free sources first (current location, saved,
/// recents, ops landmarks); Google only when typing and local results are thin.
class SearchPlacePage extends ConsumerStatefulWidget {
  const SearchPlacePage({super.key, this.focus = TripEnd.drop});
  final TripEnd focus;

  @override
  ConsumerState<SearchPlacePage> createState() => _SearchPlacePageState();
}

enum _SearchIssue { none, offline, unavailable }

class _SearchPlacePageState extends ConsumerState<SearchPlacePage> {
  final _pickupCtrl = TextEditingController();
  final _dropCtrl = TextEditingController();
  final _pickupFocus = FocusNode();
  final _dropFocus = FocusNode();

  late TripEnd _active = widget.focus;
  String _sessionToken = PlacesRepository.newSessionToken();
  Timer? _debounce;
  CancelToken? _inflight;
  var _seq = 0;

  List<PlaceSuggestion> _results = const [];
  var _searching = false;
  var _issue = _SearchIssue.none;
  int? _resolving; // index of the row being resolved (Place Details)

  LocationResult? _location;
  var _locating = false;
  var _advanced = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingDraftProvider);
    _pickupFocus.addListener(() => _onFocus(TripEnd.pickup, _pickupFocus));
    _dropFocus.addListener(() => _onFocus(TripEnd.drop, _dropFocus));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Localizations can't be read in initState — fill the fields on the first frame.
      if (!mounted) return;
      _syncFields(draft);
      (_active == TripEnd.pickup ? _pickupFocus : _dropFocus).requestFocus();
      if (draft.pickup == null || draft.pickupIsCurrentLocation) _useCurrentLocation();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _inflight?.cancel();
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _pickupFocus.dispose();
    _dropFocus.dispose();
    super.dispose();
  }

  // ---------- helpers
  TextEditingController get _ctrl => _active == TripEnd.pickup ? _pickupCtrl : _dropCtrl;

  void _syncFields(BookingDraft d) {
    final l10n = _l10nOrNull;
    _pickupCtrl.text = d.pickupIsCurrentLocation
        ? (l10n?.currentLocation ?? d.pickup?.name ?? '')
        : (d.pickup?.name ?? '');
    _dropCtrl.text = d.drop?.name ?? '';
  }

  AppLocalizations? get _l10nOrNull => mounted ? AppLocalizations.of(context) : null;

  void _onFocus(TripEnd end, FocusNode node) {
    if (!node.hasFocus) return;
    setState(() {
      _active = end;
      _results = const [];
      _issue = _SearchIssue.none;
    });
    final c = end == TripEnd.pickup ? _pickupCtrl : _dropCtrl;
    // Select all so typing replaces the chosen place (Uber/Rapido behaviour).
    c.selection = TextSelection(baseOffset: 0, extentOffset: c.text.length);
  }

  // ---------- current location
  /// Asks for permission when needed (the permissions screen already explained why).
  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    final loc = await ref.read(locationServiceProvider).current();
    if (!mounted) return;
    setState(() {
      _location = loc;
      _locating = false;
    });
    if (loc is! LocationOk) return;
    final l10n = AppLocalizations.of(context);
    String? address;
    try {
      address = await ref.read(placesRepositoryProvider).reverse(loc.position.latitude, loc.position.longitude);
    } catch (_) {
      address = null; // still usable: we have coordinates
    }
    if (!mounted) return;
    ref.read(bookingDraftProvider.notifier).setPoint(
          TripEnd.pickup,
          PlacePoint(
            name: l10n.currentLocation,
            address: address ?? '',
            lat: loc.position.latitude,
            lng: loc.position.longitude,
          ),
          isCurrentLocation: true,
        );
    _pickupCtrl.text = l10n.currentLocation;
    if (_active == TripEnd.pickup) _dropFocus.requestFocus();
    // Rider opened search with a drop already chosen (saved / recent on home).
    _maybeAdvance();
  }

  // ---------- typing
  void _onChanged(String text) {
    _debounce?.cancel();
    final cfg = ref.read(bootstrapProvider).valueOrNull;
    final minChars = cfg?.searchMinChars ?? 3;
    final q = text.trim();
    if (q.length < minChars) {
      _inflight?.cancel();
      setState(() {
        _results = const [];
        _searching = false;
        _issue = _SearchIssue.none;
      });
      return;
    }
    _debounce = Timer(Duration(milliseconds: cfg?.searchDebounceMs ?? 400), () => _search(q));
    setState(() {}); // refresh local matches immediately
  }

  Future<void> _search(String q) async {
    _inflight?.cancel();
    final token = CancelToken();
    _inflight = token;
    final seq = ++_seq;
    setState(() {
      _searching = true;
      _issue = _SearchIssue.none;
    });
    final near = ref.read(bookingDraftProvider).pickup ?? _locationPoint;
    try {
      final r = await ref.read(placesRepositoryProvider).autocomplete(
            query: q,
            sessionToken: _sessionToken,
            lat: near?.lat,
            lng: near?.lng,
            cancelToken: token,
          );
      if (!mounted || seq != _seq) return; // stale response
      setState(() {
        _results = r;
        _searching = false;
      });
    } catch (e) {
      if (!mounted || seq != _seq || token.isCancelled) return;
      setState(() {
        _searching = false;
        _results = const [];
        _issue = e is NetworkFailure ? _SearchIssue.offline : _SearchIssue.unavailable;
      });
    }
  }

  PlacePoint? get _locationPoint {
    final l = _location;
    return l is LocationOk
        ? PlacePoint(name: '', address: '', lat: l.position.latitude, lng: l.position.longitude)
        : null;
  }

  // ---------- choosing
  Future<void> _choose(PlacePoint p) async {
    ref.read(bookingDraftProvider.notifier).setPoint(_active, p);
    (_active == TripEnd.pickup ? _pickupCtrl : _dropCtrl).text = p.name;
    setState(() {
      _results = const [];
      _issue = _SearchIssue.none;
    });
    _sessionToken = PlacesRepository.newSessionToken(); // session ends on selection
    final d = ref.read(bookingDraftProvider);
    if (_active == TripEnd.pickup && d.drop == null) {
      _dropFocus.requestFocus();
      return;
    }
    if (_active == TripEnd.drop && d.pickup == null) {
      _pickupFocus.requestFocus();
      return;
    }
    _advanced = false;
    _maybeAdvance();
  }

  Future<void> _chooseSuggestion(int index, PlaceSuggestion s) async {
    final resolved = s.resolved;
    if (resolved != null) return _choose(resolved);
    if (s.placeId == null || _resolving != null) return;
    setState(() => _resolving = index);
    try {
      final p = await ref
          .read(placesRepositoryProvider)
          .place(placeId: s.placeId!, name: s.mainText, sessionToken: _sessionToken);
      if (!mounted) return;
      setState(() => _resolving = null);
      await _choose(PlacePoint(name: s.mainText, address: p.address, lat: p.lat, lng: p.lng));
    } catch (e) {
      if (!mounted) return;
      setState(() => _resolving = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is AppFailure ? e.message : AppLocalizations.of(context).errorGeneric)),
      );
    }
  }

  void _maybeAdvance() {
    final d = ref.read(bookingDraftProvider);
    if (!d.routeReady || _advanced || !mounted) return;
    _advanced = true;
    FocusScope.of(context).unfocus();
    context.push('/book/confirm').then((_) {
      if (!mounted) return;
      _advanced = false;
      _syncFields(ref.read(bookingDraftProvider));
    });
  }

  Future<void> _openMap() async {
    FocusScope.of(context).unfocus();
    final ok = await context.push<bool>('/book/map?end=${_active.name}');
    if (ok != true || !mounted) return;
    final d = ref.read(bookingDraftProvider);
    _syncFields(d);
    if (_active == TripEnd.pickup && d.drop == null) {
      _dropFocus.requestFocus();
    } else {
      _advanced = false;
      _maybeAdvance();
    }
  }

  Future<void> _saveAs(PlacePoint p) async {
    final l10n = AppLocalizations.of(context);
    final label = await showModalBottomSheet<SavedLabel>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: Text(l10n.saveAsHome),
              onTap: () => Navigator.pop(ctx, SavedLabel.home),
            ),
            ListTile(
              leading: const Icon(Icons.work_rounded),
              title: Text(l10n.saveAsWork),
              onTap: () => Navigator.pop(ctx, SavedLabel.work),
            ),
          ],
        ),
      ),
    );
    if (label == null || !mounted) return;
    try {
      await ref.read(placesRepositoryProvider).save(label, p);
      ref.invalidate(myPlacesProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.savedPlaceDone)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is AppFailure ? e.message : l10n.errorGeneric)),
        );
      }
    }
  }

  // ---------- UI
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final draft = ref.watch(bookingDraftProvider);
    final mine = ref.watch(myPlacesProvider).valueOrNull ?? const MyPlaces();
    final q = _ctrl.text.trim();
    final typing = q.isNotEmpty && !(_active == TripEnd.pickup && draft.pickupIsCurrentLocation && q == l10n.currentLocation) &&
        q != (_active == TripEnd.pickup ? draft.pickup?.name : draft.drop?.name);

    final locals = <PlacePoint>[
      for (final s in mine.saved) s.place,
      for (final r in mine.recents)
        if (!mine.saved.any((s) => s.place.sameSpot(r))) r,
    ];
    final ql = q.toLowerCase();
    final localMatches =
        typing ? locals.where((p) => p.name.toLowerCase().contains(ql) || p.address.toLowerCase().contains(ql)).take(3).toList() : const <PlacePoint>[];
    final hasGoogle = _results.any((r) => r.source == SuggestionSource.google);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Icon(serviceIcon(draft.serviceType), size: 22, color: colors.primary),
            const SizedBox(width: 8),
            Flexible(child: Text(draft.serviceName, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: Column(
        children: [
          _RouteInputs(
            pickupCtrl: _pickupCtrl,
            dropCtrl: _dropCtrl,
            pickupFocus: _pickupFocus,
            dropFocus: _dropFocus,
            active: _active,
            onChanged: _onChanged,
            onSwap: draft.routeReady
                ? () {
                    ref.read(bookingDraftProvider.notifier).swap();
                    _syncFields(ref.read(bookingDraftProvider));
                    setState(() {});
                  }
                : null,
            onClear: () {
              _ctrl.clear();
              _onChanged('');
            },
          ),
          if (_searching) const LinearProgressIndicator(minHeight: 2) else const SizedBox(height: 2),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (_active == TripEnd.pickup || draft.pickup == null) _locationRow(l10n),
                _ActionRow(
                  icon: Icons.location_searching_rounded,
                  title: l10n.setOnMap,
                  onTap: _openMap,
                ),
                const Divider(height: 1),
                if (!typing) ...[
                  for (final s in mine.saved)
                    _PlaceRow(
                      icon: s.label == SavedLabel.home ? Icons.home_rounded : Icons.work_rounded,
                      title: s.label == SavedLabel.home ? l10n.savedHome : l10n.savedWork,
                      subtitle: s.place.address.isNotEmpty ? s.place.address : s.place.name,
                      onTap: () => _choose(s.place),
                    ),
                  if (mine.recents.isNotEmpty) _SectionLabel(l10n.recentPlaces),
                  for (final r in mine.recents)
                    if (!mine.saved.any((s) => s.place.sameSpot(r)))
                      _PlaceRow(
                        icon: Icons.history_rounded,
                        title: r.name,
                        subtitle: r.address,
                        onTap: () => _choose(r),
                        onSave: () => _saveAs(r),
                        saveTooltip: l10n.saveAsHome,
                      ),
                ] else ...[
                  for (final p in localMatches)
                    _PlaceRow(icon: Icons.history_rounded, title: p.name, subtitle: p.address, onTap: () => _choose(p)),
                  for (var i = 0; i < _results.length; i++)
                    _PlaceRow(
                      icon: _results[i].source == SuggestionSource.landmark
                          ? Icons.star_rounded
                          : Icons.location_on_outlined,
                      title: _results[i].mainText,
                      subtitle: _results[i].secondaryText,
                      busy: _resolving == i,
                      onTap: () => _chooseSuggestion(i, _results[i]),
                    ),
                  if (_issue == _SearchIssue.offline)
                    _InlineNotice(icon: Icons.wifi_off_rounded, text: l10n.noInternet, action: l10n.retry, onAction: () => _search(q))
                  else if (_issue == _SearchIssue.unavailable)
                    _InlineNotice(icon: Icons.map_outlined, text: l10n.searchUnavailable, action: l10n.setOnMap, onAction: _openMap)
                  else if (!_searching &&
                      _results.isEmpty &&
                      localMatches.isEmpty &&
                      q.length >= (ref.read(bootstrapProvider).valueOrNull?.searchMinChars ?? 3) &&
                      _debounce?.isActive != true)
                    _InlineNotice(icon: Icons.search_off_rounded, text: l10n.noPlacesFound, action: l10n.setOnMap, onAction: _openMap),
                  if (hasGoogle)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Text(
                        l10n.poweredByGoogle,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow(AppLocalizations l10n) {
    final loc = _location;
    if (_locating) {
      return _ActionRow(icon: Icons.my_location_rounded, title: l10n.currentLocation, busy: true, onTap: () {});
    }
    final svc = ref.read(locationServiceProvider);
    return switch (loc) {
      LocationServiceOff() => _InlineNotice(
          icon: Icons.location_disabled_rounded,
          text: l10n.locationOffTitle,
          action: l10n.turnOnLocation,
          onAction: () async {
            await svc.openLocationSettings();
            if (mounted) _useCurrentLocation();
          },
        ),
      LocationDeniedForever() => _InlineNotice(
          icon: Icons.location_off_rounded,
          text: l10n.locationNeeded,
          action: l10n.openSettings,
          onAction: svc.openAppSettings,
        ),
      LocationDenied() => _InlineNotice(
          icon: Icons.location_off_rounded,
          text: l10n.locationNeeded,
          action: l10n.allowLocation,
          onAction: () => _useCurrentLocation(),
        ),
      _ => _ActionRow(
          icon: Icons.my_location_rounded,
          title: l10n.useCurrentLocation,
          onTap: () {
            _active = TripEnd.pickup;
            _useCurrentLocation();
          },
        ),
    };
  }
}

// ---------------------------------------------------------------- widgets

class _RouteInputs extends StatelessWidget {
  const _RouteInputs({
    required this.pickupCtrl,
    required this.dropCtrl,
    required this.pickupFocus,
    required this.dropFocus,
    required this.active,
    required this.onChanged,
    required this.onSwap,
    required this.onClear,
  });

  final TextEditingController pickupCtrl;
  final TextEditingController dropCtrl;
  final FocusNode pickupFocus;
  final FocusNode dropFocus;
  final TripEnd active;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSwap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Column(
            children: [
              TripDot(color: colors.pickup),
              Container(width: 2, height: 30, margin: const EdgeInsets.symmetric(vertical: 4), color: colors.border),
              TripDot(color: colors.drop, square: true),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _field(context, pickupCtrl, pickupFocus, l10n.searchPickupHint, active == TripEnd.pickup),
                Divider(height: 1, color: colors.border),
                _field(context, dropCtrl, dropFocus, l10n.searchDropHint, active == TripEnd.drop),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.swapPlaces,
            onPressed: onSwap,
            icon: const Icon(Icons.swap_vert_rounded),
          ),
        ],
      ),
    );
  }

  Widget _field(BuildContext context, TextEditingController c, FocusNode f, String hint, bool isActive) {
    return TextField(
      controller: c,
      focusNode: f,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: isActive ? FontWeight.w600 : FontWeight.w400),
      decoration: InputDecoration(
        hintText: hint,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        suffixIcon: isActive && c.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onClear,
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              )
            : null,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.title, required this.onTap, this.busy = false});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    return ListTile(
      minTileHeight: 56,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        child: busy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon, color: colors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: busy ? null : onTap,
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onSave,
    this.saveTooltip,
    this.busy = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final String? saveTooltip;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    return ListTile(
      minTileHeight: 64,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: colors.border.withValues(alpha: 0.6),
        child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: busy
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : onSave != null
              ? IconButton(icon: const Icon(Icons.bookmark_add_outlined), tooltip: saveTooltip, onPressed: onSave)
              : null,
      onTap: busy ? null : onTap,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.icon, required this.text, required this.action, required this.onAction});
  final IconData icon;
  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}

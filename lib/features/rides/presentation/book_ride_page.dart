import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/config/bootstrap_provider.dart';
import 'package:customer/core/errors/app_failure.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/prila_card.dart';
import 'package:customer/core/widgets/prila_gradient_button.dart';
import 'package:customer/features/rides/application/ride_session.dart';
import 'package:customer/features/rides/data/ride_repository.dart';
import 'package:customer/l10n/app_localizations.dart';

class BookRidePage extends ConsumerStatefulWidget {
  const BookRidePage({super.key, required this.serviceType, required this.serviceName});

  final String serviceType;
  final String serviceName;

  @override
  ConsumerState<BookRidePage> createState() => _BookRidePageState();
}

class _BookRidePageState extends ConsumerState<BookRidePage> {
  final _pickupCtrl = TextEditingController(text: 'Warangal Railway Station');
  final _dropCtrl = TextEditingController(text: 'Kakatiya University');
  final _couponCtrl = TextEditingController();

  // Demo coords (Warangal) — map picker comes with Places proxy later.
  static const _pickup = (lat: 17.9689, lng: 79.5941);
  static const _drop = (lat: 17.995, lng: 79.55);

  Map<String, dynamic>? _quote;
  var _loading = false;
  var _shakti = false;
  String? _error;

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _estimate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref.read(rideRepositoryProvider).estimate(
            serviceType: widget.serviceType,
            pickupLat: _pickup.lat,
            pickupLng: _pickup.lng,
            pickupName: _pickupCtrl.text.trim(),
            dropLat: _drop.lat,
            dropLng: _drop.lng,
            dropName: _dropCtrl.text.trim(),
            couponCode: _couponCtrl.text.trim().isEmpty ? null : _couponCtrl.text.trim(),
            shakti: _shakti,
          );
      setState(() => _quote = data);
    } catch (e) {
      setState(() => _error = e is AppFailure ? e.message : e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _book() async {
    final quoteId = _quote?['quoteId'] as String?;
    if (quoteId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ride = await ref.read(rideRepositoryProvider).book(
            quoteId: quoteId,
            idempotencyKey:
                'book-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
          );
      final id = ride['id'] as String?;
      await ref.read(rideSessionProvider.notifier).refreshActive();
      if (id != null && mounted) context.go('/ride/$id');
    } catch (e) {
      setState(() => _error = e is AppFailure ? e.message : e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _inr(int? paise) => '₹${((paise ?? 0) / 100).toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final flags = ref.watch(bootstrapProvider).valueOrNull?.flags ?? {};
    final fare = (_quote?['fare'] as Map?)?.cast<String, dynamic>();
    final shaktiFlag = flags['prila_shakti'] == true;
    final couponsFlag = flags['coupons'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PrilaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.pickup, style: TextStyle(color: colors.pickup, fontWeight: FontWeight.w600)),
                TextField(
                  controller: _pickupCtrl,
                  decoration: InputDecoration(hintText: l10n.pickupHint),
                ),
                const SizedBox(height: 12),
                Text(l10n.drop, style: TextStyle(color: colors.drop, fontWeight: FontWeight.w600)),
                TextField(
                  controller: _dropCtrl,
                  decoration: InputDecoration(hintText: l10n.dropHint),
                ),
              ],
            ),
          ),
          if (couponsFlag) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _couponCtrl,
              decoration: InputDecoration(
                labelText: l10n.couponCode,
                hintText: 'FIRST100',
              ),
            ),
          ],
          if (shaktiFlag) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.prilaShakti),
              subtitle: Text(l10n.prilaShaktiHint),
              value: _shakti,
              onChanged: (v) => setState(() => _shakti = v),
            ),
          ],
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: TextStyle(color: colors.danger)),
            ),
          if (fare != null)
            PrilaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.fareEstimate, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    _inr((fare['totalPaise'] as num?)?.toInt()),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if ((fare['discountPaise'] as num?)?.toInt() != null &&
                      (fare['discountPaise'] as num).toInt() > 0)
                    Text(
                      '${l10n.discount}: −${_inr((fare['discountPaise'] as num).toInt())}',
                      style: TextStyle(color: colors.pickup),
                    ),
                  Text(
                    '${((_quote?['distanceM'] as num?)?.toDouble() ?? 0) / 1000} km · '
                    '${(((_quote?['durationSec'] as num?)?.toInt() ?? 0) / 60).round()} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(l10n.cashOnly, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          const SizedBox(height: 20),
          if (_quote == null)
            PrilaGradientButton(label: l10n.getEstimate, onPressed: _loading ? null : _estimate, loading: _loading)
          else ...[
            PrilaGradientButton(label: l10n.findRide, onPressed: _loading ? null : _book, loading: _loading),
            TextButton(onPressed: _loading ? null : _estimate, child: Text(l10n.refreshEstimate)),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer/core/errors/app_failure.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/prila_gradient_button.dart';
import 'package:customer/features/rides/data/ride_repository.dart';
import 'package:customer/l10n/app_localizations.dart';

class RateRidePage extends ConsumerStatefulWidget {
  const RateRidePage({super.key, required this.rideId});
  final String rideId;

  @override
  ConsumerState<RateRidePage> createState() => _RateRidePageState();
}

class _RateRidePageState extends ConsumerState<RateRidePage> {
  var _rating = 5;
  final _tags = <String>{};
  var _busy = false;

  static const _options = ['polite', 'safe', 'on_time', 'clean_vehicle'];

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await ref.read(rideRepositoryProvider).rate(widget.rideId, _rating, _tags.toList());
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is AppFailure ? e.message : e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.rateRide)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.howWasRide, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (i) {
                final n = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = n),
                  icon: Icon(
                    n <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: n <= _rating ? colors.primary : colors.border,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final t in _options)
                  FilterChip(
                    label: Text(t.replaceAll('_', ' ')),
                    selected: _tags.contains(t),
                    onSelected: (v) => setState(() {
                      if (v) {
                        _tags.add(t);
                      } else {
                        _tags.remove(t);
                      }
                    }),
                  ),
              ],
            ),
            const Spacer(),
            PrilaGradientButton(label: l10n.submitRating, onPressed: _busy ? null : _submit, loading: _busy),
          ],
        ),
      ),
    );
  }
}

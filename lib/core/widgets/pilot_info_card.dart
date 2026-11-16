import 'package:flutter/material.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/prila_card.dart';
import 'package:customer/features/rides/domain/ride_view.dart';
import 'package:customer/l10n/app_localizations.dart';

/// "Who is coming": photo, name, rating and the number plate, big enough to match
/// against the vehicle at the pickup. Never shows the pilot's phone number.
class PilotInfoCard extends StatelessWidget {
  const PilotInfoCard({super.key, required this.pilot});

  /// `ride.pilot` from the API: {name, vehicleType, vehicleNumber, rating, ratingCount, photoUrl}.
  final Map<String, dynamic> pilot;

  String _vehicleLabel(AppLocalizations l10n, String? type) => switch (type) {
        'bike' => l10n.vehicleBike,
        'auto' => l10n.vehicleAuto,
        'parcel' => l10n.vehicleParcel,
        'logistics' => l10n.vehicleLogistics,
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.prilaColors;
    final text = Theme.of(context).textTheme;
    final name = (pilot['name'] as String?)?.trim();
    final rating = (pilot['rating'] as num?)?.toDouble();
    final plate = formatVehicleNumber(pilot['vehicleNumber'] as String?);
    final vehicle = _vehicleLabel(l10n, pilot['vehicleType'] as String?);

    return PrilaCard(
      child: Semantics(
        container: true,
        label: [l10n.yourPilot, ?name, if (plate.isNotEmpty) plate].join(', '),
        child: Row(
          children: [
            _PilotPhoto(url: pilot['photoUrl'] as String?),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name?.isNotEmpty == true ? name! : l10n.yourPilot,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (rating != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded, size: 18, color: colors.brandGradient.colors.first),
                        const SizedBox(width: 2),
                        Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                  if (vehicle.isNotEmpty)
                    Text(vehicle, style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
                  if (plate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _Plate(number: plate),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Number plate look: white plate, dark border, bold spaced letters (readable at arm's length).
class _Plate extends StatelessWidget {
  const _Plate({required this.number});
  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF16161F), width: 1.5),
      ),
      child: Text(
        number,
        style: const TextStyle(
          color: Color(0xFF16161F),
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Keeps the first signed URL for a photo: the link's signature changes on every poll,
/// the photo does not — so we don't re-download or flicker every 2 seconds.
class _PilotPhoto extends StatefulWidget {
  const _PilotPhoto({required this.url});
  final String? url;

  @override
  State<_PilotPhoto> createState() => _PilotPhotoState();
}

class _PilotPhotoState extends State<_PilotPhoto> {
  String? _url;
  String? _identity;

  @override
  void initState() {
    super.initState();
    _url = widget.url;
    _identity = photoIdentity(widget.url);
  }

  @override
  void didUpdateWidget(covariant _PilotPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    final id = photoIdentity(widget.url);
    if (id != _identity) {
      _identity = id;
      _url = widget.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    final fallback = Icon(Icons.person_rounded, color: colors.primary, size: 34);
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withValues(alpha: 0.12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _url == null
          ? fallback
          : Image.network(
              _url!,
              key: ValueKey(_identity),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
            ),
    );
  }
}

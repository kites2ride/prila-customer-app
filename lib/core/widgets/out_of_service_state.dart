import 'package:flutter/material.dart';
import 'package:customer/core/theme/prila_theme.dart';
import 'package:customer/core/widgets/prila_card.dart';

/// Friendly "we're not here yet" card (not an error screen).
/// [message] comes from the server (`zones.*Message` config) so ops can change it.
class OutOfServiceState extends StatelessWidget {
  const OutOfServiceState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Server error code for this state.
  static const code = 'OUT_OF_SERVICE_AREA';

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.prilaColors;
    final text = Theme.of(context).textTheme;
    return PrilaCard(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wrong_location_outlined, size: 30, color: colors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

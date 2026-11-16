import 'package:flutter/material.dart';

/// One icon per service everywhere (home tiles, fare screen, tracking).
IconData serviceIcon(String type) => switch (type) {
      'bike' => Icons.two_wheeler_rounded,
      'auto' => Icons.electric_rickshaw_rounded,
      'parcel' => Icons.inventory_2_rounded,
      'logistics' => Icons.local_shipping_rounded,
      _ => Icons.directions_car_rounded,
    };

/// Small coloured dot used for pickup (green) / drop (pink) everywhere.
class TripDot extends StatelessWidget {
  const TripDot({super.key, required this.color, this.size = 12, this.square = false});
  final Color color;
  final double size;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(2) : null,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 4)],
      ),
    );
  }
}

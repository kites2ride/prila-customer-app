import 'package:flutter/material.dart';

/// Brand asset paths. Masters (SVG) + generator live in `docs/brand/`;
/// PNGs here are rendered from them in 1x / 2.0x / 3.0x variants.
abstract final class PrilaBrandAssets {
  static const wordmarkOnLight = 'assets/brand/prila-wordmark-light.png';
  static const wordmarkOnDark = 'assets/brand/prila-wordmark-dark.png';
  static const lockupOnDark = 'assets/brand/prila-lockup-dark.png';
  static const mark = 'assets/brand/prila-mark.png';

  /// Brand name is never translated.
  static const semanticName = 'Prila';
}

/// The "prila" wordmark (gradient p). Picks the ink colour for the current
/// theme brightness unless [onDark] forces a variant (e.g. on the splash).
class PrilaWordmark extends StatelessWidget {
  const PrilaWordmark({super.key, this.height = 28, this.onDark});

  final double height;
  final bool? onDark;

  @override
  Widget build(BuildContext context) {
    final dark = onDark ?? Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      dark ? PrilaBrandAssets.wordmarkOnDark : PrilaBrandAssets.wordmarkOnLight,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: PrilaBrandAssets.semanticName,
    );
  }
}

/// Three-swoosh brand mark (transparent background).
class PrilaMark extends StatelessWidget {
  const PrilaMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      PrilaBrandAssets.mark,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
  }
}

/// Wordmark + "The People's Ride" tagline. Designed for dark canvases only.
class PrilaLockup extends StatelessWidget {
  const PrilaLockup({super.key, this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      PrilaBrandAssets.lockupOnDark,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: PrilaBrandAssets.semanticName,
    );
  }
}

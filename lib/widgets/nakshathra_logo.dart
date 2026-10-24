import 'package:flutter/material.dart';

/// Renders the official Nakshathra Gold & Diamonds full logo
class NakshathraLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool isDark;
  final bool useGold;
  final Color? color;
  final BoxFit fit;

  const NakshathraLogo({
    super.key,
    this.width,
    this.height,
    this.isDark = false,
    this.useGold = false,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = useGold
        ? 'assets/images/nakshathra_logo_gold.png'
        : isDark
            ? 'assets/images/nakshathra_logo_dark.png'
            : 'assets/images/nakshathra_logo_white.png';

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      filterQuality: FilterQuality.high,
    );
  }
}

/// Renders the official Nakshathra mark (the top emblem/diamond loop)
class NakshathraLogoMark extends StatelessWidget {
  final double size;
  final bool isDark;
  final bool useGold;
  final Color? color;

  const NakshathraLogoMark({
    super.key,
    this.size = 64,
    this.isDark = false,
    this.useGold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = useGold
        ? 'assets/images/nakshathra_mark_gold.png'
        : isDark
            ? 'assets/images/nakshathra_mark_dark.png'
            : 'assets/images/nakshathra_mark_white.png';

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      filterQuality: FilterQuality.high,
    );
  }
}

/// Brand header used on auth & onboarding screens (Login, Create Account)
class NakshathraBrandHeader extends StatelessWidget {
  final double width;
  final bool isDark;
  final bool useGold;

  const NakshathraBrandHeader({
    super.key,
    this.width = 180,
    this.isDark = false,
    this.useGold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NakshathraLogo(
        width: width,
        isDark: isDark,
        useGold: useGold,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NakshathraLogoMark extends StatelessWidget {
  final double size;
  final Color? color;

  const NakshathraLogoMark({
    super.key,
    this.size = 64,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NakshathraLogoPainter(
          strokeColor: color ?? Colors.white.withOpacity(0.92),
          sparkleColor: color ?? const Color(0xFFF3E5AB),
        ),
      ),
    );
  }
}

class _NakshathraLogoPainter extends CustomPainter {
  final Color strokeColor;
  final Color sparkleColor;

  _NakshathraLogoPainter({
    required this.strokeColor,
    required this.sparkleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer stylized loop / monogram shape
    final path = Path();

    // Start near bottom left, loop upwards diagonally to top right and around
    path.moveTo(w * 0.32, h * 0.72);
    path.lineTo(w * 0.72, h * 0.32);
    
    // Top right curve turning down
    path.quadraticBezierTo(w * 0.88, h * 0.48, w * 0.70, h * 0.70);
    // Bottom curve turning back up left
    path.quadraticBezierTo(w * 0.52, h * 0.88, w * 0.30, h * 0.70);
    // Left curve turning up
    path.quadraticBezierTo(w * 0.12, h * 0.52, w * 0.30, h * 0.30);
    // Top curve joining towards inner
    path.quadraticBezierTo(w * 0.48, h * 0.12, w * 0.68, h * 0.30);

    canvas.drawPath(path, paint);

    // Diamond facet/sparkle mark at top right (diamond star icon)
    final sparkCenter = Offset(w * 0.78, h * 0.15);
    final sparkRadius = w * 0.09;

    final sparkPath = Path();
    sparkPath.moveTo(sparkCenter.dx, sparkCenter.dy - sparkRadius);
    sparkPath.quadraticBezierTo(
        sparkCenter.dx, sparkCenter.dy, sparkCenter.dx + sparkRadius, sparkCenter.dy);
    sparkPath.quadraticBezierTo(
        sparkCenter.dx, sparkCenter.dy, sparkCenter.dx, sparkCenter.dy + sparkRadius);
    sparkPath.quadraticBezierTo(
        sparkCenter.dx, sparkCenter.dy, sparkCenter.dx - sparkRadius, sparkCenter.dy);
    sparkPath.quadraticBezierTo(
        sparkCenter.dx, sparkCenter.dy, sparkCenter.dx, sparkCenter.dy - sparkRadius);
    sparkPath.close();

    final sparkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(sparkPath, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _NakshathraLogoPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.sparkleColor != sparkleColor;
  }
}

class NakshathraBrandHeader extends StatelessWidget {
  const NakshathraBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NakshathraLogoMark(size: 68),
        const SizedBox(height: 14),
        // Brand Title with spaced capital lettering
        Text(
          "N A K S H A T H R A",
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.0,
            fontFamily: 'OpenSans',
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle "GOLD & DIAMONDS"
        Text(
          "G O L D   &   D I A M O N D S",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.2,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }
}

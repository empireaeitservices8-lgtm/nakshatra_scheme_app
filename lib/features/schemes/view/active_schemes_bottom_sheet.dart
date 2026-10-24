import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../home/model/my_schemes_model.dart';
import '../../home/view_model/home_view_model.dart';
import 'scheme_detail_screen.dart';

class ActiveSchemesBottomSheet extends StatelessWidget {
  final List<MySchemeDataModel>? apiSchemes;
  final List<ActiveScheme>? schemes;

  const ActiveSchemesBottomSheet({
    super.key,
    this.apiSchemes,
    this.schemes,
  });

  static Future<void> show(
    BuildContext context, {
    List<MySchemeDataModel>? apiSchemes,
    List<ActiveScheme>? fallbackSchemes,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActiveSchemesBottomSheet(
        apiSchemes: apiSchemes,
        schemes: fallbackSchemes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasApiSchemes = apiSchemes != null && apiSchemes!.isNotEmpty;
    final hasFallbackSchemes = schemes != null && schemes!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1627),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title + Close Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "All Active Schemes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'OpenSans',
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Schemes List
          if (hasApiSchemes)
            ...apiSchemes!.map(
              (scheme) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildApiSchemeItem(context, scheme),
              ),
            )
          else if (hasFallbackSchemes)
            ...schemes!.map(
              (scheme) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFallbackSchemeItem(context, scheme),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No active enrolled schemes found.",
                  style: TextStyle(
                    color: Color(0xFF8E9DB5),
                    fontSize: 14,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildApiSchemeItem(BuildContext context, MySchemeDataModel scheme) {
    return Material(
      color: const Color(0xFF142036),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            SchemeDetailScreen.routeName,
            arguments: scheme.id,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Scheme Image Thumbnail or Gold Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 54,
                  height: 54,
                  color: const Color(0xFF1E2D44),
                  child: scheme.fullImageUrl != null
                      ? Image.network(
                          scheme.fullImageUrl!,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
                        )
                      : _buildFallbackThumbnail(),
                ),
              ),

              const SizedBox(width: 14),

              // Scheme Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.planName ?? "Gold Savings Scheme",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'OpenSans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Duration: ${scheme.duration ?? '11 Months'}",
                      style: const TextStyle(
                        color: Color(0xFF8E9DB5),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Monthly Due: ${scheme.formattedMonthlyInstallment}",
                      style: const TextStyle(
                        color: Color(0xFFE5B869),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Chevron Arrow
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFE5B869),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return const Center(
      child: Icon(
        Icons.savings_rounded,
        color: Color(0xFFE5B869),
        size: 26,
      ),
    );
  }

  Widget _buildFallbackSchemeItem(BuildContext context, ActiveScheme scheme) {
    return Material(
      color: const Color(0xFF142036),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, SchemeDetailScreen.routeName);
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Scheme Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'OpenSans',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Duration: ${scheme.duration}",
                      style: const TextStyle(
                        color: Color(0xFF8E9DB5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Monthly Due: ${scheme.monthlyDue}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5B869),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Next Payment: ${scheme.nextPaymentDate}",
                          style: const TextStyle(
                            color: Color(0xFFE5B869),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Circular Progress Ring
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(64, 64),
                      painter: _BottomSheetProgressPainter(
                        progress: scheme.progressPercent,
                        trackColor: const Color(0xFF22324D),
                        progressColor: const Color(0xFFE5B869),
                        strokeWidth: 6.0,
                      ),
                    ),
                    Text(
                      "${(scheme.progressPercent * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'OpenSans',
                      ),
                    ),
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

class _BottomSheetProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _BottomSheetProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BottomSheetProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

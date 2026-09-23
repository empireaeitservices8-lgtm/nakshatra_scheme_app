import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/popular_plans_model.dart';
import '../view_model/schemes_view_model.dart';
import 'join_scheme_screen.dart';

class SchemesScreen extends StatelessWidget {
  static const String routeName = '/schemes';

  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SchemesViewModel>(
      create: (_) => SchemesViewModel(),
      child: const _SchemesScreenContent(),
    );
  }
}

class _SchemesScreenContent extends StatelessWidget {
  const _SchemesScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<SchemesViewModel>(
      builder: (context, viewModel, _) {
        return RefreshIndicator(
          onRefresh: () async => viewModel.fetchPopularPlans(),
          color: const Color(0xFFC89332),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 120, // space for floating bottom navbar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section
                _buildHeader(),

                const SizedBox(height: 24),

                // 2. Dynamic Popular Plan Cards or Loading Skeleton
                if (viewModel.isLoadingPlans && viewModel.popularPlans.isEmpty)
                  _buildLoadingPlansPlaceholder()
                else if (viewModel.popularPlans.isNotEmpty)
                  ...viewModel.popularPlans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildDynamicPlanCard(context, plan),
                      ))
                else ...[
                  // Fallback hardcoded plan cards if offline / empty
                  _buildFixedWeightPlanCard(context),
                  const SizedBox(height: 20),
                  _buildValueBasedPlanCard(context),
                  const SizedBox(height: 20),
                ],

                // 3. Investment Calculator Card
                _buildInvestmentCalculatorCard(context, viewModel),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 1. HEADER SECTION
  // ==========================================
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Explore Schemes",
          style: TextStyle(
            color: Color(0xFF0D1627),
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Choose a smart option to convert cash into solid gold weight or jewelry securely.",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w400,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }

  // ==========================================
  // LOADING PLACEHOLDER
  // ==========================================
  Widget _buildLoadingPlansPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC89332)),
              strokeWidth: 2.5,
            ),
            SizedBox(height: 12),
            Text(
              "Loading scheme plans...",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontFamily: 'OpenSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DYNAMIC POPULAR PLAN CARD
  // ==========================================
  Widget _buildDynamicPlanCard(BuildContext context, PopularPlanDataModel plan) {
    final isFixed = plan.isFixedWeight ||
        (plan.title?.toLowerCase().contains("fixed") ?? false);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Icon / Image & Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPlanBadge(plan, isFixed),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  plan.title ?? (isFixed ? "Fixed Weight Gold Plan" : "Maturity Bonus Plan"),
                  style: const TextStyle(
                    color: Color(0xFF0D1627),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Plan Description
          Text(
            plan.description ??
                (isFixed
                    ? "Every payment converts directly to gold weight based on the live market gold price on the day of payment."
                    : "Save a fixed monthly currency budget. At the maturity of the savings cycle, buy jewelry with zero making charges."),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13.5,
              height: 1.5,
              fontFamily: 'OpenSans',
            ),
          ),

          const SizedBox(height: 18),

          // Bullet Points based on type
          if (isFixed) ...[
            _buildBulletItem("Hedge against market price fluctuations"),
            const SizedBox(height: 10),
            _buildBulletItem("Grams calculated instantly with live ticker price"),
            const SizedBox(height: 10),
            _buildBulletItem("Flexible options: 11, 18, or 24 months duration"),
          ] else ...[
            _buildBulletItem("Maturity bonus added at termination"),
            const SizedBox(height: 10),
            _buildBulletItem("Zero making charges on jewelry redemption"),
            const SizedBox(height: 10),
            _buildBulletItem("Flexible budgeting custom sliders"),
          ],

          const SizedBox(height: 22),

          // Action Button
          _buildJoinButton(
            label: plan.actionLabel ?? "Configure & Join Scheme",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JoinSchemeScreen(
                    initialSchemeType: isFixed ? 0 : 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlanBadge(PopularPlanDataModel plan, bool isFixed) {
    if (plan.fullImageUrl != null && plan.fullImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 46,
          height: 46,
          color: const Color(0xFFFEF6E4),
          child: Image.network(
            plan.fullImageUrl!,
            width: 46,
            height: 46,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackIconBadge(isFixed),
          ),
        ),
      );
    }
    return _buildFallbackIconBadge(isFixed);
  }

  Widget _buildFallbackIconBadge(bool isFixed) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0xFFFEF6E4),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isFixed
            ? CustomPaint(
                size: const Size(24, 24),
                painter: _GoldScalesPainter(),
              )
            : const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFFC89332),
                size: 24,
              ),
      ),
    );
  }

  // ==========================================
  // 2. FIXED WEIGHT GOLD PLAN CARD (Fallback)
  // ==========================================
  Widget _buildFixedWeightPlanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF6E4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(24, 24),
                    painter: _GoldScalesPainter(),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  "Fixed Weight Gold Plan",
                  style: TextStyle(
                    color: Color(0xFF0D1627),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Every payment converts directly to gold weight based on the live market gold price on the day of payment. Fully hedge against gold price inflation and lock in your savings weight.",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13.5,
              height: 1.5,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(height: 18),
          _buildBulletItem("Hedge against market price fluctuations"),
          const SizedBox(height: 10),
          _buildBulletItem("Grams calculated instantly with live ticker price"),
          const SizedBox(height: 10),
          _buildBulletItem("Flexible options: 11, 18, or 24 months duration"),
          const SizedBox(height: 22),
          _buildJoinButton(
            label: "Configure & Join Scheme",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const JoinSchemeScreen(initialSchemeType: 0),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. VALUE BASED SAVINGS PLAN CARD (Fallback)
  // ==========================================
  Widget _buildValueBasedPlanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF6E4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFFC89332),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  "Value Based Savings Plan",
                  style: TextStyle(
                    color: Color(0xFF0D1627),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Save a fixed monthly currency budget. At the maturity of the savings cycle, buy jewelry, gold coins, or bars with a 100% discount on making charges plus special cash bonuses.",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13.5,
              height: 1.5,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(height: 18),
          _buildBulletItem("Maturity bonus added at termination"),
          const SizedBox(height: 10),
          _buildBulletItem("Zero making charges on jewelry redemption"),
          const SizedBox(height: 10),
          _buildBulletItem("Flexible budgeting custom sliders"),
          const SizedBox(height: 22),
          _buildJoinButton(
            label: "Configure & Join Scheme",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const JoinSchemeScreen(initialSchemeType: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. INVESTMENT CALCULATOR CARD
  // ==========================================
  Widget _buildInvestmentCalculatorCard(
    BuildContext context,
    SchemesViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1627).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Calculator Icon + Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3B840),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.calculate_rounded,
                    color: Color(0xFF0D1627),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Investment Calculator",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Subtitle
          const Text(
            "Slide the monthly budget controller to project gold weight accumulation using the live gold price ticker:",
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              height: 1.45,
              fontFamily: 'OpenSans',
            ),
          ),

          const SizedBox(height: 20),

          // Monthly Installment Metric (Gold Accent)
          Center(
            child: Text(
              "Monthly Installment: ${viewModel.formattedMonthlyBudget}",
              style: const TextStyle(
                color: Color(0xFFE5B869),
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                fontFamily: 'OpenSans',
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Estimated Accumulation Pill Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF162238),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Text(
                "Est. Accumulation: ${viewModel.formattedEstAccumulation}",
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'OpenSans',
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Slider with discrete tick dots
          _buildBudgetSlider(context, viewModel),

          // Min / Max Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "₹5k",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSans',
                  ),
                ),
                Text(
                  "₹50k",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDER COMPONENT
  // ==========================================
  Widget _buildBudgetSlider(BuildContext context, SchemesViewModel viewModel) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4.0,
        activeTrackColor: const Color(0xFFE5B869),
        inactiveTrackColor: const Color(0xFF24334B),
        thumbColor: const Color(0xFFE5B869),
        overlayColor: const Color(0xFFE5B869).withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10.0,
          elevation: 4,
        ),
        trackShape: const _CustomTrackWithDotsShape(),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
      ),
      child: Slider(
        value: viewModel.monthlyBudget,
        min: viewModel.minBudget,
        max: viewModel.maxBudget,
        onChanged: (val) {
          viewModel.updateMonthlyBudget(val);
        },
      ),
    );
  }

  // ==========================================
  // REUSABLE BULLET ITEM
  // ==========================================
  Widget _buildBulletItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 19,
          height: 19,
          decoration: const BoxDecoration(
            color: Color(0xFF22C55E),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // REUSABLE JOIN BUTTON
  // ==========================================
  Widget _buildJoinButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF0D1627),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE5B869),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTERS & SHAPES
// ==========================================

class _GoldScalesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = const Color(0xFFC89332)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFC89332)
      ..style = PaintingStyle.fill;

    // Center vertical pillar
    canvas.drawLine(Offset(w * 0.5, h * 0.2), Offset(w * 0.5, h * 0.85), paint);

    // Top fulcrum point
    canvas.drawCircle(Offset(w * 0.5, h * 0.2), 2.2, fillPaint);

    // Top horizontal crossbar
    canvas.drawLine(Offset(w * 0.18, h * 0.32), Offset(w * 0.82, h * 0.32), paint);

    // Left Pan suspension cords
    canvas.drawLine(Offset(w * 0.18, h * 0.32), Offset(w * 0.1, h * 0.62), paint);
    canvas.drawLine(Offset(w * 0.18, h * 0.32), Offset(w * 0.26, h * 0.62), paint);
    // Left Pan bowl
    final leftPan = Path();
    leftPan.moveTo(w * 0.08, h * 0.62);
    leftPan.quadraticBezierTo(w * 0.18, h * 0.74, w * 0.28, h * 0.62);
    canvas.drawPath(leftPan, paint);

    // Right Pan suspension cords
    canvas.drawLine(Offset(w * 0.82, h * 0.32), Offset(w * 0.74, h * 0.62), paint);
    canvas.drawLine(Offset(w * 0.82, h * 0.32), Offset(w * 0.9, h * 0.62), paint);
    // Right Pan bowl
    final rightPan = Path();
    rightPan.moveTo(w * 0.72, h * 0.62);
    rightPan.quadraticBezierTo(w * 0.82, h * 0.74, w * 0.92, h * 0.62);
    canvas.drawPath(rightPan, paint);

    // Bottom base
    canvas.drawLine(Offset(w * 0.32, h * 0.85), Offset(w * 0.68, h * 0.85), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CustomTrackWithDotsShape extends RoundedRectSliderTrackShape {
  const _CustomTrackWithDotsShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final dotPaint = Paint()
      ..color = const Color(0xFF64748B).withOpacity(0.55)
      ..style = PaintingStyle.fill;

    const dotCount = 9;
    final step = trackRect.width / (dotCount - 1);

    for (int i = 0; i < dotCount; i++) {
      final dx = trackRect.left + (step * i);
      final dy = trackRect.center.dy;
      if ((dx - thumbCenter.dx).abs() > 8) {
        context.canvas.drawCircle(Offset(dx, dy), 1.6, dotPaint);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/scheme_details_model.dart';
import '../view_model/scheme_details_view_model.dart';
import 'checkout_screen.dart';

class SchemeDetailScreen extends StatefulWidget {
  static const String routeName = '/scheme-detail';
  final int? enrollmentId;

  const SchemeDetailScreen({super.key, this.enrollmentId});

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _shimmerController;
  late final SchemeDetailsViewModel _viewModel;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _viewModel = SchemeDetailsViewModel();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      int targetId = 1;
      if (widget.enrollmentId != null) {
        targetId = widget.enrollmentId!;
      } else if (args is int) {
        targetId = args;
      } else if (args is String) {
        targetId = int.tryParse(args) ?? 1;
      }
      _viewModel.fetchSchemeDetails(targetId);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final details = _viewModel.schemeDetails;
        final title = details?.planName ?? "Scheme Details";

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF7F8FA),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0D1627),
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: true,
              title: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0D1627),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'OpenSans',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF0D1627),
                    size: 22,
                  ),
                  onPressed: () => _viewModel.refresh(),
                ),
              ],
            ),
            body: _buildBody(context, details),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SchemeDetailsDataModel? details) {
    if (_viewModel.isLoading && details == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4A346),
        ),
      );
    }

    if (_viewModel.errorMessage != null && details == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE11D48),
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                _viewModel.errorMessage ?? "Failed to load scheme details",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0D1627),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _viewModel.refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1627),
                  foregroundColor: const Color(0xFFE5B869),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFD4A346),
      onRefresh: () async {
        _viewModel.refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Hero Summary Card (Dark Navy)
            _buildSummaryCard(details),

            const SizedBox(height: 28),

            // 2. Installment Timeline Title
            const Text(
              "Installment Timeline",
              style: TextStyle(
                color: Color(0xFF0D1627),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'OpenSans',
              ),
            ),

            const SizedBox(height: 20),

            // 3. Timeline Items with Connected Track
            _buildTimeline(context, details),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. TOP HERO SUMMARY CARD
  // ==========================================
  Widget _buildSummaryCard(SchemeDetailsDataModel? details) {
    final currency = details?.currencySymbol ?? "₹";
    final totalInvested = details?.totalInvested != null
        ? "$currency${details!.totalInvested}"
        : "₹0";
    final installmentDue = details?.installmentDue != null
        ? "$currency${details!.installmentDue}"
        : "₹0";
    final nextDue = details?.nextDueMonth ?? "-";
    final progressText = details?.progressText ??
        "${details?.paidCount ?? 0} / ${details?.totalCount ?? 0} Paid";
    final progressFraction = details?.progressFraction ?? 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1627).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // 3-Column Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCol("Total Invested", totalInvested),
              _buildDivider(),
              _buildStatCol("Installment Due", installmentDue),
              _buildDivider(),
              _buildStatCol("Next Due Month", nextDue),
            ],
          ),

          const SizedBox(height: 20),

          // Horizontal Subtle Divider
          Divider(
            color: Colors.white.withOpacity(0.08),
            thickness: 1,
            height: 1,
          ),

          const SizedBox(height: 18),

          // Progress Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Scheme Maturity Progress",
                style: TextStyle(
                  color: Color(0xFF8E9DB5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'OpenSans',
                ),
              ),
              Text(
                progressText,
                style: const TextStyle(
                  color: Color(0xFFE5B869),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Horizontal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: const Color(0xFF1E2B42),
                ),
                FractionallySizedBox(
                  widthFactor: progressFraction > 0 ? progressFraction : 0.0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE5B869), Color(0xFFD4A346)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E9DB5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'OpenSans',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE5B869),
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.08),
    );
  }

  // ==========================================
  // 2. TIMELINE COMPONENT
  // ==========================================
  Widget _buildTimeline(BuildContext context, SchemeDetailsDataModel? details) {
    final timeline = details?.timeline ?? [];

    if (timeline.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            "No timeline installments recorded yet.",
            style: TextStyle(
              color: Color(0xFF8E9DB5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(timeline.length, (index) {
        final item = timeline[index];
        final isFirst = index == 0;
        final isLast = index == timeline.length - 1;

        if (item.isActiveMonth && item.canPay) {
          return _buildAnimatedDueCard(
            context: context,
            item: item,
            isFirst: isFirst,
            isLast: isLast,
          );
        }

        final isPaid = item.isPaid;
        final isUpcoming = item.isUpcoming;
        final currency = item.currencySymbol ?? details?.currencySymbol ?? "₹";

        Color indicatorColor = const Color(0xFF94A3B8);
        Color badgeBgColor = const Color(0xFFF1F5F9);
        Color badgeTextColor = const Color(0xFF64748B);

        if (isPaid) {
          indicatorColor = const Color(0xFF22C55E);
          badgeBgColor = const Color(0xFFE8F8F0);
          badgeTextColor = const Color(0xFF10B981);
        } else if (isUpcoming) {
          indicatorColor = const Color(0xFF38BDF8);
          badgeBgColor = const Color(0xFFE0F2FE);
          badgeTextColor = const Color(0xFF0284C7);
        }

        final amountDisplay = item.amount != null ? "$currency${item.amount}" : "-";

        return _buildTimelineTile(
          context: context,
          isFirst: isFirst,
          isLast: isLast,
          indicatorColor: indicatorColor,
          isNodeActive: false,
          card: _buildTimelineCard(
            title: item.period ?? "-",
            subtitle: isPaid
                ? "Paid: ${item.date ?? '-'}"
                : (isUpcoming ? "Scheduled: ${item.date ?? 'Upcoming'}" : "${item.date ?? '-'}"),
            badgeLabel: item.statusTag ?? item.status ?? (isPaid ? "Paid" : "Upcoming"),
            badgeBgColor: badgeBgColor,
            badgeTextColor: badgeTextColor,
            trailingWidget: Text(
              amountDisplay,
              style: TextStyle(
                color: isPaid ? const Color(0xFF0D1627) : const Color(0xFF8E9DB5),
                fontSize: isPaid ? 15 : 16,
                fontWeight: isPaid ? FontWeight.w800 : FontWeight.w700,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        );
      }),
    );
  }

  // ==========================================
  // ANIMATED DUE CARD FOR ACTIVE PAYMENT
  // ==========================================
  Widget _buildAnimatedDueCard({
    required BuildContext context,
    required SchemeTimelineItemModel item,
    required bool isFirst,
    required bool isLast,
  }) {
    final currency = item.currencySymbol ?? "₹";
    final amountText = item.amount != null ? "$currency${item.amount}" : "$currency 0";
    final actionLabel = item.actionLabel ?? "PAY NOW";

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _shimmerController]),
      builder: (context, _) {
        final pulse = _pulseAnimation.value;
        final shimmer = _shimmerController.value;

        return _buildTimelineTile(
          context: context,
          isFirst: isFirst,
          isLast: isLast,
          indicatorColor: const Color(0xFFE5B869),
          isNodeActive: true,
          activePulseValue: pulse,
          card: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color.lerp(
                  const Color(0xFFE5B869).withOpacity(0.5),
                  const Color(0xFFD4A346),
                  pulse,
                )!,
                width: 1.5 + (0.8 * pulse),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE5B869).withOpacity(0.12 + (0.22 * pulse)),
                  blurRadius: 14 + (10 * pulse),
                  spreadRadius: 1 + (2 * pulse),
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Gentle radiant shimmer light sweep
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ShimmerSweepPainter(shimmerProgress: shimmer),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.period ?? "Active Installment",
                                  style: const TextStyle(
                                    color: Color(0xFF0D1627),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'OpenSans',
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_rounded,
                                      color: Color(0xFFD97706),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Due: ${item.date ?? 'Active Month'}",
                                      style: TextStyle(
                                        color: const Color(0xFFD97706),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'OpenSans',
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFFF59E0B)
                                                .withOpacity(0.3 * pulse),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withOpacity(0.4 * pulse),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                item.statusTag ?? item.status ?? "Not Paid",
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Bottom Row: Amount + Animated Pay Now Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Due Amount",
                                  style: TextStyle(
                                    color: Color(0xFF8E9DB5),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'OpenSans',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  amountText,
                                  style: const TextStyle(
                                    color: Color(0xFF0D1627),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'OpenSans',
                                  ),
                                ),
                              ],
                            ),

                            // Pulsing interactive Pay Now Button
                            Transform.scale(
                              scale: 1.0 + (0.03 * pulse),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4A346)
                                          .withOpacity(0.35 + (0.25 * pulse)),
                                      blurRadius: 10 + (6 * pulse),
                                      spreadRadius: pulse * 1.5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      CheckoutScreen.routeName,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4A346),
                                    foregroundColor: const Color(0xFF0D1627),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    actionLabel,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineTile({
    required BuildContext context,
    required bool isFirst,
    required bool isLast,
    required Color indicatorColor,
    required bool isNodeActive,
    double activePulseValue = 0.0,
    required Widget card,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Timeline Line with Indicator Node
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vertical Line
                Positioned(
                  top: isFirst ? 36 : 0,
                  bottom: isLast ? 36 : 0,
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                // Indicator Node
                Positioned(
                  top: 30,
                  child: isNodeActive
                      ? Container(
                          width: 20 + (4 * activePulseValue),
                          height: 20 + (4 * activePulseValue),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFEF3C7),
                            border: Border.all(
                              color: indicatorColor,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: indicatorColor.withOpacity(
                                  0.3 + (0.3 * activePulseValue),
                                ),
                                blurRadius: 8 + (6 * activePulseValue),
                                spreadRadius: activePulseValue * 2,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: indicatorColor,
                            ),
                          ),
                        )
                      : Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: indicatorColor,
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: card,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard({
    required String title,
    required String subtitle,
    required String badgeLabel,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required Widget trailingWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0D1627),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8E9DB5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              trailingWidget,
            ],
          ),
        ],
      ),
    );
  }
}

// Shimmer Light Sweep Painter
class _ShimmerSweepPainter extends CustomPainter {
  final double shimmerProgress;

  _ShimmerSweepPainter({required this.shimmerProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final startX = (w * 2 * shimmerProgress) - w;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          const Color(0xFFE5B869).withOpacity(0.06),
          const Color(0xFFFFF7ED).withOpacity(0.16),
          const Color(0xFFE5B869).withOpacity(0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(startX, 0, w * 0.8, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerSweepPainter oldDelegate) {
    return oldDelegate.shimmerProgress != shimmerProgress;
  }
}

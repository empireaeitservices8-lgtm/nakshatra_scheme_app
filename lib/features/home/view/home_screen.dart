import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_config.dart';
import '../../../providers/bottom_nav_provider.dart';
import '../../../utils/app_build_methods.dart';
import '../../../widgets/nakshathra_logo.dart';
import '../../schemes/model/popular_plans_model.dart';
import '../../schemes/view/active_schemes_bottom_sheet.dart';
import '../../schemes/view/scheme_detail_screen.dart';
import '../model/my_schemes_model.dart';
import '../view_model/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return RefreshIndicator(
            onRefresh: () async {
              viewModel.refreshData();
            },
            color: const Color(0xFFD4A346),
            backgroundColor: const Color(0xFF0E1A2D),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(
                left: 18,
                right: 18,
                top: 10,
                bottom: 110, // Space for floating bottom navbar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar / Header
                  _buildTopBar(context, viewModel),

                  const SizedBox(height: 18),

                  // 2. Gold Account Details Card
                  _buildGoldAccountCard(context, viewModel),

                  const SizedBox(height: 16),

                  // 3. Live Gold Price Card
                  _buildLiveGoldPriceCard(context, viewModel),

                  const SizedBox(height: 24),

                  // 4. My Active Schemes Section
                  _buildSectionHeader(
                    title: "My Active Schemes",
                    onSeeAll: () {
                      ActiveSchemesBottomSheet.show(
                        context,
                        apiSchemes: viewModel.apiMySchemes,
                        fallbackSchemes: viewModel.activeSchemes,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Active Schemes List (Dynamic API with fallback)
                  if (viewModel.isLoadingMySchemes && viewModel.apiMySchemes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC89332)),
                          strokeWidth: 2.2,
                        ),
                      ),
                    )
                  else if (viewModel.apiMySchemes.isNotEmpty)
                    ...viewModel.apiMySchemes.map(
                      (scheme) => _buildApiActiveSchemeCard(context, scheme),
                    )
                  else
                    ...viewModel.activeSchemes.map(
                      (scheme) => _buildActiveSchemeCard(context, scheme),
                    ),

                  const SizedBox(height: 24),

                  // 5. Popular Gold Savings Plans Section
                  _buildSectionHeader(
                    title: "Popular Gold Savings Plans",
                    onSeeAll: () {
                      context.read<BottomNavProvider>().setIndex(1);
                    },
                  ),

                  const SizedBox(height: 14),

                  // Popular Plans Horizontal Carousel
                  _buildPopularPlansList(context, viewModel),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // TOP BAR
  // ==========================================
  Widget _buildTopBar(BuildContext context, HomeViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Official Brand Logo & Title
        const NakshathraLogo(
          height: 38,
          isDark: true,
        ),

        // User Avatar Badge (JD)
        GestureDetector(
          onTap: () {
            context.read<BottomNavProvider>().setIndex(2);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0B1320),
              border: Border.all(
                color: const Color(0xFFE5B869),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              viewModel.userInitials,
              style: const TextStyle(
                color: Color(0xFFE5B869),
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // GOLD ACCOUNT CARD (LUXURY GOLD)
  // ==========================================
  Widget _buildGoldAccountCard(BuildContext context, HomeViewModel viewModel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE9CB76),
            Color(0xFFDEC068),
            Color(0xFFF9E49E),
            Color(0xFFD5A442),
            Color(0xFFE2BD63),
          ],
          stops: [0.0, 0.3, 0.6, 0.85, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A738).withOpacity(0.32),
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle luster waves
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(
                painter: _GoldCardLusterPainter(),
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title & Sparkle icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "GOLD ACCOUNT DETAILS",
                      style: TextStyle(
                        color: Color(0xFF4A3816),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    // Sparkles
                    CustomPaint(
                      size: const Size(20, 20),
                      painter: _SparkleIconPainter(color: const Color(0xFF3B2C10)),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Weight in Grams
                Text(
                  "${viewModel.goldWeightGrams} grams",
                  style: const TextStyle(
                    color: Color(0xFF0C1322),
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    fontFamily: 'OpenSans',
                  ),
                ),

                const SizedBox(height: 4),

                // Current Value
                Text(
                  "Current Value: ${viewModel.currencySymbol}${viewModel.currentGoldValue.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Color(0xFF141F32),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'OpenSans',
                  ),
                ),

                const SizedBox(height: 16),

                // Divider Line
                Container(
                  height: 1,
                  color: const Color(0xFF3D2C0C).withOpacity(0.12),
                ),

                const SizedBox(height: 14),

                // Bottom Row: Member Code & 99.9% Pure Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "MEMBER CODE",
                          style: TextStyle(
                            color: Color(0xFF5A4515),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          viewModel.memberCode,
                          style: const TextStyle(
                            color: Color(0xFF0C1322),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
                    ),

                    // Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1320),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        viewModel.purityText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontFamily: 'OpenSans',
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
    );
  }

  // ==========================================
  // LIVE GOLD PRICE CARD
  // ==========================================
  Widget _buildLiveGoldPriceCard(BuildContext context, HomeViewModel viewModel) {
    final isTrendingUp = viewModel.isPriceTrendingUp;
    final trendColor = isTrendingUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final formattedPrice = viewModel.liveGoldPricePerGram > 0
        ? viewModel.liveGoldPricePerGram.toStringAsFixed(0)
        : "--";
    final changeText = viewModel.goldPriceChangePercentage != 0
        ? "${viewModel.goldPriceChangePercentage >= 0 ? '+' : ''}${viewModel.goldPriceChangePercentage.toStringAsFixed(2)}% Today"
        : "0.00% Today";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Price & Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "LIVE GOLD PRICE",
                    style: TextStyle(
                      color: Color(0xFF8E9AA8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  if (viewModel.isLoadingLivePrice) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A346)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${viewModel.currencySymbol}$formattedPrice ",
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    TextSpan(
                      text: viewModel.unit,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTrendingUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: trendColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    changeText,
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Sparkline Chart
          SizedBox(
            width: 140,
            height: 60,
            child: CustomPaint(
              painter: _SparklineChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION HEADER
  // ==========================================
  Widget _buildSectionHeader({
    required String title,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            fontFamily: 'OpenSans',
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          behavior: HitTestBehavior.opaque,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "See All",
                style: TextStyle(
                  color: Color(0xFFD4A346),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD4A346),
                size: 17,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ACTIVE SCHEME CARD (DYNAMIC FROM API)
  // ==========================================
  Widget _buildApiActiveSchemeCard(BuildContext context, MySchemeDataModel scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF0E1A2D),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.pushNamed(
              context,
              SchemeDetailScreen.routeName,
              arguments: scheme.id,
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE5B869).withOpacity(0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE5B869).withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF0E1A2D).withOpacity(0.25),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Scheme Image / Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFF1E2D44),
                    child: scheme.fullImageUrl != null
                        ? Image.network(
                            scheme.fullImageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.savings_rounded,
                                color: Color(0xFFE5B869),
                                size: 28,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.savings_rounded,
                              color: Color(0xFFE5B869),
                              size: 28,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 14),

                // Scheme Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.planName ?? "Gold Savings Scheme",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'OpenSans',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Duration: ${scheme.duration ?? '11 months'}",
                        style: const TextStyle(
                          color: Color(0xFF7E8EAA),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Monthly Due: ",
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                            TextSpan(
                              text: scheme.formattedMonthlyInstallment,
                              style: const TextStyle(
                                color: Color(0xFFE5B869),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow Pill
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16233B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFE5B869),
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ACTIVE SCHEME CARD (DARK NAVY FALLBACK)
  // ==========================================
  Widget _buildActiveSchemeCard(BuildContext context, ActiveScheme scheme) {
    return Material(
      color: const Color(0xFF0E1A2D),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.pushNamed(context, SchemeDetailScreen.routeName);
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE5B869).withOpacity(0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5B869).withOpacity(0.08),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF0E1A2D).withOpacity(0.25),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          // Left: Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheme.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Duration: ${scheme.duration}",
                  style: const TextStyle(
                    color: Color(0xFF7E8EAA),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Monthly Due: ",
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      TextSpan(
                        text: scheme.monthlyDue,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5B869),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
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

          const SizedBox(width: 12),

          // Right: Circular Progress Ring
          _buildProgressRing(scheme.progressPercent),
        ],
      ),
    ),
  ),
);
}

  Widget _buildProgressRing(double percent) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(72, 72),
            painter: _CircularProgressPainter(
              progress: percent,
              trackColor: const Color(0xFF1E2D44),
              progressColor: const Color(0xFFE5B869),
              strokeWidth: 6.5,
            ),
          ),
          Text(
            "${(percent * 100).toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              fontFamily: 'OpenSans',
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // POPULAR PLANS LIST (HORIZONTAL CAROUSEL)
  // ==========================================
  Widget _buildPopularPlansList(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isLoadingPopularPlans && viewModel.apiPopularPlans.isEmpty) {
      return const SizedBox(
        height: 195,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC89332)),
            strokeWidth: 2.2,
          ),
        ),
      );
    }

    final hasApiPlans = viewModel.apiPopularPlans.isNotEmpty;
    final count = hasApiPlans ? viewModel.apiPopularPlans.length : viewModel.popularPlans.length;

    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (hasApiPlans) {
            final apiPlan = viewModel.apiPopularPlans[index];
            return _buildApiPopularPlanCard(context, apiPlan, index);
          } else {
            final plan = viewModel.popularPlans[index];
            return _buildPopularPlanCard(context, plan);
          }
        },
      ),
    );
  }

  Widget _buildApiPopularPlanCard(
    BuildContext context,
    PopularPlanDataModel plan,
    int index,
  ) {
    final isDark = index % 2 == 0;
    final isFixed = plan.isFixedWeight ||
        (plan.title?.toLowerCase().contains("fixed") ?? false);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E1A2D) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark
            ? null
            : Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF0E1A2D).withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title ?? (isFixed ? "Fixed Weight Plan" : "Maturity Bonus Plan"),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                plan.description ?? "Accumulate physical gold monthly and protect against price hikes.",
                style: TextStyle(
                  color: isDark ? const Color(0xFF8E9DB5) : const Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'OpenSans',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Explore Scheme Button
          Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isDark
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFE5B869),
                        Color(0xFFD4A346),
                      ],
                    )
                  : null,
              color: isDark ? null : const Color(0xFF0E1A2D),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFFD4A346).withOpacity(0.25)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Navigate to the Scheme (Explore) section
                  context.read<BottomNavProvider>().setIndex(1);
                },
                child: Center(
                  child: Text(
                    plan.actionLabel ?? "Explore Scheme",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF0E1A2D) : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPlanCard(BuildContext context, SchemePlan plan) {
    final isDark = plan.isDark;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E1A2D) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark
            ? null
            : Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF0E1A2D).withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'OpenSans',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                plan.description,
                style: TextStyle(
                  color: isDark ? const Color(0xFF8E9DB5) : const Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'OpenSans',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Explore Scheme Button
          Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isDark
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFE5B869),
                        Color(0xFFD4A346),
                      ],
                    )
                  : null,
              color: isDark ? null : const Color(0xFF0E1A2D),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFFD4A346).withOpacity(0.25)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context.read<BottomNavProvider>().setIndex(1);
                },
                child: Center(
                  child: Text(
                    "Explore Scheme",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF0E1A2D) : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTERS
// ==========================================

// Header Brand Diamond Mark
class _HeaderDiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(w * 0.35, h * 0.70);
    path.lineTo(w * 0.70, h * 0.35);
    path.quadraticBezierTo(w * 0.85, h * 0.50, w * 0.68, h * 0.70);
    path.quadraticBezierTo(w * 0.50, h * 0.88, w * 0.30, h * 0.68);
    path.quadraticBezierTo(w * 0.12, h * 0.50, w * 0.32, h * 0.30);
    path.quadraticBezierTo(w * 0.50, h * 0.12, w * 0.68, h * 0.32);

    canvas.drawPath(path, paint);

    // Tiny Sparkle at top
    final dotPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.82, h * 0.18), 1.6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Metallic Gold Card Luster Wave
class _GoldCardLusterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.18),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, h * 0.4);
    path.quadraticBezierTo(w * 0.45, h * 0.15, w, h * 0.65);
    path.lineTo(w, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    final path2 = Path();
    path2.moveTo(0, h * 0.75);
    path2.quadraticBezierTo(w * 0.5, h * 0.55, w, h * 0.85);
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();

    final paint2 = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Sparkle Star Icon
class _SparkleIconPainter extends CustomPainter {
  final Color color;

  _SparkleIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Big star
    _drawStar(canvas, Offset(w * 0.7, h * 0.35), 7.0, paint);
    // Small star
    _drawStar(canvas, Offset(w * 0.3, h * 0.75), 4.2, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(
      center.dx,
      center.dy,
      center.dx + radius,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx,
      center.dy,
      center.dx,
      center.dy + radius,
    );
    path.quadraticBezierTo(
      center.dx,
      center.dy,
      center.dx - radius,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx,
      center.dy,
      center.dx,
      center.dy - radius,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkleIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

// Live Gold Sparkline Chart
class _SparklineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Points matching the screenshot curve
    final path = Path();
    path.moveTo(0, h * 0.82);
    path.lineTo(w * 0.18, h * 0.72);
    path.lineTo(w * 0.38, h * 0.80);
    path.quadraticBezierTo(w * 0.65, h * 0.45, w * 0.78, h * 0.32);
    path.lineTo(w, h * 0.15);

    // Gradient fill below path
    final fillPath = Path.from(path);
    fillPath.lineTo(w, h);
    fillPath.lineTo(0, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF10B981).withOpacity(0.22),
          const Color(0xFF10B981).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line stroke
    final linePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Circular Progress Ring Painter (80%)
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track circle
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
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../helpers/sp_helper.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/nakshathra_logo.dart';
import '../../home/view/home_screen.dart';
import '../../login/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/SplashScreen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // Staggered Animation Curves
  late Animation<double> _markFade;
  late Animation<double> _markScale;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _progressValue;
  late Animation<double> _sparkleGlow;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 1. Gold Emblem Mark zooms in gently & fades
    _markFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _markScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Full Brand Title slides up smoothly
    _titleFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Tagline & Bottom Elements
    _taglineFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.55, 0.9, curve: Curves.easeIn),
    );

    // 4. Sleek Progress Bar loading
    _progressValue = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
    );

    // 5. Ambient sparkle breathing
    _sparkleGlow = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.85, curve: Curves.easeInOut),
    );

    _animController.forward();

    // Safely load saved theme in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<ThemeProvider>().applySavedTheme(context);
      } catch (e) {
        debugPrint("Theme restore error: $e");
      }
    });

    // Check saved session and auto-route after splash delay
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final startTime = DateTime.now();

    // Check if user has active session in local storage
    bool userLoggedIn = false;
    try {
      userLoggedIn = await SpHelper.isLoggedIn();
    } catch (e) {
      debugPrint("⚠️ [SplashScreen] Error checking login session: $e");
    }

    // Keep splash animation visible for smooth cinematic timing
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final delayRemaining = 2400 - elapsed;
    if (delayRemaining > 0) {
      await Future.delayed(Duration(milliseconds: delayRemaining));
    }

    if (!mounted) return;

    if (userLoggedIn) {
      debugPrint(
          "✅ [SplashScreen] Active user session found. Navigating directly to Home.");
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      debugPrint(
          "ℹ️ [SplashScreen] No active session found. Navigating to Login.");
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: const Color(0xFF050811),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A1122),
                Color(0xFF070C18),
                Color(0xFF050811),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // 1. Subtle Celestial Stars / Gold Dust Background
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _sparkleGlow,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _CelestialStarsPainter(
                          glow: _sparkleGlow.value,
                        ),
                      );
                    },
                  ),
                ),

                // 2. Center Brand Presentation
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Golden Logo Mark with soft golden aura
                      FadeTransition(
                        opacity: _markFade,
                        child: ScaleTransition(
                          scale: _markScale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Soft golden ambient glow
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFE5B869).withValues(alpha: 0.25),
                                      const Color(0xFFD4AF37).withValues(alpha: 0.08),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.45, 1.0],
                                  ),
                                ),
                              ),
                              // Logo Mark
                              const NakshathraLogoMark(
                                size: 76,
                                useGold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Brand Typography Logo
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: const NakshathraLogo(
                            width: 210,
                            isDark: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Bottom Sleek Minimal Progress & Tagline
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 42,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ultra-slim golden progress line
                        Container(
                          width: 130,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          alignment: Alignment.centerLeft,
                          child: AnimatedBuilder(
                            animation: _progressValue,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                widthFactor: _progressValue.value.clamp(0.0, 1.0),
                                child: Container(
                                  height: 2.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9E7730),
                                        Color(0xFFE5B869),
                                        Color(0xFFFFF0B8),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE5B869).withValues(alpha: 0.5),
                                        blurRadius: 6,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Clean Luxury Tagline
                        Text(
                          "PURITY  •  TRUST  •  TRANSPARENCY",
                          style: TextStyle(
                            color: const Color(0xFFE5B869).withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.2,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
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
}

/// Custom painter for subtle, elegant starry diamond dust
class _CelestialStarsPainter extends CustomPainter {
  final double glow;

  _CelestialStarsPainter({required this.glow});

  static const List<Offset> _starPositions = [
    Offset(0.18, 0.22),
    Offset(0.82, 0.19),
    Offset(0.28, 0.42),
    Offset(0.74, 0.38),
    Offset(0.14, 0.68),
    Offset(0.86, 0.64),
    Offset(0.50, 0.14),
    Offset(0.38, 0.82),
    Offset(0.65, 0.78),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (glow <= 0.0) return;

    for (int i = 0; i < _starPositions.length; i++) {
      final pos = _starPositions[i];
      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      final radius = (i % 2 == 0) ? 1.4 : 1.0;
      final opacity = ((i.isEven ? 0.35 : 0.22) * glow).clamp(0.0, 1.0);

      // Star point
      final starPaint = Paint()
        ..color = const Color(0xFFFFF2B2).withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, starPaint);

      // Delicate sparkle aura
      if (i % 3 == 0) {
        final auraPaint = Paint()
          ..color = const Color(0xFFE5B869).withValues(alpha: opacity * 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, radius * 3.2, auraPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CelestialStarsPainter oldDelegate) {
    return oldDelegate.glow != glow;
  }
}

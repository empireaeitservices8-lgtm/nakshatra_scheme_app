import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../helpers/sp_helper.dart';
import '../../../providers/language_provider.dart';
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
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
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

    // Keep splash animation visible for minimum of 2 seconds
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final delayRemaining = 2000 - elapsed;
    if (delayRemaining > 0) {
      await Future.delayed(Duration(milliseconds: delayRemaining));
    }

    if (!mounted) return;

    if (userLoggedIn) {
      debugPrint("✅ [SplashScreen] Active user session found. Navigating directly to Home.");
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      debugPrint("ℹ️ [SplashScreen] No active session found. Navigating to Login.");
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
        systemNavigationBarColor: const Color(0xFF060A13),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF080E1C),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF080E1C),
                Color(0xFF0E1729),
                Color(0xFF0A101D),
                Color(0xFF060A13),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Center Brand Monogram & Title
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NakshathraLogo(
                            width: 220,
                            isDark: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Tagline & Subtle Progress
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 36,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE5B869),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Purity • Trust • Transparency",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                            letterSpacing: 1.2,
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

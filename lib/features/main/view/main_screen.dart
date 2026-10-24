import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../config/app_config.dart';
import '../../../providers/bottom_nav_provider.dart';
import '../../home/view/home_screen.dart';
import '../../profile/view/profile_screen.dart';
import '../../schemes/view/schemes_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';

  const MainScreen({super.key});

  static GlobalKey<MainScreenState> get bottomNavKey =>
      AppConfig.bottomNavigationKey;

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SchemesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = context.read<BottomNavProvider>().currentIndex;
  }

  void setTabIndex(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
      context.read<BottomNavProvider>().setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerIndex = context.watch<BottomNavProvider>().currentIndex;
    final activeIndex = providerIndex != _currentIndex ? providerIndex : _currentIndex;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Stack(
          children: [
            // IndexedStack preserves state across all tabs
            SafeArea(
              bottom: false,
              child: IndexedStack(
                index: activeIndex,
                children: _screens,
              ),
            ),

            // Floating Bottom Navigation Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: _buildFloatingBottomNavBar(context, activeIndex),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FLOATING BOTTOM NAVIGATION BAR
  // ==========================================
  Widget _buildFloatingBottomNavBar(BuildContext context, int activeIndex) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1320),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Home Tab
          _buildNavItem(
            index: 0,
            isSelected: activeIndex == 0,
            label: "Home",
            icon: Icons.grid_view_rounded,
            onTap: () => setTabIndex(0),
          ),

          // 2. Schemes Tab
          _buildNavItem(
            index: 1,
            isSelected: activeIndex == 1,
            label: "Schemes",
            icon: Icons.explore_rounded,
            onTap: () => setTabIndex(1),
          ),

          // 3. Profile Tab
          _buildNavItem(
            index: 2,
            isSelected: activeIndex == 2,
            label: "Profile",
            icon: Icons.person_rounded,
            onTap: () => setTabIndex(2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF192538),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color(0xFFE5B869),
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                label,
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
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          icon,
          color: const Color(0xFF8E9DB5),
          size: 23,
        ),
      ),
    );
  }
}

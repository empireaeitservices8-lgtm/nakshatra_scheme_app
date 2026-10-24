import 'package:flutter/material.dart';

import '../features/main/view/main_screen.dart';
import '../utils/enums.dart';

class AppConfig {
  static const appName = "Nakshatra Scheme";
  static const bundleId = "nakshthra.schemeapp";
  static const designWidth = 393;
  static const designHeight = 852;
  static const appLogo = "assets/images/app_logo.png";

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  static final GlobalKey<MainScreenState> bottomNavigationKey =
      GlobalKey<MainScreenState>();
  static bool isDebugMode = true;

  static EnumBuildEnvironment server = EnumBuildEnvironment.dg;
}

import 'package:flutter/material.dart';

import '../features/main/view/main_screen.dart';
import '../utils/enums.dart';

class AppConfig {
  static const appName = "Nakshathra Gold";
  static const bundleId = "com.nakshthra.schemeapp";
  static const designWidth = 375;
  static const designHeight = 812;

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  static final GlobalKey<MainScreenState> bottomNavigationKey =
      GlobalKey<MainScreenState>();
  static bool isDebugMode = true;

  static EnumBuildEnvironment server = EnumBuildEnvironment.dg;
}

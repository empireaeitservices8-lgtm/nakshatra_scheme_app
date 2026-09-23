import 'package:flutter/material.dart';
import 'package:nakshathra_scheme_app/config/app_config.dart';
import 'package:nakshathra_scheme_app/features/create_account/view/create_account_screen.dart';
import 'package:nakshathra_scheme_app/features/home/view/home_screen.dart';
import 'package:nakshathra_scheme_app/features/login/view/login_screen.dart';
import 'package:nakshathra_scheme_app/features/main/view/main_screen.dart';
import 'package:nakshathra_scheme_app/features/profile/view/profile_screen.dart';
import 'package:nakshathra_scheme_app/features/profile/view/reset_password_screen.dart';
import 'package:nakshathra_scheme_app/features/profile/view/support_faq_screen.dart';
import 'package:nakshathra_scheme_app/features/schemes/view/checkout_screen.dart';
import 'package:nakshathra_scheme_app/features/schemes/view/join_scheme_screen.dart';
import 'package:nakshathra_scheme_app/features/schemes/view/scheme_detail_screen.dart';
import 'package:nakshathra_scheme_app/features/schemes/view/schemes_screen.dart';
import 'package:nakshathra_scheme_app/features/splashscreen/view/splashscreen.dart';
import 'package:nakshathra_scheme_app/utils/connection_failed_screen.dart';

Map<String, Widget Function(BuildContext context)> appRoutes() => {
      SplashScreen.routeName: (context) => const SplashScreen(),
      LoginScreen.routeName: (context) => const LoginScreen(),
      CreateAccountScreen.routeName: (context) => const CreateAccountScreen(),
      HomeScreen.routeName: (context) =>
          MainScreen(key: AppConfig.bottomNavigationKey),
      MainScreen.routeName: (context) =>
          MainScreen(key: AppConfig.bottomNavigationKey),
      SchemesScreen.routeName: (context) => const SchemesScreen(),
      ProfileScreen.routeName: (context) => const ProfileScreen(),
      SchemeDetailScreen.routeName: (context) => const SchemeDetailScreen(),
      CheckoutScreen.routeName: (context) => const CheckoutScreen(),
      JoinSchemeScreen.routeName: (context) => const JoinSchemeScreen(),
      SupportFaqScreen.routeName: (context) => const SupportFaqScreen(),
      ResetPasswordScreen.routeName: (context) => const ResetPasswordScreen(),
    };

Widget? _getScreen(RouteSettings settings) {
  switch (settings.name) {
    case ConnectionFailedScreen.routeName:
      ConnectionFailedScreenParams params =
          settings.arguments as ConnectionFailedScreenParams;
      return ConnectionFailedScreen(
        param: params,
      );
    // case OwnerManageUserScreen.route:
    //   OwnerManageUserScreenParams params =
    //       settings.arguments as OwnerManageUserScreenParams;
    //   return OwnerManageUserScreen(
    //     params: params,
    //   );

    default:
      return null;
  }
}

RouteFactory onAppGenerateRoute() => (settings) {
      Widget? screen = _getScreen(settings);
      if (screen != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, c) {
            return FadeTransition(opacity: a, child: c);
          },
        );
      }
      return null;
    };

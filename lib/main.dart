import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nakshathra_scheme_app/config/app_config.dart';
import 'package:nakshathra_scheme_app/l10n/app_localizations.dart';

import 'package:provider/provider.dart';

import 'features/splashscreen/view/splashscreen.dart';
import 'providers/bottom_nav_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/interceptors.dart';
import 'utils/localization.dart';
import 'utils/routes.dart';
import 'utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LanguageProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BottomNavProvider(),
        ),
      ],
      builder: (context, child) => ScreenUtilInit(
        designSize: Size(
          AppConfig.designWidth.toDouble(),
          AppConfig.designHeight.toDouble(),
        ),
        builder: (context, child) => AdaptiveTheme(
          initial: AdaptiveThemeMode.dark,
          light: appLightTheme,
          dark: appDarkTheme,
          builder: (theme, darkTheme) {
            return MaterialApp(
              navigatorKey: AppConfig.navKey,
              title: AppConfig.appName,
              themeMode: context.watch<ThemeProvider>().themeMode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('ja', ''),
              ],
              theme: themedForLocale(
                theme,
                context.watch<LanguageProvider>().locale,
              ),
              darkTheme: themedForLocale(
                darkTheme,
                context.watch<LanguageProvider>().locale,
              ),
              locale: context.watch<LanguageProvider>().locale,

              // initialRoute: LoginScreen.route,
              // initialRoute: BottomNavigationScreen.route,
              initialRoute: SplashScreen.routeName,
              onGenerateRoute: onAppGenerateRoute(),
              routes: appRoutes(),
              builder: (context, child) {
                LanguageProvider.initContext(context);
                Localization.init(context);
                return child!;
              },
            );
          },
        ),
      ),
    );
  }
}

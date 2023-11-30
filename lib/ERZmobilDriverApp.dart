import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/splashScreen/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'Constants.dart';

class ERZmobilDriverApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.info("App start");

    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'ERZmobil Driver App',
        supportedLocales: [
          const Locale('en'), // English
          const Locale('de'), // German
        ],
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: CustomColors.mint,
          primarySwatch:
              CustomColors.white, //createMaterialColor(Color(0xff419eb1)),
          primaryTextTheme: TextTheme(headline6: CustomTextStyles.titleWhite),
          accentColor: CustomColors.mint,
          scaffoldBackgroundColor: CustomColors.white,
          cardTheme: CardTheme(
            color: CustomColors.mint,
          ),
          iconTheme: IconThemeData(
              color: CustomColors.black, opacity: 1.0, size: 40.0),
          textTheme: TextTheme(
            headline6: CustomTextStyles.title,
            bodyText2: CustomTextStyles.bodyGrey,
            button: CustomTextStyles.bodyWhite,
          ),
          textSelectionTheme:
              TextSelectionThemeData(cursorColor: CustomColors.anthracite),
          fontFamily: 'SourceSansPro',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}

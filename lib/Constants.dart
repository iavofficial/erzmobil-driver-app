import 'package:flutter/material.dart';

class Expressions {
  static final RegExp regExpName = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
}

class Strings {
  Strings._();

  static const String appName = 'ERZmobil-Driver';
  static const String logsWriteDirectoryName = 'ERZmobilDriverLogs';
  static const String logsExportDirectoryName = 'Exported';
  static const String logFilesDirectoryName = 'Logs';

  static const String assetPathBusStop = 'assets/ic_haltestelle.png';
  static const String assetPathBus = 'assets/ic_bus.png';
  static const String assetPathLogo = 'assets/Logo_4c_mitverlauf.png';
  static const String assetPathLocationMarker = 'assets/ic_locationmarker.png';

  static const String prefKeyCode = 'verificationCodeMode';

  static const String IMPRINT_URL = 'https://smartcity-zwoenitz.de/impressum/';
  static const String ABOUT_ERZMOBIL_URL = 'https://www.erzmobil.de/';
  static const String DATAPRIVACY_URL =
      'https://smartcity-zwoenitz.de/erzmobil-info/#privacy';

  static const String COGNITO_DATA_URL_DIRECTUS = "/customendpoints/cognito";
  static const String STOPS_URL_BACKEND = "/stops";
  static const String STOPS_URL_DIRECTUS = "/items/stop";
  static const String TOKENS_URL_BACKEND = "/tokens";
  static const String TOKENS_URL_DIRECTUS = "/customendpoints/token";

  static const String COMMUNITY_BUSES_URL_BACKEND = "/communities/1/buses";
  static const String COMMUNITY_BUSES_URL_DIRECTUS =
      "/items/bus?filter[community_id][_eq]=1&fields=id";

  static const String BUS_POSITIONS_URL_BACKEND = "/Buses/positions";
  static const String BUS_POSITIONS_URL_DIRECTUS = "/items/bus";

  static const String ORDERS_URL_BACKEND = '/orders';
}

class CustomIconThemeData {
  CustomIconThemeData._();

  static IconThemeData themeIconStyleWhiteForDarkOrBlue(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return navigationIconWhite;
    }
    return navigationIconBlue;
  }

  static IconThemeData themeIconStyleWhiteForDarkOrGrey(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return navigationIconWhite;
    }
    return navigationIconGrey;
  }

  static const IconThemeData navigationIconBlue =
      const IconThemeData(color: CustomColors.mint, opacity: 1.0, size: 30.0);

  static const IconThemeData navigationIconGrey = const IconThemeData(
      color: CustomColors.darkGrey, opacity: 1.0, size: 30.0);

  static const IconThemeData navigationIconWhite =
      const IconThemeData(color: Colors.white, opacity: 1.0, size: 30.0);
}

class CustomButtonStyles {
  CustomButtonStyles._();

  static ButtonStyle themeButtonyStyle(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return flatButtonStyleDark;
    }
    return flatButtonStyle;
  }

  static final ButtonStyle flatButtonStyleDark = TextButton.styleFrom(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      backgroundColor: CustomColors.mint,
      disabledBackgroundColor: CustomColors.lightGrey,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ));

  static final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      backgroundColor: CustomColors.marine,
      disabledBackgroundColor: CustomColors.lightGrey,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ));
}

class CustomTextStyles {
  CustomTextStyles._();

  static TextStyle themeStyleWhiteForDarkOrGrey(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return bodyWhite;
    }
    return bodyGrey;
  }

  static TextStyle themeStyleWhiteForDarkOrBlack(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return bodyWhite;
    }
    return bodyBlack;
  }

  static TextStyle themeStyleBoldWhiteForDarkOrBlack(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return bodyWhiteBold;
    }
    return bodyBlackBold;
  }

  static TextStyle themeStyleNavigationWhiteForDarkOrNavigationGrey(
      BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return navigationWhite;
    }
    return navigationGrey;
  }

  static TextStyle themeStyleWhiteForDarkOrAzure(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return bodyWhite;
    }
    return bodyAzure;
  }

  static const TextStyle title = const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: CustomColors.darkGrey);
  static const TextStyle titleWhite = const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.bold, color: CustomColors.white);
  static const TextStyle headlineGrey = const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle headlineBigBlackBold = const TextStyle(
      fontSize: 20.0, fontWeight: FontWeight.bold, color: CustomColors.black);
  static const TextStyle headlineBlackBold = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: CustomColors.black);
  static const TextStyle headlineBlack = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.normal, color: CustomColors.black);
  static const TextStyle headlineWhite = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.normal, color: CustomColors.white);
  static const TextStyle headlineWhiteBold = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: CustomColors.white);
  static const TextStyle headlineBigWhiteBold = const TextStyle(
      fontSize: 20.0, fontWeight: FontWeight.bold, color: CustomColors.white);
  static const TextStyle bodyGrey = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGrey2 = const TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGreyBold2 = const TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGreyUnderlined = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      decoration: TextDecoration.underline,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGreyBold = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: CustomColors.darkGrey,
  );
  static const TextStyle bodyMarineBold = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: CustomColors.marine,
  );
  static const TextStyle bodyMintBold = const TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: CustomColors.mint,
  );
  static const TextStyle bodyWhiteBold = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.bold, color: CustomColors.white);
  static const TextStyle bodyBlackBold = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.bold, color: CustomColors.black);
  static const TextStyle bodyBlackBoldSmall = const TextStyle(
      fontSize: 13.0, fontWeight: FontWeight.bold, color: CustomColors.black);
  static const TextStyle bodyRedVerySmall = const TextStyle(
      fontSize: 10.0, fontWeight: FontWeight.normal, color: Colors.red);
  static const TextStyle bodyRed = const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.red);
  static const TextStyle bodyGreen = const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.green);
  static const TextStyle bodyGreySmall = const TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle bodyGreyVerySmall = const TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle bodyAzure = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.marine);
  static const TextStyle bodyLightGrey = const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.lightGrey);
  static const TextStyle bodyWhite = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.normal, color: CustomColors.white);
  static const TextStyle bodyBlack = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.normal, color: CustomColors.black);
  static const TextStyle navigationBlue = const TextStyle(
      fontSize: 10.0, fontWeight: FontWeight.normal, color: CustomColors.azure);
  static const TextStyle navigationGrey = const TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: CustomColors.darkGrey);
  static const TextStyle navigationWhite = const TextStyle(
      fontSize: 10.0, fontWeight: FontWeight.normal, color: CustomColors.white);
}

class CustomColors {
  CustomColors._();

  static MaterialColor themeStyleMintForDarkOrMarine(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return mint;
    }
    return marine;
  }

  static MaterialColor themeStyleWhiteForDarkOrMarine(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return white;
    }
    return marine;
  }

  static MaterialColor themeStyleBlackForDarkOrWhite(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return black;
    }
    return white;
  }

  static MaterialColor themeStyleWhiteForDarkOrBlack(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return white;
    }
    return black;
  }

  static MaterialColor themeStyleDarkGreyForDarkOrWhite(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return darkGrey;
    }
    return white;
  }

  static MaterialColor themeStyleWhiteForDarkOrDarkGrey(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return white;
    }
    return darkGrey;
  }

  static MaterialColor themeStyleAntraciteForDarkOrWhite(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return white;
    }
    return anthracite;
  }

  static MaterialColor themeStyleBlackForDarkOrLightGrey(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return black;
    }
    return lightGrey;
  }

  static MaterialColor themeStyleDarkGreyForDarkOrLightGrey(
      BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return darkGrey;
    }
    return lightGrey;
  }

  static const MaterialColor white = const MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );

  // logo color
  static const MaterialColor sulfurYellow = const MaterialColor(
    0xFFFADE52,
    const <int, Color>{
      50: const Color(0xFFFADE52),
      100: const Color(0xFFFADE52),
      200: const Color(0xFFFADE52),
      300: const Color(0xFFFADE52),
      400: const Color(0xFFFADE52),
      500: const Color(0xFFFADE52),
      600: const Color(0xFFFADE52),
      700: const Color(0xFFFADE52),
      800: const Color(0xFFFADE52),
      900: const Color(0xFFFADE52),
    },
  );

  static const MaterialColor anthracite = const MaterialColor(
    0xFF313D47,
    const <int, Color>{
      50: const Color(0xFF313D47),
      100: const Color(0xFF313D47),
      200: const Color(0xFF313D47),
      300: const Color(0xFF313D47),
      400: const Color(0xFF313D47),
      500: const Color(0xFF313D47),
      600: const Color(0xFF313D47),
      700: const Color(0xFF313D47),
      800: const Color(0xFF313D47),
      900: const Color(0xFF313D47),
    },
  );

  static const MaterialColor backButtonIconColor = const MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );

  static const MaterialColor mint = const MaterialColor(
    0xFF65C1BE,
    const <int, Color>{
      50: const Color(0xFF65C1BE),
      100: const Color(0xFF65C1BE),
      200: const Color(0xFF65C1BE),
      300: const Color(0xFF65C1BE),
      400: const Color(0xFF65C1BE),
      500: const Color(0xFF65C1BE),
      600: const Color(0xFF65C1BE),
      700: const Color(0xFF65C1BE),
      800: const Color(0xFF65C1BE),
      900: const Color(0xFF65C1BE),
    },
  );

  static const MaterialColor marine = const MaterialColor(
    0xFF1E1D49,
    const <int, Color>{
      50: const Color(0xFF1E1D49),
      100: const Color(0xFF1E1D49),
      200: const Color(0xFF1E1D49),
      300: const Color(0xFF1E1D49),
      400: const Color(0xFF1E1D49),
      500: const Color(0xFF1E1D49),
      600: const Color(0xFF1E1D49),
      700: const Color(0xFF1E1D49),
      800: const Color(0xFF1E1D49),
      900: const Color(0xFF1E1D49),
    },
  );

  static const MaterialColor black = const MaterialColor(
    0xFF000000,
    const <int, Color>{
      50: const Color(0xFF000000),
      100: const Color(0xFF000000),
      200: const Color(0xFF000000),
      300: const Color(0xFF000000),
      400: const Color(0xFF000000),
      500: const Color(0xFF000000),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );

  static const MaterialColor darkGrey = const MaterialColor(
    0xFF4d4d4d,
    const <int, Color>{
      50: const Color(0xFF4d4d4d),
      100: const Color(0xFF4d4d4d),
      200: const Color(0xFF4d4d4d),
      300: const Color(0xFF4d4d4d),
      400: const Color(0xFF4d4d4d),
      500: const Color(0xFF4d4d4d),
      600: const Color(0xFF4d4d4d),
      700: const Color(0xFF4d4d4d),
      800: const Color(0xFF4d4d4d),
      900: const Color(0xFF4d4d4d),
    },
  );

  static const MaterialColor lightGrey = const MaterialColor(
    0xFFc4c8cb,
    const <int, Color>{
      50: const Color(0xFFc4c8cb),
      100: const Color(0xFFc4c8cb),
      200: const Color(0xFFc4c8cb),
      300: const Color(0xFFc4c8cb),
      400: const Color(0xFFc4c8cb),
      500: const Color(0xFFc4c8cb),
      600: const Color(0xFFc4c8cb),
      700: const Color(0xFFc4c8cb),
      800: const Color(0xFFc4c8cb),
      900: const Color(0xFFc4c8cb),
    },
  );

  static const MaterialColor azure = const MaterialColor(
    0xFF0060A7,
    const <int, Color>{
      50: const Color(0xFF0060A7),
      100: const Color(0xFF0060A7),
      200: const Color(0xFF0060A7),
      300: const Color(0xFF0060A7),
      400: const Color(0xFF0060A7),
      500: const Color(0xFF0060A7),
      600: const Color(0xFF0060A7),
      700: const Color(0xFF0060A7),
      800: const Color(0xFF0060A7),
      900: const Color(0xFF0060A7),
    },
  );

  static const MaterialColor green = const MaterialColor(
    0xFFC0D000,
    const <int, Color>{
      50: const Color(0xFFC0D000),
      100: const Color(0xFFC0D000),
      200: const Color(0xFFC0D000),
      300: const Color(0xFFC0D000),
      400: const Color(0xFFC0D000),
      500: const Color(0xFFC0D000),
      600: const Color(0xFFC0D000),
      700: const Color(0xFFC0D000),
      800: const Color(0xFFC0D000),
      900: const Color(0xFFC0D000),
    },
  );

  static const MaterialColor lightgreen = const MaterialColor(
    0xFFDFDE3D,
    const <int, Color>{
      50: const Color(0xFFDFDE3D),
      100: const Color(0xFFDFDE3D),
      200: const Color(0xFFDFDE3D),
      300: const Color(0xFFDFDE3D),
      400: const Color(0xFFDFDE3D),
      500: const Color(0xFFDFDE3D),
      600: const Color(0xFFDFDE3D),
      700: const Color(0xFFDFDE3D),
      800: const Color(0xFFDFDE3D),
      900: const Color(0xFFDFDE3D),
    },
  );

  static const MaterialColor orange = const MaterialColor(
    0xFFef7b10,
    const <int, Color>{
      50: const Color(0xFFef7b10),
      100: const Color(0xFFef7b10),
      200: const Color(0xFFef7b10),
      300: const Color(0xFFef7b10),
      400: const Color(0xFFef7b10),
      500: const Color(0xFFef7b10),
      600: const Color(0xFFef7b10),
      700: const Color(0xFFef7b10),
      800: const Color(0xFFef7b10),
      900: const Color(0xFFef7b10),
    },
  );

  static const MaterialColor neongreen = const MaterialColor(
    0xFF91C63E,
    const <int, Color>{
      50: const Color(0xFF91C63E),
      100: const Color(0xFF91C63E),
      200: const Color(0xFF91C63E),
      300: const Color(0xFF91C63E),
      400: const Color(0xFF91C63E),
      500: const Color(0xFF91C63E),
      600: const Color(0xFF91C63E),
      700: const Color(0xFF91C63E),
      800: const Color(0xFF91C63E),
      900: const Color(0xFF91C63E),
    },
  );

  static const Color splashScreenColor = Colors.white;
}

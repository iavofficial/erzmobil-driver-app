/**
 * Copyright © 2025 IAV GmbH Ingenieurgesellschaft Auto und Verkehr, All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
import 'package:flutter/material.dart';
import 'StoreManager.dart';
import '../Constants.dart';

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();

  final darkTheme = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColors.lightGrey),
      ),
    ),
    brightness: Brightness.dark,
    primaryColor: CustomColors.mint,
    primarySwatch: CustomColors.black, //createMaterialColor(Color(0xff419eb1)),
    primaryTextTheme: TextTheme(titleLarge: CustomTextStyles.bodyBlack),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: CustomColors.mint,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: CustomColors.black,
    cardTheme: CardTheme(
      color: CustomColors.mint,
    ),
    iconTheme: IconThemeData(
      color: CustomColors.white,
      opacity: 1.0,
      size: 40.0,
    ),
    textTheme: TextTheme(
      titleLarge: CustomTextStyles.titleWhite,
      bodyMedium: CustomTextStyles.bodyLightGrey,
      labelLarge: CustomTextStyles.bodyBlack,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: CustomColors.lightGrey,
    ),
    fontFamily: 'SourceSansPro',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  final lightTheme = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CustomColors.lightGrey))),

    brightness: Brightness.light,
    primaryColor: CustomColors.mint,
    primarySwatch: CustomColors.white, //createMaterialColor(Color(0xff419eb1)),
    primaryTextTheme: TextTheme(titleLarge: CustomTextStyles.titleWhite),
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: CustomColors.mint),
    scaffoldBackgroundColor: CustomColors.white,
    cardTheme: CardTheme(
      color: CustomColors.mint,
    ),
    iconTheme:
        IconThemeData(color: CustomColors.black, opacity: 1.0, size: 40.0),
    textTheme: TextTheme(
      titleLarge: CustomTextStyles.title,
      bodyMedium: CustomTextStyles.bodyGrey,
      labelLarge: CustomTextStyles.bodyWhite,
    ),
    textSelectionTheme:
        TextSelectionThemeData(cursorColor: CustomColors.anthracite),
    fontFamily: 'SourceSansPro',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  late ThemeData _themeData;
  ThemeData getTheme() => _themeData;

  factory ThemeNotifier() {
    return _instance;
  }

  ThemeNotifier._internal() {
    _themeData = darkTheme;
    StorageManager.readData('themeMode').then((value) {
      print('ThemeManager: value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        print('setting light theme');
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }

  Future<bool> isDarkMode() async {
    var value = await StorageManager.readData('themeMode');
    bool result = value == 'dark';
    return result;
  }
}

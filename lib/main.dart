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
import 'dart:async';

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erzmobil_driver/ERZmobilDriverApp.dart';
import 'package:erzmobil_driver/utils/ThemeManager.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.init();
  WakelockPlus.enable();
  FlutterError.onError = (FlutterErrorDetails details) {
    print("Error From INSIDE FRAME_WORK");
    Logger.info('Uncaught Exception: ');
    Logger.error(details.exception, details.stack!);
  };

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    try {
      runZonedGuarded(() async {
        await Firebase.initializeApp();
        runApp(ChangeNotifierProvider(
          create: (context) => ThemeNotifier(),
          child: ERZmobilDriverApp(),
        ));
      }, (error, stackTrace) {
        Logger.info('Uncaught Exception: ');
        Logger.error(error, stackTrace);
      });
    } catch (e) {
      Logger.info('Uncaught Exception: ');
      Logger.error(e, StackTrace.current);
    }
  });
}

import 'dart:async';

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erzmobil_driver/ERZmobilDriverApp.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.init();
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
        runApp(ERZmobilDriverApp());
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

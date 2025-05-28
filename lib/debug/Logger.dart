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

import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/utils/StoreManager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_logs/flutter_logs.dart';

class Logger {
  static bool debugMode = true;
  static var logStatus = '';
  static String TAG = "ErzMobil-Driver";
  static Completer _completer = new Completer<String>();

  static Future<String> exportAllLogs() async {
    FlutterLogs.exportLogs(exportType: ExportType.ALL);
    return _completer.future as FutureOr<String>;
  }

  static Future<void> init() async {
    await FlutterLogs.initLogs(
        logLevelsEnabled: [
          LogLevel.INFO,
          LogLevel.WARNING,
          LogLevel.ERROR,
          LogLevel.SEVERE
        ],
        timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
        directoryStructure: DirectoryStructure.FOR_DATE,
        logTypesEnabled: ["device", "network", "errors"],
        logFileExtension: LogFileExtension.LOG,
        logsWriteDirectoryName: Strings.logsWriteDirectoryName,
        logsExportDirectoryName: Strings.logsExportDirectoryName,
        debugFileOperations: true,
        isDebuggable: true);

    debugMode = await StorageManager.isLoggingActive();

    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        // Contains file name of zip
        FlutterLogs.logInfo(
            TAG, "setUpLogs", "logsExported: ${call.arguments.toString()}");

        setLogsStatus(
            status: "logsExported: ${call.arguments.toString()}", append: true);

        // Notify Future with value
        _completer.complete(call.arguments.toString());
      } else if (call.method == 'logsPrinted') {
        FlutterLogs.logInfo(
            TAG, "setUpLogs", "logsPrinted: ${call.arguments.toString()}");

        setLogsStatus(
            status: "logsPrinted: ${call.arguments.toString()}", append: true);
      }
    });
  }

  static void setLogsStatus({String status = '', bool append = false}) {
    logStatus = status;
  }

  static void debug(String text) {
    // if (!kReleaseMode || debugMode) {
    if (debugMode) {
      FlutterLogs.logWarn(TAG, "debug", text);
    }
  }

  static void info(String text) {
    // if (!kReleaseMode || debugMode) {
    if (debugMode) {
      FlutterLogs.logInfo(TAG, "info", text);
    }
  }

  static void releaseLog(String text) {
    FlutterLogs.logInfo(TAG, "info", text);
  }

  static void e(String text) {
    // if (!kReleaseMode || debugMode) {
    if (debugMode) {
      FlutterLogs.logError(TAG, "error", text);
    }
  }

  static void error(Object object, StackTrace stackTrace) {
    // if (!kReleaseMode || debugMode) {
    if (debugMode) {
      String exception = object.toString();
      FlutterLogs.logError(TAG, "error", exception);
    }
  }
}

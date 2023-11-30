import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';

class Logger {
  static bool debugMode = true;

  static Future<void> _initDebug() async {
    debugMode = true; //await InfoPlist.debugVersion;
  }

  static init() {
    if (Platform.isIOS) {
      _initDebug();
    }
  }

  static void debug(String text) {
    if (!kReleaseMode || debugMode) {
      FLog.debug(
          className: Trace.current().frames[1].member!.split(".")[0],
          methodName: Trace.current().frames[1].member!.split(".")[1],
          text: text);
    }
  }

  static void info(String text) {
    if (!kReleaseMode || debugMode) {
      FLog.info(
          className: Trace.current().frames[1].member!.split(".")[0],
          methodName: Trace.current().frames[1].member!.split(".")[1],
          text: text);
    }
  }

  static void releaseLog(String text) {
    FLog.info(
        className: Trace.current().frames[1].member!.split(".")[0],
        methodName: Trace.current().frames[1].member!.split(".")[1],
        text: text);
  }

  static void e(String text) {
    if (!kReleaseMode || debugMode) {
      FLog.error(
          className: Trace.current().frames[1].member!.split(".")[0],
          methodName: Trace.current().frames[1].member!.split(".")[1],
          text: text);
    }
  }

  static void error(Object object, StackTrace stackTrace) {
    if (!kReleaseMode || debugMode) {
      String exception = object.toString();
      FLog.logThis(
          className: Trace.current().frames[1].member!.split(".")[0],
          methodName: Trace.current().frames[1].member!.split(".")[1],
          text: exception,
          type: LogLevel.SEVERE,
          stacktrace: stackTrace);
    }
  }
}

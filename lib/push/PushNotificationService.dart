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
import 'dart:ffi';
import 'dart:io';

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:erzmobil_driver/utils/Utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import '../Constants.dart';
import 'package:audioplayers/audioplayers.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      new PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  late void Function(int) changePage;
  late BuildContext context;
  bool isFirebaseInitialized = false;
  bool isMessageHandlingInitialized = false;
  bool isAuthorized = false;
  String? fcmToken;

  PushNotificationService._internal();

  Future initializeFirebase() async {
    if (!isFirebaseInitialized) {
      isFirebaseInitialized = true;

      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      Logger.debug(
          "FirebaseMessaging: User granted permission: ${settings.authorizationStatus}");

      // If you want to test the push notification locally,
      // you need to get the token and input to the Firebase console
      // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose

      isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      if (isAuthorized) {
        if (Platform.isIOS) {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          Logger.releaseLog(
              'FlutterFire Messaging: Got APNs token: $apnsToken');
        }

        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
          Logger.info("FirebaseMessaging token: $fcmToken");
        } catch (e) {
          final bool isConnected =
              await InternetConnectionChecker.instance.hasConnection;
          if (!isConnected) {
            Logger.info("ERROR_FAILED_NO_INTERNET");
          }
        }
      }
    }
  }

  Future initialisePushMessageHandling(
      BuildContext context, Function(int) changePage) async {
    this.changePage = changePage;
    this.context = context;

    if (isAuthorized && !isMessageHandlingInitialized) {
      isMessageHandlingInitialized = true;

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Logger.releaseLog("FirebaseMessaging: push message received");
        handleMessage(message, this.context);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Logger.releaseLog("FirebaseMessaging: App opened via push message");

        if (User().isLoggedIn() && message.data["id"] != null) {
          String id = message.data["id"];

          if (id == "1" || id == "5") {
            User().loadTours();
            changePage(1);
          }
        }
      });
    }
  }

  Future<String?> getFCMToken() async {
    if (isFirebaseInitialized) {
      if (fcmToken != null) {
        return fcmToken;
      } else {
        return FirebaseMessaging.instance.getToken();
      }
    } else
      return null;
  }

  void handleMessage(RemoteMessage message, BuildContext buildContext) {
    RemoteNotification? notification = message.notification;
    if (notification != null &&
        notification.titleLocKey != null &&
        notification.bodyLocKey != null) {
      _logMessage(
          notification.titleLocKey!, notification.bodyLocKey!, message.data);
    }

    if (User().isLoggedIn()) {
      String title = "";
      String messageText = "";
      bool important = false;

      DateTime? date = message.data["date"] != null
          ? DateTime.parse(message.data["date"] as String)
          : null;

      if (message.data["id"] != null) {
        String id = message.data["id"];

        if (User().hasValidBusId() == false && id != "4") {
          return;
        }

        switch (id) {
          case "1":
            title = AppLocalizations.of(buildContext)!.notificationTitleNewTour;
            User().loadTours();
            if (checkFullData(message, date)) {
              messageText = AppLocalizations.of(buildContext)!
                  .notificationMessageNewTour(message.data["start"],
                      message.data["stop"], Utils().getDateAsString(date));
            }
            break;
          case "4":
            Locale currentLocale = Localizations.localeOf(context);
            title = AppLocalizations.of(buildContext)!
                .notificationTitleSystemMessage;

            if (currentLocale.languageCode == "de") {
              messageText = message.data["systemInformation_de"];
            } else {
              messageText = message.data["systemInformation_en"];
            }
            break;
          case "5":
            title = AppLocalizations.of(buildContext)!
                .notificationTitleTourReminder;
            User().loadTours();
            if (checkDataStartDate(message, date)) {
              messageText = AppLocalizations.of(buildContext)!
                  .notificationMessageTourReminder(
                      message.data["start"], Utils().getDateAsString(date));
            }
            break;
          case "7":
            title = AppLocalizations.of(buildContext)!
                .notificationTitleOpenTourReminder;
            User().loadTours();
            if (checkDataStartDate(message, date)) {
              messageText = AppLocalizations.of(buildContext)!
                  .notificationMessageOpenTourReminder(message.data["start"],
                      message.data["stop"], Utils().getDateAsString(date));
            }
            break;
          case "9":
            int? routeId = int.parse(message.data["route_id"]);
            bool showMessage = _isCurrentOrNextTour(routeId);

            if (showMessage) {
              playSound();
              User().loadTours().then((value) => User().initActiveTourData());
              important = true;
              title = AppLocalizations.of(buildContext)!
                  .notificationTitleDeletedOrder;
              messageText = AppLocalizations.of(buildContext)!
                  .notificationMessageDeletedOrder(message.data["route_id"]);
            }
            break;
          case "10":
            int? routeIdNew = int.parse(message.data["route_id_new"]);
            int? routeIdOld = int.parse(message.data["route_id_old"]);

            bool isRouteIdOld = _isCurrentOrNextTour(routeIdOld);
            bool isRouteIdNew = _isCurrentOrNextTour(routeIdNew);

            if (isRouteIdOld || isRouteIdNew) {
              playSound();
              User().loadTours().then((value) => User().initActiveTourData());
              important = true;
              title = AppLocalizations.of(buildContext)!
                  .notificationTitleRouteChanged;
              messageText = AppLocalizations.of(buildContext)!
                  .notificationMessageRouteChanged(
                      message.data["order_id"],
                      message.data["route_id_new"],
                      message.data["route_id_old"]);
            }
            break;
          case "11":
            int? routeId = int.parse(message.data["route_id"]);
            int? busId = int.parse(message.data["bus_id"]);

            playSound();
            User().loadTours().then((value) => User().initActiveTourData());
            important = true;
            title = AppLocalizations.of(buildContext)!
                .notificationTitleCurrentrouteChangedDriverWarning;
            messageText = AppLocalizations.of(buildContext)!
                .notificationMessageCurrentrouteChangedDriverWarning;

            break;
          default:
        }
      }

      if (title.isNotEmpty && messageText.isNotEmpty) {
        _showNotification(title, messageText, important);
      }
    }
  }

  void playSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('notification.mp3'));
  }

  bool _isCurrentOrNextTour(int? routeId) {
    if (routeId == null) {
      return false;
    }

    Tour? currentTour = User().currentRoute;
    bool isNextTourId = User().tourList!.isNextPlannedTour(routeId);
    bool isCurrentTourId = false;
    if (currentTour != null) {
      isCurrentTourId = currentTour.routeId == routeId;
    }

    return isNextTourId || isCurrentTourId;
  }

  void _showNotification(String title, String messageText, bool important) {
    _logMessage(title, messageText, null);
    Widget text;

    if (important) {
      text = Text(
        "$title\n $messageText",
        style: CustomTextStyles.headlineBigWhiteBold,
        textAlign: TextAlign.center,
      );
    } else {
      text = Text("$title:\n$messageText");
    }

    showSimpleNotification(
        Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: text), trailing: Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: IconButton(
          icon: Icon(
            Icons.close,
            color: important ? CustomColors.white : CustomColors.black,
          ),
          onPressed: () {
            OverlaySupportEntry.of(context)!.dismiss();
          },
        ),
      );
    }),
        background: important ? CustomColors.customOrange : CustomColors.green,
        foreground: important ? CustomColors.white : CustomColors.black,
        autoDismiss: false,
        slideDismissDirection: DismissDirection.up);
  }

  bool checkFullData(RemoteMessage message, DateTime? date) {
    RemoteNotification? notification = message.notification;
    return notification != null &&
        message.data["start"] != null &&
        message.data["stop"] != null;
  }

  bool checkDataStartDate(RemoteMessage message, DateTime? date) {
    RemoteNotification? notification = message.notification;
    return notification != null && message.data["start"] != null;
  }

  void _logMessage(String title, String message, Map<String, dynamic>? data) {
    try {
      Logger.releaseLog("FirebaseMessaging: $title - $message");
      if (data != null) {
        Logger.releaseLog("FirebaseMessaging data: $data");
      } else {
        Logger.releaseLog("FirebaseMessaging data: No data available");
      }
    } catch (e) {}
  }
}

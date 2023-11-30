import 'dart:io';

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:erzmobil_driver/utils/Utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../Constants.dart';

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

        fcmToken = await FirebaseMessaging.instance.getToken();
        Logger.releaseLog("FirebaseMessaging token: $fcmToken");
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
      _logMessage(notification.titleLocKey!, notification.bodyLocKey!);
    }

    if (User().isLoggedIn()) {
      String title = "";
      String messageText = "";

      DateTime? date = message.data["date"] != null
          ? DateTime.parse(message.data["date"] as String)
          : null;

      if (message.data["id"] != null) {
        String id = message.data["id"];

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
            User().loadTours().then((value) => User().initActiveTourData());
            break;
          default:
        }
      }

      if (title.isNotEmpty && messageText.isNotEmpty) {
        _logMessage(title, messageText);

        showSimpleNotification(
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                messageText,
              ),
            ), trailing: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: CustomColors.black,
              ),
              onPressed: () {
                OverlaySupportEntry.of(context)!.dismiss();
              },
            ),
          );
        }),
            background: CustomColors.green,
            autoDismiss: false,
            slideDismissDirection: DismissDirection.up);
      }
    }
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

  void _logMessage(String title, String message) {
    try {
      Logger.releaseLog("FirebaseMessaging: $title - $message");
    } catch (e) {}
  }
}

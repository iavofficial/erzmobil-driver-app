import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/home/HomeScreen.dart';
import 'package:erzmobil_driver/model/PreferenceHolder.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:provider/provider.dart';
import 'package:erzmobil_driver/push/PushNotificationService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.splashScreenColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: new Image.asset(
            Strings.assetPathLogo,
            fit: BoxFit.cover,
            repeat: ImageRepeat.noRepeat,
          ),
        ),
      ),
    );
  }

  void _loadStorage() async {
    await PreferenceHolder().init();
    await PushNotificationService().initializeFirebase();
    await User().checkBackendConnection();
    await User().loadCognitoData();
    await User().loadUser();
    await User().restoreSessionFromStore();
    await User().loadPublicDataFromBE();
    Timer(Duration(seconds: 3), _pushMeasuredRoute);
  }

  void _pushMeasuredRoute() {
    Widget widgetToPush = new ChangeNotifierProvider(
      create: (context) => User(),
      child: HomeScreen(),
    );

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => widgetToPush));
  }
}

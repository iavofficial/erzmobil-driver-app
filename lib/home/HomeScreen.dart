import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/journeys/ActiveTour.dart';
import 'package:erzmobil_driver/journeys/TourHistory.dart';
import 'package:erzmobil_driver/location/LocationMangager.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/push/PushNotificationService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil_driver/account/AccountScreen.dart';
import 'package:erzmobil_driver/information/InformationScreen.dart';
import 'package:erzmobil_driver/journeys/MyTours.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, LocationListener {
  int _selectedIndex = 0;
  int _contentIndex = 0;
  bool _isInitialLogin = true;
  AppLifecycleState lifecycleState = AppLifecycleState.resumed;

  late List<String> _pageTitles;

  @override
  void initState() {
    super.initState();

    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addObserver(this);
    }
    if (User().isLoggedIn()) {
      Future.delayed(Duration.zero, () async {
        RequestState result = await User().registerToken();
        User().showFCMErrorIfnecessary(context, result);
      });
    }
    Future.delayed(const Duration(milliseconds: 10000), () {
      LocationManager().register(this);
      LocationManager().initLocationService();
    });
  }

  Future<void> setupInteractedMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotificationService().handleMessage(initialMessage, context);
    }
  }

  @override
  void dispose() {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.removeObserver(this);
    }
    LocationManager().unregister(this);
    super.dispose();
  }

  @override
  void onLocationChanged(Position location) {
    if (lifecycleState == AppLifecycleState.resumed) {
      User().sendBusPosition(location);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    lifecycleState = state;
    Logger.info('state = $state');
    if (state == AppLifecycleState.paused) {
      LocationManager().pauseLocationUpdates();
    } else if (state == AppLifecycleState.resumed) {
      LocationManager().resumeLocationUpdates();
    }
  }

  List<Widget> _pages = <Widget>[
    AccountScreen(),
    MyTours(),
    ActiveTour(),
    InformationScreen()
  ];

  void _buildTitleList(BuildContext context) {
    _pageTitles = <String>[
      AppLocalizations.of(context)!.authentication,
      AppLocalizations.of(context)!.myJourneys,
      AppLocalizations.of(context)!.activeTour,
      AppLocalizations.of(context)!.infoTitle,
    ];
  }

  void _computeIndex() {
    if (User().isLoggedIn() && _isInitialLogin) {
      _selectedIndex = 1;
      _contentIndex = 1;
      _isInitialLogin = false;
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      bool isLoggedIn = User().isLoggedIn();
      if (index == 0) {
        _contentIndex = index;
      } else if (index == 1) {
        _contentIndex = isLoggedIn ? 1 : 3;
      } else if (index >= 1) {
        _contentIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    PushNotificationService()
        .initialisePushMessageHandling(context, onItemTapped);
    setupInteractedMessage(context);
    _buildTitleList(context);
    return Consumer<User>(builder: (context, user, child) {
      _computeIndex();
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[CustomColors.mint, CustomColors.marine])),
          ),
          centerTitle: true,
          title: Text(_pageTitles.elementAt(_contentIndex)),
          actions: !User().isProgressUpdateTours && _contentIndex == 1
              ? (<Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.history,
                      color: CustomColors.backButtonIconColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new TourHistory()));
                    },
                  )
                ])
              : !User().isProgressUpdateTours &&
                      _contentIndex == 2 &&
                      User().getCurrentTour() != null &&
                      User().getCurrentTour()!.nodes != null &&
                      User().getCurrentTour()!.nodes!.length > 1
                  ? (<Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.navigation,
                          color: CustomColors.backButtonIconColor,
                        ),
                        onPressed: () {
                          _shareRoute(User().getCurrentTour()!, context);
                        },
                      )
                    ])
                  : null,
        ),
        extendBodyBehindAppBar: false,
        body: _pages.elementAt(_contentIndex),
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: CustomTextStyles.navigationBlue,
          backgroundColor: CustomColors.white,

          type: BottomNavigationBarType.fixed,

          /// takes only font size
          unselectedLabelStyle: CustomTextStyles.navigationGrey,

          /// takes only font size
          selectedIconTheme: CustomIconThemeData.navigationIconBlue,
          unselectedIconTheme: CustomIconThemeData.navigationIconGrey,
          selectedItemColor: CustomColors.mint,
          unselectedItemColor: CustomColors.darkGrey,
          currentIndex: _selectedIndex,
          // this will be set when a new tab is tapped
          onTap: User().isProcessing ? (int index) {} : onItemTapped,
          items: _buildTabs(context),
        ),
      );
    });
  }

  Future<void> _shareRoute(Tour currentRoute, BuildContext context) async {
    double lat = currentRoute.nodes![currentRoute.nodes!.length - 1].latitude;
    double lng = currentRoute.nodes![currentRoute.nodes!.length - 1].longitude;

    String wayPoints = "";
    Logger.info(
        "share route from ${currentRoute.nodes![0].label} to ${currentRoute.nodes![currentRoute.nodes!.length - 1].label}");

    if (currentRoute.nodes!.length > 2) {
      int i = 0;
      currentRoute.nodes!.forEach((TourNode node) {
        if (i != currentRoute.nodes!.length - 1) {
          double lat = node.latitude;
          double lng = node.longitude;
          String waypoint = "$lat" + "," + "$lng";

          if (!wayPoints.contains(waypoint)) {
            Logger.info("add waypoint ${node.label}");

            wayPoints = wayPoints + (wayPoints == ("") ? "" : "%7C") + waypoint;
          }
        }
        i++;
      });

      wayPoints = "&waypoints=" + wayPoints;
    }

    String googleMapsDirectionsUri =
        "https://www.google.com/maps/dir/?api=1&travelmode=driving&destination=$lat,$lng" +
            wayPoints;

    Logger.debug("_shareRoute: $googleMapsDirectionsUri");

    if (!await launch(
      googleMapsDirectionsUri,
      forceSafariVC: false,
      forceWebView: false,
    )) {
      Logger.info('Could not launch $googleMapsDirectionsUri');
    }
  }

  List<BottomNavigationBarItem> _buildTabs(BuildContext context) {
    if (User().isLoggedIn()) {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: new Icon(Icons.account_circle),
          title: new Text(AppLocalizations.of(context)!.authentication),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.departure_board),
            title: Text(AppLocalizations.of(context)!.myJourneys)),
        BottomNavigationBarItem(
            icon: Icon(Icons.directions),
            title: Text(AppLocalizations.of(context)!.activeTour)),
        BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.infoTitle)),
      ];
    } else {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: new Icon(Icons.account_circle),
          title: new Text(AppLocalizations.of(context)!.authentication),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.infoTitle))
      ];
    }
  }
}

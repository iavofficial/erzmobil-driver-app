import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/PhoneNumberList.dart';
import 'package:erzmobil_driver/location/LocationMangager.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:erzmobil_driver/utils/Utils.dart';
import 'package:erzmobil_driver/views/ActiveTourExtendedStopView.dart';
import 'package:erzmobil_driver/views/ActiveTourNextStopHighlightedView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constants.dart';

class ActiveTour extends StatefulWidget {
  const ActiveTour({Key? key}) : super(key: key);

  @override
  _ActiveTourState createState() => _ActiveTourState();
}

class _ActiveTourState extends State<ActiveTour> {
  Tour? currentRoute;
  int lastFinishedTourNode = 0;
  int activeNodeIdx = 0;
  Position? _currentLocation;
  PhoneNumberList phoneNumberList = PhoneNumberList(null);
  final GlobalKey _targetKey = GlobalKey();

  void _scrollToTarget() {
    if (activeNodeIdx > 0 &&
        currentRoute != null &&
        currentRoute!.nodes != null) {
      final context = _targetKey.currentContext;

      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void initState() {
    Logger.info("Active Tour: initState ActiveTour screen");
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      loadPhoneNumbers();
    });
  }

  void loadPhoneNumbers() async {
    if (currentRoute != null && currentRoute!.routeId != null) {
      PhoneNumberList phoneNumbers =
          await User().loadPhoneNumbers(currentRoute!.routeId!);
      setState(() {
        this.phoneNumberList = phoneNumbers;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToTarget();
        });
      });
    }
  }

  @override
  void dispose() {
    Logger.info("Active Tour: dispose ActiveTour screen");
    super.dispose();
  }

  bool shouldHighlightNextTourNode() {
    _currentLocation = LocationManager().getCurrentLocation();
    if (currentRoute != null && currentRoute!.nodes != null) {
      int routeLength = currentRoute!.nodes!.length;

      if (routeLength > activeNodeIdx && _currentLocation != null) {
        LatLng currLatLng =
            LatLng(_currentLocation!.latitude, _currentLocation!.longitude);
        LatLng lastNode = LatLng(currentRoute!.nodes![activeNodeIdx].latitude,
            currentRoute!.nodes![activeNodeIdx].longitude);

        double distance =
            Utils.getDistanceBetweenTwoPointsInKilometer(currLatLng, lastNode);

        if (distance <= 0.025) {
          return true;
        }
      }
    }
    return false;
  }

  void _updateData() {
    currentRoute = User().getCurrentTour();
    lastFinishedTourNode = User().getLastFinishedTourNode();
    activeNodeIdx = User().activeNodeIdx;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Consumer<User>(
            builder: (context, user, child) => _buildWidgets(context)),
        onWillPop: () async {
          return !User().isProgressAnyTourAction;
        });
  }

  Widget _buildWidgets(BuildContext context) {
    bool highlightNextNode = shouldHighlightNextTourNode();
    _updateData();

    if (currentRoute == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_transfer,
              color: CustomColors.themeStyleAntraciteForDarkOrWhite(context),
            ),
            Text(AppLocalizations.of(context)!.noActiveTour),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Flexible(
            child: Container(
              child: currentRoute!.nodes!.length > 0
                  ? _buildListView(context, highlightNextNode)
                  : Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.no_transfer,
                            color: CustomColors.anthracite,
                          ),
                          Text(AppLocalizations.of(context)!.noJourneys),
                        ],
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Offstage(
                offstage: currentRoute!.status == 'Finished',
                child: getButton(context)),
          )
        ],
      );
    }
  }

  Widget _buildListView(BuildContext context, bool highlightNextNode) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(currentRoute!.nodes!.length, (index) {
          TourNode currentNode = currentRoute!.nodes![index];
          int routeId = currentRoute!.routeId!;
          bool isActiveNode = index == activeNodeIdx;
          bool isDestination = index == currentRoute!.nodes!.length - 1;
          bool isStart = index == 0;
          bool isDisabled = index < activeNodeIdx;
          bool isHistoryItem = currentRoute!.status == 'Finished';
          bool isNextNode = false;
          if (index != 0 && (index - 1) == activeNodeIdx) {
            isNextNode = true;
          }

          Widget treeView;
          if (isActiveNode || (highlightNextNode && isNextNode)) {
            GlobalKey? key = _targetKey;
            treeView = getHighlightedTourNodeWidget(
                key, currentNode, routeId, isStart, isNextNode, isDestination);
          } else {
            treeView = getNormalTourNodeWidget(isDisabled, currentNode, routeId,
                isHistoryItem, isStart, isDestination);
          }

          return Column(children: [
            treeView,
            Divider(
              height: 0,
              thickness: 1,
              color: CustomColors.themeStyleWhiteForDarkOrBlack(context),
            ),
          ]);
        }),
      ),
    );
  }

  Widget getHighlightedTourNodeWidget(GlobalKey? key, TourNode currentNode,
      int routeId, bool isStart, bool isNextNode, bool isDestination) {
    return ActiveTourNextStopHighlightedView(
        key: key,
        currentNode: currentNode,
        routeID: routeId,
        isStart: isStart,
        isNextStop: isNextNode,
        distanceToStop: User().distanceToStop,
        isDestination: isDestination,
        showBottomIcon: true,
        phoneNumberList: this.phoneNumberList);
  }

  Widget getNormalTourNodeWidget(bool isDisabled, TourNode currentNode,
      int routeId, bool isHistoryItem, bool isStart, bool isDestination) {
    return ActiveTourExtendedStopView(
      isDisabled: isDisabled,
      currentNode: currentNode,
      routeID: routeId,
      isHistoryItem: isHistoryItem,
      isStart: isStart,
      isDestination: isDestination,
      showBottomIcon: true,
      phoneNumberList: this.phoneNumberList,
    );
  }

  Widget getButton(BuildContext context) {
    bool isEnabled = !User().isProgressAnyTourAction &&
        (currentRoute!.status == 'Frozen' || currentRoute!.status == 'Started');
    bool isStarted = currentRoute!.status == 'Started';
    String buttonLabel = isStarted
        ? AppLocalizations.of(context)!.stopTour
        : AppLocalizations.of(context)!.startTour;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? MaterialStateProperty.all<Color>(CustomColors.mint)
                : MaterialStateProperty.all<Color>(CustomColors.marine),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                else if (states.contains(MaterialState.disabled))
                  return CustomColors.lightGrey;
                return CustomColors.white;
              },
            )),
        onPressed: isEnabled
            ? () {
                if (isStarted) {
                  User().confirmFinishDialog(
                      currentRoute!.routeId!, context, isStarted, false);
                }
              }
            : null,
        child: User().isProgressAnyTourAction
            ? CircularProgressIndicator()
            : Text(buttonLabel),
      ),
    );
  }
}

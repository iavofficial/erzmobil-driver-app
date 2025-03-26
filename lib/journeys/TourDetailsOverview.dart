import 'package:erzmobil_driver/UserMap.dart';
import 'package:erzmobil_driver/journeys/PhoneNumberListScreen.dart';
import 'package:erzmobil_driver/journeys/StopDetails.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/TabControllerModel.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:erzmobil_driver/views/TourInfoDetailsView.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class TourDetailsOverview extends StatelessWidget {
  const TourDetailsOverview(
      {Key? key, required this.currentRoute, required this.isHistory})
      : super(key: key);

  final Tour currentRoute;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[CustomColors.mint, CustomColors.marine])),
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
        foregroundColor: CustomColors.white,
        title: Text(AppLocalizations.of(context)!.detailedJourneys),
        actions: <Widget>[
          Offstage(
            offstage: User().useDirectus,
            child: IconButton(
              icon: Icon(
                Icons.perm_phone_msg,
                color: CustomColors.backButtonIconColor,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ChangeNotifierProvider.value(
                          value: User(),
                          child: new PhoneNumberListScreen(
                              routeID: currentRoute.routeId!)),
                ));
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.map,
              color: CustomColors.backButtonIconColor,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => ChangeNotifierProvider.value(
                    value: User(),
                    child: new UserMap(currentRoute: currentRoute)),
              ));
            },
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: CustomColors.backButtonIconColor,
          ),
        ),
      ),
      body: WillPopScope(
        child: Consumer<User>(
            builder: (context, user, child) => _buildWidgets(context)),
        onWillPop: () async {
          return !User().isProgressAnyTourAction;
        },
      ),
    );
  }

  Widget _buildWidgets(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            child: currentRoute.nodes!.length > 0
                ? ListView.builder(
                    itemCount: currentRoute.nodes!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ChangeNotifierProvider.value(
                                value: User(),
                                child: new StopDetailsScreen(
                                    tourNode: currentRoute.nodes![index],
                                    routeID: currentRoute.routeId!,
                                    isStart: index == 0,
                                    isDestination:
                                        index == currentRoute.nodes!.length - 1,
                                    isHistoryItem:
                                        currentRoute.status == 'Finished'),
                              ),
                            ),
                          );
                        },
                        child: Column(children: [
                          TourDetailInfoView(
                            currentNode: currentRoute.nodes![index],
                            isStart: index == 0,
                            isDestination:
                                index == currentRoute.nodes!.length - 1,
                            showBottomIcon: true,
                          ),
                          const Divider(
                            height: 20,
                            thickness: 1,
                          ),
                        ]),
                      );
                    })
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
          child: Offstage(offstage: isHistory, child: getButton(context)),
        )
      ],
    );
  }

  Widget getButton(BuildContext context) {
    bool isEnabled = !User().isProgressAnyTourAction &&
        (currentRoute.status == 'Frozen' || currentRoute.status == 'Started');
    bool isStarted = currentRoute.status == 'Started';
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    String buttonLabel = isStarted
        ? AppLocalizations.of(context)!.stopTour
        : AppLocalizations.of(context)!.startTour;

    MaterialStateProperty<Color> backgroundColor = isDarkTheme
        ? MaterialStateProperty.all<Color>(CustomColors.mint)
        : MaterialStateProperty.all<Color>(CustomColors.marine);

    if (isEnabled == false) {
      backgroundColor =
          MaterialStateProperty.all<Color>(CustomColors.lightGrey);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: backgroundColor,
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                else if (states.contains(MaterialState.disabled))
                  return CustomColors.black;
                return CustomColors.white; // Use the component's default.
              },
            )),
        onPressed: isEnabled
            ? () {
                startOrStopTour(context, isStarted);
              }
            : null,
        child: User().isProgressAnyTourAction
            ? CircularProgressIndicator()
            : Text(buttonLabel),
      ),
    );
  }

  void startOrStopTour(BuildContext context, bool isStarted) async {
    if (isStarted) {
      User()
          .confirmFinishDialog(currentRoute.routeId!, context, isStarted, true);
    } else {
      if (User().hasOpenTours()) {
        await _confirmStartTourDialog(context);
      } else if (!User().hasOpenTours()) {
        _startTour(context);
      }
    }
  }

  void _startTour(BuildContext context) async {
    RequestState resultState = await User().startTour(currentRoute.routeId!);
    if (resultState != RequestState.SUCCESS) {
      if (resultState == RequestState.ERROR_FAILED_NO_INTERNET) {
        _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogMessageNoInternet, context);
      } else if (resultState == RequestState.ERROR_TIMEOUT) {
        _showDialog(AppLocalizations.of(context)!.dialogInfoTitle,
            AppLocalizations.of(context)!.dialogTimeoutErrorText, context);
      } else {
        _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogGenericErrorText, context);
      }
    } else {
      Navigator.of(context).pop();
      TabControllerModel().showActiveTourTab();
    }
  }

  Future<void> _confirmStartTourDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.infoTitle,
              style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.openTourAlert,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(
                  AppLocalizations.of(context)!.startTour,
                  style: CustomTextStyles.bodyMarineBold,
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                }),
            TextButton(
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: CustomTextStyles.bodyAzure,
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                }),
          ],
        );
      },
    ).then((confirm) {
      if (confirm) {
        _startTour(context);
      }
    });
  }

  Future<void> _showDialog(
      String title, String message, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((confirm) async {
      return confirm;
    });
  }
}

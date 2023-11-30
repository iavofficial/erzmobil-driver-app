import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/model/BusStop.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:erzmobil_driver/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class TourListViewItem extends StatelessWidget {
  const TourListViewItem(
      {Key? key, required this.tour, required this.showArrow})
      : super(key: key);

  final Tour tour;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      //constraints: BoxConstraints(
      //    minHeight: 100, minWidth: double.infinity, maxHeight: 125),
      margin: EdgeInsets.fromLTRB(10, 10, 5, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  width: 40,
                                  child: Text(
                                    getStartTime(),
                                    style: CustomTextStyles.bodyBlackBold,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                    child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    getStartName(context),
                                    style: CustomTextStyles.bodyBlackBold,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.topLeft,
                                  width: 40,
                                  child: Text(
                                    getEndTime(),
                                    style: CustomTextStyles.bodyBlackBold,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                    child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    getStopName(context),
                                    style: CustomTextStyles.bodyBlackBold,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.bottomLeft,
                child: showStatus()
                    ? Text(
                        getRequestStateString(context),
                        style: TextStyle(color: getRequestColor()),
                      )
                    : Text(''),
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 5, 0),
                  child: Text(getDepartureDayAsString(context),
                      style: CustomTextStyles.bodyBlack))
            ],
          )
        ],
      ),
    );
  }

  String getStartName(BuildContext context) {
    if (tour.nodes != null &&
        tour.nodes!.isEmpty == false &&
        tour.nodes![0].label != null) {
      return tour.nodes![0].label;
    } else {
      return stopFromGeolocation(
          User().stopList!.getBusData(),
          tour.nodes![0].longitude,
          tour.nodes![0].latitude,
          AppLocalizations.of(context)!.start);
    }
  }

  String getStopName(BuildContext context) {
    int index = tour.nodes!.length - 1;
    if (tour.nodes != null && tour.nodes![index].label != null) {
      return tour.nodes![index].label;
    } else {
      return stopFromGeolocation(
          User().stopList!.getBusData(),
          tour.nodes![index].longitude,
          tour.nodes![index].latitude,
          AppLocalizations.of(context)!.destination);
    }
  }

  String stopFromGeolocation(List<BusStop>? availableStops, double long,
      double lat, String defaultName) {
    List matchingStops = [];
    if (availableStops != null) {
      availableStops.forEach((BusStop stop) {
        if (stop.position!.latitude == long && stop.position!.latitude == lat) {
          matchingStops.add(stop);
        }
      });

      if (matchingStops.length == 1) {
        return matchingStops[0].name!;
      }
    }
    return defaultName;
  }

  String getStartTime() {
    if (tour.nodes != null && tour.nodes!.length > 0) {
      return Utils().getTimeAsTimeString(tour.nodes![0].tMin);
    }
    return "";
  }

  String getEndTime() {
    if (tour.nodes != null && tour.nodes!.length > 0) {
      return Utils()
          .getTimeAsTimeString(tour.nodes![tour.nodes!.length - 1].tMin);
    }
    return "";
  }

  String getDepartureDayAsString(BuildContext context) {
    if (tour.nodes != null &&
        tour.nodes!.length > 0 &&
        tour.nodes![0].tMin != null) {
      DateTime departureTime = tour.nodes![0].tMin!;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tourDate =
          DateTime(departureTime.year, departureTime.month, departureTime.day);
      if (tourDate == today) {
        return AppLocalizations.of(context)!.today;
      } else {
        return Utils().getTimeAsDayString(departureTime);
      }
    }
    return "";
  }

  bool showStatus() {
    return true;
    //return tour.status != 'Started' && tour.status != 'Reserved';
  }

  String getRequestStateString(BuildContext context) {
    switch (tour.status) {
      case 'Frozen':
        return AppLocalizations.of(context)!.tourConfirmed;
      case 'Booked':
        return AppLocalizations.of(context)!.tourBooked;
      case 'Started':
        return AppLocalizations.of(context)!.tourStarted;
      case 'Finished':
      default:
        return AppLocalizations.of(context)!.tourCompleted;
    }
  }

  Color getRequestColor() {
    switch (tour.status) {
      case 'Frozen':
      case 'Started':
        return CustomColors.white;
      case 'Booked':
      case 'Finished':
      default:
        return CustomColors.marine;
    }
  }
}

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/journeys/OrderIdListViewItem.dart';
import 'package:erzmobil_driver/model/PhoneNumberList.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:erzmobil_driver/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ActiveTourNextStopHighlightedView extends StatefulWidget {
  const ActiveTourNextStopHighlightedView(
      {Key? key,
      required this.currentNode,
      required this.routeID,
      required this.isStart,
      required this.isNextStop,
      required this.distanceToStop,
      required this.isDestination,
      required this.showBottomIcon})
      : super(key: key);

  final TourNode currentNode;
  final bool isStart;
  final bool isNextStop;
  final bool isDestination;
  final bool showBottomIcon;
  final int distanceToStop;
  final int routeID;

  @override
  ActiveTourNextStopHighlightedState createState() =>
      ActiveTourNextStopHighlightedState();
}

class ActiveTourNextStopHighlightedState
    extends State<ActiveTourNextStopHighlightedView> {
  Map<int, int>? customerStatusList;
  PhoneNumberList phoneNumberList = PhoneNumberList(null);
  bool customerStatusListLoaded = false;

  @override
  void initState() {
    customerStatusList = new Map<int, int>();
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      loadOrderStatus();
      loadPhoneNumbers();
    });
  }

  void loadOrderStatus() async {
    if (widget.currentNode.hopOns.length != 0) {
      Tuple2<RequestState, Map<int, int>?> result =
          await User().loadCustomerStatusForTourNode(widget.currentNode);
      if (result.item1 != RequestState.SUCCESS) {
        String message = AppLocalizations.of(context)!.dialogGenericErrorText;
        if (result.item1 == RequestState.ERROR_TIMEOUT) {
          message = AppLocalizations.of(context)!.dialogTimeoutErrorText;
        } else if (result.item1 == RequestState.ERROR_FAILED_NO_INTERNET) {
          message = AppLocalizations.of(context)!.dialogMessageNoInternet;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            message,
          ),
        ));
      }
      if (mounted) {
        setState(() {
          customerStatusList = result.item2;
          customerStatusListLoaded = true;
        });
      }
    }
  }

  void loadPhoneNumbers() async {
    PhoneNumberList phoneNumbers =
        await User().loadPhoneNumbers(widget.routeID);

    setState(() {
      this.phoneNumberList = phoneNumbers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Consumer<User>(
          builder: (context, user, child) => Card(
                child: _buildWidgets(context),
                color: widget.isNextStop
                    ? CustomColors.azure
                    : CustomColors.marine,
              )),
      onWillPop: () async {
        return !User().isProgressOrderStatus;
      },
    );
  }

  Widget _buildWidgets(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isNextStop ? "Nächster Halt: " : "Aktueller Halt: ",
                style: CustomTextStyles.headlineWhite,
              ),
              Text(getStartTime(), style: CustomTextStyles.headlineWhiteBold),
            ],
          ),
          Text(getDistance(), style: CustomTextStyles.bodyWhite),
          _buildNextStopRow(context, widget.currentNode.label),
          _buildRow(context, AppLocalizations.of(context)!.numberSeats,
              getHopOnsOffsText(),
              textStyle: CustomTextStyles.bodyWhite),
          Offstage(
            offstage: getHopOnSeats() == 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: const Divider(
                height: 0,
                color: CustomColors.white,
                indent: 20,
                endIndent: 20,
                thickness: 1,
              ),
            ),
          ),
          _getCustomerInformation()
        ],
      ),
    );
  }

  Widget _getCustomerInformation() {
    if (widget.currentNode.hopOns.length > 0 && customerStatusListLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (_, index) => OrderIdCheckListItem(
            showDivider: index != widget.currentNode.hopOns.length - 1,
            useWhiteTextStyle: true,
            centerItems: true,
            orderId: widget.currentNode.hopOns[index].orderId,
            number: getPhoneNumberForBookingCode(
                widget.currentNode.hopOns[index].orderId),
            isSelectable: true,
            isChecked:
                customerStatusList![widget.currentNode.hopOns[index].orderId] ==
                    1),
        itemCount: widget.currentNode.hopOns.length,
      );
    } else {
      return Container();
    }
  }

  String? getPhoneNumberForBookingCode(int orderId) {
    String phoneNumber = "";

    if (phoneNumberList.data != null) {
      List phoneNumbers = phoneNumberList.data;
      phoneNumbers.forEach((number) {
        if (number.userId == orderId) {
          phoneNumber = number.number;
          return;
        }
      });
    }

    if (phoneNumber == "") {
      return null;
    }
    return phoneNumber;
  }

  String getDistance() {
    int distance = widget.distanceToStop;
    if (widget.distanceToStop > 1000) {
      return "Entfernung: ${(distance / 1000).round()} km";
    } else {
      return "Entfernung: $distance m";
    }
  }

  String getStartTime() {
    if (widget.currentNode.tMin != null) {
      return getTimeAsTimeString(widget.currentNode.tMin);
    }
    return "";
  }

  String getTimeAsTimeString(DateTime? time) {
    if (time != null) {
      return Utils().getTimeAsTimeString(time);
    } else
      return '';
  }

  String getTimeAsString(String pattern, DateTime? time) {
    if (time != null) {
      return Utils().getTimeAsTimeString(time);
    } else
      return '';
  }

  int getHopOnSeats() {
    int hopOn = 0;

    if (widget.currentNode.hopOns != null) {
      widget.currentNode.hopOns.forEach((v) {
        hopOn += v.seats;
      });
    }

    return hopOn;
  }

  String getHopOnsOffsText() {
    int hopOn = getHopOnSeats();
    int hopOff = 0;

    if (widget.currentNode.hopOffs != null) {
      widget.currentNode.hopOffs.forEach((v) {
        hopOff += v.seats;
      });
    }

    return "+$hopOn / -$hopOff";
  }

  Widget _buildNextStopRow(BuildContext context, String title) {
    return Flexible(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          title,
          style: CustomTextStyles.headlineBigWhiteBold,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String title, String information,
      {TextStyle textStyle = CustomTextStyles.bodyWhiteBold}) {
    return Flexible(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: Text(
                  title,
                  style: textStyle,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Flexible(
              child: Text(
                information,
                style: CustomTextStyles.bodyWhite,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

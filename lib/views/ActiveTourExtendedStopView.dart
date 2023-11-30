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

class ActiveTourExtendedStopView extends StatefulWidget {
  const ActiveTourExtendedStopView(
      {Key? key,
      required this.currentNode,
      required this.routeID,
      required this.isHistoryItem,
      required this.isStart,
      this.isDisabled = false,
      required this.isDestination,
      required this.showBottomIcon})
      : super(key: key);

  final TourNode currentNode;
  final bool isStart;
  final bool isDisabled;
  final bool isDestination;
  final bool showBottomIcon;
  final bool isHistoryItem;
  final int routeID;

  @override
  ActiveTourExtendedStopState createState() => ActiveTourExtendedStopState();
}

class ActiveTourExtendedStopState extends State<ActiveTourExtendedStopView> {
  Map<int, int>? customerStatusList;
  bool customerStatusListLoaded = false;
  PhoneNumberList phoneNumberList = PhoneNumberList(null);

  @override
  void initState() {
    customerStatusList = new Map<int, int>();
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      loadOrderStatus();
      loadPhoneNumbers();
    });
  }

  void loadPhoneNumbers() async {
    PhoneNumberList phoneNumbers =
        await User().loadPhoneNumbers(widget.routeID);

    setState(() {
      this.phoneNumberList = phoneNumbers;
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
      setState(() {
        customerStatusList = result.item2;
        customerStatusListLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Consumer<User>(
          builder: (context, user, child) => (widget.isDisabled
              ? Container(
                  decoration: BoxDecoration(color: CustomColors.lightGrey),
                  child: _buildWidgets(context))
              : _buildWidgets(context))),
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
          _buildRow(
              context, getIcon(), widget.currentNode.label, null, () => null,
              textStyle: CustomTextStyles.bodyBlackBold),
          _buildRow(
              context,
              Text(""),
              AppLocalizations.of(context)!.numberSeatsWheelchair,
              getHopOnsOffsWheelchairText(),
              () => null,
              textStyle: CustomTextStyles.bodyBlack),
          _buildRow(
              context,
              Text(""),
              AppLocalizations.of(context)!.numberSeats,
              getHopOnsOffsText(),
              () => null,
              textStyle: CustomTextStyles.bodyBlack),
          Offstage(
            offstage: getHopOnSeats() == 0,
            child: const Divider(
              height: 5,
              thickness: 1,
            ),
          ),
          _getCustomerInformation(),
          _buildRow(
              context,
              Text(""),
              AppLocalizations.of(context)!.dateTimeStartViewLabel,
              getStartTime(),
              () => null,
              textStyle: CustomTextStyles.bodyBlack),
        ],
      ),
    );
  }

  Widget _getCustomerInformation() {
    //Logger.info("Active Tour View: _getCustomerInformation");
    if (widget.currentNode.hopOns.length > 0 && customerStatusListLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (_, index) => OrderIdCheckListItem(
            showDivider: true,
            centerItems: false,
            useWhiteTextStyle: false,
            orderId: widget.currentNode.hopOns[index].orderId,
            number: getPhoneNumberForBookingCode(
                widget.currentNode.hopOns[index].orderId),
            isSelectable: !widget.isHistoryItem,
            isChecked:
                customerStatusList![widget.currentNode.hopOns[index].orderId] ==
                    1),
        itemCount: widget.currentNode.hopOns.length,
      );
    } else {
      return Container();
    }
  }

  String getStartTime() {
    return Utils().getTimeAsTimeString(widget.currentNode.tMin);
  }

  Icon getIcon() {
    int hopOn = getHopOnSeats();
    int hopOff = getHopOffSeats();

    if (hopOn > 0 && hopOff > 0) {
      return Icon(
        Icons.sync_alt,
        size: 30,
      );
    } else if (hopOn > 0 && hopOff == 0) {
      return Icon(
        Icons.login,
        size: 30,
      );
    } else {
      return Icon(
        Icons.logout,
        size: 30,
      );
    }
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

  int getHopOffSeats() {
    int hopOff = 0;

    if (widget.currentNode.hopOffs != null) {
      widget.currentNode.hopOffs.forEach((v) {
        hopOff += v.seats;
      });
    }

    return hopOff;
  }

  String getHopOnsOffsText() {
    int hopOn = getHopOnSeats();
    int hopOff = getHopOffSeats();

    return "+$hopOn / -$hopOff";
  }

  String getHopOnsOffsWheelchairText() {
    int hopOn = 0;
    int hopOff = 0;

    if (widget.currentNode.hopOns != null) {
      widget.currentNode.hopOns.forEach((v) {
        hopOn += v.seatsWheelchair;
      });
    }
    if (widget.currentNode.hopOffs != null) {
      widget.currentNode.hopOffs.forEach((v) {
        hopOff += v.seatsWheelchair;
      });
    }
    return "+$hopOn / -$hopOff";
  }

  Widget _buildRow(BuildContext context, Widget iconPlaceholder, String title,
      String? information, Function()? onPressed,
      {TextStyle textStyle = CustomTextStyles.bodyBlackBold}) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: (information != null)
            ? Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    alignment: Alignment.topLeft,
                    width: 30,
                    child: iconPlaceholder,
                  ),
                  Flexible(
                    child: Container(
                      alignment: Alignment.topLeft,
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
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Text(
                          information,
                          style: CustomTextStyles.bodyBlack,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    alignment: Alignment.topLeft,
                    width: 20,
                    child: iconPlaceholder,
                  ),
                  Flexible(
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        title,
                        style: textStyle,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
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
}

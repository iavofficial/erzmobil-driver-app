import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/journeys/OrderIdListViewItem.dart';
import 'package:erzmobil_driver/model/PhoneNumber.dart';
import 'package:erzmobil_driver/model/PhoneNumberList.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:erzmobil_driver/views/TourInfoDetailsView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class StopDetailsScreen extends StatefulWidget {
  final TourNode tourNode;
  final bool isStart;
  final bool isDestination;
  final bool isHistoryItem;
  final int routeID;

  const StopDetailsScreen(
      {Key? key,
      required this.tourNode,
      required this.routeID,
      required this.isStart,
      required this.isDestination,
      required this.isHistoryItem})
      : super(key: key);

  @override
  _StopDetailsScreenState createState() => _StopDetailsScreenState();
}

class _StopDetailsScreenState extends State<StopDetailsScreen> {
  Map<int, int>? customerStatusList;
  PhoneNumberList phoneNumberList = PhoneNumberList(null);
  bool customerStatusListLoaded = false;

  @override
  void initState() {
    customerStatusList = new Map<int, int>();
    super.initState();
    try {
      Future.delayed(const Duration(milliseconds: 100), () {
        loadOrderStatus();
        loadPhoneNumbers();
      });
    } catch (e) {
      Logger.info("Could not load stop details");
    }
  }

  void loadPhoneNumbers() async {
    PhoneNumberList phoneNumbers =
        await User().loadPhoneNumbers(widget.routeID);

    if (mounted) {
      setState(() {
        this.phoneNumberList = phoneNumbers;
      });
    }
  }

  void loadOrderStatus() async {
    if (widget.tourNode.hopOns.length != 0) {
      Tuple2<RequestState, Map<int, int>?> result =
          await User().loadCustomerStatusForTourNode(widget.tourNode);
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
        title: Text(AppLocalizations.of(context)!.stopDetails),
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
          return !User().isProgressOrderStatus;
        },
      ),
    );
  }

  Widget _buildWidgets(BuildContext context) {
    return Column(
      children: [
        TourDetailInfoView(
          currentNode: widget.tourNode,
          isStart: widget.isStart,
          isDestination: widget.isDestination,
          showBottomIcon: false,
        ),
        const Divider(
          height: 20,
          thickness: 1,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(15, 15, 10, 5),
          alignment: Alignment.centerLeft,
          child: Text(AppLocalizations.of(context)!.passengerCodes,
              style:
                  CustomTextStyles.themeStyleBoldWhiteForDarkOrBlack(context),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis),
        ),
        const Divider(
          height: 20,
          thickness: 1,
        ),
        widget.tourNode.hopOns.length > 0 && customerStatusListLoaded
            ? Expanded(
                child: ListView.builder(
                    itemCount: widget.tourNode.hopOns.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OrderIdCheckListItem(
                          centerItems: false,
                          useWhiteTextStyle:
                              Theme.of(context).brightness == Brightness.dark
                                  ? true
                                  : false,
                          showDivider: true,
                          orderId: widget.tourNode.hopOns[index].orderId,
                          number: getPhoneNumberForBookingCode(
                              widget.tourNode.hopOns[index].orderId),
                          isSelectable: !widget.isHistoryItem,
                          isChecked: customerStatusList![
                                  widget.tourNode.hopOns[index].orderId] ==
                              1);
                    }),
              )
            : Container(),
      ],
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

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderIdCheckListItem extends StatefulWidget {
  final int orderId;
  final bool isSelectable;
  final bool isChecked;
  final bool showDivider;
  final String? number;
  final bool centerItems;
  final bool useWhiteTextStyle;

  const OrderIdCheckListItem(
      {Key? key,
      required this.orderId,
      required this.isSelectable,
      required this.isChecked,
      required this.showDivider,
      required this.centerItems,
      required this.useWhiteTextStyle,
      required this.number})
      : super(key: key);

  @override
  _OrderIdCheckListItemState createState() => _OrderIdCheckListItemState();
}

class _OrderIdCheckListItemState extends State<OrderIdCheckListItem> {
  bool isSelected = false;
  bool initialIsSelected = false;

  @override
  void initState() {
    initialIsSelected = widget.isChecked;
    isSelected = widget.isChecked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Logger.info(
    //  "Active Tour View: orderId: ${widget.orderId}, isChecked: ${widget.isChecked} isSelected: $isSelected initialIsSelected: $initialIsSelected");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(widget.centerItems ? 0 : 50, 5, 5, 0),
          child: SizedBox(
            height: 30,
            child: Row(
              children: [
                Offstage(
                  offstage: !User().useDirectus,
                  child: InkWell(
                    onTap: () => _callCustomer(widget.number),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: widget.centerItems
                          ? Alignment.center
                          : Alignment.centerLeft,
                      width: 30,
                      child: Icon(
                        Icons.phone,
                        color: widget.number == null
                            ? CustomColors.lightGrey
                            : widget.useWhiteTextStyle
                                ? CustomColors.white
                                : CustomColors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Offstage(
                    offstage: !User().useDirectus,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    )),
                Flexible(
                  child: InkWell(
                    onTap: () async {
                      onBookingCodeTapped();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              widget.orderId.toString(),
                              style: widget.useWhiteTextStyle
                                  ? CustomTextStyles.bodyWhite
                                  : CustomTextStyles.bodyBlack,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Container(
                              child: Offstage(
                                offstage: !isSelected,
                                child: Icon(
                                  Icons.check,
                                  color: widget.useWhiteTextStyle
                                      ? CustomColors.white
                                      : CustomColors.black,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Offstage(
          offstage: !widget.showDivider,
          child: Divider(
            height: 10,
            indent: 30,
            color: widget.useWhiteTextStyle ? CustomColors.white : null,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  void _callCustomer(String? phoneNumber) async {
    if (phoneNumber != null) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunch(launchUri.toString())) {
        await launch(launchUri.toString());
      } else {
        Logger.info('Could not launch $phoneNumber');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context)!.phoneNumberError,
          ),
        ));
        Logger.info('Could not launch $phoneNumber');
      }
    } else {
      Logger.info('Could not launch $phoneNumber');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context)!.noNumberAvailableError,
        ),
      ));
    }
  }

  Future<void> onBookingCodeTapped() async {
    if (widget.isSelectable) {
      isSelected = !isSelected;
      Tuple2<RequestState, int> result =
          await User().setCustomerStatus(widget.orderId, isSelected ? 1 : 0);
      if (mounted) {
        setState(() {
          String message = AppLocalizations.of(context)!.dialogGenericErrorText;
          if (result.item1 != RequestState.SUCCESS) {
            if (result.item1 == RequestState.ERROR_TIMEOUT) {
              message = AppLocalizations.of(context)!.dialogTimeoutErrorText;
            } else if (result.item1 == RequestState.ERROR_FAILED_NO_INTERNET) {
              message = AppLocalizations.of(context)!.dialogMessageNoInternet;
            } else if (result.item2 != 0 && result.item2 != -1) {
              message = message = AppLocalizations.of(context)!
                  .generalErrorMessageActionFailed(result.item2);
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                message,
              ),
            ));
            isSelected = !isSelected;
          }
        });
      }
    }
  }
}

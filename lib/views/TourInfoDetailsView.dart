import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TourDetailInfoView extends StatelessWidget {
  const TourDetailInfoView(
      {Key? key,
      required this.currentNode,
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

  @override
  Widget build(BuildContext context) {
    if (isDisabled) {
      return Container(
          decoration: BoxDecoration(color: CustomColors.lightGrey),
          child: _buildWidgets(context));
    } else {
      return _buildWidgets(context);
    }
  }

  Widget _buildWidgets(BuildContext context) {
    return Container(
      //constraints: BoxConstraints(
      //    minHeight: 100, minWidth: double.infinity, maxHeight: 125),

      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(
              context,
              isStart
                  ? Icon(
                      Icons.location_on,
                      size: 30,
                    )
                  : isDestination
                      ? Icon(
                          Icons.flag,
                          size: 30,
                        )
                      : Icon(
                          Icons.outlined_flag,
                          size: 30,
                        ),
              currentNode.label,
              null,
              () => null,
              textStyle:
                  CustomTextStyles.themeStyleBoldWhiteForDarkOrBlack(context)),
          _buildRow(
              context,
              Text(""),
              AppLocalizations.of(context)!.numberSeats,
              getHopOnsOffsText(),
              () => null,
              textStyle:
                  CustomTextStyles.themeStyleWhiteForDarkOrBlack(context)),
          _buildRow(
              context,
              Text(""),
              AppLocalizations.of(context)!.numberSeatsWheelchair,
              getHopOnsOffsWheelchairText(),
              () => null,
              textStyle:
                  CustomTextStyles.themeStyleWhiteForDarkOrBlack(context)),
          _buildRow(
              context,
              Offstage(
                offstage: isDestination || !showBottomIcon,
                child: Icon(
                  Icons.south,
                  size: 30,
                ),
              ),
              AppLocalizations.of(context)!.dateTimeStartViewLabel,
              getStartTime(),
              () => null,
              textStyle:
                  CustomTextStyles.themeStyleWhiteForDarkOrBlack(context)),
        ],
      ),
    );
  }

  String getStartTime() {
    return Utils().getTimeAsTimeString(currentNode.tMin);
  }

  String getHopOnsOffsText() {
    int hopOn = 0;
    int hopOff = 0;

    if (currentNode.hopOns != null) {
      currentNode.hopOns.forEach((v) {
        hopOn += v.seats;
      });
    }
    if (currentNode.hopOffs != null) {
      currentNode.hopOffs.forEach((v) {
        hopOff += v.seats;
      });
    }

    return "+$hopOn / -$hopOff";
  }

  String getHopOnsOffsWheelchairText() {
    int hopOn = 0;
    int hopOff = 0;

    if (currentNode.hopOns != null) {
      currentNode.hopOns.forEach((v) {
        hopOn += v.seatsWheelchair;
      });
    }
    if (currentNode.hopOffs != null) {
      currentNode.hopOffs.forEach((v) {
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
                        style: Theme.of(context).brightness == Brightness.dark
                            ? CustomTextStyles.bodyWhite
                            : textStyle,
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
                          style: CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                              context),
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
                        style: Theme.of(context).brightness == Brightness.dark
                            ? CustomTextStyles.bodyWhite
                            : textStyle,
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
}

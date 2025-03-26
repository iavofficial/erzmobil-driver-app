import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/views/TourListView.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TourHistory extends StatelessWidget {
  const TourHistory({Key? key}) : super(key: key);

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
        title: Text(AppLocalizations.of(context)!.tourHistory),
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
      body: TourListView(
        routes: User().tourList!.getFinishedTours(),
        isHistory: true,
      ),
    );
  }
}

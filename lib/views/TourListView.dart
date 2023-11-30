import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/journeys/TourDetailsOverview.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:provider/provider.dart';

//import '../model/Location.dart';
import 'TourListViewItem.dart';

class TourListView extends StatelessWidget {
  const TourListView({Key? key, required this.routes, required this.isHistory})
      : super(key: key);

  final List<Tour> routes;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: routes.length > 0
          ? ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: routes.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChangeNotifierProvider.value(
                                value: User(),
                                child: new TourDetailsOverview(
                                  currentRoute: routes[index],
                                  isHistory: isHistory,
                                )),
                      ),
                    );
                  },
                  child: Card(
                      elevation: 5,
                      child: TourListViewItem(
                        tour: routes[index],
                        showArrow: isHistory,
                      )),
                );
              })
          : Stack(
              children: [
                ListView(),
                Container(
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
              ],
            ),
    );
  }
}

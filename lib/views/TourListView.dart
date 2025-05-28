/**
 * Copyright © 2025 IAV GmbH Ingenieurgesellschaft Auto und Verkehr, All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
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
    String emptyText = User().hasValidBusId()
        ? AppLocalizations.of(context)!.noJourneys
        : AppLocalizations.of(context)!.noVehicleConnected;

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
                        color: CustomColors.themeStyleAntraciteForDarkOrWhite(
                            context),
                      ),
                      Text(emptyText),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

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
import 'package:erzmobil_driver/model/RequestState.dart';

import '../views/TourListView.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MyTours extends StatelessWidget {
  const MyTours({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<User>(
          builder: (context, user, child) =>
              User().isLoggedIn() && User().isProgressUpdateTours
                  ? Container(
                      alignment: Alignment.center,
                      child: getLoadingContent(context))
                  : _buildList(context)),
    );
  }

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        RequestState result = await User().loadTours();
        if (result == RequestState.ERROR_FAILED_NO_INTERNET) {
          Future.delayed(Duration.zero, () async {
            _showDialog(
                AppLocalizations.of(context)!.dialogErrorTitle,
                AppLocalizations.of(context)!.dialogMessageNoInternet,
                context,
                null);
          });
        }
      },
      child: User().isLoggedIn() && User().tourList != null
          ? TourListView(
              routes: User().tourList!.getRequestedRoutes(),
              isHistory: false,
            )
          : Container(
              margin: EdgeInsets.all(15),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.noRoutesError),
                  IconButton(
                    onPressed: () {
                      User().loadTours();
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: CustomColors.anthracite,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget getLoadingContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: CustomColors.anthracite,
          ),
          Padding(padding: EdgeInsets.all(5)),
          Text(
            AppLocalizations.of(context)!.loadingJourneys,
          ),
        ],
      ),
    );
  }

  Future<void> _showDialog(String title, String message, BuildContext context,
      Function()? onPressed) async {
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
                  style: CustomTextStyles.bodyMarineBold,
                ),
                onPressed: onPressed == null
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : onPressed),
          ],
        );
      },
    );
  }
}

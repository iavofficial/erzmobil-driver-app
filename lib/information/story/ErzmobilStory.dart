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
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';

import 'ViewPager.dart';

class HeatStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<StoryData> _data = <StoryData>[
      StoryData('StoryHeadline1', 'StoryText1'),
      StoryData('StoryHeadline2', 'StoryText2'),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text('StoryTitle'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: CustomColors.backButtonIconColor,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.copyright_outlined,
            ),
            onPressed: () {
              /*Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new ConsentOverviewScreen()));*/
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            alignment: Alignment.topCenter,
            child: Icon(
              Icons.directions_bus_outlined,
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
              alignment: Alignment.bottomCenter,
              child: ViewPager(
                data: _data,
              ),
            ),
          )
        ],
      ),
    );
  }
}

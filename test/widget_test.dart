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
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/model/Location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test journey status', (WidgetTester tester) async {
    /*Address start = Address(1, "Brünlos-Am Tampel", new Location(54.11, 54.11));
    Address destination =
        Address(1, "Brünlos-Gemeindeverwaltung", new Location(57.11, 57.11));
    BusRoute journey = BusRoute(
        1,
        start,
        destination,
        "19:00",
        DateTime.parse("2021-11-01T13:35:00+00:00"),
        false,
        1,
        1,
        "Started",
        null,
        null);

    JourneyListViewItem item =
        JourneyListViewItem(journey: journey, showArrow: false);

    String dayString = item.getTimeAsDayString();
    expect(dayString, "01.11.2021");

    String timeString = item.getTimeAsTimeString();
    expect(timeString, "13:35");*/
  });
}

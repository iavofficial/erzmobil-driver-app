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
import 'dart:convert';
import 'dart:core';

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/BackendResponse.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:http/http.dart' as http;

class TourList extends BackendResponse {
  List<Tour>? completedRoutes;
  List<Tour>? requestedRoutes;

  @override
  TourList(http.Response? responseOptional) : super(responseOptional) {
    if (responseOptional != null) {
      super.logStatus();
      try {
        if (data != null) {
          data.clear();
        }
        if (completedRoutes != null) {
          completedRoutes!.clear();
        }
        if (requestedRoutes != null) {
          requestedRoutes!.clear();
        }
        final parsed = json
            .decode(utf8.decode(responseOptional.bodyBytes))
            .cast<Map<String, dynamic>>();

        data = parsed.map<Tour>((json) => Tour.fromJson(json)).toList();

        if (data != null) {
          for (Tour tour in data) {
            tour.logJson();
          }
        }

        filterJourneys(data);
      } catch (e) {
        super.markInvalid();
      }
    }
  }

  List<Tour> getFinishedTours() {
    if (completedRoutes == null) {
      return <Tour>[];
    } else {
      return completedRoutes!;
    }
  }

  List<Tour> getRequestedRoutes() {
    if (requestedRoutes == null) {
      requestedRoutes = [];
    }
    return requestedRoutes!.toList();
  }

  bool isNextPlannedTour(int tourId) {
    List<Tour> tours = getRequestedRoutes();
    return tours.first.routeId == tourId;
  }

  void filterJourneys(journeys) {
    if (completedRoutes == null) {
      completedRoutes = [];
    }
    if (requestedRoutes == null) {
      requestedRoutes = [];
    }
    for (Tour tour in journeys) {
      if (tour.nodes != null && tour.nodes!.length > 0) {
        if (tour.status == 'Finished') {
          completedRoutes!.add(tour);
        } else if (tour.status == 'Frozen' ||
            tour.status == 'Started' ||
            tour.status == 'Booked') {
          requestedRoutes!.add(tour);
        }
      } else {
        int routeId = tour.routeId!;
        String status = tour.status!;
        Logger.info(
            "filtering routes: Tour without nodes was removed: $routeId, $status");
      }
    }
    requestedRoutes!
        .sort((a, b) => a.nodes![0].tMin!.compareTo(b.nodes![0].tMin!));
    completedRoutes!
        .sort((a, b) => b.nodes![0].tMin!.compareTo(a.nodes![0].tMin!));
  }

  @override
  Error createErrorObject(String responseBody) {
    throw UnimplementedError();
  }
}

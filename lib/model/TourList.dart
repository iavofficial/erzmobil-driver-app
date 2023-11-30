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

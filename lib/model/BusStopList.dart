import 'dart:convert';
import 'dart:core';

import 'package:erzmobil_driver/model/BackendResponse.dart';
import 'package:erzmobil_driver/model/BusStop.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:http/http.dart' as http;

class BusStopList extends BackendResponse {
  @override
  BusStopList(http.Response? responseOptional) : super(responseOptional) {
    if (responseOptional != null) {
      super.logStatus();
      try {
        final parsed = User().useDirectus
            ? jsonDecode(responseOptional.body)["data"]
                .cast<Map<String, dynamic>>()
            : jsonDecode(responseOptional.body).cast<Map<String, dynamic>>();

        data = parsed
            .map<BusStop>((json) => User().useDirectus
                ? BusStop.fromJsonDirectus(json)
                : BusStop.fromJson(json))
            .toList();
      } catch (e) {
        if (data == null) {
          data = <BusStop>[];
          super.markInvalid();
        }
      }
    } else {
      if (data == null) {
        data = <BusStop>[];
      }
    }
  }

  List<BusStop>? getBusData() {
    if (data == null) {
      data = <BusStop>[];
    }
    return data as List<BusStop>;
  }

  @override
  Error createErrorObject(String responseBody) {
    throw UnimplementedError();
  }
}

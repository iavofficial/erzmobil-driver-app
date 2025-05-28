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

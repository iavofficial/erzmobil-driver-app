import 'dart:convert';

import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/PhoneNumber.dart';

import 'BackendResponse.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:http/http.dart' as http;

class PhoneNumberList extends BackendResponse {
  @override
  PhoneNumberList(http.Response? responseOptional) : super(responseOptional) {
    if (responseOptional != null) {
      super.logStatus();
      try {
        List<PhoneNumber> phoneNumbers = <PhoneNumber>[];

        if (responseOptional.statusCode == 200) {
          if (User().useDirectus) {
            final parsed = jsonDecode(responseOptional.body)["data"]
                .cast<Map<String, dynamic>>();
            phoneNumbers = parsed
                .map<PhoneNumber>((json) => PhoneNumber.fromJson(json))
                .toList();
            data = phoneNumbers;
          } else {
            data = <PhoneNumber>[];
            List<dynamic> numbers = jsonDecode(responseOptional.body);
            numbers.forEach((number) {
              Logger.info("Phone number: $number");
              data.add(PhoneNumber(0, number));
            });
          }

          //data = numbers.map((s) => s as String).toList();
          Logger.info(responseOptional.request.toString());
        } else {
          data = phoneNumbers;
          super.markInvalid();
        }
      } catch (e) {
        if (data == null) {
          data = <PhoneNumber>[];
          super.markInvalid();
        }
      }
    } else {
      if (data == null) {
        data = <PhoneNumber>[];
      }
    }
  }

  @override
  Error createErrorObject(String responseBody) {
    // TODO: implement createErrorObject
    throw UnimplementedError();
  }
}

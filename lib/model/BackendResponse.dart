import 'dart:core';
import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class BackendResponse {
  final http.Response? responseOptional;
  String? _backendErrorCode;
  String? _backendErrorDescription;
  Error? _errorObject;
  bool _isMappingError = false;
  bool _notLoaded = false;
  bool _invalid = false;
  bool _notAuthorized = false;
  bool _outdated = false;

  late List<dynamic> data;

  BackendResponse(this.responseOptional) {
    data = <dynamic>[];
  }

  void logStatus() {
    if (responseOptional != null) {
      Logger.info(responseOptional!.request.toString());
      Logger.info("RESPONSE: ");
      Logger.info("<-- " + responseOptional!.statusCode.toString());
    }
  }

  bool isNotLoaded() {
    return _notLoaded;
  }

  bool isLoaded() {
    return !isNotLoaded();
  }

  void markNotLoaded() {
    _notLoaded = true;
    Logger.info("There seems to be a problem with the internet connection");
  }

  bool isInvalid() {
    return _invalid;
  }

  void markInvalid() {
    _invalid = true;
    Logger.info("Error during backend request: ");
  }

  void markNotAuthorized() {
    _notAuthorized = true;
    Logger.info("Operation not authorized");
  }

  bool isNotAuthorized() {
    return _notAuthorized;
  }

  void markOutdated() {
    _outdated = true;
  }

  bool isOutdated() {
    return _outdated;
  }

  Map<String, String> getHeaders() {
    if (responseOptional != null) {
      return responseOptional!.headers;
    } else
      return Map<String, String>();
  }

  bool isNetworkError() {
    // a response code less than zero indicates that the request was not handled at all
    return getResponseCode() < 0;
  }

  bool isMappingError() {
    return _isMappingError;
  }

  void markAsMappingError() {
    _isMappingError = true;
  }

  int getResponseCode() {
    return responseOptional != null ? responseOptional!.statusCode : -1;
  }

  bool isSuccessful() {
    return responseOptional != null &&
        (responseOptional!.statusCode == 201 ||
            responseOptional!.statusCode == 200 ||
            responseOptional!.statusCode == 204);
  }

  bool isEmpty() {
    return responseOptional == null || responseOptional!.body == null;
  }

  String? body() {
    return responseOptional != null ? responseOptional!.body : null;
  }

  bool isAuthError() {
    return responseOptional != null &&
        (responseOptional!.statusCode == 401 ||
            responseOptional!.statusCode == 403);
  }

  String? getBackendErrorCode() {
    return _backendErrorCode;
  }

  String? getBackendErrorDescription() {
    return _backendErrorDescription;
  }

  bool hasAdditionalErrorDescription() {
    if (_notLoaded) {
      return true;
    }

    return false;
  }

  String getErrorMessage(BuildContext context) {
    if (_notLoaded) {
      return AppLocalizations.of(context)!.lostInternetConnection;
    }
    if (_invalid) {}
    if (_notAuthorized) {}
    return "";
  }

  Error? getError() {
    return _errorObject;
  }

  http.Response? getResponse() {
    return responseOptional;
  }

  Error createErrorObject(String responseBody);
}

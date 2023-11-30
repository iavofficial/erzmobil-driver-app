import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:erzmobil_driver/debug/Logger.dart';

class SecureStorageHolder extends CognitoStorage {
  static final SecureStorageHolder _instance =
      new SecureStorageHolder._internal();

  FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  factory SecureStorageHolder() {
    return _instance;
  }

  SecureStorageHolder._internal();

  @override
  Future<void> clear() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
  }

  @override
  Future getItem(String key) async {
    String item;
    try {
      String? data = await _secureStorage.read(key: key);
      if (data == null) {
        return null;
      }

      item = json.decode(data);
    } catch (e) {
      return null;
    }
    return item;
  }

  @override
  Future removeItem(String key) async {
    final item = getItem(key);
    if (item != null) {
      try {
        await _secureStorage.delete(key: key);
      } catch (e) {}
      return item;
    }
    return null;
  }

  @override
  Future setItem(String key, value) async {
    try {
      await _secureStorage.write(key: key, value: json.encode(value));
    } catch (e) {}

    return getItem(key);
  }
}

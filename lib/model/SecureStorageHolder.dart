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

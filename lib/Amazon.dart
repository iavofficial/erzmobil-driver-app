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
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:erzmobil_driver/model/SecureStorageHolder.dart';

class Amazon {
  Amazon._();

  static initUserPool(String userPoolId, String clientId) {
    Amazon.userPoolId = userPoolId;
    Amazon.clientId = clientId;
    userPool =
        CognitoUserPool(userPoolId, clientId, storage: SecureStorageHolder());
  }

  static late String userPoolId = '';
  static late String clientId = '';

  static const String region = '';
  static const String baseUrl = '';

  static late CognitoUserPool userPool;
}

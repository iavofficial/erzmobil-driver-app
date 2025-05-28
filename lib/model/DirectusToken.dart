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
class DirectusToken {
  final String? accessToken;
  final DateTime? expires;
  final String? refreshToken;

  const DirectusToken(this.accessToken, this.expires, this.refreshToken);

  factory DirectusToken.fromJson(Map<String, dynamic> json) {
    return DirectusToken(
        json['accessToken'],
        json['expires'] != null
            ? DateTime.parse(json['expires'] as String)
            : null,
        json['refreshToken']);
  }

  @override
  String toString() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (accessToken != null) {
      data['access_token'] = this.accessToken;
    }
    if (expires != null) {
      data['expires'] = this.expires;
    }
    if (refreshToken != null) {
      data['refresh_token'] = this.refreshToken;
    }

    return data.toString();
  }
}

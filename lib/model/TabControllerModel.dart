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
import 'package:flutter/foundation.dart';
import 'package:erzmobil_driver/model/User.dart';

class TabControllerModel extends ChangeNotifier {
  // Private constructor
  TabControllerModel._privateConstructor();

  // Static instance of the class
  static final TabControllerModel _instance =
      TabControllerModel._privateConstructor();

  // Factory constructor to return the same instance
  factory TabControllerModel() {
    return _instance;
  }

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void showAccountTab() {
    setTabIndex(0);
    notifyListeners();
  }

  void showMyToursTab() {
    setTabIndex(1);
    notifyListeners();
  }

  void showActiveTourTab() {
    setTabIndex(2);
    notifyListeners();
  }

  void showInformationTab() {
    int index = User().isLoggedIn() ? 3 : 1;
    setTabIndex(index);
    notifyListeners();
  }

  void setTabIndex(int index) {
    if (index != _currentIndex) {
      _currentIndex = index;
    }
  }

  void computeInitialIndex() {
    bool hasCurrentTour = User().getCurrentTour() != null;

    if (User().isLoggedIn()) {
      _currentIndex = hasCurrentTour ? 2 : 1;
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHolder {
  static final PreferenceHolder _instance = new PreferenceHolder._internal();

  SharedPreferences? _sharedPreferences;

  factory PreferenceHolder() {
    return _instance;
  }

  PreferenceHolder._internal();

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  SharedPreferences? getPreferences() {
    return _sharedPreferences;
  }
}

import 'dart:async';

import 'package:erzmobil_driver/model/User.dart';
import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:geolocator/geolocator.dart';

class LocationManager {
  static final LocationManager _instance = new LocationManager._internal();

  StreamSubscription<Position>? positionStream;
  bool serviceEnabled = false;
  bool hasPermissions = false;
  Position? _currentLocation;
  List<LocationListener> listeners = [];

  factory LocationManager() {
    return _instance;
  }

  LocationManager._internal();

  void register(LocationListener listener) {
    if (!listeners.contains(listener)) {
      listeners.add(listener);
    }
  }

  void unregister(LocationListener listener) {
    if (listeners.contains(listener)) {
      listeners.remove(listener);
    }
  }

  Future<Position?> _determinePosition() async {
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Logger.info('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Logger.info('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    hasPermissions = true;

    _currentLocation = await Geolocator.getCurrentPosition();
    return _currentLocation;
  }

  Position? getCurrentLocation() {
    return _currentLocation;
  }

  void initLocationService() async {
    await _determinePosition();

    if (serviceEnabled && hasPermissions && positionStream == null ||
        positionStream!.isPaused) {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      );

      Logger.info("start listening for location updates");
      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? position) {
        if (position != null && User().isLoggedIn()) {
          Logger.info("onLocationChanged: " + position.toString());
          _notifyListeners(position);
          _currentLocation = position;
        }
        print(position == null
            ? 'Unknown'
            : position.latitude.toString() +
                ', ' +
                position.longitude.toString());
      });
    } else if (positionStream != null && positionStream!.isPaused) {
      resumeLocationUpdates();
    }
  }

  void pauseLocationUpdates() {
    if (positionStream != null) {
      Logger.info("pause listening for location updates");
      positionStream!.pause();
    }
  }

  void resumeLocationUpdates() {
    if (positionStream != null) {
      Logger.info("resume listening for location updates");
      positionStream!.resume();
    }
  }

  void _notifyListeners(Position newLocation) {
    listeners.forEach((listener) {
      listener.onLocationChanged(newLocation);
    });
  }
}

class LocationListener {
  void onLocationChanged(Position location) {}
}

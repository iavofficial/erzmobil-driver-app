import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math';

class Utils {
  static final int RADIUS_OF_EARTH_IN_KILOMETER = 6371;
  static final double STOP_RANGE_IN_KILOMETER = 0.025;
  static final String NO_DATA = "---";

  String getTimeAsTimeString(DateTime? date) {
    return _getTimeAsString(date, 'kk:mm');
  }

  String getDateAsString(DateTime? date) {
    if (date == null) {
      return NO_DATA;
    }
    return _getTimeAsString(date, 'dd.MM.yyyy kk:mm');
  }

  String getTimeAsDayString(DateTime date) {
    return _getTimeAsString(date, 'dd.MM.yyyy');
  }

  String _getTimeAsString(DateTime? time, String pattern) {
    if (time != null) {
      return DateFormat(pattern).format(time.toLocal());
    } else
      return '';
  }

  static double getDistanceBetweenTwoPointsInKilometer(
      LatLng startPoint, LatLng endPoint) {
    double lat1 = startPoint.latitude;
    double lat2 = endPoint.latitude;
    double lon1 = startPoint.longitude;
    double lon2 = endPoint.longitude;
    double dLat = radians(lat2 - lat1);
    double dLon = radians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(a));
    double result = RADIUS_OF_EARTH_IN_KILOMETER * c;
    Logger.info("getDistanceBetweenTwoPointsInKilometer: " + result.toString());
    return result;
  }

  static Tuple2<bool, int> isWithInStopRange(TourNode node, Position location) {
    LatLng currLatLng = LatLng(location.latitude, location.longitude);
    LatLng lastNode = LatLng(node.latitude, node.longitude);

    double distance =
        Utils.getDistanceBetweenTwoPointsInKilometer(currLatLng, lastNode);

    Logger.info("Active Tour: Distance in m to current stop: " +
        (distance * 1000).toString());

    if (distance <= STOP_RANGE_IN_KILOMETER) {
      return Tuple2(true, (distance * 1000).round());
    }
    return Tuple2(false, (distance * 1000).round());
  }

  static String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 Bytes";
    const int k = 1024;
    const List<String> sizes = ["Bytes", "kB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(k)).floor();
    double size = bytes / pow(k, i);
    return "${size.toStringAsFixed(decimals)} ${sizes[i]}";
  }
}

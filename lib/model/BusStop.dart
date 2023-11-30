import 'package:latlong2/latlong.dart';

class BusStop {
  final int id;
  final int communityId;
  final String? name;
  final LatLng? position;

  const BusStop(this.id, this.communityId, this.name, this.position);

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(json['id'], json['communityId'], json['name'],
        LatLng(json["latitude"] as double, json["longitude"] as double));
  }

  factory BusStop.fromJsonDirectus(Map<String, dynamic> json) {
    return BusStop(
        json['id'],
        json['communityId'],
        json['name'],
        LatLng(json["location"]["coordinates"][1] as double,
            json["location"]["coordinates"][0] as double));
  }
}

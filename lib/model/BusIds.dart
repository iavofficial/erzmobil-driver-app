import 'package:latlong2/latlong.dart';

class BusId {
  final int id;

  const BusId(this.id);

  factory BusId.fromJson(Map<String, dynamic> json) {
    return BusId(json['id']);
  }
}

class Depot {
  final LatLng? location;

  const Depot(this.location);

  factory Depot.fromJson(Map<String, dynamic> json) {
    return Depot(
        LatLng(json["latitude"] as double, json["longitude"] as double));
  }
}

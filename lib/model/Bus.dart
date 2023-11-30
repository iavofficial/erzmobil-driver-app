import 'package:latlong2/latlong.dart';

class Bus {
  final int id;
  final int communityId;
  final int seats;
  final String? name;
  final Depot? depot;

  const Bus(this.id, this.communityId, this.seats, this.name, this.depot);

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
        json['id'],
        json['communityId'],
        json['seats'] as int,
        json['name'],
        json['depot'] != null ? new Depot.fromJson(json['depot']) : null);
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

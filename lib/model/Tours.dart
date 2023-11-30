import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:intl/intl.dart';

class Tour {
  final int? routeId;
  final int busId;
  final String? status;
  final List<TourNode>? nodes;

  const Tour(this.routeId, this.busId, this.status, this.nodes);

  factory Tour.fromJson(Map<String, dynamic> json) {
    List<TourNode> _tmpNodes = [];
    if (json['nodes'] != null) {
      json['nodes'].forEach((v) {
        _tmpNodes.add(new TourNode.fromJson(v));
      });
    }
    return Tour(
        json['routeId'], json['busId'], json['status'] as String, _tmpNodes);
  }

  void logJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['routeId'] = this.routeId;
    if (routeId != null) {
      data['routeId'] = this.routeId;
    }
    data['status'] = this.status;
    int idx = 0;
    nodes!.forEach((v) {
      String label = v.label;
      if (label != null) {
        data['node$idx'] = label;
        idx++;
      }
      idx = 0;
      DateTime? date = v.tMin;
      if (date != null) {
        data['tMin$idx'] = getFormatISOTime(date);
        idx++;
      }
    });
    Logger.info(data.toString());
  }
}

String getFormatISOTime(DateTime date) {
  var duration = date.timeZoneOffset;
  if (duration.isNegative)
    return (DateFormat("yyyy-MM-ddTHH:mm:ss").format(date) +
        "-${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
  else
    return (DateFormat("yyyy-MM-ddTHH:mm:ss").format(date) +
        "+${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
}

class TourNode {
  final double latitude;
  final double longitude;
  final String label;
  final DateTime? tMin;
  final DateTime? tMax;
  final List<HopOnsAndOffs> hopOns;
  final List<HopOnsAndOffs> hopOffs;

  const TourNode(this.latitude, this.longitude, this.label, this.tMin,
      this.tMax, this.hopOns, this.hopOffs);

  factory TourNode.fromJson(Map<String, dynamic> json) {
    List<HopOnsAndOffs> _tmpHopOns = [];
    if (json['hopOns'] != null) {
      json['hopOns'].forEach((v) {
        _tmpHopOns.add(new HopOnsAndOffs.fromJson(v));
      });
    }
    List<HopOnsAndOffs> _tmpHopOffs = [];
    if (json['hopOffs'] != null) {
      json['hopOffs'].forEach((v) {
        _tmpHopOffs.add(new HopOnsAndOffs.fromJson(v));
      });
    }
    return TourNode(
        json['latitude'] as double,
        json['longitude'] as double,
        json['label'] as String,
        json['tMin'] != null ? DateTime.parse(json['tMin'] as String) : null,
        json['tMax'] != null ? DateTime.parse(json['tMax'] as String) : null,
        _tmpHopOns,
        _tmpHopOffs);
  }

  String toString() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = label;
    return data.toString();
  }
}

class HopOnsAndOffs {
  final int orderId;
  final int seats;
  final int seatsWheelchair;

  const HopOnsAndOffs(this.orderId, this.seats, this.seatsWheelchair);

  factory HopOnsAndOffs.fromJson(Map<String, dynamic> json) {
    return HopOnsAndOffs(json['orderId'] as int, json['seats'] as int,
        json['seatsWheelchair'] as int);
  }
}

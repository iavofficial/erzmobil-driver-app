import 'package:erzmobil_driver/model/Location.dart';
import 'package:intl/intl.dart';

class BusPosition {
  final LastPosition? lastPosition;
  final DateTime? lastPositionUpdatedAt;

  const BusPosition(this.lastPosition, this.lastPositionUpdatedAt);

  factory BusPosition.fromJson(Map<String, dynamic> json) {
    return BusPosition(
      json['last_position'] != null
          ? new LastPosition.fromJson(json['last_position'])
          : null,
      json['last_position_updated_at'] != null
          ? DateTime.parse(json['last_position_updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lastPosition != null) {
      data['last_position'] = this.lastPosition!.toJson();
    }
    data['last_position_updated_at'] =
        getFormatISOTime(this.lastPositionUpdatedAt!);
    return data;
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
}

class LastPosition {
  List<double>? coordinates;
  String? type;

  LastPosition({this.coordinates, this.type});

  LastPosition.fromJson(Map<String, dynamic> json) {
    coordinates = json['coordinates'].cast<double>();
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coordinates'] = this.coordinates;
    data['type'] = this.type;
    return data;
  }
}

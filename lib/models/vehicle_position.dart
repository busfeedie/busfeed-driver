import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class VehiclePosition {
  final String id;

  final double lon;
  final double lat;
  final double? bearing;
  final double? odometer;
  final double? speed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? measuredAt;
  final String tripId;
  final String appId;
  final String vehicleId;

  VehiclePosition(
      {required this.id,
      required this.appId,
      required this.lat,
      required this.lon,
      this.bearing,
      this.odometer,
      this.speed,
      this.createdAt,
      this.updatedAt,
      this.measuredAt,
      required this.tripId,
      required this.vehicleId});

  factory VehiclePosition.fromJson(Map<String, dynamic> json) {
    return VehiclePosition(
      id: json['id'].toString(),
      lon: json['lon'].toDouble(),
      lat: json['lat'].toDouble(),
      // bearing: json['bearing']?.toDouble(),
      // odometer: json['odometer']?.toDouble(),
      // speed: json['speed']?.toDouble(),
      // measuredAt: json['measured_at'] != null
      //     ? DateTime.parse(json['measured_at'])
      //     : null,
      // createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tripId: json['trip_id'].toString(),
      appId: json['app_id'].toString(),
      vehicleId: json['vehicle_id'].toString(),
    );
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      'latitude': lat,
      'longitude': lon,
      'accuracy': 0.0,
      'altitude': 0.0,
      'speed': speed ?? 0.0,
      'speed_accuracy': 0.0,
      'heading': bearing ?? 0.0,
      'time': measuredAt?.millisecondsSinceEpoch ?? 0.0,
      'floor': 0.0,
      'vertical_accuracy': 0.0,
    });
  }

  final markerId = const MarkerId("vehicle");

  Duration timeSinceLastUpdate() {
    return DateTime.now().difference(updatedAt!);
  }

  Marker toMarker() {
    return Marker(
        markerId: markerId,
        position: LatLng(lat, lon),
        infoWindow: InfoWindow(
            title: 'Updated ${timeSinceLastUpdate().inMinutes}m ago'));
  }
}

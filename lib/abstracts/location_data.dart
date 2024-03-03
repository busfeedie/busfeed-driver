import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:busfeed_driver/abstracts/pointable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData with Pointable {
  final double? bearing;
  final double? speed;
  DateTime? measuredAt;

  LocationData(
      {required double lat,
      required double lon,
      this.bearing,
      this.speed,
      this.measuredAt}) {
    this.lat = lat;
    this.lon = lon;
    measuredAt ??= DateTime.now();
  }

  @override
  final markerId = const MarkerId("location");

  @override
  Marker toMarker() {
    return Marker(
      markerId: markerId,
      position: LatLng(lat!, lon!),
      rotation: bearing ?? 0.0,
      // icon: Icons.directions_bus
    );
  }

  LocationData.fromBackGroundLocationData(
      BackgroundLocationUpdateData locationData)
      : this(
            lat: locationData.lat,
            lon: locationData.lon,
            bearing: locationData.course,
            speed: locationData.speed);
}

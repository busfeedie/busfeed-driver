import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin Pointable {
  double? lat;
  double? lon;

  pointFromJson(Map<String, dynamic> json) {
    lat = json['lat']?.toDouble();
    lon = json['lon']?.toDouble();
  }

  final markerId = MarkerId("point-${DateTime.now().millisecondsSinceEpoch}");

  String? get infoWindowTitle => null;

  Marker? toMarker() {
    if (lat == null || lon == null) {
      return null;
    }
    return Marker(
      markerId: markerId,
      position: LatLng(lat!, lon!),
      infoWindow: infoWindowTitle != null
          ? InfoWindow(title: infoWindowTitle)
          : InfoWindow.noText,
    );
  }
}

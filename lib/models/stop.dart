import 'package:busfeed_driver/models/pointable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'model.dart';

class Stop extends Model with Pointable {
  final String gtfsStopId;
  final String? stopCode;
  final String? stopName;
  final String? ttsStopName;
  final String? stopDesc;
  final String? gtfsZoneId;
  final String? stopUrl;
  final LocationType locationType;
  final String? parentStationId;
  final String? stopTimezone;
  final WheelchairBoarding wheelchairBoarding;
  final String? gtfsLevelId;
  final String? platformCode;

  Stop({
    required super.id,
    required super.appId,
    required this.gtfsStopId,
    this.stopCode,
    this.stopName,
    this.ttsStopName,
    this.stopDesc,
    this.gtfsZoneId,
    this.stopUrl,
    this.locationType = LocationType.stop,
    this.parentStationId,
    this.stopTimezone,
    this.wheelchairBoarding = WheelchairBoarding.unknown,
    this.gtfsLevelId,
    this.platformCode,
    required double lat,
    required double lon,
    super.createdAt,
    super.updatedAt,
  }) {
    this.lat = lat;
    this.lon = lon;
  }

  Stop.fromJson(Map<String, dynamic> json)
      : gtfsStopId = json['gtfs_stop_id'].toString(),
        stopCode = json['stop_code'],
        stopName = json['stop_name'],
        ttsStopName = json['tts_stop_name'],
        stopDesc = json['stop_desc'],
        gtfsZoneId = json['gtfs_zone_id'],
        stopUrl = json['stop_url'],
        locationType = LocationTypeExtension.fromJson(json['location_type']),
        parentStationId = json['parent_station_id'],
        stopTimezone = json['stop_timezone'],
        wheelchairBoarding =
            WheelchairBoardingExtension.fromJson(json['wheelchair_boarding']),
        gtfsLevelId = json['gtfs_level_id'],
        platformCode = json['platform_code'],
        super.fromJson(json) {
    pointFromJson(json);
  }

  @override
  double get lat => super.lat!;

  @override
  double get lon => super.lon!;

  @override
  MarkerId get markerId => MarkerId("stop-$id");
}

enum WheelchairBoarding { unknown, accessible, notAccessible }

extension WheelchairBoardingExtension on WheelchairBoarding {
  static WheelchairBoarding fromJson(String? wheelchairBoarding) {
    switch (wheelchairBoarding) {
      case 'unknown':
        return WheelchairBoarding.unknown;
      case 'accessible':
        return WheelchairBoarding.accessible;
      case 'not_accessible':
        return WheelchairBoarding.notAccessible;
      default:
        return WheelchairBoarding.unknown;
    }
  }
}

enum LocationType { stop, station, entrance, genericNode, boardingArea }

extension LocationTypeExtension on LocationType {
  static LocationType fromJson(String? locationType) {
    switch (locationType) {
      case 'stop':
        return LocationType.stop;
      case 'station':
        return LocationType.station;
      case 'entrance':
        return LocationType.entrance;
      case 'generic_node':
        return LocationType.genericNode;
      case 'boarding_area':
        return LocationType.boardingArea;
      default:
        return LocationType.stop;
    }
  }
}

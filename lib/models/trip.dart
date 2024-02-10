import 'dart:convert';

import 'package:busfeed_driver/models/user.dart';
import 'package:http/http.dart' as http;

enum Direction { inbound, outbound }

enum WheelchairAccessible {
  wheelchairAccessibilityUnknown,
  wheelchairAccessible,
  wheelchairNotAccessible
}

extension WheelchairAccessibleExtension on WheelchairAccessible {
  static WheelchairAccessible fromJson(String wheelchairAccessible) {
    switch (wheelchairAccessible) {
      case 'wheelchair_accessibility_unknown':
        return WheelchairAccessible.wheelchairAccessibilityUnknown;
      case 'wheelchair_accessible':
        return WheelchairAccessible.wheelchairAccessible;
      case 'wheelchair_not_accessible':
        return WheelchairAccessible.wheelchairNotAccessible;
      default:
        throw Exception(
            'Unknown wheelchair accessible value $wheelchairAccessible');
    }
  }
}

enum BikesAllowed { bikesUnknown, bikesAllowed, bikesNotAllowed }

extension BikesAllowedExtension on BikesAllowed {
  static BikesAllowed fromJson(String bikesAllowed) {
    switch (bikesAllowed) {
      case 'bikes_unknown':
        return BikesAllowed.bikesUnknown;
      case 'bikes_allowed':
        return BikesAllowed.bikesAllowed;
      case 'bikes_not_allowed':
        return BikesAllowed.bikesNotAllowed;
      default:
        throw Exception('Unknown bikes allowed value $bikesAllowed');
    }
  }
}

class Trip {
  final String id;
  final String appId;
  final String routeId;
  final String blockId;
  final String shapeId;
  final String serviceId;
  final String serviceType;
  final String gtfsTripId;
  final String tripHeadsign;
  final String tripShortName;
  final Direction direction;
  final WheelchairAccessible wheelchairAccessible;
  final BikesAllowed bikesAllowed;

  Trip(
      {required this.id,
      required this.appId,
      required this.routeId,
      required this.blockId,
      required this.shapeId,
      required this.serviceId,
      required this.serviceType,
      required this.gtfsTripId,
      required this.tripHeadsign,
      required this.tripShortName,
      required this.direction,
      required this.wheelchairAccessible,
      required this.bikesAllowed});

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      appId: json['app_id'],
      routeId: json['route_id'],
      blockId: json['block_id'],
      shapeId: json['shape_id'],
      serviceId: json['service_id'],
      serviceType: json['service_type'],
      gtfsTripId: json['gtfs_trip_id'],
      tripHeadsign: json['trip_headsign'],
      tripShortName: json['trip_short_name'],
      direction: Direction.values[json['direction']],
      wheelchairAccessible:
          WheelchairAccessibleExtension.fromJson(json['wheelchair_accessible']),
      bikesAllowed: BikesAllowedExtension.fromJson(json['bikes_allowed']),
    );
  }

  static Future<List<Trip>> fetchTrips(User user) async {
    final url = Uri.http('localhost:3000', 'api/trips');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': user.authorization,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch trips');
    }
    var responseBody = jsonDecode(response.body);
    return responseBody.map<Trip>((json) => Trip.fromJson(json)).toList();
  }
}

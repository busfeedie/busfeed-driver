import 'dart:convert';

import 'package:busfeed_driver/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constants/api.dart';
import 'route.dart';

enum Direction { inbound, outbound }

extension DirectionExtension on Direction {
  static Direction fromJson(String direction) {
    switch (direction) {
      case 'outbound':
        return Direction.outbound;
      case 'inbound':
        return Direction.inbound;
      default:
        throw Exception('Unknown direction value $direction');
    }
  }
}

enum WheelchairAccessible {
  wheelchairAccessibilityUnknown,
  wheelchairAccessible,
  wheelchairNotAccessible
}

extension WheelchairAccessibleExtension on WheelchairAccessible {
  static WheelchairAccessible fromJson(String? wheelchairAccessible) {
    switch (wheelchairAccessible) {
      case 'wheelchair_accessibility_unknown':
        return WheelchairAccessible.wheelchairAccessibilityUnknown;
      case 'wheelchair_accessible':
        return WheelchairAccessible.wheelchairAccessible;
      case 'wheelchair_not_accessible':
        return WheelchairAccessible.wheelchairNotAccessible;
      default:
        return WheelchairAccessible.wheelchairAccessibilityUnknown;
    }
  }
}

enum BikesAllowed { bikesUnknown, bikesAllowed, bikesNotAllowed }

extension BikesAllowedExtension on BikesAllowed {
  static BikesAllowed fromJson(String? bikesAllowed) {
    switch (bikesAllowed) {
      case 'bikes_unknown':
        return BikesAllowed.bikesUnknown;
      case 'bikes_allowed':
        return BikesAllowed.bikesAllowed;
      case 'bikes_not_allowed':
        return BikesAllowed.bikesNotAllowed;
      default:
        return BikesAllowed.bikesUnknown;
    }
  }
}

class Days {
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

  Days(
      {required this.monday,
      required this.tuesday,
      required this.wednesday,
      required this.thursday,
      required this.friday,
      required this.saturday,
      required this.sunday});

  factory Days.fromJson(Map<String, dynamic> json) {
    return Days(
      monday: json['monday'] == true,
      tuesday: json['tuesday'] == true,
      wednesday: json['wednesday'] == true,
      thursday: json['thursday'] == true,
      friday: json['friday'] == true,
      saturday: json['saturday'] == true,
      sunday: json['sunday'] == true,
    );
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
  final Days? days;
  final Duration? startTime;

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
      required this.bikesAllowed,
      this.days,
      this.startTime});

  startDateTime(DateTime date) {
    return date.add(startTime!);
  }

  String startTimeString() {
    if (startTime == null) {
      return '';
    }
    final hours = startTime!.inHours;
    final minutes = (startTime!.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'].toString(),
      appId: json['app_id'].toString(),
      routeId: json['route_id'].toString(),
      blockId: json['block_id'].toString(),
      shapeId: json['shape_id'].toString(),
      serviceId: json['service_id'].toString(),
      serviceType: json['service_type'].toString(),
      gtfsTripId: json['gtfs_trip_id'].toString(),
      tripHeadsign: json['trip_headsign'],
      tripShortName: json['trip_short_name'],
      direction: DirectionExtension.fromJson(json['direction']),
      wheelchairAccessible:
          WheelchairAccessibleExtension.fromJson(json['wheelchair_accessible']),
      bikesAllowed: BikesAllowedExtension.fromJson(json['bikes_allowed']),
      days: json['days'] != null ? Days.fromJson(json['days']) : null,
      startTime: Duration(seconds: json['first_stop_time'] ?? 0),
    );
  }

  static Future<List<Trip>> fetchTrips(
      {required User user, TripRoute? route, DateTime? dateTime}) async {
    final queryParameters = <String, String>{
      if (route != null) 'route_id': route.id,
      if (dateTime != null) 'date': DateFormat('yyyy-MM-dd').format(dateTime),
    };
    final url = Uri.https(API_URL, 'api/trips', queryParameters);
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

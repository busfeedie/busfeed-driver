import 'package:busfeed_driver/models/user.dart';
import 'package:busfeed_driver/models/vehicle_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../constants/gtfs.dart';
import '../helpers/api.dart';
import 'route.dart';
import 'stop_time.dart';

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
  bool activeTracking;
  StopTime? firstStopTime;

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
      this.activeTracking = false,
      this.days,
      this.startTime,
      this.firstStopTime});

  static const _storage = FlutterSecureStorage();
  static const String _trackingTripKey = 'trackingTripId';

  startDateTimeFromDate(DateTime date) {
    return date.add(startTime!);
  }

  statusText() {
    if (overdue) {
      return 'Overdue';
    }
    return activeTracking ? 'Tracked' : 'Not tracking';
  }

  DateTime get startDateTimeToday {
    final now = DateTime.now();
    final timeAtMidnight = DateTime(now.year, now.month, now.day);
    return startDateTimeFromDate(timeAtMidnight);
  }

  bool get overdue {
    return startDateTimeToday.isBefore(DateTime.now()) && !activeTracking;
  }

  statusColor() {
    if (overdue) {
      return Colors.orange;
    }
    return activeTracking ? Colors.green : Colors.yellow;
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
      activeTracking: json['active'] == true,
      firstStopTime: json['first_stop'] != null
          ? StopTime.fromJson(json['first_stop'])
          : null,
    );
  }

  static Future<List<Trip>> fetchTrips(
      {required User user, TripRoute? route, DateTime? dateTime}) async {
    final queryParameters = <String, String>{
      if (route != null) 'route_id': route.id,
      if (dateTime != null) 'date': DateFormat('yyyy-MM-dd').format(dateTime),
    };
    var responseBody = await HttpClient().makeRequest(
        user: user, path: 'api/trips', queryParameters: queryParameters);
    return responseBody.map<Trip>((json) => Trip.fromJson(json)).toList();
  }

  Future<VehiclePosition?> fetchLastLocation({required User user}) async {
    var responseBody = await HttpClient()
        .makeRequest(user: user, path: 'api/trips/$id/latest_position');
    if (responseBody == null) {
      return null;
    }
    return VehiclePosition.fromJson(responseBody);
  }

  void startTracking() async {
    _writeTripIdToStore();
  }

  _writeTripIdToStore() async {
    await _storage.write(key: _trackingTripKey, value: id);
  }

  static Future<String?> tripIdFromStorage() async {
    return _storage.read(key: _trackingTripKey);
  }
}

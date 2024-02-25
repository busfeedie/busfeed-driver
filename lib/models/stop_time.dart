import 'model.dart';
import 'stop.dart';

class StopTime extends Model {
  String tripId;
  String stopId;
  Stop? stop;
  int stopSequence;
  String? stopHeadsign;
  PickupType pickupType;
  PickupType dropoffType;
  ContinuousPickupType continuousPickup;
  ContinuousPickupType continuousDropoff;
  double? shapeDistTraveled;
  bool timepoint;
  Duration arrivalDuration;
  Duration departureDuration;

  StopTime({
    required super.id,
    required super.appId,
    required this.tripId,
    required this.stopId,
    this.stop,
    required this.stopSequence,
    this.stopHeadsign,
    this.pickupType = PickupType.regular,
    this.dropoffType = PickupType.regular,
    this.continuousPickup = ContinuousPickupType.none,
    this.continuousDropoff = ContinuousPickupType.none,
    this.shapeDistTraveled,
    this.timepoint = true,
    required this.arrivalDuration,
    required this.departureDuration,
    super.createdAt,
    super.updatedAt,
  });

  StopTime.fromJson(super.json)
      : tripId = json['trip_id'].toString(),
        stopId = json['stop_id'].toString(),
        stop = json['stop'] != null ? Stop.fromJson(json['stop']) : null,
        stopSequence = json['stop_sequence'],
        stopHeadsign = json['stop_headsign'],
        pickupType = PickupTypeExtension.fromJson(json['pickup_type']),
        dropoffType = PickupTypeExtension.fromJson(json['dropoff_type']),
        continuousPickup =
            ContinuousPickupTypeExtension.fromJson(json['continuous_pickup']),
        continuousDropoff =
            ContinuousPickupTypeExtension.fromJson(json['continuous_dropoff']),
        shapeDistTraveled = json['shape_dist_traveled']?.toDouble(),
        timepoint = json['timepoint'] == true,
        arrivalDuration = Duration(seconds: json['arrival_time']),
        departureDuration = Duration(seconds: json['arrival_time']),
        super.fromJson();

  String get scheduledToDepartIn {
    final now = DateTime.now();
    final diff = departureTime.difference(now);
    if (diff.inMinutes > 60) {
      return 'Due to depart in ${diff.inHours} hours';
    } else {
      return 'Due to depart in ${diff.inMinutes} minutes';
    }
  }

  DateTime get departureTime {
    final now = DateTime.now();
    final timeAtMidnight = DateTime(now.year, now.month, now.day);
    return timeAtMidnight.add(departureDuration);
  }
}

enum PickupType { regular, none, phone, coordinate }

extension PickupTypeExtension on PickupType {
  static PickupType fromJson(String? pickupType) {
    switch (pickupType) {
      case 'regular':
        return PickupType.regular;
      case 'none':
        return PickupType.none;
      case 'phone':
        return PickupType.phone;
      case 'coordinate':
        return PickupType.coordinate;
      default:
        return PickupType.regular;
    }
  }
}

enum ContinuousPickupType { continuous, none, phone, coordinate }

extension ContinuousPickupTypeExtension on ContinuousPickupType {
  static ContinuousPickupType fromJson(String? pickupType) {
    switch (pickupType) {
      case 'continuous':
        return ContinuousPickupType.continuous;
      case 'none':
        return ContinuousPickupType.none;
      case 'phone':
        return ContinuousPickupType.phone;
      case 'coordinate':
        return ContinuousPickupType.coordinate;
      default:
        return ContinuousPickupType.none;
    }
  }
}

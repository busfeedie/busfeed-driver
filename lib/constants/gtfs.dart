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

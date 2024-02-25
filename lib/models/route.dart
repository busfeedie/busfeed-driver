import 'package:busfeed_driver/helpers/api.dart';
import 'package:busfeed_driver/models/user.dart';

class TripRoute {
  final String id;
  final String appId;
  final String gtfsRouteId;
  final String agencyId;
  final String? routeShortName;
  final String? routeLongName;
  final String? routeDesc;

  TripRoute(
      {required this.id,
      required this.appId,
      required this.gtfsRouteId,
      this.routeShortName,
      this.routeLongName,
      this.routeDesc,
      required this.agencyId});

  factory TripRoute.fromJson(Map<String, dynamic> json) {
    return TripRoute(
      id: json['id'].toString(),
      appId: json['app_id'].toString(),
      gtfsRouteId: json['gtfs_route_id'].toString(),
      routeShortName: json['route_short_name'],
      routeLongName: json['route_long_name'],
      routeDesc: json['route_desc'],
      agencyId: json['agency_id'].toString(),
    );
  }

  static Future<List<TripRoute>> fetchRoutes(User user) async {
    var responseBody =
        await BusfeedApi.makeRequest(user: user, path: 'api/routes');
    if (responseBody == null ||
        (responseBody is! List && responseBody["error"] != null)) {
      return [];
    }
    return responseBody
        .map<TripRoute>((json) => TripRoute.fromJson(json))
        .toList();
  }
}

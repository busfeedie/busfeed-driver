import 'dart:async';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:busfeed_driver/models/vehicle_position.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../abstracts/location_data.dart';
import '../helpers/api.dart';
import '../models/stop_time.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../models/user_common.dart';

const viewRefreshTime = Duration(seconds: 10);

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated(
    (data) async => _locationChanged(locationData: data),
  );
}

class TrackPage extends StatefulWidget {
  const TrackPage(
      {super.key, required this.title, required this.user, this.trip});

  final String title;
  final User user;
  final Trip? trip;

  @override
  State<TrackPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TrackPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  User? user;

  PermissionStatus _locationPermissionGranted = PermissionStatus.denied;
  bool _isTracking = false;
  Timer? viewUpdateTimer;
  VehiclePosition? vehiclePosition;
  Set<Marker> markers = {};

  @override
  void initState() {
    if (_firstStopMarker() != null) {
      markers.add(_firstStopMarker()!);
    }
    if (widget.trip == null || widget.trip!.activeTracking == false) {
      _setupLocation();
    } else {
      _setupShowTrip();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !_isTracking,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          _showBackDialog();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Stack(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height - 70,
                    child: GoogleMap(
                      myLocationEnabled: _locationPermissionGranted ==
                          PermissionStatus.granted,
                      compassEnabled: false,
                      myLocationButtonEnabled: true,
                      buildingsEnabled: false,
                      tiltGesturesEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: initalCameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: markers,
                    )),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    leading: const Icon(Icons.directions_bus),
                    title: Text(widget.title),
                    subtitle: Text('To ${widget.trip?.tripHeadsign}'),
                    trailing: !_activeTrip()
                        ? FilledButton(
                            onPressed: startTracking,
                            child: const Text('Start tracking'))
                        : null,
                    tileColor: widget.trip?.statusColor() ?? Colors.white,
                  ),
                ),
              ],
            )));
  }

  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Do you want to stop tracking this trip?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Nevermind'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Stop Tracking'),
              onPressed: () async {
                await BackgroundLocationTrackerManager.stopTracking();
                _isTracking = false;
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Marker? _firstStopMarker() {
    if (widget.trip != null && widget.trip!.firstStopTime?.stop != null) {
      StopTime stopTime = widget.trip!.firstStopTime!;
      return Marker(
        markerId: stopTime.stop!.markerId,
        position: LatLng(stopTime.stop!.lat, stopTime.stop!.lon),
        infoWindow: InfoWindow(title: stopTime.scheduledToDepartIn),
      );
    }
    return null;
  }

  CameraPosition get initalCameraPosition {
    if (widget.trip != null && widget.trip!.firstStopTime?.stop != null) {
      return CameraPosition(
        target: LatLng(widget.trip!.firstStopTime!.stop!.lat,
            widget.trip!.firstStopTime!.stop!.lon),
        zoom: 14,
      );
    }
    return _dublin;
  }

  static const CameraPosition _dublin = CameraPosition(
    target: LatLng(53.3447996, -6.2906393),
    zoom: 12,
  );

  bool _activeTrip() {
    return widget.trip?.activeTracking ?? false;
  }

  void _goToTheUser(LocationData locationData) async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition userLocation = CameraPosition(
        bearing: locationData.bearing!,
        target: LatLng(locationData.lat!, locationData.lon!),
        zoom: 14.4746);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(userLocation));
  }

  void startTracking() async {
    _setupLocation();
    widget.trip!.startTracking();
    WidgetsFlutterBinding.ensureInitialized();
    await BackgroundLocationTrackerManager.initialize(
      backgroundCallback,
      config: const BackgroundLocationTrackerConfig(
        loggingEnabled: true,
        androidConfig: AndroidConfig(
          notificationIcon: 'explore',
          trackingInterval: Duration(seconds: 10),
          distanceFilterMeters: null,
        ),
        iOSConfig: IOSConfig(
          activityType: ActivityType.FITNESS,
          distanceFilterMeters: null,
          restartAfterKill: true,
        ),
      ),
    );
    await BackgroundLocationTrackerManager.startTracking();
    setState(() {
      _isTracking = true;
      widget.trip?.activeTracking = true;
    });
  }

  onDispose() {
    viewUpdateTimer?.cancel();
    super.dispose();
  }

  void _showTrip() async {
    try {
      final vehiclePosition =
          await widget.trip?.fetchLastLocation(user: widget.user);
      if (vehiclePosition != null) {
        markers.remove(this.vehiclePosition?.toMarker());
        setState(() {
          this.vehiclePosition = vehiclePosition;
          markers.add(vehiclePosition.toMarker());
        });
        _goToTheUser(vehiclePosition.toLocationData());
        final GoogleMapController controller = await _controller.future;
        controller.showMarkerInfoWindow(this.vehiclePosition!.markerId);
      }
    } on Exception catch (e, stackTrace) {
      print('Error fetching last location');
      print(stackTrace.toString());
    }
  }

  _setupShowTrip() {
    _showTrip();
    viewUpdateTimer = Timer.periodic(viewRefreshTime, (Timer t) => _showTrip());
  }

  void _setupLocation() async {
    final result = await Permission.locationAlways.request();

    final notificationResult = await Permission.notification.request();
    if (notificationResult != PermissionStatus.granted) {
      return;
    }

    setState(() {
      _locationPermissionGranted = result;
    });
    if (_locationPermissionGranted != PermissionStatus.granted) {
      return;
    }
  }
}

void _locationChanged(
    {required BackgroundLocationUpdateData locationData}) async {
  LocationData locData = LocationData.fromBackGroundLocationData(locationData);
  var user = await UserCommon.loadFromStorage();
  if (user is! User) {
    return;
  }
  var tripId = await Trip.tripIdFromStorage();
  // _goToTheUser(locData);
  try {
    await BusfeedApi()
        .makePostRequest(user: user, path: 'api/positions', body: {
      'lat': locData.lat,
      'lon': locData.lon,
      'bearing': locData.bearing,
      'speed': locData.speed,
      'measured_at': locData.measuredAt!.toIso8601String(),
      if (tripId != null) 'trip': {'trip_id': tripId},
    });
  } catch (e) {
    print('Error sending location');
    print(e);
  }
}

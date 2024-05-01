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

  bool _locationPermissionGranted = false;
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
                      myLocationEnabled: _locationPermissionGranted,
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

  void startTracking({bool skipPermissionModal = false}) async {
    var result = await _setupLocation(forTripTrack: true);
    if (!result) {
      return;
    }
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

  Future<bool> _setupLocation(
      {bool forTripTrack = false, bool skipPermissionModal = false}) async {
    if (!skipPermissionModal &&
        (await Permission.locationAlways.shouldShowRequestRationale ||
            await Permission.locationWhenInUse.shouldShowRequestRationale)) {
      _showLocationPermissionDialog(widget.user, forTripTrack: forTripTrack);
      return false;
    }
    if (await Permission.locationWhenInUse.request() !=
        PermissionStatus.granted) {
      return false;
    }
    if (await Permission.locationAlways.request() != PermissionStatus.granted) {
      return false;
    }
    if (await Permission.notification.request() != PermissionStatus.granted) {
      return false;
    }

    setState(() {
      _locationPermissionGranted = true;
    });
    return true;
  }

  void _showLocationPermissionDialog(User user, {bool forTripTrack = false}) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept location permission'),
          content: const Text(
              'This app collects location data to enable tracking your driving in order to share real time info with bus users, location is tracked even when the app is closed or not in use. It is only used for tracking the vehicle location for real time information and only when you select to start tracking.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Accept'),
              onPressed: () {
                user.locationPermission = true;
                user.writeLocationPermissionToStore();
                if (forTripTrack) {
                  startTracking(skipPermissionModal: true);
                } else {
                  _setupLocation(skipPermissionModal: true);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
    await HttpClient()
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

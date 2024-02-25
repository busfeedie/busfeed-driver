import 'dart:async';

import 'package:busfeed_driver/models/vehicle_position.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../helpers/api.dart';
import '../models/stop_time.dart';
import '../models/trip.dart';
import '../models/user.dart';

const viewRefreshTime = Duration(seconds: 10);

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

  Location location = Location();
  User? user;

  bool _locationServiceEnabled = false;
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
              onPressed: () {
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
        bearing: locationData.heading!,
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 14.4746);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(userLocation));
  }

  _locationChanged(LocationData locationData) async {
    _goToTheUser(locationData);
    if (_isTracking) {
      _trackLocationChanged(locationData);
    }
  }

  _trackLocationChanged(LocationData locationData) async {
    if (widget.trip != null) {
      try {
        final time = locationData.time != null
            ? DateTime.fromMillisecondsSinceEpoch(locationData.time!.toInt())
            : DateTime.now();
        await BusfeedApi.makePostRequest(
            user: widget.user,
            path: 'api/positions',
            body: {
              'lat': locationData.latitude,
              'lon': locationData.longitude,
              'bearing': locationData.heading,
              'speed': locationData.speed,
              'measured_at': time.toIso8601String(),
              if (widget.trip != null) 'trip': {'trip_id': widget.trip?.id},
            });
      } catch (e) {
        print('Error sending location');
        print(e);
      }
    }
  }

  void startTracking() {
    location.enableBackgroundMode(enable: true);
    setState(() {
      _isTracking = true;
      widget.trip?.activeTracking = true;
    });
    location.getLocation();
    location.onLocationChanged.listen(_locationChanged);
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
      print(e);
      print(stackTrace.toString());
    }
  }

  _setupShowTrip() {
    _showTrip();
    viewUpdateTimer = Timer.periodic(viewRefreshTime, (Timer t) => _showTrip());
  }

  void _setupLocation() async {
    _locationServiceEnabled = await location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await location.requestService();
      if (!_locationServiceEnabled) {
        return;
      }
    }

    _locationPermissionGranted = await location.hasPermission();
    if (_locationPermissionGranted == PermissionStatus.denied) {
      _locationPermissionGranted = await location.requestPermission();
      if (_locationPermissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    await location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 10,
    );
    await location.getLocation();
    location.onLocationChanged.listen(_locationChanged);
  }
}

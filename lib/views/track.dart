import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../helpers/api.dart';
import '../models/trip.dart';
import '../models/user.dart';

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

  static const CameraPosition _ireland = CameraPosition(
    target: LatLng(53, -6),
    zoom: 14.4746,
  );

  @override
  void initState() {
    _setupLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height - 70,
                child: GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: false,
                  myLocationButtonEnabled: false,
                  buildingsEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: _ireland,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                )),
            Container(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: const Icon(Icons.directions_bus),
                title: const Text('Tracking...'),
                subtitle: Text('Heading for ${widget.trip?.tripHeadsign}'),
                // trailing: const Icon(Icons.more_vert),
                tileColor: Colors.white,
              ),
            ),
          ],
        ));
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
    try {
      await BusfeedApi.makePostRequest(
          user: widget.user,
          path: 'api/positions',
          body: {
            'lat': locationData.latitude,
            'lon': locationData.longitude,
            if (widget.trip != null) 'trip': {'trip_id': widget.trip?.id},
          });
    } catch (e) {
      print('Error sending location');
      print(e);
    }
  }

  void _setupLocation() async {
    location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 10,
    );

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
    location.enableBackgroundMode(enable: true);
    await location.getLocation();
    location.onLocationChanged.listen(_locationChanged);
  }
}

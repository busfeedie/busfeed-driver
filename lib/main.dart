import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busfeed Driver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Busfeed Driver App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Location location = Location();

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
          child: const ListTile(
            leading: Icon(Icons.directions_bus),
            title: Text('Tracking...'),
            subtitle: Text('Route 1'),
            trailing: Icon(Icons.more_vert),
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

  _locationChanged(LocationData locationData) {
    print(locationData.latitude);
    print(locationData.longitude);
    _goToTheUser(locationData);
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

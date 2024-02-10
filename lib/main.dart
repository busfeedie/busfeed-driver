import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'login.dart';
import 'models/trip.dart';
import 'models/user.dart';

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

  User? user;
  List<Trip>? trips;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: user == null || trips == null
            ? LoginPage(
                loginCallback: userLoggedIn,
              )
            : ListView(
                children: trips!.map((trip) {
                return ListTile(
                  title: Text(trip.tripHeadsign),
                  subtitle: Text(trip.serviceType),
                );
              }).toList()));
  }

  void userLoggedIn(User user) {
    setState(() {
      this.user = user;
    });
    setupTrips();
  }

  void setupTrips() async {
    var trips = await Trip.fetchTrips(user!);
    setState(() {
      trips = trips;
    });
  }
}

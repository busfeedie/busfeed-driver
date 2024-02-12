import 'package:busfeed_driver/views/track.dart';
import 'package:flutter/material.dart';

import '../models/route.dart';
import '../models/trip.dart';
import '../models/user.dart';

class TripList extends StatefulWidget {
  const TripList({super.key, required this.user, this.route});

  final User user;
  final TripRoute? route;

  @override
  State<TripList> createState() => TripListState();
}

class TripListState extends State<TripList> {
  List<Trip>? trips;

  @override
  void initState() {
    setupTrips();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.route?.routeShortName ?? 'All Trips'} today'),
        ),
        body: trips == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: trips!.map((trip) {
                return ListTile(
                  title: Text('To ${trip.tripHeadsign}'),
                  subtitle: Text('Departing ${trip.startTimeString()}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TrackPage(
                                user: widget.user,
                                trip: trip,
                                title:
                                    'Tracking ${widget.route?.routeShortName} to ${trip.tripHeadsign}',
                              )),
                    );
                  },
                );
              }).toList()));
  }

  void setupTrips() async {
    var trips = await Trip.fetchTrips(
        user: widget.user, route: widget.route, dateTime: DateTime.now());
    setState(() {
      this.trips = trips;
    });
  }
}

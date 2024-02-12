import 'package:flutter/material.dart';

import '../models/route.dart';
import '../models/user.dart';
import 'trip_list.dart';

class RouteListPage extends StatelessWidget {
  const RouteListPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('All Routes'),
        ),
        body: RouteList(
          user: user,
        ));
  }
}

class RouteList extends StatefulWidget {
  const RouteList({super.key, required this.user});

  final User user;

  @override
  State<RouteList> createState() => RouteListState();
}

class RouteListState extends State<RouteList> {
  List<TripRoute>? routes;

  @override
  void initState() {
    setupRoutes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return routes == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            children: routes!.map((route) {
            return ListTile(
              title: Text('Route ${route.routeShortName ?? ''}'),
              subtitle: Text(route.routeLongName ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TripList(
                            user: widget.user,
                            route: route,
                          )),
                );
              },
            );
          }).toList());
  }

  void setupRoutes() async {
    var routes = await TripRoute.fetchRoutes(widget.user);
    setState(() {
      this.routes = routes;
    });
  }
}

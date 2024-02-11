import 'package:flutter/material.dart';

import 'login.dart';
import 'models/trip.dart';
import 'models/user.dart';
import 'views/route_list.dart';

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
  User? user;
  List<Trip>? trips;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: user == null
            ? LoginPage(
                loginCallback: userLoggedIn,
              )
            : RouteList(user: user!));
  }

  void userLoggedIn(User user) {
    setState(() {
      this.user = user;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RouteListPage(
                user: user,
              )),
    );
  }
}

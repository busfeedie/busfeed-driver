import 'package:busfeed_driver/models/user_logged_out.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'models/trip.dart';
import 'models/user.dart';
import 'models/user_common.dart';
import 'views/route_list.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busfeed',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Busfeed'),
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
  UserCommon? user;
  List<Trip>? trips;
  bool loadingUser = true;

  @override
  void initState() {
    checkUserStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: loadingUser
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : user == null || !user!.authenticated
                ? LoginPage(
                    user: user,
                    loginCallback: userLoggedIn,
                  )
                : RouteList(user: user as User));
  }

  void checkUserStorage() async {
    var user = await UserCommon.loadFromStorage();
    if (user is User) {
      user.userExpiryCallback = logoutUser;
    }
    setState(() {
      this.user = user;
      loadingUser = false;
    });
  }

  void userLoggedIn(User user) {
    user.userExpiryCallback = logoutUser;
    setState(() {
      this.user = user;
    });
  }

  void logoutUser() {
    setState(() {
      if (user != null) {
        user = UserLoggedOut(email: user!.email);
      } else {
        user = null;
      }
    });
  }
}

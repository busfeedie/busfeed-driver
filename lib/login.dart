import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'models/user.dart';
import 'models/user_logged_out.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.userLoggedOut, required this.loginCallback});

  final UserLoggedOut? userLoggedOut;
  final Function(User) loginCallback;

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  Location location = Location();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _loginLoading = false;
  bool _loginFailed = false;
  String failureMessage = '';

  @override
  void initState() {
    emailController.text = widget.userLoggedOut?.email ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loginLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'busfeed',
                      style: TextStyle(
                          // color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: () {
                //     //forgot password screen
                //   },
                //   child: const Text(
                //     'Forgot Password',
                //   ),
                // ),
                if (_loginFailed)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Login failed, please try again. $failureMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    )),
                // Row(
                //   children: <Widget>[
                //     const Text('Does not have account?'),
                //     TextButton(
                //       child: const Text(
                //         'Sign in',
                //         style: TextStyle(fontSize: 20),
                //       ),
                //       onPressed: () {
                //         //signup screen
                //       },
                //     )
                //   ],
                //   mainAxisAlignment: MainAxisAlignment.center,
                // ),
              ],
            ));
  }

  void _login() async {
    setState(() {
      _loginLoading = true;
    });
    var userLoggedOut = UserLoggedOut(email: emailController.text);
    try {
      var user = await userLoggedOut.login(password: passwordController.text);
      widget.loginCallback(user);
    } catch (e) {
      setState(() {
        _loginLoading = false;
        _loginFailed = true;
        failureMessage = e.toString();
      });
    }
  }
}

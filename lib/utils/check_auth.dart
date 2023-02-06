import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/screens/auth/complete_register_screen.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/screens/bookings/bookings_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  bool isFullySet = false;

  @override
  void initState() {
    _checkWhereUserHaveToGo();
    super.initState();
  }

  void _checkWhereUserHaveToGo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final token = localStorage.getString('token');
    if (token != null) {
      setState(() {
        isAuth = true;
      });
    }

    // localStorage.clear();

    if (localStorage.containsKey('user')) {
      String? userStr = localStorage.getString("user");
      User user = User.fromJson(jsonDecode(userStr!));

      Sentry.configureScope(
            (scope) => scope.user = SentryUser(id: user.id.toString(), email: user.email),
      );

      if (user.isFullySet) {
        setState(() {
          isFullySet = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth && !isFullySet) {
      child = CompleteRegisterScreen();
    } else if (isAuth && isFullySet) {
      // child = MatchesScreen();
      child = BookingsScreen();
    } else {
      child = LoginScreen();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: child,
    );
  }
}

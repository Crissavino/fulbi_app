import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/complete_profile/complete_profile_bloc.dart';
import 'package:fulbito_app/bloc/login/login_bloc.dart';
import 'package:fulbito_app/bloc/profile/profile_bloc.dart';
import 'package:fulbito_app/bloc/register/register_bloc.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/routes.dart';
import 'package:fulbito_app/screens/auth/complete_register_screen.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/matches/matches_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RegisterBloc(),),
        BlocProvider(create: (_) => LoginBloc(),),
        BlocProvider(create: (_) => CompleteProfileBloc(),),
        BlocProvider(create: (_) => ProfileBloc(),),
      ],
      child: MaterialApp(
        title: 'Fulbito',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        routes: routes,
        home: CheckAuth(),
        // home: CompleteRegisterScreen(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('es'),
        ],
      ),
    );
  }
}

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

  void _checkWhereUserHaveToGo() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    final token = localStorage.getString('token');
    if(token != null){
      setState(() {
        isAuth = true;
      });
    }

    // localStorage.clear();

    if (localStorage.containsKey('user')) {
      String? userStr = localStorage.getString("user");
      User user = User.fromJson(jsonDecode(userStr!));
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
      child = MatchesScreen();
    } else {
      child = LoginScreen();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: child,
    );
  }
}
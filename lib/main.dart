import 'dart:async';
import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/complete_profile/complete_profile_bloc.dart';
import 'package:fulbito_app/bloc/login/login_bloc.dart';
import 'package:fulbito_app/bloc/profile/profile_bloc.dart';
import 'package:fulbito_app/bloc/register/register_bloc.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/routes.dart';
import 'package:fulbito_app/screens/auth/complete_register_screen.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/screens/matches/match_chat_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/custom_snack_bar.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'screens/matches/matches_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initializeApp();
  runZonedGuarded<Future<void>>(() async {
    // The following lines are the same as previously explained in "Handling uncaught errors"
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(MyApp());
  }, FirebaseCrashlytics.instance.recordError);
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Column(
        children: [
          Padding(
            child: Text(
              "Something is not right here...",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            padding: const EdgeInsets.all(8.0),
          ),
          Padding(
            child: Text(
              errorDetails.exceptionAsString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 10,
            ),
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
      color: Colors.red,
      margin: EdgeInsets.only(
        top: 100.0,
        left: 60.0,
        right: 60.0,
        bottom: 200.0
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  String _appBadgeSupported = 'Unknown';

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.path.contains('/my_matches')) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MyMatchesScreen(),
            ),
          );
        }

        if (deepLink.path.contains('/invite-new-player')) {
          Map query = deepLink.queryParameters;
          // invite new player to match
          User user = await UserRepository.getCurrentUser();
          final response =
          await MatchRepository().joinMatchFromInvitationLinkNewUser(
            int.parse(query['userWhoInvite']),
            user.id,
            int.parse(query['matchId']),
          );
          if (response['success']) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => MyMatchesScreen(),
              ),
            );
          } else {
            Navigator.pop(context);
            showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
          }
        }

        if (deepLink.path.contains('/invite-existing-player')) {
          Map query = deepLink.queryParameters;
          // invite new player to match
          User user = await UserRepository.getCurrentUser();
          final response =
          await MatchRepository().joinMatchFromInvitationLinkExistingUser(
            int.parse(query['userWhoInvite']),
            user.id,
            int.parse(query['matchId']),
          );
          if (response['success']) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => MyMatchesScreen(),
              ),
            );
          } else {
            Navigator.pop(context);
            showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
          }
        }

      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      if (deepLink.path.contains('/my_matches')) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MyMatchesScreen(),
          ),
        );
      }

      if (deepLink.path.contains('/invite-new-player')) {
        Map query = deepLink.queryParameters;
        // invite new player to match
        User user = await UserRepository.getCurrentUser();
        final response =
            await MatchRepository().joinMatchFromInvitationLinkNewUser(
          int.parse(query['userWhoInvite']),
          user.id,
          int.parse(query['matchId']),
        );
        if (response['success']) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MyMatchesScreen(),
            ),
          );
        } else {
          Navigator.pop(context);
          showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
        }
      }

      if (deepLink.path.contains('/invite-existing-player')) {
        Map query = deepLink.queryParameters;
        // invite new player to match
        User user = await UserRepository.getCurrentUser();
        final response =
        await MatchRepository().joinMatchFromInvitationLinkExistingUser(
          int.parse(query['userWhoInvite']),
          user.id,
          int.parse(query['matchId']),
        );
        if (response['success']) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MyMatchesScreen(),
            ),
          );
        } else {
          Navigator.pop(context);
          showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
        }
      }
    }
  }

  void _addBadge() {
    FlutterAppBadger.updateBadgeCount(1);
  }

  void _removeBadge() {
    FlutterAppBadger.removeBadge();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
    PushNotificationService.messageStream.listen((notificationData) {
      if (notificationData.containsKey('chatMessage')) {
        if (notificationData['inApp']) {
          // messengerKey.currentState
          //     ?.showSnackBar(customSnackBar(notificationData['title'], () {
          //   navigatorKey.currentState?.push(
          //     MaterialPageRoute(
          //       builder: (context) => MatchChatScreen(
          //         match: notificationData['match'],
          //         currentUser: notificationData['currentUser'],
          //       ),
          //     ),
          //   );
          // }));
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MatchChatScreen(
                match: notificationData['match'],
                currentUser: notificationData['currentUser'],
                calledFromMyMatches: false,
              ),
            ),
          );
        }
      }
      if (notificationData.containsKey('goToMyMatches')) {
        if (notificationData['inApp']) {
          messengerKey.currentState
              ?.showSnackBar(customSnackBar(notificationData['title'], () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => MyMatchesScreen(),
              ),
            );
          }));
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MyMatchesScreen(),
            ),
          );
        }
      }
      if (notificationData.containsKey('goToMatchInfo')) {
        if (notificationData['inApp']) {
          messengerKey.currentState
              ?.showSnackBar(customSnackBar(notificationData['title'], () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => MatchInfoScreen(
                  match: notificationData['match'],
                  calledFromMyMatches: false,
                ),
              ),
            );
          }));
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MatchInfoScreen(
                match: notificationData['match'],
                calledFromMyMatches: false,
              ),
            ),
          );
        }
      }
      if (notificationData.containsKey('goToMatchesScreen')) {
        if (notificationData['inApp']) {
          messengerKey.currentState
              ?.showSnackBar(customSnackBar(notificationData['title'], () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => MatchesScreen(),
              ),
            );
          }));
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MatchesScreen(),
            ),
          );
        }
      }
    });
    this.initDynamicLinks();
  }

  initPlatformState() async {
    String appBadgeSupported;
    try {
      bool res = await FlutterAppBadger.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = 'Supported';
      } else {
        appBadgeSupported = 'Not supported';
      }
    } on PlatformException {
      appBadgeSupported = 'Failed to get badge support.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _appBadgeSupported = appBadgeSupported;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RegisterBloc(),
        ),
        BlocProvider(
          create: (_) => LoginBloc(),
        ),
        BlocProvider(
          create: (_) => CompleteProfileBloc(),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(),
        ),
      ],
      child: MaterialApp(
        builder: (BuildContext context, Widget? widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
            return CustomError(errorDetails: errorDetails);
          };

          return widget!;
        },
        title: 'Fulbito',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        routes: routes,
        navigatorKey: navigatorKey,
        //Navigator
        scaffoldMessengerKey: messengerKey,
        // Snack
        home: CheckAuth(),
        // home: CompleteRegisterScreen(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('es'),
          const Locale('en'),
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

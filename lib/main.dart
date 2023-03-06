import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

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
import 'package:fulbito_app/screens/matches/match_chat_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/check_app_version.dart';
import 'package:fulbito_app/utils/custom_error.dart';
import 'package:fulbito_app/utils/custom_snack_bar.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/matches/matches_screen.dart';

void main() async {
  await SentryFlutter.init(
      (options) {
        options.dsn = 'https://f511d436e9b54b04a6b7c96dc476ff85@o965176.ingest.sentry.io/5916005';
      },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await PushNotificationService.initializeApp();
      runZonedGuarded<Future<void>>(() async {
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

        runApp(MyApp());
      }, FirebaseCrashlytics.instance.recordError);
    }
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //FirebaseCrashlytics.instance.crash();
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
                calledFromMatchInfo: true,
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
                  calledFromMatchInfo: true,
                ),
              ),
            );
          }));
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => MatchInfoScreen(
                match: notificationData['match'],
                calledFromMatchInfo: true,
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
      if (notificationData.containsKey('openSocial')) {
        if (notificationData['inApp']) {
          Future.delayed(Duration(seconds: 2)).then((value) {
            launch(notificationData['url']);
          });
        } else {
          Future.delayed(Duration(seconds: 2)).then((value) {
            launch(notificationData['url']);
          });
        }
      }
    });
    this.initDynamicLinks();
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
        home: CheckAppVersion(),
        // home: CheckAuth(),
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
import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:fulbito_app/models/message.dart';
import 'package:fulbito_app/repositories/match_repository.dart';

// B2:AA:58:CA:75:9C:1C:D8:76:C8:61:15:34:FC:9E:8B:48:FE:A1:1C
// P8 - Key ID:QDLXV987Q6
// csXLEIPQSguIVDXEsmTtpD:APA91bGI3CiMKLr8m-V5c5EzzCubwZbOl0AXRtWLsXlEJkMQ41FZj2yPSS1WObFT1_hy52TasxNcfCmUoHKFIvpIUknWejq2Dy0xigGvSjRhC6e5or04sceB62Mewsm4hVhfm1ogaVhZ

class PushNotificationService {

  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<Map<String, dynamic>> _messageStreamController = new StreamController.broadcast();
  static Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;

  static Future<void> _onBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    // cuando la app esta en segundo plano
    if (message.data['notification_type'] == 'new_chat_message') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'chatMessage': true,
          'inApp': false,
          'match': getMatchResponse['match'],
          'currentUser': getMatchResponse['myUser'],
        });
      }
    }
    if (message.data['notification_type'] == 'match_invitation') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': false,
      });
    }
    if (message.data['notification_type'] == 'reject_invitation') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': false,
      });
    }
    if (message.data['notification_type'] == 'joined_match') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'goToMatchInfo': true,
          'inApp': false,
          'match': getMatchResponse['match'],
        });
      }
    }
    if (message.data['notification_type'] == 'left_match') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': false,
      });
    }
    if (message.data['notification_type'] == 'match_edited') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'goToMatchInfo': true,
          'inApp': false,
          'match': getMatchResponse['match'],
        });
      }
    }
    if (message.data['notification_type'] == 'match_created') {
      _messageStreamController.sink.add({
        'goToMatchesScreen': true,
        'inApp': false,
      });
    }
    if (message.data['notification_type'] == 'open_social') {
      _messageStreamController.sink.add({
        'openSocial': true,
        'inApp': false,
        'url': message.data['url'],
        'socialNetwork': message.data['social_network'],
      });
    }

    // silence
    await handleSilenceNotification(message);

    FlutterAppBadger.updateBadgeCount(1);

  }

  static Future<void> _onMessageOpenedHandler(RemoteMessage message) async {

    // cuando das click en la notificacion
    if (message.data['notification_type'] == 'new_chat_message') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'chatMessage': true,
          'inApp': false,
          'match': getMatchResponse['match'],
          'currentUser': getMatchResponse['myUser'],
        });
      }
    }
    if (message.data['notification_type'] == 'match_invitation') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': false,
      });
    }
    if (message.data['notification_type'] == 'reject_invitation') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': false,
      });
    }
    if (message.data['notification_type'] == 'joined_match') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'goToMatchInfo': true,
          'inApp': false,
          'match': getMatchResponse['match'],
        });
      }
    }
    if (message.data['notification_type'] == 'left_match') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': false,
      });
    }
    if (message.data['notification_type'] == 'match_edited') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'goToMatchInfo': true,
          'inApp': false,
          'match': getMatchResponse['match'],
        });
      }
    }
    if (message.data['notification_type'] == 'match_created') {
      _messageStreamController.sink.add({
        'goToMatchesScreen': true,
        'inApp': false,
      });
    }

    if (message.data['notification_type'] == 'open_social') {
      _messageStreamController.sink.add({
        'openSocial': true,
        'inApp': false,
        'url': message.data['url'],
        'socialNetwork': message.data['social_network'],
      });
    }
    // silence
    await handleSilenceNotification(message);

    FlutterAppBadger.removeBadge();

  }

  static Future<void> _onMessageHandler(RemoteMessage message) async {
    // cuando estas en la app
    // if (message.data['notification_type'] == 'new_chat_message') {
    //   final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
    //   if (getMatchResponse['success']){
    //     _messageStreamController.sink.add({
    //       'chatMessage': true,
    //       'inApp': true,
    //       'title': message.notification?.title ?? '',
    //       'body': message.notification?.body ?? '',
    //       'match': getMatchResponse['match'],
    //       'currentUser': getMatchResponse['myUser'],
    //     });
    //   }
    // }
    if (message.data['notification_type'] == 'match_invitation') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': true,
        'title': message.notification?.title ?? '',
      });
    }
    if (message.data['notification_type'] == 'reject_invitation') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': true,
        'title': message.notification?.title ?? '',
      });
    }
    if (message.data['notification_type'] == 'joined_match') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'goToMatchInfo': true,
          'inApp': true,
          'title': message.notification?.title ?? '',
          'match': getMatchResponse['match'],
        });
      }
    }
    if (message.data['notification_type'] == 'left_match') {
      _messageStreamController.sink.add({
        'goToMyMatches': true,
        'inApp': true,
        'title': message.notification?.title ?? '',
      });
    }
    if (message.data['notification_type'] == 'match_edited') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'goToMatchInfo': true,
          'inApp': true,
          'title': message.notification?.title ?? '',
          'match': getMatchResponse['match'],
        });
      }
    }
    if (message.data['notification_type'] == 'match_created') {
      _messageStreamController.sink.add({
        'goToMatchesScreen': true,
        'title': message.notification?.title ?? '',
        'inApp': true,
      });
    }
    if (message.data['notification_type'] == 'open_social') {
      _messageStreamController.sink.add({
        'openSocial': true,
        'title': message.notification?.title ?? '',
        'inApp': true,
        'url': message.data['url'],
        'socialNetwork': message.data['social_network'],
      });
    }

    FlutterAppBadger.removeBadge();
    // silence
    await handleSilenceNotification(message);
  }

  static Future<void> handleSilenceNotification(RemoteMessage message) async {

    if (message.data['notification_type'] == 'silence_match_created') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'silentCreatedMatch': true,
          'match': getMatchResponse['match'],
          'response': getMatchResponse,
        });
      }
    }

    if (message.data['notification_type'] == 'silence_match_edited') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'silentUpdateMatch': true,
          'match': getMatchResponse['match'],
          'response': getMatchResponse,
        });
      }
    }

    if (message.data['notification_type'] == 'silence_join_match' ||
        message.data['notification_type'] == 'silence_leave_match') {
      final getMatchResponse =
      await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']) {
        _messageStreamController.sink.add({
          'silentUpdateParticipants': true,
          'match': getMatchResponse['match'],
          'response': getMatchResponse,
        });
      }
    }

    if (message.data['notification_type'] == 'silence_new_chat_message') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      final messageData = json.decode(message.data['message']);
      final Message newMessage = Message.fromJson(messageData);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'silentUpdateChat': true,
          'match': getMatchResponse['match'],
          'newMessage': newMessage,
        });
      }
    }

    if (message.data['notification_type'] == 'silence_invited_match' ||
        message.data['notification_type'] == 'silence_rejected_match') {
      final getMatchesResponse = await MatchRepository().getMyMatches();
      if (getMatchesResponse['success']) {
        _messageStreamController.sink.add({
          'silentUpdateMatch': true,
          'matches': getMatchesResponse['matches'],
          'response': getMatchesResponse,
        });
      }
    }

    if (message.data['notification_type'] == 'silence_deleted_match') {
      _messageStreamController.sink.add({
        'silentUpdateMyMatches': true,
        'matchIdToDelete': message.data['match_id'],
      });

      _messageStreamController.sink.add({
        'silentUpdateMatches': true,
        'matchIdToDelete': message.data['match_id'],
      });
    }

    if (message.data['notification_type'] == 'silence_player_expelled') {

      final getMatchResponse =
      await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']) {
        _messageStreamController.sink.add({
          'silentUpdateParticipants': true,
          'match': getMatchResponse['match'],
          'response': getMatchResponse,
        });
      }

    }

    if (message.data['notification_type'] == 'silence_im_expelled') {
      _messageStreamController.sink.add({
        'silentUpdateMyMatches': true,
        'matchIdToDelete': message.data['match_id'],
      });
    }

  }

  static Future initializeApp() async {
    // push notif
    await Firebase.initializeApp();

    try{
      token = await FirebaseMessaging.instance.getToken();
    } catch(error) {
      token = '';
      print('error $error');
    }

    // NotificationSettings settings = await messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );
    // print(settings);
    //
    // if (
    // settings.authorizationStatus == AuthorizationStatus.authorized ||
    //     settings.authorizationStatus == AuthorizationStatus.provisional
    // ) {
    //   // handlers
    //   FirebaseMessaging.onBackgroundMessage(_onBackgroundHandler);
    //   FirebaseMessaging.onMessage.listen(_onMessageHandler);
    //   FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedHandler);
    // } else {
    //   print('User declined or has not accepted permission');
    // }
    //
    // print('entra');
    // local notif

  }

  static closeStreams(){
    _messageStreamController.close();
  }

}
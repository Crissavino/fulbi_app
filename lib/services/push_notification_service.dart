import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fulbito_app/models/match.dart';
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
  }

  static Future<void> _onMessageHandler(RemoteMessage message) async {

    // cuando estas en la app
    if (message.data['notification_type'] == 'new_chat_message') {
      final getMatchResponse = await MatchRepository().getMatch(message.data['match_id']);
      if (getMatchResponse['success']){
        _messageStreamController.sink.add({
          'chatMessage': true,
          'inApp': true,
          'title': message.notification?.title ?? '',
          'body': message.notification?.body ?? '',
          'match': getMatchResponse['match'],
          'currentUser': getMatchResponse['myUser'],
        });
      }
    }
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

  }

  static Future initializeApp() async {
    // push notif
    await Firebase.initializeApp();

    try{
      token = await FirebaseMessaging.instance.getToken();
      print('token $token');
    } catch(error) {
      token = '';
      print('error $error');
    }

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (
    settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional
    ) {
      print('User granted permission');
      // handlers
      FirebaseMessaging.onBackgroundMessage(_onBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_onMessageHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedHandler);
    } else {
      print('User declined or has not accepted permission');
    }

    // local notif

  }

  static closeStreams(){
    _messageStreamController.close();
  }

}
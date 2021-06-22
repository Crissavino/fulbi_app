import 'dart:convert';

import 'package:fulbito_app/models/message.dart';
import 'package:fulbito_app/utils/api.dart';

class ChatRepository {
  Api api = Api();

  Future sendMessage(int matchId, String text, int ownerId, int chatId) async {

    final data = {
      "match_id": matchId,
      "text": text,
      "owner_id": ownerId,
      "chat_id": chatId,
    };

    final res = await api.postData(data, '/chat/send-message');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      // List matches = body['matches'];
      // body['matches'] = matches.map((match) => Match.fromJson(match)).toList();
      // final match = body['match'];
      // body['match'] = Match.fromJson(match);

    }

    return body;
  }

  Future getMyChatMessages(int matchId) async {

    final data = {
      "match_id": matchId,
    };

    final res = await api.postData(data, '/chat/my-messages');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List messages = body['messages'];
      if (messages.length == 0) return body;
      body['messages'] = messages.map((message) => Message.fromJson(message)).toList();

    }

    return body;
  }

}
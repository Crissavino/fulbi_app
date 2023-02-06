import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fulbito_app/models/booking.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/utils/api.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchRepository {
  Api api = Api();

  Future getAll() async {

    final res = await api.getData('/get-all-matches');

    Map body = json.decode(res.body);

    return body;
  }

  Future getMatch(matchId) async {

    final res = await api.getData('/match/$matchId');

    FirebaseCrashlytics.instance.log(res.toString());
    FirebaseCrashlytics.instance.log(res.body.toString());
    FirebaseCrashlytics.instance.log(res.statusCode.toString());

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      final response = {
        'success': true,
        'myUser': User.fromJson(jsonDecode(localStorage.getString('user')!)),
        'match': Match.fromJson(body['match']),
        'booking': Booking.fromJson(body['booking']),
        'owner': User.fromJson(body['owner']),
        'location': Location.fromJson(body['location']),
        'genre': Genre(id: body['genre']['id'], name: translations[localeName]![body['genre']['name_key']]!),
        'type': Type(id: body['type']['id'], name: translations[localeName]![body['type']['name_key']]!),
        'currency': body['currency'] == null ? null : body['currency']['symbol'],
        'playersEnrolled': body['players_enrolled']
      };

      return response;
    }

    return body;
  }

  Future getMatchesOffers(int range, Genre genre, List<int?> types) async {

    final data = {
      "range": range,
      "genre_id": genre.id,
      "types": jsonEncode(types),
    };

    final res = await api.postData(data, '/matches/get-matches-offers');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();

    }

    return body;
  }

  Future joinMatch(int matchId) async {

    final data = {
      "match_id": matchId,
    };

    final res = await api.postData(data, '/join-match');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();
      final match = body['match'];
      body['match'] = Match.fromJson(match);

    }

    return body;
  }

  Future expelFromMatch(int matchId, int userToExpel) async {

    final data = {
      "match_id": matchId,
      "user_to_expel": userToExpel,
    };

    final res = await api.postData(data, '/matches/expel-from-match');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();

    }

    return body;
  }

  Future getMyMatches() async {

    final res = await api.getData('/matches/get-my-matches');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();

    }

    return body;
  }

  Future leaveMatch(int matchId) async {

    final data = {
      "match_id": matchId,
    };

    final res = await api.postData(data, '/leave-match');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();

    }

    return body;
  }

  Future rejectInvitationToMatch(int matchId) async {

    final data = {
      "match_id": matchId,
    };

    final res = await api.postData(data, '/matches/reject-invitation');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();

    }

    return body;
  }

  Future getMyCreatedMatches() async {

    final res = await api.getData('/get-my-created-matches');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();

    }

    return body;
  }

  Future sendInvitationToUser(int userId, int matchId) async {

    final data = {
      "user_id": userId,
      "match_id": matchId,
    };

    final res = await api.postData(data, '/matches/send-invitation-to-user');

    Map body = json.decode(res.body);

    return body;
  }

  Future joinMatchFromInvitationLinkNewUser(int ownerId, int userId, int matchId) async {

    final data = {
      "owner_id": ownerId,
      "user_id": userId,
      "match_id": matchId,
    };

    final res = await api.postData(data, '/matches/join-match-from-invitation-link-new-user');

    Map body = json.decode(res.body);

    return body;
  }

  Future joinMatchFromInvitationLinkExistingUser(int ownerId, int userId, int matchId) async {

    final data = {
      "owner_id": ownerId,
      "user_id": userId,
      "match_id": matchId,
    };

    final res = await api.postData(data, '/matches/join-match-from-invitation-link-existing-user');

    Map body = json.decode(res.body);

    return body;
  }

  Future create(
    Map locationData,
    String whenPlay,
    int genreId,
    int typeId,
    int currencyId,
    double cost,
    int playersForMatch,
    bool isFreeMatch,
    String? description
  ) async {
    final data = {
      "locationData": locationData,
      "when_play": whenPlay,
      "genre_id": genreId,
      "type_id": typeId,
      "currency_id": currencyId,
      "cost": cost,
      "num_players": playersForMatch,
      "is_free_match": isFreeMatch,
      "description": description,
    };

    final res = await api.postData(data, '/match/create');

    Map body = json.decode(res.body);

    return body;
  }

  Future edit(
      int? matchId,
      Map locationData,
      String whenPlay,
      int genreId,
      int typeId,
      int currencyId,
      double cost,
      int playersForMatch,
      bool isFreeMatch,
      String? description,
      ) async {
    final data = {
      "match_id": matchId,
      "locationData": locationData,
      "when_play": whenPlay,
      "genre_id": genreId,
      "type_id": typeId,
      "currency_id": currencyId,
      "cost": cost,
      "num_players": playersForMatch,
      "is_free_match": isFreeMatch,
      "description": description,
    };

    final res = await api.postData(data, '/match/edit');

    Map body = json.decode(res.body);

    return body;
  }

  Future deleteMatch(int matchId) async {

    final data = {
      "match_id": matchId,
    };

    final res = await api.postData(data, '/match/delete');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();

    }

    return body;
  }


}
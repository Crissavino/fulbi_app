import 'dart:convert';

import 'package:fulbito_app/models/player.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/utils/api.dart';

import 'package:fulbito_app/models/field.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRepository {
  Api api = Api();

  Future getInfo() async {
    final res = await api.postData({}, '/home/get-info');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      SharedPreferences localStorage = await SharedPreferences.getInstance();

      List news = body['news'];
      localStorage.setString('homeInfo-news', jsonEncode(news));

      // fields
      List fields = body['fields'];
      body['fields'] = fields.map((field) => Field.fromJson(field)).toList();
      localStorage.setString('homeInfo-fields', json.encode(body['fields'], toEncodable: (e) => e.toJson()));

      // matches
      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();
      localStorage.setString('homeInfo-matches', json.encode(body['matches'], toEncodable: (e) => e.toJson()));
    }

    return body;
  }

  Future search(textToSearch) async {
    final res = await api.postData({
      'text_to_search': textToSearch
    }, '/home/search');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      // fields
      List fields = body['fields'];
      body['fields'] = fields.map((field) => Field.fromJson(field)).toList();
      localStorage.setString('search-fields', json.encode(body['fields'], toEncodable: (e) => e.toJson()));

      // matches
      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();
      localStorage.setString('search-matches', json.encode(body['matches'], toEncodable: (e) => e.toJson()));

      // users
      List users = body['users'];
      body['users'] = users.map((player) => User.fromJson(player)).toList();
      localStorage.setString('search-users', json.encode(body['users'], toEncodable: (e) => e.toJson()));
    }

    return body;
  }
}
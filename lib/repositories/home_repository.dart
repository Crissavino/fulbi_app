import 'dart:convert';

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

  Future getNewsForHome() async {
    final res = await api.postData({}, '/home/get-news-for-home');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      SharedPreferences localStorage = await SharedPreferences.getInstance();

      List news = body['news'];
      localStorage.setString('homeInfo-news', jsonEncode(news));

    }

    return body;
  }

  Future getFieldsForHome() async {
    final res = await api.postData({}, '/home/get-fields-for-home');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      // fields
      List fields = body['fields'];
      body['fields'] = fields.map((field) => Field.fromJson(field)).toList();
      localStorage.setString('homeInfo-fields', jsonEncode(body['fields']));
    }

    return body;
  }

  Future getMatchesForHome() async {
    final res = await api.postData({}, '/home/get-matches-for-home');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      // matches
      List matches = body['matches'];
      body['matches'] = matches.map((match) => Match.fromJson(match)).toList();
      localStorage.setString('homeInfo-matches', jsonEncode(body['matches']));
    }

    return body;
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/player.dart';
import 'package:fulbito_app/models/position_db.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/utils/api.dart';
import 'package:fulbito_app/utils/environment.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  Api api = Api();

  static getCurrentUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? userStr = localStorage.getString("user");
    User user = User.fromJson(jsonDecode(userStr!));
    return user;
  }

  static getAllCurrentUserData() async {

    final res = await Api().postData([], '/me');

    final body = json.decode(res.body);

    if (body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('user', json.encode(body['user']));
      await localStorage.setString('userPositions', json.encode(body['user']!['player']!['positions']!));
      if (body['user']['player']['location'] != null) {
        await localStorage.setString('userLocation', json.encode(body['user']!['player']!['location']!));
      }

      User user = User.fromJson(body['user']);
      Player player = Player.fromJson(body['user']['player']);
      var locationDB = body['user']['player']['location'];
      Location location = Location.fromJson(locationDB);
      List posDB = body['user']['player']['positions'];
      List<PositionDB>? positions = posDB.map((position) {
        return PositionDB.fromJson(position);
      }).toList();

      return {
        'success': true,
        'user': user,
        'player': player,
        'positions': positions,
        'location': location,
      };
    }

    return body;
  }

  Future<bool> logout(int userId) async {

    final data = {
      'user_id': userId,
      'uuid': await getDeviceUuid()
    };

    final res = await api.postData(data, '/logout');

    final body = json.decode(res.body);

    if (body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.remove('user');
      await localStorage.remove('token');
      Sentry.configureScope((scope) => scope.user = null);
      return true;
    } else {
      return false;
    }
  }

  Future<Map> getAppMinimumVersion() async {

    Uri fullUrl = Uri.parse(EnvironmentConstants.apiUrl + '/app/minimum-version');
    final res = await http.get(fullUrl);

    Map body = json.decode(res.body);

    return body;
  }

  Future<Map> login(
    String email,
    String password,
  ) async {

    final data = {
      'email': email,
      'password': password,
      'uuid': await getDeviceUuid(),
      'language': localeName,
      'platform': Platform.isIOS ? 'ios' : 'android'
    };

    final res = await api.authData(data, '/login');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('token', json.encode(body['token']));
      await localStorage.setString('fcm_token', json.encode(body['fcm_token']));
      await localStorage.setString('user', json.encode(body['user']));
      await localStorage.setString('userPositions', json.encode(body['user']!['player']!['positions']!));
      if (body['user']['player']['location'] != null) {
        await localStorage.setString('userLocation', json.encode(body['user']!['player']!['location']!));
      }
      String? userStr = localStorage.getString("user");
      body['user'] = User.fromJson(jsonDecode(userStr!));
    }

    return body;
  }

  Future<String> getDeviceUuid() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String uuid;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      uuid = androidDeviceInfo.androidId;
    } else {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      uuid = iosDeviceInfo.identifierForVendor;
    }
    return uuid;
  }

  Future<Map> loginWithGoogle(
      String? token,
      ) async {
    final data = {
      'id_token': token,
      'uuid': await getDeviceUuid(),
      'language': localeName,
      'platform': Platform.isIOS ? 'ios' : 'android'
    };

    final res = await api.authData(data, '/login-with-google');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('token', json.encode(body['token']));
      await localStorage.setString('fcm_token', json.encode(body['fcm_token']));
      await localStorage.setString('user', json.encode(body['user']));
      await localStorage.setString('userPositions', json.encode(body['user']!['player']!['positions']!));
      if (body['user']['player']['location'] != null) {
        await localStorage.setString('userLocation', json.encode(body['user']!['player']!['location']!));
      }
      String? userStr = localStorage.getString("user");
      body['user'] = User.fromJson(jsonDecode(userStr!));
    }

    return body;
  }

  Future<Map> loginWithApple(
      String? code,
      String? firstName,
      String? lastName,
      String? useBundleId,
      String? state,
      ) async {
    final data = {
      'code': code,
      'first_name': firstName,
      'last_name': lastName,
      'use_bundle_id': useBundleId,
      'state': state,
      'uuid': await getDeviceUuid(),
      'language': localeName,
      'platform': Platform.isIOS ? 'ios' : 'android'
    };

    final res = await api.authData(data, '/login-with-apple');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('token', json.encode(body['token']));
      await localStorage.setString('fcm_token', json.encode(body['fcm_token']));
      await localStorage.setString('user', json.encode(body['user']));
      await localStorage.setString('userPositions', json.encode(body['user']!['player']!['positions']!));
      if (body['user']['player']['location'] != null) {
        await localStorage.setString('userLocation', json.encode(body['user']!['player']!['location']!));
      }
      String? userStr = localStorage.getString("user");
      body['user'] = User.fromJson(jsonDecode(userStr!));
    }

    return body;
  }

  Future<Map> register(
    String email,
    String password,
    String confirmPassword,
    String fullName,
  ) async {
    final data = {
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
      'name': fullName,
      'uuid': await getDeviceUuid(),
      'language': localeName,
      'platform': Platform.isIOS ? 'ios' : 'android'
    };

    final res = await api.authData(data, '/register');

    final Map body = json.decode(res.body);
    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('token', json.encode(body['token']));
      await localStorage.setString('user', json.encode(body['user']));
      await localStorage.setString('fcm_token', json.encode(body['fcm_token']));
      String? userStr = localStorage.getString("user");
      body['user'] = User.fromJson(jsonDecode(userStr!));

      User user = User.fromJson(jsonDecode(userStr));
      Sentry.configureScope(
            (scope) => scope.user = SentryUser(id: user.id.toString(), email: user.email),
      );
    }

    return body;
  }

  Future<bool> isFullySet() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    User user = getUserFromStorage(localStorage);
    return user.isFullySet;
  }

  Future<bool> existEmail(String email) async {
    final data = {
      'email': email,
    };

    final res = await api.authData(data, '/existEmail');

    final body = json.decode(res.body);

    return body['success'];
  }

  Future<dynamic> completeUserProfile(
    dynamic userLocationDetails,
    int genreId
  ) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    User user = getUserFromStorage(localStorage);

    final data = {
      "user_id": user.id,
      "userLocationDetails": userLocationDetails,
      "genre_id": genreId
    };

    final res = await api.postData(data, '/complete-user-profile');

    final body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      await localStorage.setString('user', json.encode(body['user']));
      if (body['user']['player']['location'] != null) {
        await localStorage.setString('userLocation', json.encode(body['user']!['player']!['location']!));
      }
    }

    return body;
  }

  static getUserData(
      int userId,
      ) async {

    final data = {
      "user_id": userId,
    };

    final res = await Api().postData(data, '/get-user-data');

    final body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      List positions = body['user']['player']['positions'];

      return {
        'success': true,
        'user': User.fromJson(body['user']),
        'location': Location.fromJson(body['user']['player']['location']),
        'positions': positions.map((pos) => PositionDB.fromJson(pos)).toList(),
      };
    }

    return body;
  }

  static Future<List<PositionDB>> getUserPositions() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    List<PositionDB> userPositions = [];
    jsonDecode(localStorage.getString('userPositions')!).forEach((element) {
      userPositions.add(PositionDB.fromJson(element));
    });

    return userPositions;
  }

  static Future<Location> getUserLocation() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return Location.fromJson(jsonDecode(localStorage.getString('userLocation')!));
  }

  Future<dynamic> editUserPositions(List positionsIds) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    final data = {
      "positions_ids": positionsIds,
    };

    final res = await api.postData(data, '/edit-user-positions');

    final body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      await localStorage.setString('user', json.encode(body['user']));
      await localStorage.setString('userPositions', json.encode(body['user']['player']['positions']));
    }

    return body;
  }

  User getUserFromStorage(SharedPreferences localStorage) {
    String? userStr = localStorage.getString("user");
    User user = User.fromJson(jsonDecode(userStr!));
    return user;
  }

  Future<dynamic> editUserLocation(dynamic userLocationDetails) async {

    final data = {
      "userLocationDetails": userLocationDetails,
    };

    final res = await api.postData(data, '/edit-user-location');

    final body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('user', json.encode(body['user']));
      await localStorage.setString('userLocation', json.encode(body['user']['player']['location']));
    }

    return body;
  }

  Future<dynamic> getUserOffers(
      int range,
      List<int?> genresIds,
      List positionsIds,
      ) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    final data = {
      "range": range,
      "genres_ids": genresIds,
      "positions_ids": positionsIds,
    };

    final res = await api.postData(data, '/get-users-offers');

    final body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      List players = body['users'];
      if(players.isEmpty) body['players'] = [];
      body['players'] = players.map((user) => User.fromJson(user)).toList();
      await localStorage.setString('players', json.encode(body['users']));
    }

    return body;
  }

  Future<dynamic> changeNickname(String? newNickname) async {

    final data = {
      "new_nickname": newNickname,
    };

    final res = await api.postData(data, '/user/change-nickname');

    final body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      final user = body['user'];
      body['user'] = User.fromJson(user);
      await localStorage.setString('user', json.encode(body['user']));

    }

    return body;
  }

  Future<dynamic> changePassword(String newPassword) async {

    final data = {
      "new_password": newPassword,
    };

    final res = await api.postData(data, '/user/change-password');

    final body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      final user = body['user'];
      body['user'] = User.fromJson(user);
      await localStorage.setString('user', json.encode(body['user']));
    }

    return body;
  }

  Future<dynamic> updateProfilePicture(File localImage) async {

    User user = await getCurrentUser();
    final response = await Api().addImage(
        user.id,
        'profile-image',
        localImage,
        '/user/update-profile-picture'
    );

    if (response.containsKey('success') && response['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      final user = response['user'];
      response['user'] = User.fromJson(user);
      await localStorage.setString('user', json.encode(response['user']));
    }

    return response;
  }

  Future<dynamic> recoverPassword(String email) async {

    final data = {
      "email": email,
    };

    final response = await api.authData(data, '/user/send-recovery-password-email');

    final body = json.decode(response.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      final user = body['user'];
      body['user'] = User.fromJson(user);
      await localStorage.setString('user', json.encode(body['user']));
    }

    return body;
  }

}

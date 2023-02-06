import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fulbito_app/models/field.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/utils/api.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FieldRepository {
  Api api = Api();

  Future getField(fieldId) async {

    final res = await api.getData('/field/$fieldId');

    FirebaseCrashlytics.instance.log(res.toString());
    FirebaseCrashlytics.instance.log(res.body.toString());
    FirebaseCrashlytics.instance.log(res.statusCode.toString());

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      final response = {
        'success': true,
        'myUser': User.fromJson(jsonDecode(localStorage.getString('user')!)),
        'field': Field.fromJson(body['field']),
        'location': Location.fromJson(body['location']),
        'types': body['types'].map((type) => Type.fromJson(type)).toList(),
        'currency': body['currency'] == null ? null : body['currency']['symbol'],
      };

      return response;
    }

    return body;
  }

  Future getFieldsOffers(int range, List<int?> types) async {

    final data = {
      "range": range,
      "types": jsonEncode(types),
    };

    final res = await api.postData(data, '/field/get-fields-offers');

    Map body = json.decode(res.body);

    if (body.containsKey('success') && body['success'] == true) {

      List fields = body['fields'];
      body['fields'] = fields.map((field) => Field.fromJson(field)).toList();

    }

    return body;

  }
}
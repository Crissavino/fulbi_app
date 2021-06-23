import 'dart:convert';
import 'dart:io';
import 'package:fulbito_app/utils/environment.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class Api {
  final String _url = Environment.apiUrl;
  //if you are using android studio emulator, change localhost to 10.0.2.2
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString("token")!);
  }

  authData(data, apiUrl) async {
    Uri fullUrl = Uri.parse(_url + apiUrl);
    return await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }

  getData(apiUrl) async {
    Uri fullUrl = Uri.parse(_url + apiUrl);
    await _getToken();
    return await http.get(
        fullUrl,
        headers: _setHeaders()
    );
  }

  postData(data, apiUrl) async {
    Uri fullUrl = Uri.parse(_url + apiUrl);
    await _getToken();
    return await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }

  Future<dynamic> addImage(int userId, String imageType, File file, String uploadURL) async {
    String addImageUrl = _url + uploadURL;
    var request = http.MultipartRequest('POST', Uri.parse(addImageUrl))
      ..fields.addAll({
        'file': imageType,
        'user_id': userId.toString()
      })
      ..headers.addAll( _setFileHeaders())
      ..files.add(await http.MultipartFile.fromPath(imageType, file.path));
    // var request = http.MultipartRequest('POST', Uri.parse(addImageUrl));
    // request.fields['file'] = imageType;
    // request.files.add(
    //     http.MultipartFile(
    //         'picture',
    //         file.readAsBytes().asStream(),
    //         file.lengthSync(),
    //         filename: imageType
    //     )
    // );
    // request.headers.addAll(_setFileHeaders());

    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    final body = json.decode(respStr);

    if (body.containsKey('success') && body['success'] == true) {
      return body;
    } else {
      return {
        'success': false
      };
    }
  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer $token'
  };

  _setFileHeaders() => {
    'Content-type' : 'multipart/form-data',
    'Authorization' : 'Bearer $token'
  };

}
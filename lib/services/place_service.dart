import 'dart:convert';
import 'dart:io';

import 'package:fulbito_app/models/user_location.dart';
import 'package:fulbito_app/utils/environment.dart';
import 'package:http/http.dart';

// For storing our result
class Suggestion {
  final String? placeId;
  final String? description;
  final UserLocation? details;

  Suggestion(this.placeId, this.description, this.details);

  get desc => this.description;

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId, details: $details)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  static final String androidKey = 'YOUR_API_KEY_HERE';
  static final String iosKey = 'YOUR_API_KEY_HERE';
  final apiKey = EnvironmentConstants.googlePlaceApiKey;

  Future<List<Suggestion>> fetchSuggestions2(String input) async {
    final lang = Platform.localeName;
    Uri request = Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$lang&key=$apiKey&sessiontoken=$sessionToken');
    // final request2 = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$input&radius=10000&key=$apiKey';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) =>
            Suggestion(p['place_id'], p['description'], UserLocation()))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    // final lang = Platform.localeName;
    Uri request = Uri.parse('https://maps.googleapis.com/maps/api/place/textsearch/json?query=$input&radius=10000&key=$apiKey');
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['results']
            .map<Suggestion>((p) =>
            Suggestion(p['place_id'], p['formatted_address'],
              UserLocation(lat: p['geometry']['location']['lat'], lng:p['geometry']['location']['lng'],)))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Suggestion> fetchMyLocation(lat, long) async {
    // final lang = Platform.localeName;
    Uri request = Uri.parse('https://maps.googleapis.com/maps/api/place/textsearch/json?query=a&location=$lat,$long&radius=10000&key=$apiKey');
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['status'] == 'OK') {
        // compose suggestions in a list
        final List<Suggestion> suggestions = result['results']
            .map<Suggestion>((p) =>
            Suggestion(p['place_id'], p['formatted_address'], UserLocation(lat: p['geometry']['location']['lat'], lng:p['geometry']['location']['lng'],)))
            .toList();

        return suggestions[0];
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return Suggestion('0', 'Nada', UserLocation());
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<dynamic> getPlaceDetailFromId(String placeId) async {
    // final lang = Platform.localeName;
    // &fields=name,rating,formatted_phone_number
    Uri request = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?fields=address_components&place_id=$placeId&key=$apiKey');
    final response = await client.get(request);
    String? country;
    String? countryCode;
    String? province;
    String? provinceCode;
    String? city;

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['status'] == 'OK') {
        // compose suggestions in a list

        final List arrayResult = result['result']['address_components'];
        arrayResult.forEach((element) {
          if (element['types'].asMap()[0] == 'country') {
            country = element['long_name'];
            countryCode = element['short_name'];
          }

          if (element['types'].asMap()[0] == 'administrative_area_level_1') {
            province = element['long_name'];
            provinceCode = element['short_name'];
          }

          if (element['types'].asMap()[0] == 'administrative_area_level_2' ||
              element['types'].asMap()[0] == 'locality') {
            city = element['short_name'];
          }
        });

        UserLocation userLocation = UserLocation(
          country: country,
          countryCode: countryCode,
          province: province,
          provinceCode: provinceCode,
          city: city,
        );

        return userLocation;
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
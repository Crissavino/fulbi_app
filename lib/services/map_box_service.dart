import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fulbito_app/models/map_box_search_response.dart';
import 'package:fulbito_app/utils/debouncer.dart';
import 'package:fulbito_app/utils/environment.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:http/http.dart' as http;

class MapBoxService {

  //Singleton
  MapBoxService._privateConstructor();
  static final MapBoxService _instance = MapBoxService._privateConstructor();
  factory MapBoxService(){
    return _instance;
  }

  String apiToken = EnvironmentConstants.mapBoxApiKey;
  String _baseUrl = 'https://api.mapbox.com/geocoding/v5';
  final debouncer = Debouncer<String>(duration: Duration(milliseconds: 400 ));
  final StreamController<MapBoxSearchResponse> _suggestionsStreamController = new StreamController<MapBoxSearchResponse>.broadcast();
  Stream<MapBoxSearchResponse> get suggestionsStream => this._suggestionsStreamController.stream;

  Future<MapBoxSearchResponse> searchPlaceByQuery(String search, LatLng? proximity) async {
    String apiUrl = '$_baseUrl/mapbox.places/$search.json?access_token=$apiToken&cachebuster=1626765438887&autocomplete=true';
    if (proximity != null) {
      apiUrl = '$_baseUrl/mapbox.places/$search.json?access_token=$apiToken&cachebuster=1626765438887&autocomplete=true&proximity=${proximity.longitude},${proximity.latitude}';
    }

    Uri fullUrl = Uri.parse(apiUrl);
    final res = await http.get(fullUrl);

    FirebaseCrashlytics.instance.log(res.toString());
    FirebaseCrashlytics.instance.log(res.body.toString());
    FirebaseCrashlytics.instance.log(res.statusCode.toString());

    if (res.statusCode == 200) {
      final mapBoxSearchResponse = mapBoxResponseFromJson(res.body);

      return mapBoxSearchResponse;
    } else {
      return MapBoxSearchResponse(
          attribution: '',
          features: [],
          query: [],
          type: ''
      );
    }

  }

  void getSuggestionsByQuery( String search, LatLng? proximity ) {

    debouncer.value = '';
    if (proximity == null) {
      debouncer.onValue = ( value ) async {
        final results = await this.searchPlaceByQuery(value, proximity);
        this._suggestionsStreamController.add(results);
      };
    } else {
      debouncer.onValue = ( value ) async {
        final results = await this.searchPlaceByQuery(value, proximity);
        this._suggestionsStreamController.add(results);
      };
    }

    final timer = Timer.periodic(Duration(milliseconds: 200), (_) {
      debouncer.value = search;
    });

    Future.delayed(Duration(milliseconds: 201)).then((_) => timer.cancel());

  }

  void cancel() {
    _suggestionsStreamController.close();
  }

}
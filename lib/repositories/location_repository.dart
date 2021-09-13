import 'package:geolocator/geolocator.dart';

class LocationRepository {
  // final String _accessToken = 'pk.eyJ1IjoiY3Jpc3NhdmlubyIsImEiOiJja2R4OXk4YmQyemUwMnl0YXBtb2psc2tiIn0.P857CLf3OM5PRBPL7IPHbw';
  // String _searchLatLongUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  Future<dynamic> determinePosition({bool calledFromCreateMatch = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Future.error('Location services are disabled.');
      return {
        'denied': true
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return {
        'denied': true
      };
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return {
          'denied': true
        };
      }
    }

    return await Geolocator.getCurrentPosition();
  }

}
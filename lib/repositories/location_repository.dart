import 'package:geolocator/geolocator.dart';

class LocationRepository {
  // final String _accessToken = 'pk.eyJ1IjoiY3Jpc3NhdmlubyIsImEiOiJja2R4OXk4YmQyemUwMnl0YXBtb2psc2tiIn0.P857CLf3OM5PRBPL7IPHbw';
  // String _searchLatLongUrl = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

}
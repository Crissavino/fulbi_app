import 'package:url_launcher/url_launcher.dart';

class MapsUtil {
  MapsUtil._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    print('openMap');
    print(googleUrl);
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future<void> openMapWithAddress(String formattedAddress) async {
    String query = Uri.encodeComponent(formattedAddress);
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    print('openMapWithAddress');
    print(googleUrl);
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
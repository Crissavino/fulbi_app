import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class MapsUtil {
  MapsUtil._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  static Future<void> openMapApp(double latitude, double longitude) async {
    if (Platform.isIOS) {
      String googleUrl =
          'comgooglemaps://?q=$latitude,$longitude&z=17';
      String appleUrl =
          'https://maps.apple.com/?q=$latitude,$longitude';
      if (await canLaunch("comgooglemaps://")) {
        await launch(googleUrl);
      } else if (await canLaunch(appleUrl)) {
        await launch(appleUrl);
      } else {
        throw 'Could not launch url';
      }
    } else {
      String googleAppUrl =
          'geo://$latitude,$longitude?q=$latitude,$longitude&z=17';
      String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch("geo://")) {
        await launch(googleAppUrl);
      } else if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not launch url';
      }
    }

  }

  static Future<void> openMapWithAddress(String formattedAddress) async {
    String query = Uri.encodeComponent(formattedAddress);
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class CreateDynamicLink {

  static Future<Uri> createLink(String path, bool short) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://fulbitoapp.page.link',
      link: Uri.parse('https://fulbito.app/$path'),
      androidParameters: AndroidParameters(
        packageName: 'com.crissavino.fulbito.fulbito_app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.crissavino.fulbito.fulbitoApp',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    return url;
  }

  static Future<Uri> createLinkWithQuery(String path, String query, bool short) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://fulbitoapp.page.link',
      link: Uri.parse('https://fulbito.app/$path?$query'),
      androidParameters: AndroidParameters(
        packageName: 'com.crissavino.fulbito.fulbito_app',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.crissavino.fulbito.fulbitoApp',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    return url;
  }
}
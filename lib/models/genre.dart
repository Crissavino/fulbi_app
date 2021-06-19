import 'dart:io';

import 'package:fulbito_app/utils/translations.dart';

class Genre {
  Genre({
    this.id,
    this.name,
    this.checked,
  });

  int? id;
  String? name;
  bool? checked;

  List<Genre> get genres {
    return [
      Genre(
        id: 1,
        name: translations[Platform.localeName.split('_')[0]]![
            'general.genres.males']!,
        checked: true,
      ),
      Genre(
        id: 2,
        name: translations[Platform.localeName.split('_')[0]]![
            'general.genres.females']!,
        checked: false,
      ),
      Genre(
        id: 3,
        name: translations[Platform.localeName.split('_')[0]]![
            'general.genres.mix']!,
        checked: false,
      ),
    ];
  }
}

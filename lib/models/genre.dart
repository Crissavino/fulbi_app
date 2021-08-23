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
        name: translations[localeName]!['general.genres.males']!,
        checked: true,
      ),
      Genre(
        id: 2,
        name: translations[localeName]!['general.genres.females']!,
        checked: false,
      ),
      Genre(
        id: 3,
        name: translations[localeName]!['general.genres.mix']!,
        checked: false,
      ),
    ];
  }

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
    id: json["id"],
    name: json["name"],
    checked: json["checked"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "checked": checked,
  };
}

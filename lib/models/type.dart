import 'dart:io';

import 'package:fulbito_app/utils/translations.dart';

class Type {
  Type({
    this.id,
    this.name,
    this.checked,
  });

  int? id;
  String? name;
  bool? checked;

  List<Type> get matchTypes {
    return [
      Type(id: 1, name: translations[localeName]!['general.types.f5']!, checked: true),
      Type(id: 2, name: translations[localeName]!['general.types.f7']!, checked: true),
      Type(id: 3, name: translations[localeName]!['general.types.f9']!, checked: true),
      Type(id: 4, name: translations[localeName]!['general.types.f11']!, checked: true),
    ];
  }

  factory Type.fromJson(Map<String, dynamic> json) => Type(
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

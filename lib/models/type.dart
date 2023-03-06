import 'dart:io';

import 'package:fulbito_app/utils/translations.dart';

class Type {
  int? id;
  String? name;
  int? number;
  String? vs;
  double? cost;
  bool? checked;

  Type({
    this.id,
    this.name,
    this.number,
    this.vs,
    this.cost,
    this.checked,
  });

  List<Type> get matchTypes {
    return [
      Type(
        id: 1,
        name: translations[localeName]!['general.types.f5']!,
        vs: "5 vs 5",
        checked: true,
      ),
      Type(
        id: 2,
        name: translations[localeName]!['general.types.f7']!,
        vs: "7 vs 7",
        checked: true,
      ),
      Type(
        id: 3,
        name: translations[localeName]!['general.types.f9']!,
        vs:  "9 vs 9",
        checked: true,
      ),
      Type(
        id: 4,
        name: translations[localeName]!['general.types.f11']!,
        vs: "11 vs 11",
        checked: true,
      ),
    ];
  }

  factory Type.fromJson(Map<String, dynamic> json) => Type(
    id: json["id"],
    name: json["name"],
    cost: json['pivot'] != null ? (json["pivot"]["cost"] != null ? double.parse(json["pivot"]["cost"].toString()) : null) : null,
    number: json['pivot'] != null ? (json["pivot"]["number"] != null ? json["pivot"]["number"] : null) : null,
    checked: json["checked"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "checked": checked,
  };

}

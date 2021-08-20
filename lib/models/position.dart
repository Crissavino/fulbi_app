import 'dart:io';

import 'package:fulbito_app/utils/translations.dart';

class Position {
  Position({
    this.id,
    this.name,
    this.checked,
  });

  int? id;
  String? name;
  bool? checked;

  List<Position> get positions {
    return [
      Position(id: 1, name: translations[localeName]!['general.positions.gk']!, checked: true),
      Position(id: 2, name: translations[localeName]!['general.positions.def']!, checked: true),
      Position(id: 3, name: translations[localeName]!['general.positions.mid']!, checked: true),
      Position(id: 4, name: translations[localeName]!['general.positions.for']!, checked: true),
    ];
  }
}
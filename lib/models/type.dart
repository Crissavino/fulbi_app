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
      Type(id: 1, name: translations[Platform.localeName.split('_')[0]]!['general.types.f5']!, checked: true),
      Type(id: 2, name: translations[Platform.localeName.split('_')[0]]!['general.types.f7']!, checked: true),
      Type(id: 3, name: translations[Platform.localeName.split('_')[0]]!['general.types.f9']!, checked: true),
      Type(id: 4, name: translations[Platform.localeName.split('_')[0]]!['general.types.f11']!, checked: true),
    ];
  }

}

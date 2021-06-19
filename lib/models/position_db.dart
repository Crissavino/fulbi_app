// To parse this JSON data, do
//
//     final positionDb = positionDbFromJson(jsonString);

import 'dart:convert';

PositionDB positionDbFromJson(String str) => PositionDB.fromJson(json.decode(str));

String positionDbToJson(PositionDB data) => json.encode(data.toJson());

class PositionDB {
  PositionDB({
    required this.id,
    this.nameKey,
    this.sportId,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String? nameKey;
  int? sportId;
  dynamic deletedAt;
  dynamic createdAt;
  dynamic updatedAt;

  factory PositionDB.fromJson(Map<String, dynamic> json) => PositionDB(
    id: json["id"],
    nameKey: json["name_key"],
    sportId: json["sport_id"],
    deletedAt: json["deleted_at"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name_key": nameKey,
    "sport_id": sportId,
    "deleted_at": deletedAt,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

// To parse this JSON data, do
//
//     final player = playerFromJson(jsonString);

import 'dart:convert';

Player playerFromJson(String str) => Player.fromJson(json.decode(str));

String playerToJson(Player data) => json.encode(data.toJson());

class Player {
  Player({
    required this.id,
    required this.userId,
    this.teamId,
    required this.locationId,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int userId;
  dynamic teamId;
  int locationId;
  DateTime createdAt;
  DateTime updatedAt;

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json["id"],
    userId: json["user_id"],
    teamId: json["team_id"],
    locationId: json["location_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "team_id": teamId,
    "location_id": locationId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

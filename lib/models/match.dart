// To parse this JSON data, do
//
//     final match = matchFromJson(jsonString);

import 'dart:convert';

import 'package:fulbito_app/models/user.dart';

Match matchFromJson(String str) => Match.fromJson(json.decode(str));

String matchToJson(Match data) => json.encode(data.toJson());

class Match {
  Match({
    required this.id,
    required this.locationId,
    required this.whenPlay,
    required this.genreId,
    required this.typeId,
    required this.numPlayers,
    required this.cost,
    required this.chatId,
    required this.ownerId,
    required this.haveNotifications,
    required this.isConfirmed,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.currencyId,
    this.participants,
  });

  int id;
  int locationId;
  DateTime whenPlay;
  int genreId;
  int typeId;
  int numPlayers;
  double cost;
  int chatId;
  int ownerId;
  bool haveNotifications;
  bool isConfirmed;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  int currencyId;
  List<User>? participants;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: json["id"],
    locationId: json["location_id"],
    whenPlay: DateTime.parse(json["when_play"]),
    genreId: json["genre_id"],
    typeId: json["type_id"],
    numPlayers: json["num_players"],
    cost: double.tryParse(json["cost"].toString())!,
    chatId: json["chat_id"],
    ownerId: json["owner_id"],
    haveNotifications: ((json["have_notifications"] == 1) || json["have_notifications"] == true) ? true : false,
    isConfirmed: ((json["is_confirmed"] == 1) || json["is_confirmed"] == true) ? true : false,
    deletedAt: json["deleted_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    currencyId: json["currency_id"],
    participants: List<User>.from(json["participants"].map((x) => User.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "location_id": locationId,
    "when_play": whenPlay.toIso8601String(),
    "genre_id": genreId,
    "type_id": typeId,
    "num_players": numPlayers,
    "cost": cost,
    "chat_id": chatId,
    "owner_id": ownerId,
    "have_notifications": haveNotifications,
    "is_confirmed": isConfirmed,
    "deleted_at": deletedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "currency_id": currencyId,
    "participants": List<dynamic>.from(participants!.map((x) => x.toJson())),
  };
}

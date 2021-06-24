// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'dart:convert';

import 'package:fulbito_app/models/user.dart';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {

  static const TYPES = {
    'text': 1,
    'image': 2,
    'audio': 3,
    'header': 4,
  };

  Message({
    required this.id,
    required this.text,
    required this.ownerId,
    required this.owner,
    required this.chatId,
    this.language,
    required this.type,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String text;
  int ownerId;
  User owner;
  int chatId;
  dynamic language;
  int type;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    text: json["text"],
    ownerId: json["owner_id"],
    owner: User.fromJson(json["owner"]),
    chatId: json["chat_id"],
    language: json["language"],
    type: json["type"],
    deletedAt: json["deleted_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "text": text,
    "owner_id": ownerId,
    "owner": owner,
    "chat_id": chatId,
    "language": language,
    "type": type,
    "deleted_at": deletedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

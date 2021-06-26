// To parse this JSON data, do
//
//     final device = deviceFromJson(jsonString);

import 'dart:convert';

Device deviceFromJson(String str) => Device.fromJson(json.decode(str));

String deviceToJson(Device data) => json.encode(data.toJson());

class Device {
  Device({
    required this.id,
    required this.userId,
    required this.token,
    this.uuid,
    this.language,
  });

  int id;
  int userId;
  String token;
  dynamic uuid;
  dynamic language;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json["id"],
    userId: json["user_id"],
    token: json["token"],
    uuid: json["uuid"],
    language: json["language"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "token": token,
    "uuid": uuid,
    "language": language,
  };
}

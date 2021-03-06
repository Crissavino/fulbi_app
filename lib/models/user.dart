// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    required this.id,
    required this.name,
    required this.nickname,
    required this.email,
    this.emailVerifiedAt,
    required this.isFullySet,
    required this.premium,
    required this.matchesCreated,
    required this.genreId,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  String nickname;
  String email;
  dynamic emailVerifiedAt;
  bool isFullySet;
  bool premium;
  int matchesCreated;
  int? genreId;
  String? profileImage;
  DateTime createdAt;
  DateTime updatedAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    nickname: json["nickname"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    isFullySet: ((json["is_fully_set"] == 1) || json["is_fully_set"] == true) ? true : false,
    premium: ((json["premium"] == 1) || json["premium"] == true) ? true : false,
    matchesCreated: json["matches_created"],
    profileImage: json["profile_image"],
    genreId: json["genre_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "nickname": nickname,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "is_fully_set": isFullySet,
    "premium": premium,
    "matches_created": matchesCreated,
    "profile_image": profileImage,
    "genre_id": genreId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

// To parse this JSON data, do
//
//     final location = locationFromJson(jsonString);

import 'dart:convert';

Location locationFromJson(String str) => Location.fromJson(json.decode(str));

String locationToJson(Location data) => json.encode(data.toJson());

class Location {
  Location({
    required this.id,
    required this.lat,
    required this.lng,
    required this.country,
    required this.countryCode,
    required this.province,
    required this.provinceCode,
    required this.city,
    required this.placeId,
    required this.formattedAddress,
    this.isByLatLng,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  double lat;
  double lng;
  String country;
  String countryCode;
  String province;
  String provinceCode;
  String city;
  String placeId;
  String formattedAddress;
  bool? isByLatLng;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    id: json["id"],
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble(),
    country: json["country"],
    countryCode: json["country_code"],
    province: json["province"],
    provinceCode: json["province_code"],
    city: json["city"],
    placeId: json["place_id"],
    formattedAddress: json["formatted_address"],
    isByLatLng: (json["is_by_lat_lng"] == 1) ? true : false,
    deletedAt: json["deleted_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lat": lat,
    "lng": lng,
    "country": country,
    "country_code": countryCode,
    "province": province,
    "province_code": provinceCode,
    "city": city,
    "place_id": placeId,
    "formatted_address": formattedAddress,
    "is_by_lat_lng": isByLatLng,
    "deleted_at": deletedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

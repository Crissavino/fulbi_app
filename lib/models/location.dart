// To parse this JSON data, do
//
//     final location = locationFromJson(jsonString);

import 'dart:convert';

Location locationFromJson(String str) => Location.fromJson(json.decode(str));

String locationToJson(Location data) => json.encode(data.toJson());

class Location {
  Location({
    this.id,
    required this.lat,
    required this.lng,
    required this.country,
    this.countryCode,
    required this.province,
    this.provinceCode,
    required this.city,
    this.placeId,
    required this.formattedAddress,
    this.isByLatLng,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  double lat;
  double lng;
  String country;
  String? countryCode;
  String province;
  String? provinceCode;
  String city;
  String? placeId;
  String formattedAddress;
  bool? isByLatLng;
  dynamic deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    id: json["id"],
    lat: json["lat"] is double ? json["lat"] : double.parse(json["lat"]),
    lng: json["lng"] is double ? json["lng"] : double.parse(json["lng"]),
    country: json["country"],
    countryCode: json["country_code"] == null ? null : json["country_code"],
    province: json["province"],
    provinceCode: json["province_code"] == null ? null : json["province_code"],
    city: json["city"],
    placeId: json["place_id"] == null ? null : json["place_id"],
    formattedAddress: json["formatted_address"],
    isByLatLng: ((json["is_by_lat_lng"] == 1) || json["is_by_lat_lng"] == true) ? true : false,
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
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}

class UserLocation {
  final String? country;
  final String? countryCode;
  final String? province;
  final String? provinceCode;
  final String? city;
  String? placeId;
  String? formattedAddress;
  double? lat;
  double? lng;
  bool? isByLatLng;

  UserLocation({
    this.country,
    this.countryCode,
    this.province,
    this.provinceCode,
    this.placeId,
    this.formattedAddress,
    this.city,
    this.lat,
    this.lng,
    this.isByLatLng,
  });

  Map<String, dynamic> toJson() => {
    "country": country,
    "country_code": countryCode,
    "province": province,
    "province_code": provinceCode,
    "place_id": placeId,
    "formatted_address": formattedAddress,
    "city": city,
    "lat": lat,
    "lng": lng,
    "is_by_lat_lng": isByLatLng,
  };
}

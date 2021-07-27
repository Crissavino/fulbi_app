// To parse this JSON data, do
//
//     final mapBoxResponse = mapBoxResponseFromJson(jsonString);

import 'dart:convert';

MapBoxSearchResponse mapBoxResponseFromJson(String str) => MapBoxSearchResponse.fromJson(json.decode(str));

String mapBoxResponseToJson(MapBoxSearchResponse data) => json.encode(data.toJson());

class MapBoxSearchResponse {
  MapBoxSearchResponse({
    required this.type,
    required this.query,
    required this.features,
    required this.attribution,
  });

  String type;
  List<String> query;
  List<Feature> features;
  String attribution;

  factory MapBoxSearchResponse.fromJson(Map<String, dynamic> json) => MapBoxSearchResponse(
    type: json["type"],
    query: json["query"] != null ? List<String>.from(json["query"].map((x) => x.toString())) : [],
    features: json["features"] != null ? List<Feature>.from(json["features"].map((x) => Feature.fromJson(x))) : [],
    attribution: json["attribution"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "query": List<dynamic>.from(query.map((x) => x)),
    "features": List<dynamic>.from(features.map((x) => x.toJson())),
    "attribution": attribution,
  };
}

class Feature {
  Feature({
    required this.id,
    required this.type,
    required this.placeType,
    required this.relevance,
    required this.properties,
    required this.text,
    required this.placeName,
    required this.bbox,
    required this.center,
    required this.geometry,
    required this.context,
  });

  String id;
  String type;
  List<String> placeType;
  double relevance;
  Properties properties;
  String text;
  String placeName;
  List<double>? bbox;
  List<double> center;
  Geometry geometry;
  List<Context> context;

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    id: json["id"],
    type: json["type"],
    placeType: List<String>.from(json["place_type"].map((x) => x)),
    relevance: double.parse(json["relevance"].toString()),
    properties: Properties.fromJson(json["properties"]),
    text: json["text"],
    placeName: json["place_name"],
    bbox: json["bbox"] == null ? null : List<double>.from(json["bbox"].map((x) => x.toDouble())),
    center: List<double>.from(json["center"].map((x) => x.toDouble())),
    geometry: Geometry.fromJson(json["geometry"]),
    context: json["context"] != null ? List<Context>.from(json["context"].map((x) => Context.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "place_type": List<dynamic>.from(placeType.map((x) => x)),
    "relevance": relevance,
    "properties": properties.toJson(),
    "text": text,
    "place_name": placeName,
    "bbox": bbox == null ? null : List<dynamic>.from(bbox!.map((x) => x)),
    "center": List<dynamic>.from(center.map((x) => x)),
    "geometry": geometry.toJson(),
    "context": List<dynamic>.from(context.map((x) => x.toJson())),
  };
}

class Context {
  Context({
    required this.id,
    required this.wikidata,
    required this.shortCode,
    required this.text,
  });

  String id;
  String wikidata;
  String shortCode;
  String text;

  factory Context.fromJson(Map<String, dynamic> json) => Context(
    id: json["id"],
    wikidata: json["wikidata"] == null ? null : json["wikidata"],
    shortCode: json["short_code"] == null ? null : json["short_code"],
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "wikidata": wikidata == null ? null : wikidata,
    "short_code": shortCode == null ? null : shortCode,
    "text": text,
  };
}

class Geometry {
  Geometry({
    required this.type,
    required this.coordinates,
  });

  String type;
  List<double> coordinates;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    type: json["type"],
    coordinates: List<double>.from(json["coordinates"].map((x) => x.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
  };
}

class Properties {
  Properties({
    required this.wikidata,
    required this.foursquare,
    required this.landmark,
    required this.address,
    required this.category,
  });

  String wikidata;
  String foursquare;
  bool landmark;
  String address;
  String category;

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    wikidata: json["wikidata"] == null ? null : json["wikidata"],
    foursquare: json["foursquare"] == null ? null : json["foursquare"],
    landmark: json["landmark"] == null ? null : json["landmark"],
    address: json["address"] == null ? null : json["address"],
    category: json["category"] == null ? null : json["category"],
  );

  Map<String, dynamic> toJson() => {
    "wikidata": wikidata == null ? null : wikidata,
    "foursquare": foursquare == null ? null : foursquare,
    "landmark": landmark == null ? null : landmark,
    "address": address == null ? null : address,
    "category": category == null ? null : category,
  };
}

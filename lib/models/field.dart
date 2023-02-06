import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/type.dart';

class Field {
  final int id;
  final int locationId;
  final String name;
  final String address;
  final String description;
  final int currencyId;
  final double cost;
  final String image;
  List<Type> types;
  Location? location;
  dynamic currency;

  Field({
    required this.id,
    required this.locationId,
    required this.name,
    required this.address,
    required this.description,
    required this.currencyId,
    required this.cost,
    required this.image,
    required this.types,
    required this.location,
    this.currency
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      locationId: json['location_id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      currencyId: json['currency_id'],
      cost: json['cost'],
      image: json['image'],
      types: json['types'] != null ? (json['types'] as List).map((i) => Type.fromJson(i)).toList() : [],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      currency: json['currency'] != null ? json['currency']['symbol'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'name': name,
      'address': address,
      'description': description,
      'currency_id': currencyId,
      'cost': cost,
      'image': image,
    };
  }

}
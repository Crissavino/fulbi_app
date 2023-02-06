import 'package:fulbito_app/models/field.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/type.dart';

class Booking {
  final int id;
  final int userId;
  final int fieldId;
  final int matchId;
  final int typeId;
  final DateTime when;
  final String message;
  final String status;
  final bool haveNotifications;
  Field? field;
  User? user;
  Match? match;
  Type type;

  Booking({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.matchId,
    required this.typeId,
    required this.when,
    required this.message,
    required this.status,
    required this.haveNotifications,
    this.field,
    this.user,
    this.match,
    required this.type,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      fieldId: json['field_id'],
      matchId: json['match_id'],
      typeId: json['type_id'],
      when: DateTime.parse(json['when']),
      message: json['message'],
      status: json['status'],
      haveNotifications: ((json["have_notifications"] == 1) || json["have_notifications"] == true) ? true : false,
      field: json['field'] != null ? Field.fromJson(json['field']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      match: json['match'] != null ? Match.fromJson(json['match']) : null,
      type: Type.fromJson(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'field_id': fieldId,
      'match_id': matchId,
      'when': when.toIso8601String(),
      'message': message,
      'status': status,
      'have_notifications': haveNotifications,
    };
  }
}
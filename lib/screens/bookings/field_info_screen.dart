import 'package:flutter/material.dart';
import 'package:fulbito_app/models/field.dart';

// ignore: must_be_immutable
class FieldInfoScreen extends StatefulWidget {

  Field field;

  FieldInfoScreen({
    Key? key,
    required this.field,
  }) : super(key: key);

  @override
  State<FieldInfoScreen> createState() => _FieldInfoScreenState();
}

class _FieldInfoScreenState extends State<FieldInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

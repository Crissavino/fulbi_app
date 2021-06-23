import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> openDatePicker(BuildContext context, ) async {
  DateTime today = DateTime.now();

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: today,
    firstDate: DateTime(today.year),
    lastDate: DateTime((today.year + 1)),
    builder: (context, Widget? child) {
      return Theme(
        data: ThemeData.dark(),
        child: child!,
      );
    },
  );

  return selectedDate;
}
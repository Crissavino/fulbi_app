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
  //
  // if (Platform.isAndroid) {
  //   return showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(selectedDate.year),
  //     lastDate: DateTime((selectedDate.year + 1)),
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.light(),
  //         child: child,
  //       );
  //     },
  //   );
  // }
  //
  // return showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext builder) {
  //       return Container(
  //         height: MediaQuery.of(context).copyWith().size.height / 3,
  //         color: Colors.white,
  //         child: CupertinoDatePicker(
  //           mode: CupertinoDatePickerMode.date,
  //           onDateTimeChanged: (picked) {
  //             print(picked);
  //           },
  //           initialDateTime: selectedDate,
  //           minimumYear: 2000,
  //           maximumYear: 2025,
  //         ),
  //       );
  //     });
}
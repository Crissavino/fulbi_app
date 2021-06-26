import 'package:flutter/material.dart';

customSnackBar(String content, Function() onPressed) => SnackBar(
  content: Text(
    content,
    style: TextStyle(
      color: Colors.white
    ),
  ),
  duration: Duration(seconds: 10),
  action: SnackBarAction(
    label:'Click',
    onPressed: onPressed,
    textColor: Colors.white,
    disabledTextColor: Colors.grey,
  ),
  onVisible: () {
    print('Snackbar is visible');
  },
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
  behavior: SnackBarBehavior.floating,
  margin: EdgeInsets.all(30.0),
  padding: EdgeInsets.all(15.0),
  backgroundColor: Colors.green[400],
);
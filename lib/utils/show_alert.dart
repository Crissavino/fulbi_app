import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fulbito_app/utils/translations.dart';

showAlert(BuildContext context, String title, String subTitle) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(subTitle),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ok'),
            color: Colors.blue,
            elevation: 5,
          ),
        ],
      ),
    );
  }

  return showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(subTitle),
      actions: [
        CupertinoDialogAction(
          child: Text('Ok'),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

showAlertWithEvent(BuildContext context, String title, Function()? onPressed) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              translations[localeName]!['general.cancel']!,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            color: Colors.blue,
            elevation: 5,
          ),
          MaterialButton(
            onPressed: onPressed,
            child: Text(
              translations[localeName]!['general.accept']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            color: Colors.blue,
            elevation: 5,
          ),
        ],
      ),
    );
  }

  return showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text(title),
      actions: [
        CupertinoDialogAction(
          child: Text(
            translations[localeName]!['general.cancel']!,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          textStyle: TextStyle(fontWeight: FontWeight.w100),
        ),
        CupertinoDialogAction(
          child: Text(
            translations[localeName]!['general.accept']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          isDefaultAction: false,
          onPressed: onPressed,
        ),
      ],
    ),
  );
}

showAlertWithEventAcceptAndCancel(BuildContext context, String title, Function()? onAcceptPressed, Function()? onCancelPressed) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        actions: [
          MaterialButton(
            onPressed: onCancelPressed,
            child: Text(
              translations[localeName]!['general.cancel']!,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            color: Colors.blue,
            elevation: 5,
          ),
          MaterialButton(
            onPressed: onAcceptPressed,
            child: Text(
              translations[localeName]!['general.accept']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            color: Colors.blue,
            elevation: 5,
          ),
        ],
      ),
    );
  }

  return showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text(title),
      actions: [
        CupertinoDialogAction(
          child: Text(
            translations[localeName]!['general.cancel']!,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          isDefaultAction: true,
          onPressed: onCancelPressed,
          textStyle: TextStyle(fontWeight: FontWeight.w100),
        ),
        CupertinoDialogAction(
          child: Text(
            translations[localeName]!['general.accept']!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          isDefaultAction: false,
          onPressed: onAcceptPressed,
        ),
      ],
    ),
  );
}

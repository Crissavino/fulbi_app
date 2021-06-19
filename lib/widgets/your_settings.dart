import 'package:flutter/material.dart';

class YourSettings extends StatefulWidget {
  @override
  _YourSettingsState createState() => _YourSettingsState();
}

class _YourSettingsState extends State<YourSettings> {
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height / 1.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          top: 40.0,
          left: 20.0,
          right: 20.0,
        ),
        child: Text('Tu configuracion'),
      ),
    );
  }
}

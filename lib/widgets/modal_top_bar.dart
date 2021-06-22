import 'package:flutter/material.dart';

class ModalTopBar extends StatelessWidget {
  const ModalTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    return Positioned(
      top: 6.0,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: Container(
          width: _width * 0.5,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }
}

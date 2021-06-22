import 'package:flutter/material.dart';

class HeaderMessage extends StatelessWidget {
  final String? text;
  final AnimationController animationController;

  const HeaderMessage({
    required this.text,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticOut,
        ),
        child: message(context, text!),
      ),
    );
  }

  Container message(BuildContext context, String text) {
    return Container(
        margin: EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
        ),
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        width: MediaQuery.of(context).size.width,
        child: Text(
          this.text!,
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      );
  }
}

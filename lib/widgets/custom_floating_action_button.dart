import 'package:flutter/material.dart';
import 'package:fulbito_app/screens/matches/create_match_screen.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              CreateMatchScreen(),
          transitionDuration: Duration(seconds: 0),
        ),);
      },
      child: Icon(
        Icons.add,
        size: 30.0,
      ),
      backgroundColor: Colors.green[500],
      foregroundColor: Colors.white,
    );
  }
}

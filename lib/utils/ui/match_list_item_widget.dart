import 'package:flutter/material.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:intl/intl.dart';

class MatchListItemWidget extends StatelessWidget {
  final Match match;
  final Animation<double> animation;

  const MatchListItemWidget({
    Key? key,
    required this.match,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => buildItem(context, this.match);

  Widget buildItem(context, Match match) => SizeTransition(
    sizeFactor: this.animation,
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchInfoScreen(
              match: match,
              calledFromMyMatches: false,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[600]!,
              Colors.green[500]!,
              Colors.green[500]!,
              Colors.green[600]!,
            ],
            stops: [0.1, 0.4, 0.7, 0.9],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green[100]!,
              blurRadius: 6.0,
              offset: Offset(0, 8),
            ),
          ],
          color: Colors.green[400],
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: 80.0,
        child: Center(
          child: ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.sports_soccer,
                color: Colors.green[700],
                size: 40.0,
              ),
            ),
            title: Text(
              DateFormat('dd/MM HH:mm').format(match.whenPlay),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            trailing: Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
              size: 40.0,
            ),
          ),
        ),
      ),
    ),
  );
}

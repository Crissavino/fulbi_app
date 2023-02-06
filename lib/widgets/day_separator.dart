import 'package:flutter/material.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DaySeparator extends StatelessWidget {
  dynamic matches;
  int index;

  DaySeparator({
    required this.matches,
    required this.index,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (index != matches.length + 1) {
      Match match = matches[index];
      DateTime today = DateTime.now();
      bool itsPlayToday = today.day == match.whenPlay.day;
      bool itsPlayTomorrow = today.day + 1 == match.whenPlay.day;
      String gameDay = DateFormat('EEEE').format(match.whenPlay);
      if (itsPlayToday) {
        if (index != 0) {
          Match previousMatch = matches[index - 1];
          bool itsPlaySameDay = match.whenPlay.day == previousMatch.whenPlay.day;
          if (itsPlaySameDay) {
            return Container();
          } else {
            return dayDivider(translations[localeName]!['general.today']!);
          }
        }
        return dayDivider(translations[localeName]!['general.today']!);
      } else if(itsPlayTomorrow) {
        if (index != 0) {
          Match previousMatch = matches[index - 1];
          bool itsPlaySameDay = match.whenPlay.day == previousMatch.whenPlay.day;
          if (itsPlaySameDay) {
            return Container();
          } else {
            return dayDivider(translations[localeName]!['general.tomorrow']!);
          }
        }
        return dayDivider(translations[localeName]!['general.tomorrow']!);
      } else {
        if (index != 0) {
          Match previousMatch = matches[index - 1];
          bool itsPlaySameDay = match.whenPlay.day == previousMatch.whenPlay.day;
          if (itsPlaySameDay) {
            return Container();
          } else {
            return dayDivider(
              '${translations[localeName]!['general.day.${gameDay.toLowerCase()}']!} ${DateFormat('dd/MM').format(match.whenPlay)}',
            );
          }
        }
        return dayDivider(
          '${translations[localeName]!['general.day.${gameDay.toLowerCase()}']!} ${DateFormat('dd/MM').format(match.whenPlay)}',
        );
      }

    } else {
      return Container();
    }
  }

  Widget dayDivider (String day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 10.0,),
            child: Text(day, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Divider(
                  color: Colors.black
              ),
            ),
          )
        ],
      ),
    );
  }
}

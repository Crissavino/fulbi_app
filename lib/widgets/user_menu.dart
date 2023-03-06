import 'package:flutter/material.dart';
import 'package:fulbito_app/screens/bookings/bookings_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/screens/players/players_screen.dart';
import 'package:fulbito_app/screens/profile/private_profile_screen.dart';
import 'package:fulbito_app/utils/translations.dart';

// ignore: must_be_immutable
class UserMenu extends StatefulWidget {

  bool isLoading;
  int currentIndex;

  UserMenu({
    Key? key,
    required this.isLoading,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  @override
  Widget build(BuildContext context) {

    return BottomAppBar(
      elevation: 20.0,
      shape: CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: Container(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildButton(
                BookingsScreen(), Icons.calendar_month_outlined, 0, translations[localeName]!['menu.bookings']!),
            _buildButton(MatchesScreen(), Icons.sports_soccer, 1, translations[localeName]!['menu.matches']!),
            SizedBox(width: 40.0),
            _buildButton(
                PlayersScreen(), Icons.groups_outlined, 2, translations[localeName]!['menu.players']!),
            _buildButton(
                PrivateProfileScreen(), Icons.person_outline, 3, translations[localeName]!['menu.profile']!),
          ],
        ),
      ),
    );

  }

  TextButton _buildButton(screen, icon, index, menuText) {
    return TextButton(
        onPressed: () {
          if (widget.currentIndex == index) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => screen,
              transitionDuration: Duration(seconds: 0),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: widget.currentIndex == index
                  ? Colors.green[400]
                  : Colors.green[900],
            ),
            Text(
              menuText,
              style: TextStyle(
                color: widget.currentIndex == index
                    ? Colors.green[400]
                    : Colors.green[900],
              ),
            ),
          ],
        ),
      );
  }
}

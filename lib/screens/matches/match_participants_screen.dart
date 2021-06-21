import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/matches/match_chat_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/screens/profile/public_profile_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';

// ignore: must_be_immutable
class MatchParticipantsScreen extends StatefulWidget {
  Match match;

  MatchParticipantsScreen({Key? key, required this.match}) : super(key: key);

  @override
  _MatchParticipantsScreenState createState() =>
      _MatchParticipantsScreenState();
}

class _MatchParticipantsScreenState extends State<MatchParticipantsScreen> {
  String localeName = Platform.localeName.split('_')[0];

  @override
  Widget build(BuildContext context) {
    bool imInscribed = false;
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              appBar: new PreferredSize(
                child: new Container(
                  decoration: horizontalGradient,
                  child: AppBar(
                    backwardsCompatibility: false,
                    systemOverlayStyle:
                        SystemUiOverlayStyle(statusBarColor: Colors.white),
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    title: Text(
                      translations[localeName]!['general.players']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                preferredSize: new Size(
                  MediaQuery.of(context).size.width,
                  70.0,
                ),
              ),
              resizeToAvoidBottomInset: false,
              body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: Container(
                  padding:
                      EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                  margin: EdgeInsets.only(top: 20.0),
                  width: _width,
                  height: _height,
                  child: FutureBuilder(
                    future: MatchRepository().getMatch(widget.match.id),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          width: _width,
                          height: _height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [circularLoading],
                          ),
                        );
                      }

                      dynamic response = snapshot.data;

                      if (response['success']) {
                        Match match = snapshot.data['match'];
                        List<User?> participants =
                            match.participants!;
                        User myUser = snapshot.data['myUser'];

                        if (participants.isNotEmpty) {
                          User? me = participants
                              .firstWhere((user) => user!.id == myUser.id, orElse: () => null);
                          imInscribed = me != null;
                        }

                        if (participants.isEmpty) {
                          return Container(
                            width: _width,
                            height: _height,
                            child: Center(child: Text(translations[localeName]!['general.noParticipants']!)),
                          );
                        }

                        return ListView.builder(
                          itemCount: participants.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildPlayerRow(participants[index]!);
                          },
                        );
                      } else {
                        return showAlert(
                          context,
                          'Error!',
                          'Ocurrió un error cargar los jugadores!',
                        );
                      }
                    },
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.add_circle_outline,
                  size: 40.0,
                ),
                onPressed: () {
                  if (imInscribed) {
                    showAlert(
                        context, 'Error', 'Ya estas inscripto en este partido');
                  } else {
                    showAlertWithEvent(
                      context,
                      translations[localeName]!['match.join']!,
                      () async {
                        print('unirese');
                        // TODO unirse al partido
                        final response =
                            await MatchRepository().joinMatch(widget.match.id);
                        if (response['success']) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyMatchesScreen(),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                          showAlert(
                              context, 'Error', 'Oooops ocurrio un error');
                        }
                      },
                    );
                  }
                },
                backgroundColor: Colors.green[800]!,
              ),
              bottomNavigationBar: _buildBottomNavigationBar(),
            ),
          )
        ],
      ),
    );
  }

  void _navigateToSection(index) async {

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchInfoScreen(
              match: widget.match,
            ),
          ),
        );
        break;
      case 2:
        User currentUser = await UserRepository.getCurrentUser();
        bool imIn = false;
        if (widget.match.participants!.isNotEmpty) {
          imIn = (widget.match.participants!.firstWhere((user) => user.id == currentUser.id)) != null;
        }

        if (!imIn) {
          return showAlertWithEvent(
            context,
            translations[localeName]!['match.chat.join']!,
                () async {
              final response =
              await MatchRepository().joinMatch(widget.match.id);
              if (response['success']) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchChatScreen(
                        match: widget.match,
                        currentUser: currentUser
                    ),
                  ),
                );
              } else {
                Navigator.pop(context);
                showAlert(
                    context, 'Error', 'Oooops ocurrio un error');
              }
            },
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MatchChatScreen(
                  match: widget.match,
                  currentUser: currentUser
              ),
            ),
          );
        }

        break;
      default:
        return;
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0.0,
      iconSize: 30,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.green[400],
      unselectedItemColor: Colors.green[900],
      backgroundColor: Colors.white,
      currentIndex: 1,
      onTap: (index) {
        if (index != 1) {
          _navigateToSection(index);
        }
        print(index);
      },
      items: [
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Informacion'),
          icon: Icon(Icons.info_outline),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Participantes'),
          icon: Icon(
            Icons.group,
          ),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Chat'),
          icon: Icon(Icons.chat_bubble_outline),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(User user) {
    final _width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicProfileScreen(
              userId: user.id,
              calledFromMatch: true,
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
              offset: Offset(0, 4),
            ),
          ],
          color: Colors.green[400],
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        width: _width,
        height: 80.0,
        child: Center(
          child: ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.green[700],
                size: 40.0,
              ),
            ),
            title: Text(
              user.name,
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
    );
  }
}
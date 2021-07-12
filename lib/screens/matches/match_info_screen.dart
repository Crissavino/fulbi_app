import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/matches/match_chat_screen.dart';
import 'package:fulbito_app/screens/matches/match_participants_screen.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/maps_util.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

// ignore: must_be_immutable
class MatchInfoScreen extends StatefulWidget {
  Match match;

  MatchInfoScreen({Key? key, required this.match}) : super(key: key);

  @override
  _MatchInfoScreenState createState() => _MatchInfoScreenState();
}

class _MatchInfoScreenState extends State<MatchInfoScreen> {
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
                      translations[localeName]!['match.info']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            enableDrag: true,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Container(
                                height: _height / 4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 10.0),
                                    GestureDetector(
                                      onTap: () async {
                                        await Clipboard.setData(
                                          new ClipboardData(
                                            text: 'Hola',
                                          ),
                                        );

                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Link copiado",
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Invitar nuevo jugador con link',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await Clipboard.setData(
                                          new ClipboardData(
                                            text: 'Hola 2',
                                          ),
                                        );

                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Link copiado 2",
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Invitar jugador existente con link',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.menu),
                      )
                    ],
                  ),
                ),
                preferredSize: new Size(
                  MediaQuery.of(context).size.width,
                  70.0,
                ),
              ),
              resizeToAvoidBottomInset: false,
              body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: Platform.isIOS
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                child: Center(
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

                      Match match = snapshot.data['match'];
                      Location location = snapshot.data['location'];
                      Genre genre = snapshot.data['genre'];
                      Type type = snapshot.data['type'];
                      String currencySymbol = snapshot.data['currency'];
                      int playersEnrolled = match.participants!.length;
                      String spotsAvailable =
                          (match.numPlayers - playersEnrolled).toString();

                      List<User?> participants = match.participants!;
                      User myUser = snapshot.data['myUser'];

                      if (participants.isNotEmpty) {
                        User? me = participants.firstWhereOrNull(
                                (user) => user!.id == myUser.id);
                        imInscribed = me != null;
                      }

                      return Container(
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 40.0,
                                    bottom: 20.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildPlaysIn(location, _width),
                                      _buildPlaysOn(match),
                                      _buildMatchType(type),
                                      _buildMatchGenre(genre),
                                      _buildMatchCost(currencySymbol, match),
                                      _buildMatchSpots(spotsAvailable),
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      );
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

  Container _buildMatchSpots(String spotsAvailable) {
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Text(
        localeName == 'es'
            ? 'Quedan $spotsAvailable lugares disponibles'
            : 'There are $spotsAvailable spots available',
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  Container _buildMatchCost(String currencySymbol, Match match) {
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Text(
        translations[localeName]!['match.aproxCost']! +
            ' ' +
            currencySymbol +
            match.cost.toString(),
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  Container _buildMatchGenre(Genre genre) {
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Text(
        translations[localeName]!['general.for']! + ' ' + genre.name!,
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  Container _buildMatchType(Type type) {
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Text(
        translations[localeName]!['match.isMatchType']! + ' ' + type.name!,
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  Container _buildPlaysOn(Match match) {
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Text(
        localeName == 'es'
            ? 'El ${DateFormat('d').format(match.whenPlay)} de ${DateFormat('MMMM').format(match.whenPlay)} de ${DateFormat('y').format(match.whenPlay)}'
            : 'On ${DateFormat('MMMM').format(match.whenPlay)} ${DateFormat('d').format(match.whenPlay)}, ${DateFormat('y').format(match.whenPlay)}',
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  Row _buildPlaysIn(Location location, double _width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Text(
            translations[localeName]!['match.itPlayedIn']! +
                ' ' +
                location.formattedAddress,
            style: TextStyle(),
            overflow: TextOverflow.clip,
          ),
          width: _width / 1.5,
        ),
        Container(
          child: GestureDetector(
            onTap: () async {
              if (location.isByLatLng!) {
                await MapsUtil.openMapWithAddress(location.formattedAddress);
                // await MapsUtil.openMap(location.lat, location.lng);
              } else {
                await MapsUtil.openMapWithAddress(location.formattedAddress);
              }
            },
            child: Column(
              children: [
                Container(
                  child: Icon(Icons.location_on, color: Colors.blueAccent),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  child: Text(
                    'Ver mapa',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToSection(index) async {
    // TODO usar sockets para esto
    final resp = await MatchRepository().getMatch(widget.match.id);
    Match match = resp['match'];
    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchParticipantsScreen(
              match: match,
            ),
          ),
        );
        break;
      case 2:
        User currentUser = await UserRepository.getCurrentUser();
        bool imIn = false;
        if (match.participants!.isNotEmpty) {
          imIn = (match.participants
                  ?.firstWhereOrNull((user) => user.id == currentUser.id)) !=
              null;
        }

        if (!imIn) {
          return showAlertWithEvent(
            context,
            translations[localeName]!['match.chat.join']!,
            () async {
              final response =
                  await MatchRepository().joinMatch(widget.match.id);
              if (response['success']) {
                setState(() {
                  widget.match = response['match'];
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchChatScreen(
                        match: widget.match, currentUser: currentUser),
                  ),
                );
              } else {
                Navigator.pop(context);
                showAlert(context, 'Error', 'Oooops ocurrio un error');
              }
            },
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MatchChatScreen(
                  match: widget.match, currentUser: currentUser),
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
      currentIndex: 0,
      onTap: (index) {
        if (index != 0) {
          _navigateToSection(index);
        }
      },
      items: [
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Informacion'),
          icon: Icon(Icons.info),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Participantes'),
          icon: Icon(
            Icons.group_outlined,
          ),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Chat'),
          icon: widget.match.haveNotifications
              ? Stack(
                  children: [
                    Icon(Icons.chat_bubble_outline),
                    _buildNotification(),
                  ],
                )
              : Icon(Icons.chat_bubble_outline),
        ),
      ],
    );
  }

  Positioned _buildNotification() {
    return Positioned(
      top: 0.0,
      right: 0.0,
      child: Container(
        width: 12.0,
        height: 12.0,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(
            Radius.circular(50.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/screens/matches/create_match_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/matches_filter.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/screens/players/players_screen.dart';
import 'package:fulbito_app/screens/profile/private_profile_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<MatchesScreen> {
  List<Genre> _searchedGender = Genre().genres;
  List<Type> _searchedMatchType = Type().matchTypes;
  Map<String, double> _searchedRange = {'distance': 20.0};
  List<Match?> matches = [];
  Future? _future;
  bool areNotifications = false;
  StreamController notificationStreamController = StreamController.broadcast();
  StreamController matchesStreamController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    getMatchesOffers(
      _searchedRange['distance']!.toInt(),
      _searchedGender.first,
      _searchedMatchType.map((Type type) => type.id).toList(),
    );

    silentNotificationListener();

  }

  void silentNotificationListener() {
    PushNotificationService.messageStream.listen((notificationData) {
      if (notificationData.containsKey('silentUpdateChat')) {
        if (!notificationStreamController.isClosed) notificationStreamController.sink.add(true);
      }
      if (notificationData.containsKey('silentUpdateMatch')) {
        final Match? editedMatch = notificationData['match'];
        final Match? editedMatchToReplace = this.matches.firstWhere((match) => match!.id == editedMatch!.id);
        var index = this.matches.indexOf(editedMatchToReplace);
        this.matches.replaceRange(index, index + 1, [editedMatch]);
        if (!matchesStreamController.isClosed) matchesStreamController.sink.add(this.matches);
        if (!notificationStreamController.isClosed) notificationStreamController.sink.add(true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    notificationStreamController.close();
    matchesStreamController.close();
  }

  Future getMatchesOffers(int range, Genre genre, List<int?> types) async {
    final response = await MatchRepository().getMatchesOffers(
      range,
      genre,
      types,
    );
    final responseMyMatches = await MatchRepository().getMyMatches();

    if (response['success']) {
      setState(() {
        List<Match> myMatches = responseMyMatches['matches'];
        this.areNotifications = myMatches
            .firstWhereOrNull((match) => match.haveNotifications == true) !=
            null;
        this.matches = response['matches'];
      });

      if (!notificationStreamController.isClosed)
        notificationStreamController.sink.add(
          this.areNotifications,
        );
      if (!matchesStreamController.isClosed)
        matchesStreamController.sink.add(
          this.matches,
        );
      return this.matches;
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {

    Positioned _buildNotification() {
      return Positioned(
        top: 6.0,
        right: 5.0,
        child: Container(
          width: 15.0,
          height: 15.0,
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

    StreamBuilder<dynamic> buildNotificationStreamBuilder() {
      return StreamBuilder(
        initialData: this.areNotifications,
        stream: notificationStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          bool areNotis = snapshot.data;

          if (!areNotis) {
            return Container();
          }

          return _buildNotification();
        },
      );
    }

    Widget _buildMatchesMenu() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: IconButton(
              icon: Icon(Icons.add_circle_outline),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () {
                Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      CreateMatchScreen(),
                  transitionDuration: Duration(seconds: 0),
                ),);
              },
            ),
          ),
          Stack(
            children: [
              Container(
                child: IconButton(
                  icon: Icon(Icons.calendar_today),
                  iconSize: 30.0,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          MyMatchesScreen(),
                      transitionDuration: Duration(seconds: 0),
                    ),);
                  },
                ),
              ),
              buildNotificationStreamBuilder(),
            ],
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.filter_list),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () async {
                List<Match?> matches = await showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  enableDrag: true,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return MatchesFilter(
                      searchedGender: this._searchedGender,
                      searchedRange: this._searchedRange,
                      searchedMatchType: this._searchedMatchType,
                    );
                  },
                );

                if (matches != null) {
                  setState(() {
                    this.matches = matches;
                  });
                }
              },
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: Platform.isIOS
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                child: Center(
                  child: Container(
                    decoration: horizontalGradient,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Stack(
                          children: [
                            buildMatchesStreamBuilder(),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: horizontalGradient,
                                padding: EdgeInsets.only(left: 10.0, top: 40.0),
                                alignment: Alignment.center,
                                child: _buildMatchesMenu(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: _buildBottomNavigationBarRounded(),
            ),
          )
        ],
      ),
    );
  }

  buildMatchesStreamBuilder() {
    return StreamBuilder(
      stream: matchesStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (snapshot.connectionState !=
            ConnectionState.done &&
            !snapshot.hasData) {
          return Positioned(
            top: 80.0,
            left: 0.0,
            right: 0.0,
            bottom: -20.0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: Offset(0, -2),
                  ),
                ],
                color: Colors.white,
                borderRadius: screenBorders,
              ),
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              child: Container(
                width: _width,
                height: _height,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [circularLoading],
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.done &&
            !snapshot.hasData) {
          return Positioned(
            top: 80.0,
            left: 0.0,
            right: 0.0,
            bottom: -20.0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: Offset(0, -2),
                  ),
                ],
                color: Colors.white,
                borderRadius: screenBorders,
              ),
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              child: Container(
                width: _width,
                height: _height,
                child: Center(
                    child:
                    Text(translations[localeName]!['general.noMatches']!)),
              ),
            ),
          );
        }

        List matches = snapshot.data;

        if (matches.isEmpty) {
          return Positioned(
            top: 80.0,
            left: 0.0,
            right: 0.0,
            bottom: -20.0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: Offset(0, -2),
                  ),
                ],
                color: Colors.white,
                borderRadius: screenBorders,
              ),
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              child: Container(
                width: _width,
                height: _height,
                child: Center(
                    child:
                        Text(translations[localeName]!['general.noMatches']!)),
              ),
            ),
          );
        }

        return Positioned(
          top: 80.0,
          left: 0.0,
          right: 0.0,
          bottom: -20.0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, -2),
                ),
              ],
              color: Colors.white,
              borderRadius: screenBorders,
            ),
            padding: EdgeInsets.only(
                bottom: 20.0, left: 20.0, right: 20.0),
            margin: EdgeInsets.only(top: 20.0),
            width: _width,
            child: RefreshIndicator(
              onRefresh: () => this.getRefreshData(
                this
                    ._searchedRange['distance']!
                    .toInt(),
                this._searchedGender.first,
                this
                    ._searchedMatchType
                    .map((Type type) => type.id)
                    .toList(),
              ),
              child: ListView.builder(
                itemBuilder: (
                    BuildContext context,
                    int index,
                    ) {
                  return _buildMatchRow(
                      matches[index]);
                },
                itemCount: matches.length,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> getRefreshData(
      range,
      genre,
      types,
      ) async {
    final response = await MatchRepository().getMatchesOffers(
      range,
      genre,
      types,
    );
    final responseMyMatches = await MatchRepository().getMyMatches();

    if (response['success']) {
      setState(() {
        List<Match> myMatches = responseMyMatches['matches'];
        this.areNotifications = myMatches
            .firstWhereOrNull((match) => match.haveNotifications == true) !=
            null;
        this.matches = response['matches'];
      });
      if (!notificationStreamController.isClosed)
        notificationStreamController.sink.add(
          this.areNotifications,
        );
      if (!matchesStreamController.isClosed)
        matchesStreamController.sink.add(
          this.matches,
        );
    }
  }

  Widget _buildMatchRow(match) {
    return GestureDetector(
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
    );
  }

  void _navigateToSection(index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => PlayersScreen(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                PrivateProfileScreen(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        break;
      default:
        return;
    }
  }

  Widget _buildBottomNavigationBarRounded() {
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
      },
      items: [
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Jugadores'),
          icon: Icon(Icons.groups_outlined),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Partidos'),
          icon: Icon(
            Icons.sports_soccer,
          ),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Perfil'),
          icon: Icon(Icons.person_outline),
        ),
      ],
    );
  }
}

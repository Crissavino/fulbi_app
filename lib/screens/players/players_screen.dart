import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/player.dart';
import 'package:fulbito_app/models/position.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/screens/players/players_filter.dart';
import 'package:fulbito_app/screens/profile/private_profile_screen.dart';
import 'package:fulbito_app/screens/profile/public_profile_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({Key? key}) : super(key: key);

  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  dynamic search = '';
  List<Genre> _searchedGender = Genre().genres;
  List<Position> _searchedPlayerPositions = Position().positions;
  Map<String, double> _searchedRange = {'distance': 20.0};
  List<User?> players = [];
  Future? _future;
  bool isLoading = false;
  var responseFromStorage;
  StreamController playersStreamController = StreamController.broadcast();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    loadFromLocalStorage();
    this._searchedGender[1].checked = true;
    List<int?> genres = [1, 2];
    getUsersOffers(
      _searchedRange['distance']!.toInt(),
      genres,
      _searchedPlayerPositions.map((Position pos) => pos.id).toList(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    playersStreamController.close();
  }

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('playersScreen.players')) {
      var thisPlayers = json.decode(json.decode(localStorage.getString('playersScreen.players')!));
      List players = thisPlayers;
      thisPlayers = players.map((user) => User.fromJson(user)).toList();

      this.players = thisPlayers;
      if (!playersStreamController.isClosed)
        playersStreamController.sink.add(
          this.players,
        );

    }

  }

  Future getUsersOffers(
    int range,
    List<int?> genres,
    List<int?> positionsIds,
  ) async {
    final response = await UserRepository().getUserOffers(
      range,
      genres,
      positionsIds,
    );

    if (response['message'] == 'Unauthenticated.') {
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }

    if (response['success']) {
      this.players = response['players'];
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var jsonPlayers = this.players.map((e) => json.encode(e)).toList();
      await localStorage.setString('playersScreen.players', json.encode(jsonPlayers.toString()));

      if (!playersStreamController.isClosed)
        playersStreamController.sink.add(
          this.players,
        );
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Widget _buildSearchTF() {
      final width = MediaQuery.of(context).size.width;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 10.0),
            height: 30.0,
            width: width * 0.82,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: -3),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                hintText: translations[localeName]!['search']!,
                hintStyle: kHintTextStyle,
              ),
              onChanged: (val) async {
                val = val.toLowerCase();
                SharedPreferences localStorage =
                    await SharedPreferences.getInstance();
                List players = jsonDecode(localStorage.getString('players')!);
                this.players = players.map((user) => User.fromJson(user)).toList();
                this.players = this.players.where((player) {
                  return player!.name.toLowerCase().contains(val) ||
                      player.nickname.toLowerCase().contains(val);
                }).toList();
                if (val.isEmpty) {
                  this.players =
                      players.map((user) => User.fromJson(user)).toList();
                }
                if (!playersStreamController.isClosed)
                  playersStreamController.sink.add(
                    this.players,
                  );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: IconButton(
              icon: Icon(Icons.filter_list),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () async {
                List<User?>? filteredPlayers = await showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  enableDrag: true,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return PlayersFilter(
                      searchedPositions: this._searchedPlayerPositions,
                      searchedGender: this._searchedGender,
                      searchedRange: this._searchedRange,
                    );
                  },
                );

                if (filteredPlayers != null) {
                  this.players = filteredPlayers;
                  if (!playersStreamController.isClosed)
                    playersStreamController.sink.add(
                      this.players,
                    );
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
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: horizontalGradient,
                                padding: EdgeInsets.only(left: 10.0, top: 33.0),
                                alignment: Alignment.center,
                                child: _buildSearchTF(),
                              ),
                            ),
                            Positioned(
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
                                height: _height,
                                child: buildPlayersStreamBuilder(),
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

  buildPlayersStreamBuilder() {
    return StreamBuilder(
      stream: playersStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (!snapshot.hasData) {

          this.isLoading = true;

          return Container(
            width: _width,
            height: _height,
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [circularLoading],
            ),
          );
        }

        this.isLoading = false;

        if (snapshot.connectionState ==
            ConnectionState.done &&
            !snapshot.hasData) {
          return Container(
            width: _width,
            height: _height,
            child: Center(
                child: Text(
                    translations[localeName]![
                    'general.noPlayers']!)),
          );
        }

        List players = snapshot.data;

        if (players != null && players.isEmpty) {
          return Container(
            width: _width,
            height: _height,
            child: Center(
                child: Text(
                    translations[localeName]![
                    'general.noPlayers']!)),
          );
        }

        return RefreshIndicator(
          onRefresh: () => getRefreshData(
            _searchedRange['distance']!.toInt(),
            _searchedGender.first.id,
            _searchedPlayerPositions
                .map((Position pos) => pos.id)
                .toList(),
          ),
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (
                BuildContext context,
                int index,
                ) {
              return _buildPlayerRow(
                  players[index]!);
            },
            itemCount: players.length,
          ),
        );
      },
    );
  }

  Future<void> getRefreshData(
    range,
    genreId,
    positionsIds,
  ) async {
    Iterable<Genre> genders = this._searchedGender.where((Genre genre) {
      bool? isChecked = genre.checked;
      if (isChecked == null) {
        return false;
      }
      return isChecked;
    });

    final response = await UserRepository().getUserOffers(
      range,
      genders.map((Genre genre) => genre.id).toList(),
      positionsIds,
    );
    if (response['success']) {
      this.players = response['players'];
      if (!playersStreamController.isClosed)
        playersStreamController.sink.add(
          this.players,
        );
    }
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
              child: user.profileImage == null
                  ? Icon(
                      Icons.person,
                      color: Colors.green[700],
                      size: 40.0,
                    )
                  : null,
              backgroundImage: user.profileImage == null
                  ? null
                  : NetworkImage(user.profileImage!),
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

  void _navigateToSection(index) {
    if (this.isLoading) {
      return;
    }
    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => MatchesScreen(),
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
      currentIndex: 0,
      onTap: (index) {
        if (index != 0) {
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

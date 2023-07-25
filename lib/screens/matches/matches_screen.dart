import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/booking.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/screens/matches/create_match_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/matches_filter.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/screens/players/players_screen.dart';
import 'package:fulbito_app/screens/profile/private_profile_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/custom_floating_action_button.dart';
import 'package:fulbito_app/widgets/user_menu.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<MatchesScreen> {
  List<Genre> _searchedGender = Genre().genres;
  List<Type> _searchedMatchType = Type().matchTypes;
  Map<String, double> _searchedRange = {'distance': 20.0};
  List<Match?> matches = [];
  List<Match?> myMatches = [];
  bool areNotifications = false;
  StreamController notificationStreamController = StreamController.broadcast();
  StreamController matchesStreamController = StreamController.broadcast();
  StreamController myMatchesStreamController = StreamController.broadcast();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadFromLocalStorage();
    getMyMatches();
    getMatchesOffers(
      _searchedRange['distance']!.toInt(),
      _searchedGender.first,
      _searchedMatchType.map((Type type) => type.id).toList(),
      true,
    );

    silentNotificationListener();
  }

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('matchesScreen.matches') &&
        localStorage.containsKey('matchesScreen.areNotifications')) {
      var thisAreNotifications = json.decode(json
          .decode(localStorage.getString('matchesScreen.areNotifications')!));
      var thisMatches = json.decode(
          json.decode(localStorage.getString('matchesScreen.matches')!));

      List matches = thisMatches;
      thisMatches = matches.map((match) => Match.fromJson(match)).toList();

      this.areNotifications = thisAreNotifications;
      this.matches = thisMatches;

      if (!notificationStreamController.isClosed)
        notificationStreamController.sink.add(
          this.areNotifications,
        );
      if (!matchesStreamController.isClosed)
        matchesStreamController.sink.add(
          this.matches,
        );
    }

    if (localStorage.containsKey('matchesScreen.myMatches')) {
      var thisMatches = json.decode(
          json.decode(localStorage.getString('matchesScreen.myMatches')!));

      List matches = thisMatches;
      thisMatches = matches.map((match) => Match.fromJson(match)).toList();

      this.myMatches = thisMatches;

      if (!myMatchesStreamController.isClosed)
        myMatchesStreamController.sink.add(
          this.myMatches,
        );
    }
  }

  void silentNotificationListener() {
    PushNotificationService.messageStream.listen((notificationData) async {
      if (notificationData.containsKey('silentUpdateChat')) {
        if (!notificationStreamController.isClosed)
          notificationStreamController.sink.add(true);
        await saveVariablesInLocalStorage();
      }
      if (notificationData.containsKey('silentUpdateMatch')) {
        if (!notificationStreamController.isClosed)
          notificationStreamController.sink.add(true);
        final Match? editedMatch = notificationData['match'];

        // match offer
        final Match? editedMatchToReplace = this
            .matches
            .firstWhereOrNull((match) => match!.id == editedMatch!.id);
        if (editedMatchToReplace != null) {
          var index = this.matches.indexOf(editedMatchToReplace);
          this.matches.replaceRange(index, index + 1, [editedMatch]);
          if (!matchesStreamController.isClosed)
            matchesStreamController.sink.add(this.matches);
          await saveVariablesInLocalStorage();
        }

        //my match
        final Match? editedMyMatchToReplace = this
            .myMatches
            .firstWhereOrNull((match) => match!.id == editedMatch!.id);
        if (editedMyMatchToReplace != null) {
          var index = this.myMatches.indexOf(editedMatchToReplace);
          this.myMatches.replaceRange(index, index + 1, [editedMatch]);
          if (!myMatchesStreamController.isClosed)
            myMatchesStreamController.sink.add(this.myMatches);

          await saveVariablesInLocalStorage(isMyMatch: true);
        }
      }
      if (notificationData.containsKey('silentCreatedMatch')) {
        final Match? editedMatch = notificationData['match'];
        this.matches.add(editedMatch);
        this.matches.sort((a, b) => a!.whenPlay.compareTo(b!.whenPlay));
        if (!matchesStreamController.isClosed)
          matchesStreamController.sink.add(this.matches);
        await saveVariablesInLocalStorage();
      }

      if (notificationData.containsKey('silentUpdateMatches')) {
        final int? matchIdToDelete =
            int.tryParse(notificationData['matchIdToDelete']);
        this.matches.removeWhere((match) => match!.id == matchIdToDelete!);
        if (!matchesStreamController.isClosed)
          matchesStreamController.sink.add(this.matches);
        await saveVariablesInLocalStorage();
      }

      if (notificationData.containsKey('silentUpdateMyMatches')) {
        final int? matchIdToDelete =
            int.tryParse(notificationData['matchIdToDelete']);
        this.myMatches.removeWhere((match) => match!.id == matchIdToDelete!);
        if (!myMatchesStreamController.isClosed)
          myMatchesStreamController.sink.add(this.myMatches);

        await saveVariablesInLocalStorage(isMyMatch: true);
      }
    });
  }

  Future<void> saveVariablesInLocalStorage({bool isMyMatch = false}) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (isMyMatch) {
      var jsonMyMatches = this.myMatches.map((e) => json.encode(e)).toList();
      await localStorage.setString(
          'matchesScreen.myMatches', json.encode(jsonMyMatches.toString()));
    } else {
      var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
      await localStorage.setString(
          'matchesScreen.matches', json.encode(jsonMatches.toString()));
    }
    await localStorage.setString('matchesScreen.areNotifications',
        json.encode(this.areNotifications.toString()));
  }

  @override
  void dispose() {
    super.dispose();
    notificationStreamController.close();
    matchesStreamController.close();
  }

  Future getMatchesOffers(
      int range, Genre genre, List<int?> types, calledFromInitState) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (calledFromInitState && localStorage.containsKey('user')) {
      User user = await UserRepository.getCurrentUser();
      Genre? userGenre = this
          ._searchedGender
          .firstWhereOrNull((genre) => user.genreId == genre.id);
      this._searchedGender = this._searchedGender.map((Genre genre) {
        genre.checked = false;
        return genre;
      }).toList();
      this
          ._searchedGender
          .firstWhere((Genre genre) => genre.id == userGenre!.id)
          .checked = true;
      if (userGenre != null) {
        genre = userGenre;
      }
    }
    final response = await MatchRepository().getMatchesOffers(
      range,
      genre,
      types,
    );
    final responseMyMatches = await MatchRepository().getMyMatches();

    if (response['message'] == 'Unauthenticated.') {
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }

    if (response['success']) {
      List<Match> myMatches = responseMyMatches['matches'];
      this.areNotifications = myMatches
              .firstWhereOrNull((match) => match.haveNotifications == true) !=
          null;
      this.matches = response['matches'];

      await saveVariablesInLocalStorage();

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

  Future getMyMatches() async {
    final response = await MatchRepository().getMyMatches();
    if (response['success']) {
      // check if the widget is disposed
      if (this.mounted) {
        setState(() {
          this.myMatches = response['matches'];
        });
      }

      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var jsonMatches = this.myMatches.map((e) => json.encode(e)).toList();
      await localStorage.setString(
          'matchesScreen.myMatches', json.encode(jsonMatches.toString()));

      if (!myMatchesStreamController.isClosed)
        myMatchesStreamController.sink.add(this.myMatches);

      return this.myMatches;
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    StreamBuilder<dynamic> buildNotificationStreamBuilder() {
      return StreamBuilder(
        initialData: this.areNotifications,
        stream: notificationStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          bool areNotifications = snapshot.data;

          if (!areNotifications) {
            return Container();
          }

          return _buildNotification();
        },
      );
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Center(
              child: Container(
                width: _width,
                height: _height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: 50.0,
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mis partidos',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    buildMyMatchesStreamBuilder(),
                    Container(
                      margin: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Proximos partidos',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildFilterButton(context)
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    buildMatchesStreamBuilder(),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: CustomFloatingActionButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: UserMenu(
            isLoading: this.isLoading,
            currentIndex: 2,
          ),
        ),
      ),
    );
  }

  Container _buildFilterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(2, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 20.0,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(Icons.filter_list),
          iconSize: 24.0,
          color: Colors.black,
          onPressed: () async {
            List<Match?>? matches = await showModalBottomSheet(
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
              this.matches = matches;
              if (!matchesStreamController.isClosed)
                matchesStreamController.sink.add(
                  this.matches,
                );
            }
          },
        ),
      ),
    );
  }

  buildMyMatchesStreamBuilder() {
    return StreamBuilder(
      stream: myMatchesStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          this.isLoading = true;

          return Container(
            width: _width,
            height: 100.0,
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              child: Container(
                width: _width,
                height: _height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [circularLoading],
                ),
              ),
            ),
          );
        }

        this.isLoading = false;

        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return Container(
            width: _width,
            height: 100.0,
            child: Container(
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
          return Container(
            width: 260.0,
            height: 100.0,
            margin: EdgeInsets.only(left: 10.0),
            child: _buildMyMatchCardPlaceHolder(),
          );
        }

        return Container(
          width: _width,
          margin: EdgeInsets.only(left: 10.0),
          height: 100.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: matches.length,
            itemBuilder: (BuildContext _, int index) {
              return _buildMyMatchCard(matches[index]);
            },
          ),
        );
      },
    );
  }

  buildMatchesStreamBuilder() {
    return StreamBuilder(
      stream: matchesStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          this.isLoading = true;

          return Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              child: Container(
                width: _width,
                height: _height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [circularLoading],
                ),
              ),
            ),
          );
        }

        this.isLoading = false;

        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              height: _height,
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
          return Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 10.0),
              width: _width,
              height: _height,
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

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            width: _width,
            child: RefreshIndicator(
              onRefresh: () => this.getRefreshData(
                  this._searchedRange['distance']!.toInt(),
                  this._searchedGender.first,
                  this._searchedMatchType.map((Type type) => type.id).toList(),
                  true),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: matches.length,
                itemBuilder: (BuildContext _, int index) {
                  return _buildMatchRow(matches[index]);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> getRefreshData(range, genre, types, calledFromInitState) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('user')) {
      User user = await UserRepository.getCurrentUser();
      // Genre? userGenre = this._searchedGender.firstWhereOrNull((genre) => user.genreId == genre.id);
      Genre? userGenre = this
          ._searchedGender
          .firstWhereOrNull((genre) => genre.checked == true);
      if (userGenre != null) {
        genre = userGenre;
      }
    }
    final response = await MatchRepository().getMatchesOffers(
      range,
      genre,
      types,
    );
    final responseMyMatches = await MatchRepository().getMyMatches();

    if (response['success']) {
      List<Match> myMatches = responseMyMatches['matches'];
      this.areNotifications = myMatches
              .firstWhereOrNull((match) => match.haveNotifications == true) !=
          null;
      this.matches = response['matches'];
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

  Widget _buildMatchRow(Match match) {
    // check if match have a booking or is only a match
    Booking? booking = match.booking;
    BoxDecoration boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      image: DecorationImage(
        image: AssetImage('assets/match_info_header.png'),
        fit: BoxFit.cover,
      ),
    );
    String? imageUrl = booking?.field!.image;
    if (imageUrl != null) {
      boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchInfoScreen(
              match: match,
              calledFromMatchInfo: false,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            height: 200.0,
            width: MediaQuery.of(context).size.width,
            decoration: boxDecoration,
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (booking != null)
                      ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.field!.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          booking.field!.address,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  )
                      : Container(
                    child: (match.location != null)
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.location!.city,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                        : Container(),
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateFormat('HH:mm').format(match.whenPlay)} hs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${DateFormat('MMMMd').format(match.whenPlay)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            translations[localeName]!['match.missing']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                (match.numPlayers - match.participants!.length).toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Icon(
                                Icons.group_outlined,
                                color: Colors.white,
                                size: 18.0,
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: Text(
                match.type.vs!,
                style: TextStyle(
                  // add a RGB color #8B9586
                  color: Color(0xFF8B9586),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: (booking != null)
                ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 20.0,
                color: Colors.yellow[700],
              ),
            )
                : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMatchCard(Match match) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchInfoScreen(
              match: match,
              calledFromMatchInfo: false,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              right: 20.0,
              top: 5.0,
            ),
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
                  blurRadius: 8.0,
                  offset: Offset(6, 4),
                ),
              ],
              color: Colors.green[400],
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            height: 80.0,
            width: 260.0,
            child: Container(
              child: Row(
                children: [
                  SizedBox(width: 20.0),
                  // CircleAvatar(
                  //   radius: 25.0,
                  //   backgroundColor: Colors.green[600],
                  //   child: Icon(
                  //     Icons.sports_soccer,
                  //     color: Colors.green[700],
                  //     size: 50.0,
                  //   ),
                  // ),
                  Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/my-matches-football.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(50.0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${DateFormat('MMMd').format(match.whenPlay)} '
                      '| ${DateFormat('HH:mm').format(match.whenPlay)} hs',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          match.haveNotifications ? _buildNotification() : Container(),
        ],
      ),
    );
  }

  Positioned _buildNotification() {
    return Positioned(
      top: 0.0,
      right: 14.0,
      child: Container(
        width: 30.0,
        height: 30.0,
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

  Widget _buildMyMatchCardPlaceHolder() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                CreateMatchScreen(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          right: 20.0,
          bottom: 20.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[500]!,
              Colors.green[400]!,
              Colors.green[400]!,
              Colors.green[500]!,
            ],
            stops: [0.1, 0.4, 0.7, 0.9],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(10, 6),
            ),
          ],
          color: Colors.green[400],
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        width: 260.0,
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Crear partido',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                Icons.add,
                color: Colors.white,
                size: 30.0,
              ),
              SizedBox(width: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

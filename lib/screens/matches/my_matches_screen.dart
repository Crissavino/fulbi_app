import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/matches/edit_match_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMatchesScreen extends StatefulWidget {
  MyMatchesScreen({Key? key}) : super(key: key);

  @override
  _MyMatchesScreenState createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  List<Match?> matches = [];
  User? myUser;
  StreamController matchesStreamController = StreamController.broadcast();
  bool isLoadingAlert = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFromLocalStorage();
    getMyMatches();
    this.getMyUser();
    silentNotificationListener();
  }

  void silentNotificationListener() {
    PushNotificationService.messageStream.listen((notificationData) async {
      if (notificationData.containsKey('silentUpdateChat') ||
          notificationData.containsKey('silentUpdateMatch')) {
        final Match? editedMatch = notificationData['match'];
        final Match? editedMatchToReplace =
        this.matches.firstWhereOrNull((match) => match!.id == editedMatch!.id);
        if (editedMatchToReplace != null) {
          var index = this.matches.indexOf(editedMatchToReplace);
          this.matches.replaceRange(index, index + 1, [editedMatch]);
          if (!matchesStreamController.isClosed)
            matchesStreamController.sink.add(this.matches);

          SharedPreferences localStorage = await SharedPreferences.getInstance();
          var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
          await localStorage.setString('myMatchesScreen.matches', json.encode(jsonMatches.toString()));
        }
      } else if (notificationData.containsKey('silentUpdateMyMatches')) {
        final int? matchIdToDelete = int.tryParse(notificationData['matchIdToDelete']);
        this.matches.removeWhere((match) => match!.id == matchIdToDelete!);
        if (!matchesStreamController.isClosed)
          matchesStreamController.sink.add(this.matches);

        SharedPreferences localStorage = await SharedPreferences.getInstance();
        var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
        await localStorage.setString('myMatchesScreen.matches', json.encode(jsonMatches.toString()));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    matchesStreamController.close();
  }

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('myMatchesScreen.matches')) {
      var thisMatches = json.decode(json.decode(localStorage.getString('myMatchesScreen.matches')!));

      List matches = thisMatches;
      thisMatches = matches.map((match) => Match.fromJson(match)).toList();

      this.matches = thisMatches;

      if (!matchesStreamController.isClosed)
        matchesStreamController.sink.add(
          this.matches,
        );
    }

  }

  Future getMyMatches() async {
    final response = await MatchRepository().getMyMatches();
    if (response['success']) {
      setState(() {
        this.matches = response['matches'];
      });
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
      await localStorage.setString('myMatchesScreen.matches', json.encode(jsonMatches.toString()));

      if (!matchesStreamController.isClosed)
        matchesStreamController.sink.add(this.matches);

      return this.matches;
    }

    return response;
  }

  Future<void> getRefreshData() async {
    final response = await MatchRepository().getMyMatches();
    if (response['success']) {
      setState(() {
        this.matches = response['matches'];
      });
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
      await localStorage.setString('myMatchesScreen.matches', json.encode(jsonMatches.toString()));
      if (!matchesStreamController.isClosed)
        matchesStreamController.sink.add(this.matches);
    }
  }

  Future getMyUser() async {
    final user = await UserRepository.getCurrentUser();
    setState(() {
      this.myUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {

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
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        double innerHeight = constraints.maxHeight;

                        return Stack(
                          children: [
                            buildMatchesStreamBuilder(innerHeight),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: horizontalGradient,
                                padding: EdgeInsets.only(left: 10.0, top: 0.0),
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: horizontalGradient,
                                  child: AppBar(
                                    backwardsCompatibility: false,
                                    systemOverlayStyle: SystemUiOverlayStyle(
                                        statusBarColor: Colors.white),
                                    backgroundColor: Colors.transparent,
                                    elevation: 0.0,
                                    leading: IconButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MatchesScreen(),
                                              ),
                                            )
                                            .then((_) => setState(() {}));
                                      },
                                      icon: Platform.isIOS
                                          ? Icon(Icons.arrow_back_ios)
                                          : Icon(Icons.arrow_back),
                                      splashColor: Colors.transparent,
                                    ),
                                    title: Text(
                                      translations[localeName]![
                                          'general.myMatches']!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  buildMatchesStreamBuilder(innerHeight) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return StreamBuilder(
      stream: matchesStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: (MediaQuery.of(context).viewInsets.bottom)),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding:
                      EdgeInsets.only(bottom: 70.0, left: 20.0, right: 20.0),
                  margin: EdgeInsets.only(top: 70.0),
                  width: _width,
                  height: innerHeight - 0,
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
              ),
            ),
          );
        }

        if (this.isLoadingAlert) {
          return Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: (MediaQuery.of(context).viewInsets.bottom)),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding:
                  EdgeInsets.only(bottom: 70.0, left: 20.0, right: 20.0),
                  margin: EdgeInsets.only(top: 70.0),
                  width: _width,
                  height: innerHeight - 0,
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
              ),
            ),
          );
        }

        List matches = snapshot.data;

        if (matches.isEmpty) {
          return Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: (MediaQuery.of(context).viewInsets.bottom)),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  padding:
                      EdgeInsets.only(bottom: 70.0, left: 20.0, right: 20.0),
                  margin: EdgeInsets.only(top: 70.0),
                  width: _width,
                  height: innerHeight - 0,
                  child: Container(
                    width: _width,
                    height: _height,
                    child: Center(
                        child: Text(
                            translations[localeName]!['general.noMatches']!)),
                  ),
                ),
              ),
            ),
          );
        }

        return Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: (MediaQuery.of(context).viewInsets.bottom)),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: EdgeInsets.only(bottom: 70.0, left: 20.0, right: 20.0),
                margin: EdgeInsets.only(top: 70.0),
                width: _width,
                height: innerHeight,
                child: RefreshIndicator(
                  onRefresh: () => this.getRefreshData(),
                  child: ListView.separated(
                    itemCount: matches.length + 1,
                    separatorBuilder: (BuildContext _, int index,) => buildSeparator(index, matches),
                    itemBuilder: (
                        BuildContext context,
                        int index,
                        ) {
                      if (index == 0) {
                        return Container();
                      } else {
                        return _buildMatchRow(matches[index - 1]);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSeparator(index, matches) {
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

  Widget _buildMatchRow(Match match) {
    bool imTheCreator = this.myUser!.id == match.ownerId;
    bool imParticipating;
    if (match.participants!.isNotEmpty) {
      imParticipating = (match.participants
              ?.firstWhereOrNull((user) => user.id == this.myUser!.id)) !=
          null;
    } else {
      imParticipating = false;
    }

    if (!match.isConfirmed && !imTheCreator) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.green[100]!,
              blurRadius: 6.0,
              offset: Offset(0, 6),
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        margin: EdgeInsets.only(bottom: 20.0),
        width: double.infinity,
        height: 80.0,
        child: Card(
          margin: EdgeInsets.all(0),
          elevation: 0,
          shadowColor: null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: () => showAlertToJoinOrCancelMatch(match),
            child: Container(
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
                color: Colors.green[400]!.withOpacity(0.5),
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
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: Icon(
                      Icons.sports_soccer,
                      color: Colors.green[700]!.withOpacity(0.5),
                      size: 50.0,
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
        ),
      );
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.green[100]!,
              blurRadius: 6.0,
              offset: Offset(0, 6),
            ),
          ], borderRadius: BorderRadius.all(Radius.circular(30.0))),
          margin: EdgeInsets.only(bottom: 20.0),
          width: double.infinity,
          height: 80.0,
          child: Card(
            margin: EdgeInsets.all(0),
            elevation: 0,
            shadowColor: null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Dismissible(
              child: GestureDetector(
                child: Container(
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
                    color: Colors.green[400],
                  ),
                  child: Center(
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.sports_soccer,
                          color: Colors.green[700],
                          size: 50.0,
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
              ),
              background: imTheCreator
                  ? Container(
                      padding: EdgeInsets.only(
                        left: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[600]!,
                            Colors.blue[500]!,
                            Colors.blue[500]!,
                            Colors.blue[600]!,
                          ],
                          stops: [0.1, 0.4, 0.7, 0.9],
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              secondaryBackground: Container(
                padding: EdgeInsets.only(
                  right: 20.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red[600]!,
                      Colors.red[500]!,
                      Colors.red[500]!,
                      Colors.red[600]!,
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ((!imTheCreator && imParticipating) ||
                            (imTheCreator && imParticipating))
                        ? Icon(
                            Icons.remove_circle,
                            color: Colors.white,
                            size: 30.0,
                          )
                        : imTheCreator && !imParticipating
                            ? Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30.0,
                              )
                            : Container(),
                  ],
                ),
              ),
              key: UniqueKey(),
              direction: imTheCreator
                  ? DismissDirection.horizontal
                  : DismissDirection.endToStart,
              confirmDismiss: (DismissDirection dismissDirection) async {
                if (dismissDirection == DismissDirection.endToStart) {
                  if ((imTheCreator && imParticipating) ||
                      (!imTheCreator && imParticipating)) {
                    await showAlertToLeaveMatch(match);
                  } else if (imTheCreator && !imParticipating) {
                    await showAlertToDeleteMatch(match);
                  }
                } else {
                  setState(() {});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMatchScreen(
                        match: match,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        match.haveNotifications ? _buildNotification() : Container(),
      ],
    );
  }

  Positioned _buildNotification() {
    return Positioned(
      top: 0.0,
      right: 0.0,
      child: Container(
        width: 25.0,
        height: 25.0,
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

  showAlertToLeaveMatch(Match match) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(translations[localeName]!['match.leave']!),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                translations[localeName]!['general.cancel']!,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              color: Colors.blue,
              elevation: 5,
            ),
            MaterialButton(
              onPressed: this.isLoadingAlert ? null : () async {
                setState(() {
                  this.isLoadingAlert = true;
                });
                Navigator.pop(context);
                final response =
                await MatchRepository().leaveMatch(match.id);
                if (response['success']) {
                  this.matches = response['matches'];

                  if (!matchesStreamController.isClosed)
                    matchesStreamController.sink.add(this.matches);

                  setState(() {
                    this.isLoadingAlert = false;
                  });
                } else {
                  setState(() {
                    this.isLoadingAlert = false;
                  });
                  showAlert(
                      context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
                }
              },
              child: Text(
                translations[localeName]!['general.accept']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              color: Colors.blue,
              elevation: 5,
            ),
          ],
        ),
      );
    }

    return showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(translations[localeName]!['match.leave']!),
        actions: [
          CupertinoDialogAction(
            child: Text(
              translations[localeName]!['general.cancel']!,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            textStyle: TextStyle(fontWeight: FontWeight.w100),
          ),
          CupertinoDialogAction(
            child: Text(
              translations[localeName]!['general.accept']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            isDefaultAction: false,
            onPressed: this.isLoadingAlert ? null : () async {
              setState(() {
                this.isLoadingAlert = true;
              });
              Navigator.pop(context);
              final response =
              await MatchRepository().leaveMatch(match.id);
              if (response['success']) {
                this.matches = response['matches'];

                if (!matchesStreamController.isClosed)
                  matchesStreamController.sink.add(this.matches);

                setState(() {
                  this.isLoadingAlert = false;
                });
              } else {
                setState(() {
                  this.isLoadingAlert = false;
                });
                showAlert(
                    context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
              }
            },
          ),
        ],
      ),
    );
  }

  showAlertToDeleteMatch(Match match) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(translations[localeName]!['match.delete']!),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                translations[localeName]!['general.cancel']!,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              color: Colors.blue,
              elevation: 5,
            ),
            MaterialButton(
              onPressed: this.isLoadingAlert ? null : () async {
                setState(() {
                  this.isLoadingAlert = true;
                });
                Navigator.pop(context);
                final response =
                await MatchRepository().deleteMatch(match.id);
                if (response['success']) {
                  this.matches = response['matches'];

                  if (!matchesStreamController.isClosed)
                    matchesStreamController.sink.add(this.matches);

                  setState(() {
                    this.isLoadingAlert = false;
                  });
                } else {
                  setState(() {
                    this.isLoadingAlert = false;
                  });
                  showAlert(
                      context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
                }
              },
              child: Text(
                translations[localeName]!['general.accept']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              color: Colors.blue,
              elevation: 5,
            ),
          ],
        ),
      );
    }

    return showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(translations[localeName]!['match.delete']!),
        actions: [
          CupertinoDialogAction(
            child: Text(
              translations[localeName]!['general.cancel']!,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            textStyle: TextStyle(fontWeight: FontWeight.w100),
          ),
          CupertinoDialogAction(
            child: Text(
              translations[localeName]!['general.accept']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            isDefaultAction: false,
            onPressed: this.isLoadingAlert ? null : () async {
              setState(() {
                this.isLoadingAlert = true;
              });
              Navigator.pop(context);
              final response =
              await MatchRepository().deleteMatch(match.id);
              if (response['success']) {
                this.matches = response['matches'];

                if (!matchesStreamController.isClosed)
                  matchesStreamController.sink.add(this.matches);

                setState(() {
                  this.isLoadingAlert = false;
                });
              } else {
                setState(() {
                  this.isLoadingAlert = false;
                });
                showAlert(
                    context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
              }
            },
          ),
        ],
      ),
    );
  }

  showAlertToJoinOrCancelMatch(Match match) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(translations[localeName]!['match.join']!),
          actions: [
            MaterialButton(
              onPressed: this.isLoadingAlert ? null : () async {
                setState(() {
                  this.isLoadingAlert = true;
                });
                Navigator.pop(context);
                final response =
                await MatchRepository().rejectInvitationToMatch(match.id);
                if (response['success']) {
                  this.matches = response['matches'];
                  if (!matchesStreamController.isClosed)
                    matchesStreamController.sink.add(this.matches);

                  this.isLoadingAlert = false;

                  SharedPreferences localStorage = await SharedPreferences.getInstance();
                  var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
                  await localStorage.setString('myMatchesScreen.matches', json.encode(jsonMatches.toString()));
                  setState(() {});
                } else {
                  setState(() {
                    this.isLoadingAlert = false;
                  });
                  Navigator.pop(context);
                  showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
                }
              },
              child: Text(
                translations[localeName]!['general.cancel']!,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              color: Colors.blue,
              elevation: 5,
            ),
            MaterialButton(
              onPressed: this.isLoadingAlert ? null : () async {
                setState(() {
                  this.isLoadingAlert = true;
                });
                Navigator.pop(context);
                final response = await MatchRepository().joinMatch(match.id);
                if (response['success']) {
                  this.matches = response['matches'];
                  if (!matchesStreamController.isClosed)
                    matchesStreamController.sink.add(this.matches);

                  this.isLoadingAlert = false;

                  SharedPreferences localStorage = await SharedPreferences.getInstance();
                  var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
                  await localStorage.setString('myMatchesScreen.matches', json.encode(jsonMatches.toString()));
                  setState(() {});
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchInfoScreen(
                        match: match,
                        calledFromMatchInfo: false,
                      ),
                    ),
                  );
                } else {
                  setState(() {
                    this.isLoadingAlert = false;
                  });
                  showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
                }
              },
              child: Text(
                translations[localeName]!['general.accept']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              color: Colors.blue,
              elevation: 5,
            ),
          ],
        ),
      );
    }

    return showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(translations[localeName]!['match.join']!),
        actions: [
          CupertinoDialogAction(
            child: Text(
              translations[localeName]!['general.cancel']!,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            isDefaultAction: true,
            onPressed: this.isLoadingAlert ? null : () async {
              setState(() {
                this.isLoadingAlert = true;
              });
              Navigator.pop(context);
              final response =
              await MatchRepository().rejectInvitationToMatch(match.id);
              if (response['success']) {
                this.matches = response['matches'];
                if (!matchesStreamController.isClosed)
                  matchesStreamController.sink.add(this.matches);

                this.isLoadingAlert = false;

                SharedPreferences localStorage = await SharedPreferences.getInstance();
                var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
                await localStorage.setString('myMatchesScreen.matches', json.encode(jsonMatches.toString()));
                setState(() {});
              } else {
                setState(() {
                  this.isLoadingAlert = false;
                });
                showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
              }
            },
            textStyle: TextStyle(fontWeight: FontWeight.w100),
          ),
          CupertinoDialogAction(
            child: Text(
              translations[localeName]!['general.accept']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            isDefaultAction: false,
            onPressed: this.isLoadingAlert ? null : () async {
              setState(() {
                this.isLoadingAlert = true;
              });
              Navigator.pop(context);
              final response = await MatchRepository().joinMatch(match.id);
              if (response['success']) {
                this.matches = response['matches'];
                if (!matchesStreamController.isClosed)
                  matchesStreamController.sink.add(this.matches);

                this.isLoadingAlert = false;

                SharedPreferences localStorage = await SharedPreferences.getInstance();
                var jsonMatches = this.matches.map((e) => json.encode(e)).toList();
                await localStorage.setString('myMatchesScreen.matches', json.encode(jsonMatches.toString()));
                setState(() {});
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchInfoScreen(
                      match: match,
                      calledFromMatchInfo: false,
                    ),
                  ),
                );
              } else {
                setState(() {
                  this.isLoadingAlert = false;
                });
                showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
              }
            },
          ),
        ],
      ),
    );
  }
}

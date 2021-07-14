import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/matches/edit_match_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class MyMatchesScreen extends StatefulWidget {
  MyMatchesScreen({Key? key}) : super(key: key);

  @override
  _MyMatchesScreenState createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  Future? _future;
  List<Match?> matches = [];
  User? myUser;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    this._future = getMyMatches();
    this.getMyUser();
  }

  Future getMyMatches() async {
    final response = await MatchRepository().getMyMatches();
    if (response['success']) {
      setState(() {
        this.matches = response['matches'];
      });
    }

    return response;
  }

  Future<void> getRefreshData() async {
    final response = await MatchRepository().getMyMatches();
    if (response['success']) {
      setState(() {
        this.matches = response['matches'];
      });
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
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final args = ModalRoute.of(context)?.settings.arguments ?? 'No data';

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
                        double innerWidth = constraints.maxWidth;

                        return Stack(
                          children: [
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
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                MatchesScreen(),
                                            transitionDuration:
                                                Duration(seconds: 0),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.arrow_back_ios),
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
                            Positioned(
                              top: 80.0,
                              left: 0.0,
                              right: 0.0,
                              bottom: 0.0,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: (MediaQuery.of(context)
                                        .viewInsets
                                        .bottom)),
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        bottom: 20.0, left: 20.0, right: 20.0),
                                    margin: EdgeInsets.only(top: 20.0),
                                    width: _width,
                                    height: innerHeight - 50,
                                    child: FutureBuilder(
                                      future: this._future,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<dynamic> snapshot) {
                                        dynamic response = snapshot.data;

                                        if (!snapshot.hasData) {
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

                                        if (!response['success']) {
                                          return showAlert(context, 'Error',
                                              'Oops, ocurrió un error');
                                        }

                                        if (this.matches.isEmpty) {
                                          return Container(
                                            width: _width,
                                            height: _height,
                                            child: Center(
                                                child: Text(
                                                    translations[localeName]![
                                                        'general.noMatches']!)),
                                          );
                                        }

                                        return RefreshIndicator(
                                          onRefresh: () =>
                                              this.getRefreshData(),
                                          child: ListView.builder(
                                            itemBuilder: (
                                              BuildContext context,
                                              int index,
                                            ) {
                                              return _buildMatchRow(
                                                  this.matches[index]!);
                                            },
                                            itemCount: this.matches.length,
                                          ),
                                        );
                                      },
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
      return GestureDetector(
        onTap: () {
          showAlertWithEventAcceptAndCancel(
            context,
            translations[localeName]!['match.join']!,
            () async {
              final response = await MatchRepository().joinMatch(match.id);
              if (response['success']) {
                setState(() {
                  this.matches = response['matches'];
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchInfoScreen(
                      match: match,
                    ),
                  ),
                );
              } else {
                Navigator.pop(context);
                showAlert(context, 'Error', 'Oooops ocurrio un error');
              }
            },
            () async {
              final response =
                  await MatchRepository().rejectInvitationToMatch(match.id);
              if (response['success']) {
                setState(() {
                  this.matches = response['matches'];
                });
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                showAlert(context, 'Error', 'Oooops ocurrio un error');
              }
            },
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

    return Stack(
      children: [
        Dismissible(
          key: UniqueKey(),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchInfoScreen(
                    match: match,
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
          direction: imTheCreator
              ? DismissDirection.horizontal
              : DismissDirection.endToStart,
          onDismissed: (DismissDirection dismissDirection) async {
            if (dismissDirection == DismissDirection.endToStart) {
              if ((imTheCreator && imParticipating) ||
                  (!imTheCreator && imParticipating)) {
                final resp = await showAlertWithEvent(
                  context,
                  translations[localeName]!['match.leave']!,
                  () async {
                    final response =
                        await MatchRepository().leaveMatch(match.id);
                    if (response['success']) {
                      setState(() {
                        this.matches = response['matches'];
                      });
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      showAlert(context, 'Error', 'Oooops ocurrio un error');
                    }
                  },
                );

                if (resp == null) {
                  setState(() {});
                }
              } else if (imTheCreator && !imParticipating) {
                final resp = await showAlertWithEvent(
                  context,
                  translations[localeName]!['match.delete']!,
                  () async {
                    final response =
                        await MatchRepository().deleteMatch(match.id);
                    if (response['success']) {
                      setState(() {
                        this.matches = response['matches'];
                      });
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      showAlert(context, 'Error', 'Oooops ocurrio un error');
                    }
                  },
                );

                if (resp == null) {
                  setState(() {});
                }
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
          secondaryBackground: Container(
            margin: EdgeInsets.only(bottom: 20.0),
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
            child: Container(
              padding: EdgeInsets.only(
                right: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ((!imTheCreator && imParticipating) ||
                          (imTheCreator && imParticipating))
                      ? Icon(
                          Icons.remove_circle,
                          color: Colors.white,
                          size: 40.0,
                        )
                      : imTheCreator && !imParticipating
                          ? Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 40.0,
                            )
                          : Container(),
                ],
              ),
            ),
          ),
          background: imTheCreator
              ? Container(
                  margin: EdgeInsets.only(bottom: 20.0),
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
                    padding: EdgeInsets.only(
                      left: 20.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 40.0,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
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
}

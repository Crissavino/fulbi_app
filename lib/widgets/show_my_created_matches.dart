import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

// ignore: must_be_immutable
class ShowMyCreatedMatches extends StatefulWidget {
  User userToInvite;

  ShowMyCreatedMatches({required this.userToInvite});

  @override
  _ShowMyCreatedMatchesState createState() => _ShowMyCreatedMatchesState();
}

class _ShowMyCreatedMatchesState extends State<ShowMyCreatedMatches> {
  Future? _future;
  List<Match?> matches = [];
  bool isLoadingAlert = false;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    this._future = getMyCreatedMatches();
  }

  Future getMyCreatedMatches() async {
    final response = await MatchRepository().getMyCreatedMatches();
    if (response['success']) {
      setState(() {
        this.matches = response['matches'];
      });
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height / 1.1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 50.0),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Container(
                    padding:
                        EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                    margin: EdgeInsets.only(top: 20.0),
                    width: _width,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [circularLoading],
                            ),
                          );
                        }

                        if (this.isLoadingAlert) {
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

                        if (!response['success']) {
                          return showAlert(
                              context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
                        }

                        if (this.matches.isEmpty) {
                          return Container(
                            width: _width,
                            height: _height,
                            child: Center(
                              child: Text(
                                translations[localeName]!['general.noMatches']!,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: this.matches.length + 1,
                          separatorBuilder: (BuildContext _, int index,) => buildSeparator(index, this.matches),
                          itemBuilder: (
                              BuildContext context,
                              int index,
                              ) {
                            if (index == 0) {
                              return Container();
                            } else {
                              return _buildMatchRow(this.matches[index - 1]!);
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 15.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: Container(
                margin: EdgeInsets.only(top: 10.0),
                child: Text(
                  translations[localeName]![
                  'general.myMatches']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          ModalTopBar(),
        ],
      ),
    );
  }

  Widget buildSeparator(index, matches) {

    if (index != matches.length + 1) {
      Match match = matches[index];

      bool isMatchSameSex = (widget.userToInvite.genreId == match.genreId || match.genreId == 3);
      if (isMatchSameSex) {
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
      }
      return Container();
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
    bool isTheUserAlreadyIn;
    if (match.participants!.isNotEmpty) {
      isTheUserAlreadyIn = (match.participants
              ?.firstWhereOrNull((user) => user.id == widget.userToInvite.id)) !=
          null;
    } else {
      isTheUserAlreadyIn = false;
    }
    bool isMatchSameSex = (widget.userToInvite.genreId == match.genreId || match.genreId == 3);

    if (isMatchSameSex) {
      return GestureDetector(
        onTap: isTheUserAlreadyIn
            ? () => showAlert(context, translations[localeName]!['attention']!, translations[localeName]!['attention.playerAlreadyInscribed']!)
            : () async => await showAlertForInviteToMatch(match),
        child: Container(
          margin: EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(gradient: LinearGradient(
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
            color: isTheUserAlreadyIn
                ? Colors.green[400]!.withOpacity(0.5)
                : Colors.green[400],
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
                Icons.add_circle_outline,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ),
        ),
      );
    }

    return Container();
  }

  Future showAlertForInviteToMatch(Match match) {

    String title = translations[localeName]!['general.areYouGoingToInvite']! +
        ' ${widget.userToInvite.name} ' +
        translations[localeName]!['general.toYourMatch']!;

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
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
                final response = await MatchRepository()
                    .sendInvitationToUser(widget.userToInvite.id, match.id);
                if (response['success']) {
                  setState(() {
                    this._future = getMyCreatedMatches();
                    this.isLoadingAlert = false;
                  });
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
        title: Text(title),
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
              final response = await MatchRepository()
                  .sendInvitationToUser(widget.userToInvite.id, match.id);
              if (response['success']) {
                setState(() {
                  this._future = getMyCreatedMatches();
                  this.isLoadingAlert = false;
                });
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

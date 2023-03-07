import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fulbito_app/models/booking.dart';
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
                        EdgeInsets.only(left: 20.0, right: 20.0),
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
      Booking? booking = match.booking;
      BoxDecoration boxDecoration = BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/cancha-futbol-5.jpeg'),
          fit: BoxFit.cover,
          opacity: isTheUserAlreadyIn ? 0.6 : 1.0
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green[100]!,
            blurRadius: 6.0,
            offset: Offset(0, 8),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      );
      String? imageUrl = booking?.field!.image;
      if (imageUrl != null) {
        boxDecoration = BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            opacity: isTheUserAlreadyIn ? 0.6 : 1.0
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green[100]!,
              blurRadius: 6.0,
              offset: Offset(0, 8),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        );
      }

      return GestureDetector(
        onTap: isTheUserAlreadyIn
            ? () => showAlert(context, translations[localeName]!['attention']!, translations[localeName]!['attention.playerAlreadyInscribed']!)
            : () async => await showAlertForInviteToMatch(match),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: boxDecoration,
                  width: MediaQuery.of(context).size.width,
                  height: 85.0,
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  // add a container child with a star icon if match has a booking
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isTheUserAlreadyIn
                      ? [
                          Colors.green[100]!,
                          Colors.green[200]!,
                        ]
                      : [
                          Colors.green[600]!,
                          Colors.green[500]!,
                        ],
                  stops: [0.1, 0.9],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green[100]!,
                    blurRadius: 8.0,
                    offset: Offset(3, 4),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: 115.0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (booking != null) ? Row(
                          children: [
                            Text(
                              booking.field!.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                                booking.field!.address,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
                                ),
                            ),
                          ],
                        ) : Row(
                          children: [
                            Text(
                              (match.location != null)
                                  ? match.location!.city
                                  : "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.0,
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
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Row(
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
                                    (match.numPlayers -
                                        match.participants!.length)
                                        .toString(),
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
                                    size: 21.0,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.0),
          ],
        ),
      );

      return GestureDetector(
        onTap: isTheUserAlreadyIn
            ? () => showAlert(context, translations[localeName]!['attention']!, translations[localeName]!['attention.playerAlreadyInscribed']!)
            : () async => await showAlertForInviteToMatch(match),
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
            color: isTheUserAlreadyIn
                ? Colors.green[400]!.withOpacity(0.4)
                : Colors.green[400],
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: 80.0,
          child: Center(
            child: ListTile(
              leading: CircleAvatar(
                radius: 25.0,
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
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              trailing: Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 30.0,
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                translations[localeName]!['general.cancel']!,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
            TextButton(
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
                  Navigator.pop(context);
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
                Navigator.pop(context);
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

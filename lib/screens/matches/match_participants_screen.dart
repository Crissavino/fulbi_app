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
import 'package:fulbito_app/screens/matches/match_chat_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/screens/profile/public_profile_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MatchParticipantsScreen extends StatefulWidget {
  Match match;
  bool calledFromMyMatches;

  MatchParticipantsScreen({
    Key? key,
    required this.match,
    required this.calledFromMyMatches,
  }) : super(key: key);

  @override
  _MatchParticipantsScreenState createState() =>
      _MatchParticipantsScreenState();
}

class _MatchParticipantsScreenState extends State<MatchParticipantsScreen> {
  bool imInscribed = true;
  StreamController notificationStreamController = StreamController.broadcast();
  StreamController matchStreamController = StreamController.broadcast();
  bool isLoading = false;
  bool isLoadingAlert = false;
  bool isFull = false;
  bool imTheCreator = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('matchParticipants.match')) {
      var thisMatch = json.decode(json.decode(localStorage.getString('matchParticipants.match')!));
      dynamic matchDynamic = thisMatch;
      thisMatch = Match.fromJson(matchDynamic);

      Match match = thisMatch;
      if (!matchStreamController.isClosed)
        matchStreamController.sink.add({'match': match});
    }
  }

  Future getFutureData() async {
    final response = await MatchRepository().getMatch(widget.match.id);

    if (response['success']) {
      List<User?> participants = response['match'].participants!;
      User myUser = response['myUser'];

      Match match = response['match'];
      int playersEnrolled = response['playersEnrolled'];
      int spotsAvailable = match.numPlayers - playersEnrolled;
      if (spotsAvailable == 0) {
        setState(() {
          this.isFull = true;
        });
      }

      setState(() {
        this.imTheCreator = myUser.id == match.ownerId;
      });
      print(this.imTheCreator);

      if (participants.isNotEmpty) {
        User? me = participants.firstWhereOrNull(
                (user) => user!.id == myUser.id);
        setState(() {
          this.imInscribed = me != null;
        });
      } else {
        setState(() {
          this.imInscribed = false;
        });
      }

      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('matchParticipants.match', json.encode(json.encode(match)));

      if (!notificationStreamController.isClosed)
        notificationStreamController.sink.add(
          match.haveNotifications,
        );

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add({'match': match});
    }

    return response;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFromLocalStorage();
    silentNotificationListener();
    this.getFutureData();
  }

  void silentNotificationListener() {
    PushNotificationService.messageStream.listen((notificationData) {
      if (notificationData.containsKey('silentUpdateChat')) {
        if (!notificationStreamController.isClosed)
          notificationStreamController.sink.add(
            true,
          );
      }

      if (notificationData.containsKey('silentUpdateParticipants')) {
        if (!matchStreamController.isClosed)
          matchStreamController.sink.add(
            notificationData['response'],
          );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    notificationStreamController.close();
    matchStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
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
                    leading: IconButton(
                      onPressed: () {
                        if (widget.calledFromMyMatches) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyMatchesScreen(),
                            ),
                          ).then((_) => setState(() {}));
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MatchesScreen(),
                            ),
                          ).then((_) => setState(() {}));
                        }
                      },
                      icon: Platform.isIOS ? Icon(Icons.arrow_back_ios) : Icon(Icons.arrow_back),
                      splashColor: Colors.transparent,
                    ),
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
                value: Platform.isIOS
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                child: Container(
                  padding:
                      EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                  margin: EdgeInsets.only(top: 20.0),
                  width: _width,
                  height: _height,
                  child: buildMatchStreamBuilder(),
                ),
              ),
              floatingActionButton: (this.imInscribed || this.isFull || this.isLoadingAlert)
                  ? null
                  : FloatingActionButton(
                child: Icon(
                  Icons.add_circle_outline,
                  size: 40.0,
                ),
                onPressed: showAlertToJoinMatch,
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
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchInfoScreen(
              match: widget.match,
              calledFromMyMatches: widget.calledFromMyMatches,
            ),
          ),
        );
        break;
      case 2:
        User currentUser = await UserRepository.getCurrentUser();
        if (this.isFull) return;
        if (!this.imInscribed) {
          this.isLoading = false;
          await showAlertToJoinMatch(enterToChat: true);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MatchChatScreen(
                match: widget.match,
                currentUser: currentUser,
                calledFromMyMatches: widget.calledFromMyMatches,
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
          icon: buildNotificationStreamBuilder(),
        ),
      ],
    );
  }

  StreamBuilder<dynamic> buildMatchStreamBuilder() {
    return StreamBuilder(
      stream: matchStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {

        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (!snapshot.hasData) {

          this.isLoading = true;

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

        Match match = snapshot.data['match'];
        List<User?> participants = match.participants!;

        this.isLoading = false;

        if (participants.isEmpty) {
          return Container(
            width: _width,
            height: _height,
            child: Center(
                child: Text(translations[localeName]![
                'general.noParticipants']!)),
          );
        }

        return ListView.builder(
          itemCount: participants.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildPlayerRow(participants[index]!);
          },
        );
      },
    );
  }

  Widget _buildPlayerRow(User user) {
    final _width = MediaQuery.of(context).size.width;

    return Container(
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublicProfileScreen(
                    userId: user.id,
                    calledFromMatch: true,
                    match: widget.match,
                  ),
                ),
              );
            },
          ),
          background: this.imTheCreator
              ? Container(
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
                Icon(
                  Icons.remove_circle,
                  color: Colors.white,
                  size: 30.0,
                ),
              ],
            ),
          )
              : Container(),
          key: UniqueKey(),
          direction: this.imTheCreator
              ? DismissDirection.endToStart
              : DismissDirection.none,
          confirmDismiss: (DismissDirection dismissDirection) async {
            if (dismissDirection == DismissDirection.endToStart) {
              // TODO eliminar del partido
              await showAlertToExpelFromMatch(user.id);
            }
          },
        ),
      ),
    );
  }

  StreamBuilder<dynamic> buildNotificationStreamBuilder() {
    return StreamBuilder(
      initialData: widget.match.haveNotifications,
      stream: notificationStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {

        if (!this.imInscribed) {
          return Stack(
            children: [
              Icon(Icons.chat_bubble_outline),
            ],
          );
        }

        if (!snapshot.hasData) {
          return Stack(
            children: [
              Icon(Icons.chat_bubble_outline),
            ],
          );
        }

        bool areNotis = snapshot.data;

        if (!areNotis) {
          return Stack(
            children: [
              Icon(Icons.chat_bubble_outline),
            ],
          );
        }

        return Stack(
          children: [
            Icon(Icons.chat_bubble_outline),
            _buildNotification(),
          ],
        );
      },
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

  showAlertToJoinMatch({enterToChat = false}) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(translations[localeName]!['match.join']!),
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
                await MatchRepository().joinMatch(widget.match.id);
                if (response['success']) {
                  await getFutureData();
                  setState(() {
                    this.isLoadingAlert = false;
                  });
                  if (enterToChat) {
                    User currentUser = await UserRepository.getCurrentUser();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchChatScreen(
                          match: widget.match,
                          currentUser: currentUser,
                          calledFromMyMatches: widget.calledFromMyMatches,
                        ),
                      ),
                    );
                  }
                } else {
                  setState(() {
                    this.isLoadingAlert = false;
                  });
                  showAlert(context, translations[localeName]!['error']!,
                      translations[localeName]!['error.ops']!);
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
              await MatchRepository().joinMatch(widget.match.id);
              if (response['success']) {
                await getFutureData();
                setState(() {
                  this.isLoadingAlert = false;
                });
                if (enterToChat) {
                  User currentUser = await UserRepository.getCurrentUser();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchChatScreen(
                        match: widget.match,
                        currentUser: currentUser,
                        calledFromMyMatches: widget.calledFromMyMatches,
                      ),
                    ),
                  );
                }
              } else {
                setState(() {
                  this.isLoadingAlert = false;
                });
                showAlert(context, translations[localeName]!['error']!,
                    translations[localeName]!['error.ops']!);
              }
            },
          ),
        ],
      ),
    );
  }

  showAlertToExpelFromMatch(int userToExpel) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(translations[localeName]!['match.expel']!),
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
                await MatchRepository().expelFromMatch(widget.match.id, userToExpel);
                if (response['success']) {
                  await getFutureData();
                  setState(() {
                    this.isLoadingAlert = false;
                  });
                } else {
                  setState(() {
                    this.isLoadingAlert = false;
                  });
                  showAlert(context, translations[localeName]!['error']!,
                      translations[localeName]!['error.ops']!);
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
        title: Text(translations[localeName]!['match.expel']!),
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
              await MatchRepository().expelFromMatch(widget.match.id, userToExpel);
              if (response['success']) {
                await getFutureData();
                setState(() {
                  this.isLoadingAlert = false;
                });
              } else {
                setState(() {
                  this.isLoadingAlert = false;
                });
                showAlert(context, translations[localeName]!['error']!,
                    translations[localeName]!['error.ops']!);
              }
            },
          ),
        ],
      ),
    );
  }

}

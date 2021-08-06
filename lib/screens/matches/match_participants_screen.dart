import 'dart:async';
import 'dart:io';

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
  String localeName = Platform.localeName.split('_')[0];
  bool imInscribed = true;
  StreamController notificationStreamController = StreamController.broadcast();
  StreamController matchStreamController = StreamController.broadcast();
  bool isLoading = false;

  Future getFutureData() async {
    final response = await MatchRepository().getMatch(widget.match.id);

    if (response['success']) {
      List<User?> participants = response['match'].participants!;
      User myUser = response['myUser'];
      if (!notificationStreamController.isClosed)
        notificationStreamController.sink.add(
          response['match'].haveNotifications,
        );

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

      if (!matchStreamController.isClosed) matchStreamController.sink.add(
          response
      );

    }

    return response;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              floatingActionButton: this.imInscribed
                  ? null
                  : FloatingActionButton(
                child: Icon(
                  Icons.add_circle_outline,
                  size: 40.0,
                ),
                onPressed: () {
                  if (this.imInscribed) {
                    showAlert(
                        context, translations[localeName]!['error']!, 'Ya estas inscripto en este partido');
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
                              context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
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
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;
    final resp = await MatchRepository().getMatch(widget.match.id);
    Match match = resp['match'];
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchInfoScreen(
              match: match,
              calledFromMyMatches: widget.calledFromMyMatches,
            ),
          ),
        );
        break;
      case 2:
        User currentUser = await UserRepository.getCurrentUser();
        if (!this.imInscribed) {
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
                        match: widget.match,
                        currentUser: currentUser,
                      calledFromMyMatches: widget.calledFromMyMatches,
                    ),
                  ),
                );
              } else {
                Navigator.pop(context);
                showAlert(context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
              }
            },
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MatchChatScreen(
                match: match,
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
              match: widget.match,
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

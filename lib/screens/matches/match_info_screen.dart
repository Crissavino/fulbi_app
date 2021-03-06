import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/matches/match_chat_screen.dart';
import 'package:fulbito_app/screens/matches/match_participants_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/screens/profile/public_profile_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/create_dynamic_link.dart';
import 'package:fulbito_app/utils/maps_util.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MatchInfoScreen extends StatefulWidget {
  Match match;
  bool calledFromMyMatches;

  MatchInfoScreen({
    Key? key,
    required this.match,
    required this.calledFromMyMatches,
  }) : super(key: key);

  @override
  _MatchInfoScreenState createState() => _MatchInfoScreenState();
}

class _MatchInfoScreenState extends State<MatchInfoScreen> {
  bool _isCreatingLink = false;
  String? _linkMessage;
  bool imInscribed = true;
  StreamController notificationStreamController = StreamController.broadcast();
  StreamController matchStreamController = StreamController.broadcast();
  bool isLoading = false;
  bool isLoadingAlert = false;
  bool isFreeMatch = false;
  bool isFull = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Future<void> _createDynamicLinkToNewPlayer(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    Uri url = await CreateDynamicLink.createLinkWithQuery(
        'invite-new-player',
        'userWhoInvite=${widget.match.ownerId}&matchId=${widget.match.id}',
        short);

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  Future<void> _createDynamicLinkToExistingPlayer(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    Uri url = await CreateDynamicLink.createLinkWithQuery(
        'invite-existing-player',
        'userWhoInvite=${widget.match.ownerId}&matchId=${widget.match.id}',
        short);

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  Future<void> shareToNewPlayer() async {
    Navigator.pop(context);
    await _createDynamicLinkToNewPlayer(true);
    await FlutterShare.share(
        title: translations[localeName]!['match.info.inviteNewPlayer']!,
        // text: 'Example share text',
        linkUrl: _linkMessage,
        chooserTitle: translations[localeName]!['match.info.inviteNewPlayer']!);
  }

  Future<void> shareToExistingPlayer() async {
    Navigator.pop(context);
    await _createDynamicLinkToExistingPlayer(true);
    await FlutterShare.share(
        title: translations[localeName]!['match.info.inviteExistPlayer']!,
        // text: 'Example share text',
        linkUrl: _linkMessage,
        chooserTitle:
            translations[localeName]!['match.info.inviteExistPlayer']!);
  }

  Future<void> shareFile() async {
    // TODO import https://pub.dev/packages/documents_picker to share files
    // List<dynamic> docs = await DocumentsPicker.pickDocuments;
    // if (docs == null || docs.isEmpty) return null;
    //
    // await FlutterShare.shareFile(
    //   title: 'Example share',
    //   text: 'Example share text',
    //   filePath: docs[0] as String,
    // );
  }

  Future getFutureData() async {
    final response = await MatchRepository().getMatch(widget.match.id);

    if (response['success']) {
      List<User?> participants = response['match'].participants!;
      User myUser = response['myUser'];
      if (participants.isNotEmpty) {
        User? me =
            participants.firstWhereOrNull((user) => user!.id == myUser.id);
        setState(() {
          this.imInscribed = me != null;
        });
      } else {
        setState(() {
          this.imInscribed = false;
        });
      }

      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString(
          'matchInfo.match.${widget.match.id}', json.encode(json.encode(response['match'])));
      await localStorage.setString(
          'matchInfo.owner.${widget.match.id}', json.encode(json.encode(response['owner'])));
      await localStorage.setString(
          'matchInfo.location.${widget.match.id}', json.encode(json.encode(response['location'])));
      await localStorage.setString('matchInfo.genre.${widget.match.id}',
          json.encode(json.encode(response['genre'].toJson())));
      await localStorage.setString('matchInfo.type.${widget.match.id}',
          json.encode(json.encode(response['type'].toJson())));
      await localStorage.setString(
          'matchInfo.currency.${widget.match.id}', json.encode(json.encode(response['currency'])));
      await localStorage.setString('matchInfo.playersEnrolled.${widget.match.id}',
          json.encode(json.encode(response['playersEnrolled'])));

      Match match = response['match'];
      if (!notificationStreamController.isClosed)
        notificationStreamController.sink.add(match.haveNotifications);

      int playersEnrolled = response['playersEnrolled'];
      int spotsAvailable = match.numPlayers - playersEnrolled;
      if (spotsAvailable == 0) {
        setState(() {
          this.isFull = true;
        });
      }

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add({
          'match': match,
          'owner': response['owner'],
          'location': response['location'],
          'genre': response['genre'],
          'type': response['type'],
          'currency': response['currency'],
          'playersEnrolled': response['playersEnrolled'],
        });
    }

    return response;
  }

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('matchInfo.owner.${widget.match.id}')) {
      var thisMatch =
          json.decode(json.decode(localStorage.getString('matchInfo.match.${widget.match.id}')!));
      Match match = Match.fromJson(thisMatch);

      var thisMatchOwner =
      json.decode(json.decode(localStorage.getString('matchInfo.owner.${widget.match.id}')!));
      User owner = User.fromJson(thisMatchOwner);

      var thisLocation = json
          .decode(json.decode(localStorage.getString('matchInfo.location.${widget.match.id}')!));
      Location location = Location.fromJson(thisLocation);

      var thisGenre =
          json.decode(json.decode(localStorage.getString('matchInfo.genre.${widget.match.id}')!));
      Genre genre = Genre.fromJson(thisGenre);

      var thisType =
          json.decode(json.decode(localStorage.getString('matchInfo.type.${widget.match.id}')!));
      Type type = Type.fromJson(thisType);

      String? currency = json
          .decode(json.decode(localStorage.getString('matchInfo.currency.${widget.match.id}')!));

      int playersEnrolled = json.decode(
          json.decode(localStorage.getString('matchInfo.playersEnrolled.${widget.match.id}')!));

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add({
          'match': match,
          'owner': owner,
          'location': location,
          'genre': genre,
          'type': type,
          'currency': currency,
          'playersEnrolled': playersEnrolled,
        });
    }
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
      if (notificationData.containsKey('silentUpdateMatch')) {
        if (!matchStreamController.isClosed)
          matchStreamController.sink.add(
            notificationData['response'],
          );
      }
      if (notificationData.containsKey('silentUpdateChat')) {
        if (!notificationStreamController.isClosed)
          notificationStreamController.sink.add(
            true,
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
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) => MyMatchesScreen(),
                                ),
                              )
                              .then((_) => setState(() {}));
                        } else {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) => MatchesScreen(),
                                ),
                              )
                              .then((_) => setState(() {}));
                        }
                      },
                      icon: Platform.isIOS
                          ? Icon(Icons.arrow_back_ios)
                          : Icon(Icons.arrow_back),
                      splashColor: Colors.transparent,
                    ),
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
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                                      onTap: shareToNewPlayer,
                                      child: Text(
                                        translations[localeName]![
                                            'match.info.inviteNewPlayer']!,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: shareToExistingPlayer,
                                      child: Text(
                                        translations[localeName]![
                                            'match.info.inviteExistPlayer']!,
                                        style: TextStyle(
                                          fontSize: 18.0,
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

  Container _buildMatchSpots(String spotsAvailable) {
    String spotsText = 'There are $spotsAvailable spots available';
    if (localeName == 'es') {
      spotsText = 'Quedan $spotsAvailable lugares disponibles';
    } else if (localeName == 'pt') {
      spotsText = 'Existem $spotsAvailable vagas dispon??veis';
    } else if (localeName == 'fr') {
      spotsText = 'Il y a $spotsAvailable places disponibles';
    } else if (localeName == 'it') {
      spotsText = 'Ci sono $spotsAvailable posti disponibili';
    }
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Text(
        spotsText,
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  _buildOwnerName(User matchOwner) {

    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Row(
        children: [
          Text(
            '${translations[localeName]!['match.create.owner']!} ',
            style: TextStyle(),
            overflow: TextOverflow.clip,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PublicProfileScreen(
                    userId: matchOwner.id,
                    calledFromMatchInfo: true,
                    match: widget.match,
                  ),
                ),
              );
            },
            child: Text(
              matchOwner.name,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _buildMatchDescription(String description) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      child: Container(
        width: _width / 1.5,
        margin: EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Container(
            child: Text(
              translations[localeName]!['match.create.otherInfo']!,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_up_outlined,
            size: 40.0,
          ),
        ),
      ),
      onTap: () async {
        await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
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
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                      top: 100.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ModalTopBar()
                ],
              ),
            );
          },
        );
      },
    );
  }

  Container _buildMatchCost(String? currencySymbol, Match match) {
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: this.isFreeMatch
          ? Text(
              translations[localeName]!['match.isFree']!,
              overflow: TextOverflow.clip,
            )
          : Text(
              translations[localeName]!['match.aproxCost']! +
                  ' ' +
                  currencySymbol! +
                  match.cost.toString(),
              overflow: TextOverflow.clip,
            ),
    );
  }

  Container _buildMatchGenre(Genre genre) {
    String genreText = '';
    if (genre.id == 1) {
      genreText = translations[localeName]!['general.for']! +
          ' ' +
          translations[localeName]!['general.genres.males']!.toLowerCase();
    } else if (genre.id == 2) {
      genreText = translations[localeName]!['general.for']! +
          ' ' +
          translations[localeName]!['general.genres.females']!.toLowerCase();
    } else {
      genreText = translations[localeName]!['general.is']! +
          ' ' +
          translations[localeName]!['general.genres.mix']!.toLowerCase();
    }

    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Text(
        genreText,
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
    String month = translations[localeName]!['general.month.${DateFormat('MMMM').format(match.whenPlay).toLowerCase()}']!;
    String playsOnText = 'On $month ${DateFormat('d').format(match.whenPlay)}, ${DateFormat('y').format(match.whenPlay)}';
    if (localeName == 'es') {
      playsOnText = 'El ${DateFormat('d').format(match.whenPlay)} de $month de ${DateFormat('y').format(match.whenPlay)}';
    } else if (localeName == 'pt') {
      playsOnText = 'Em ${DateFormat('d').format(match.whenPlay)} de $month de ${DateFormat('y').format(match.whenPlay)}';
    } else if (localeName == 'fr') {
      playsOnText = 'Le ${DateFormat('d').format(match.whenPlay)} $month ${DateFormat('y').format(match.whenPlay)}';
    } else if (localeName == 'it') {
      playsOnText = 'Il ${DateFormat('d').format(match.whenPlay)} $month ${DateFormat('y').format(match.whenPlay)}';
    }
    return Container(
      padding: EdgeInsets.only(top: 40.0),
      child: Text(
        playsOnText,
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  _buildPlaysInText(location) {
    String text;
    if (location.city != null && location.province != null) {
      text = translations[localeName]!['match.itPlayedIn']! +
          ' ' +
          location.city +
          ', ' +
          location.province;
    } else if (location.city != null && location.province == null) {
      text =
          translations[localeName]!['match.itPlayedIn']! + ' ' + location.city;
    } else {
      text = translations[localeName]!['match.itPlayedIn']! +
          ' ' +
          location.province;
    }
    return Text(text, style: TextStyle(), overflow: TextOverflow.clip);
  }

  Row _buildPlaysIn(Location location, double _width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: _buildPlaysInText(location),
          width: _width / 1.5,
        ),
        Container(
          child: GestureDetector(
            onTap: () async {
              await MapsUtil.openMapApp(location.lat, location.lng);
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
                    translations[localeName]!['match.info.seeMap']!,
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
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;
    switch (index) {
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchParticipantsScreen(
              match: widget.match,
              calledFromMyMatches: widget.calledFromMyMatches,
            ),
          ),
        );
        break;
      case 2:
        if (this.isFull) return;
        if (!this.imInscribed) {
          this.isLoading = false;
          await showAlertToJoinMatch(enterToChat: true);
        } else {
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
          icon: buildNotificationStreamBuilder(),
        ),
      ],
    );
  }

  buildMatchStreamBuilder() {
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
        User matchOwner = snapshot.data['owner'];
        Location location = snapshot.data['location'];
        Genre genre = snapshot.data['genre'];
        Type type = snapshot.data['type'];
        String? currencySymbol = snapshot.data['currency'];
        int playersEnrolled = snapshot.data['playersEnrolled'];
        String spotsAvailable = (match.numPlayers - playersEnrolled).toString();
        this.isFreeMatch = match.isFreeMatch;

        this.isLoading = false;

        return Container(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlaysIn(location, _width),
                        _buildPlaysOn(match),
                        _buildMatchType(type),
                        _buildMatchGenre(genre),
                        _buildMatchCost(currencySymbol, match),
                        _buildMatchSpots(spotsAvailable),
                        _buildOwnerName(matchOwner),
                        Expanded(
                          child: Container(),
                        ),
                        match.description != null ? _buildMatchDescription(match.description!) : Container(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
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
}

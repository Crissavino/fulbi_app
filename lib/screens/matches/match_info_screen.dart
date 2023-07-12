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
import 'package:fulbito_app/screens/matches/edit_match_screen.dart';
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
  bool calledFromMatchInfo;

  MatchInfoScreen({
    Key? key,
    required this.match,
    required this.calledFromMatchInfo,
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
  bool imTheCreator = false;
  String currencySymbol = "\$";

  @override
  void setState(fn) {
    if (mounted) {
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
      setState(() {
        this.imTheCreator = myUser.id == widget.match.ownerId;
      });

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
      await localStorage.setString('matchInfo.match.${widget.match.id}',
          json.encode(json.encode(response['match'])));
      await localStorage.setString('matchInfo.owner.${widget.match.id}',
          json.encode(json.encode(response['owner'])));
      await localStorage.setString('matchInfo.location.${widget.match.id}',
          json.encode(json.encode(response['location'])));
      await localStorage.setString('matchInfo.genre.${widget.match.id}',
          json.encode(json.encode(response['genre'].toJson())));
      await localStorage.setString('matchInfo.type.${widget.match.id}',
          json.encode(json.encode(response['type'].toJson())));
      await localStorage.setString('matchInfo.currency.${widget.match.id}',
          json.encode(json.encode(response['currency'])));
      await localStorage.setString(
          'matchInfo.playersEnrolled.${widget.match.id}',
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
      var thisMatch = json.decode(json.decode(
          localStorage.getString('matchInfo.match.${widget.match.id}')!));
      Match match = Match.fromJson(thisMatch);

      var thisMatchOwner = json.decode(json.decode(
          localStorage.getString('matchInfo.owner.${widget.match.id}')!));
      User owner = User.fromJson(thisMatchOwner);

      var thisLocation = json.decode(json.decode(
          localStorage.getString('matchInfo.location.${widget.match.id}')!));
      Location location = Location.fromJson(thisLocation);

      var thisGenre = json.decode(json.decode(
          localStorage.getString('matchInfo.genre.${widget.match.id}')!));
      Genre genre = Genre.fromJson(thisGenre);

      var thisType = json.decode(json.decode(
          localStorage.getString('matchInfo.type.${widget.match.id}')!));
      Type type = Type.fromJson(thisType);

      String? currency = json.decode(json.decode(
          localStorage.getString('matchInfo.currency.${widget.match.id}')!));

      int playersEnrolled = json.decode(json.decode(localStorage
          .getString('matchInfo.playersEnrolled.${widget.match.id}')!));

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
    if (widget.match.currencyId == 1) {
      setState(() {
        this.currencySymbol = '€';
      });
    } else if (widget.match.currencyId == 2) {
      setState(() {
        this.currencySymbol = '£';
      });
    } else if (widget.match.currencyId == 3) {
      setState(() {
        this.currencySymbol = '\$';
      });
    }
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
              appBar: PreferredSize(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/match_info_header.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 290.0,
                  margin: EdgeInsets.only(
                    top: 30.0,
                    left: 5.0,
                    right: 5.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => MatchesScreen(),
                                    ),
                                  )
                                  .then((_) => setState(() {}));
                            },
                            icon: Platform.isIOS
                                ? Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 40.0,
                                  )
                                : Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 40.0,
                                  ),
                            splashColor: Colors.transparent,
                          ),
                          this.isFull
                              ? Container()
                              : Container(
                                  width: 40.0,
                                  height: 40.0,
                                  margin: EdgeInsets.only(
                                    top: 10.0,
                                    right: 10.0,
                                  ),
                                  child: Center(
                                    child: buildNotificationStreamBuilder(),
                                  ),
                                ),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 10.0,
                              bottom: 10.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat('HH:mm').format(widget.match.whenPlay)} hs',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${DateFormat('MMMMd').format(widget.match.whenPlay)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  right: 10.0,
                                ),
                                child: this.imTheCreator
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FloatingActionButton(
                                            heroTag: 'editMatch',
                                            onPressed: () {
                                              setState(() {});
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditMatchScreen(
                                                    match: widget.match,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            mini: true,
                                            backgroundColor: Colors.blue,
                                            splashColor: Colors.transparent,
                                          ),
                                          FloatingActionButton(
                                            heroTag: 'deleteMatchButton',
                                            key: Key('deleteMatchButton'),
                                            onPressed: showAlertToDeleteMatch,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            mini: true,
                                            backgroundColor: Colors.red,
                                            splashColor: Colors.transparent,
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  right: 10.0,
                                  bottom: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                                width: 100.0,
                                height: 40.0,
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {},
                                    child: this.isFreeMatch
                                        ? Text("\$\1000",
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ))
                                        : Text(
                                            this.currencySymbol +
                                                ' ' +
                                                widget.match.cost.toString(),
                                            overflow: TextOverflow.clip,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                preferredSize: new Size(
                  MediaQuery.of(context).size.width,
                  290.0,
                ),
              ),
              resizeToAvoidBottomInset: false,
              body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: Platform.isIOS
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 20.0,
                    left: 5.0,
                    right: 5.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          imInscribed ? _buildLeaveButton("Leave") : _buildJoinButton("Join"),
                          _buildOutlinedButton(translations[localeName]!['general.invite']!)
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      buildMatchStreamBuilder(),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildJoinButton(String text) {
    final _width = MediaQuery.of(context).size.width;

    return Container(
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
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
        color: Colors.green[400],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      width: _width * .45,
      height: 50.0,
      child: Center(
        child: TextButton(
          onPressed: showAlertToJoinMatch,
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveButton(String text) {
    final _width = MediaQuery.of(context).size.width;

    return Container(
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
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
        color: Colors.green[400],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      width: _width * .45,
      height: 50.0,
      child: Center(
        child: TextButton(
          onPressed: showAlertToLeaveMatch,
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(String text) {
    final _width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      width: _width * .45,
      height: 50.0,
      child: Center(
        child: TextButton(
          onPressed: shareToNewPlayer,
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.green[500],
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  Container _buildMatchSpots(String spotsAvailable) {
    String spotsText = 'There are $spotsAvailable spots available';
    if (localeName == 'es') {
      spotsText = 'Quedan $spotsAvailable lugares disponibles';
    } else if (localeName == 'pt') {
      spotsText = 'Existem $spotsAvailable vagas disponíveis';
    } else if (localeName == 'fr') {
      spotsText = 'Il y a $spotsAvailable places disponibles';
    } else if (localeName == 'it') {
      spotsText = 'Ci sono $spotsAvailable posti disponibili';
    }
    return Container(
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
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _buildMatchDescription(String description) {
    final _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey[200],
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
              height: _height / 1.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                        top: 30.0,
                        bottom: 50.0,
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
                    ModalTopBar(),
                  ],
                ),
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

   _buildPlaysOn(Match match) {
    String month = translations[localeName]![
        'general.month.${DateFormat('MMMM').format(match.whenPlay).toLowerCase()}']!;
    String playsOnText =
        'On $month ${DateFormat('d').format(match.whenPlay)}, ${DateFormat('y').format(match.whenPlay)}';
    if (localeName == 'es') {
      playsOnText =
          'El ${DateFormat('d').format(match.whenPlay)} de $month de ${DateFormat('y').format(match.whenPlay)}';
    } else if (localeName == 'pt') {
      playsOnText =
          'Em ${DateFormat('d').format(match.whenPlay)} de $month de ${DateFormat('y').format(match.whenPlay)}';
    } else if (localeName == 'fr') {
      playsOnText =
          'Le ${DateFormat('d').format(match.whenPlay)} $month ${DateFormat('y').format(match.whenPlay)}';
    } else if (localeName == 'it') {
      playsOnText =
          'Il ${DateFormat('d').format(match.whenPlay)} $month ${DateFormat('y').format(match.whenPlay)}';
    }

    // open calendar
    return GestureDetector(
      onTap: () {},
      child: Container(
        child: Text(
          playsOnText,
          style: TextStyle(),
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }

  _buildPlaysInText(location) {
    String text;
    if (location.city != null && location.province != null) {
      text = location.city + ', ' + location.province;
    } else if (location.city != null && location.province == null) {
      text = location.city;
    } else {
      text = location.province;
    }

    return Row(
        children: [
          Text(translations[localeName]!['match.itPlayedIn']! + ' ', style: TextStyle(), overflow: TextOverflow.clip),
          Text(
              text,
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.clip,
          ),
        ]
    );

    return Text(text, style: TextStyle(), overflow: TextOverflow.clip);
  }

  GestureDetector _buildPlaysIn(Location location, double _width) {
    return GestureDetector(
      onTap: () async {
        await MapsUtil.openMapApp(location.lat, location.lng);
      },
      child: Container(
        child: _buildPlaysInText(location),
        width: _width / 1.5,
      ),
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

        if (this.isLoadingAlert) {
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

        Match match = snapshot.data['match'];
        User matchOwner = snapshot.data['owner'];
        Location location = snapshot.data['location'];
        Genre genre = snapshot.data['genre'];
        Type type = snapshot.data['type'];
        String? currencySymbol = snapshot.data['currency'];
        int playersEnrolled = snapshot.data['playersEnrolled'];
        List<User?> participants = match.participants!;
        String spotsAvailable = (match.numPlayers - playersEnrolled).toString();
        this.isFreeMatch = match.isFreeMatch;

        return Expanded(
            child: Container(
          margin: EdgeInsets.only(
            left: 5.0,
            right: 5.0,
          ),
          width: _width,
          // create a scrollable view
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await MapsUtil.openMapApp(location.lat, location.lng);
                  },
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[100]!,
                              blurRadius: 10.0,
                              offset: Offset(0, 5),
                            ),
                          ],
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        width: 50.0,
                        height: 50.0,
                        child: Center(
                          child: Icon(
                            Icons.location_on,
                            size: 30.0,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Container(
                        child: _buildPlaysInText(location),
                        width: _width / 1.5,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[100]!,
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      width: 50.0,
                      height: 50.0,
                      child: Center(
                        child: Icon(
                          Icons.groups,
                          size: 30.0,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Container(
                      child: _buildMatchSpots(spotsAvailable),
                      width: _width / 1.5,
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[100]!,
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      width: 50.0,
                      height: 50.0,
                      child: Center(
                        child: Icon(
                          Icons.calendar_month,
                          size: 30.0,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Container(
                      child: _buildPlaysOn(match),
                      width: _width / 1.5,
                    ),
                  ],
                ),
                match.description != null ? _buildMatchDescription(match.description!) : Container(),
                SizedBox(height: 20.0),
                Text(
                  'Players enrolled',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                participants.isEmpty
                    ? Container(
                        width: _width,
                        height: _height,
                        child: Center(
                            child: Text(translations[localeName]![
                                'general.noParticipants']!)),
                      )
                    : Column(
                        children: participants
                            .map((user) => _buildPlayerRow(user!))
                            .toList(),
                      ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
        ));

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
                        match.description != null
                            ? _buildMatchDescription(match.description!)
                            : Container(),
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

  Widget _buildPlayerRow(User user) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.green[100]!,
            blurRadius: 6.0,
            offset: Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      height: 60.0,
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 0,
        shadowColor: null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
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
                    radius: 20.0,
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
                  trailing: Container(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.transparent,
                    ),
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
                    calledFromMatchInfo: true,
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
                      Radius.circular(10.0),
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
              await showAlertToExpelFromMatch(user.id);
            }
          },
        ),
      ),
    );
  }

  showAlertToDeleteMatch() {
    Match match = widget.match;
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(translations[localeName]!['match.delete']!),
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
                final response =
                await MatchRepository().deleteMatch(match.id);

                setState(() {
                  this.isLoadingAlert = false;
                });

                if (!response['success']) {
                  showAlert(
                      context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
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

              setState(() {
                this.isLoadingAlert = false;
              });

              if (!response['success']) {
                showAlert(
                    context, translations[localeName]!['error']!, translations[localeName]!['error.ops']!);
              }
            },
          ),
        ],
      ),
    );
  }

  showAlertToLeaveMatch() {
    Match match = widget.match;
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

  showAlertToExpelFromMatch(int userToExpel) {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(translations[localeName]!['match.expel']!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                translations[localeName]!['general.cancel']!,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
            TextButton(
              onPressed: this.isLoadingAlert
                  ? null
                  : () async {
                      setState(() {
                        this.isLoadingAlert = true;
                      });
                      Navigator.pop(context);
                      final response = await MatchRepository()
                          .expelFromMatch(widget.match.id, userToExpel);
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
            onPressed: this.isLoadingAlert
                ? null
                : () async {
                    setState(() {
                      this.isLoadingAlert = true;
                    });
                    Navigator.pop(context);
                    final response = await MatchRepository()
                        .expelFromMatch(widget.match.id, userToExpel);
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

  StreamBuilder<dynamic> buildNotificationStreamBuilder() {
    return StreamBuilder(
      initialData: widget.match.haveNotifications,
      stream: notificationStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Stack(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 30.0,
                color: Colors.green[700],
              ),
            ],
          );
        }

        if (!this.imInscribed) {
          return FloatingActionButton(
            heroTag: 'matchChat',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () async {
              await showAlertToJoinMatch(enterToChat: true);
            },
            child: Stack(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 30.0,
                  color: Colors.green[700],
                ),
              ],
            ),
            mini: true,
            backgroundColor: Colors.grey[200],
            splashColor: Colors.transparent,
          );
        }

        bool haveNotification = snapshot.data;

        if (!haveNotification) {
          return FloatingActionButton(
            heroTag: 'matchChat',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () async {
              User currentUser = await UserRepository.getCurrentUser();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchChatScreen(
                    match: widget.match,
                    currentUser: currentUser,
                    calledFromMatchInfo: true,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 30.0,
                  color: Colors.green[700],
                ),
              ],
            ),
            mini: true,
            backgroundColor: Colors.grey[200],
            splashColor: Colors.transparent,
          );
        }

        return FloatingActionButton(
          heroTag: 'matchChat',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          onPressed: () async {
            User currentUser = await UserRepository.getCurrentUser();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MatchChatScreen(
                  match: widget.match,
                  currentUser: currentUser,
                  calledFromMatchInfo: true,
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 30.0,
                color: Colors.green[700],
              ),
              _buildNotification(),
            ],
          ),
          mini: true,
          backgroundColor: Colors.grey[200],
          splashColor: Colors.transparent,
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                translations[localeName]!['general.cancel']!,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
            TextButton(
              onPressed: this.isLoadingAlert
                  ? null
                  : () async {
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
                          User currentUser =
                              await UserRepository.getCurrentUser();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchChatScreen(
                                match: widget.match,
                                currentUser: currentUser,
                                calledFromMatchInfo: true,
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
            onPressed: this.isLoadingAlert
                ? null
                : () async {
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
                        User currentUser =
                            await UserRepository.getCurrentUser();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchChatScreen(
                              match: widget.match,
                              currentUser: currentUser,
                              calledFromMatchInfo: true,
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

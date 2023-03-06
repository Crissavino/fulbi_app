import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/position_db.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/match_participants_screen.dart';
import 'package:fulbito_app/screens/players/players_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/show_my_created_matches.dart';
import 'package:fulbito_app/widgets/show_user_positions.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

// ignore: must_be_immutable
class PublicProfileScreen extends StatefulWidget {
  int userId;
  bool calledFromMatch;
  bool? calledFromMatchInfo;
  Match? match;

  PublicProfileScreen({
    required this.userId,
    this.calledFromMatch = false,
    this.calledFromMatchInfo = false,
    this.match,
  });

  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  Future? _future;
  User? _user;
  List<PositionDB>? _userPositions;
  Location? _userLocation;
  String profileImagePath = '';

  @override
  void initState() {
    super.initState();
    this._future = getUserData(widget.userId);
  }

  Future<dynamic> getUserData(int userId) async {
    final response =  await UserRepository.getUserData(userId);
    if (response['success']) {
      this._user = response['user'];
      this._userPositions = response['positions'];
      this._userLocation = response['location'];
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        FutureBuilder(
            future: this._future,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                if(this._user!.profileImage != null) {
                  this.profileImagePath = this._user!.profileImage!;
                }
                return SafeArea(
                  top: false,
                  bottom: false,
                  child: Scaffold(
                    appBar: new PreferredSize(
                      child: new Container(
                        decoration: horizontalGradient,
                        child: AppBar(
                          systemOverlayStyle:
                          SystemUiOverlayStyle(statusBarColor: Colors.white),
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          leading: Container(
                            child: IconButton(
                              onPressed: () {
                                if (widget.calledFromMatch) {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) =>
                                          MatchParticipantsScreen(match: widget.match!, calledFromMyMatches: false),
                                      transitionDuration: Duration(seconds: 0),
                                    ),
                                  );
                                } else if(widget.calledFromMatchInfo!) {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) =>
                                          MatchInfoScreen(match: widget.match!, calledFromMatchInfo: false),
                                      transitionDuration: Duration(seconds: 0),
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) =>
                                          PlayersScreen(),
                                      transitionDuration: Duration(seconds: 0),
                                    ),
                                  );
                                }

                              },
                              icon: Icon(Icons.arrow_back_ios),
                            ),
                          ),
                          title: Text(
                            this._user!.name,
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
                      child: Center(
                        child: Container(
                          height: _height,
                          decoration: horizontalGradient,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double innerHeight = constraints.maxHeight;
                              double innerWidth = constraints.maxWidth;

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      height: innerHeight * 0.9,
                                      width: innerWidth,
                                      decoration: BoxDecoration(
                                        borderRadius: screenBorders,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6.0,
                                            offset: Offset(0, -2),
                                          ),
                                        ],
                                      ),
                                      child: _userInformationNew(innerWidth, innerHeight),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Center(
                                      child: this.profileImagePath == ''
                                          ? CircleAvatar(
                                        backgroundColor: Colors.green[300],
                                        radius: 60,
                                            child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 54,
                                        child: Icon(
                                            Icons.person,
                                            color: Colors.green[700],
                                            size: 100.0,
                                        ),
                                      ),
                                          )
                                          : CircleAvatar(
                                        backgroundColor: Colors.green[300],
                                        radius: 60,
                                            child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 54,
                                        backgroundImage: NetworkImage(
                                            this.profileImagePath,
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
                );
              } else {
                return SafeArea(
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
                          leading: Container(
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation1, animation2) =>
                                        PlayersScreen(),
                                    transitionDuration: Duration(seconds: 0),
                                  ),
                                );
                              },
                              icon: Icon(Icons.arrow_back_ios),
                            ),
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
                      child: Center(
                        child: Container(
                          height: _height,
                          decoration: horizontalGradient,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double innerHeight = constraints.maxHeight;
                              double innerWidth = constraints.maxWidth;

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      height: innerHeight * 0.9,
                                      width: innerWidth,
                                      decoration: BoxDecoration(
                                        borderRadius: screenBorders,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6.0,
                                            offset: Offset(0, -2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [circularLoading],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Center(
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 60,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.green[700],
                                          size: 100.0,
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
                );
              }
            }),
      ],
    );
  }

  _buildUserNickname(innerWidth) {
    return Container(
      child: Text(
        '@${this._user!.nickname}',
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  _buildUserReviews(innerWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 2.0,
        ),
        Container(
          width: innerWidth * .3,
          height: 60.0,
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Puntualidad',
                  style: kLabelStyleBlack,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star_border,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star_border,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          width: innerWidth * .3,
          height: 60.0,
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Puntualidad',
                  style: kLabelStyleBlack,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star_border,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star_border,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          width: innerWidth * .3,
          height: 60.0,
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Puntualidad',
                  style: kLabelStyleBlack,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star_border,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                    Icon(
                      Icons.star_border,
                      size: 20.0,
                      color: Colors.yellow[700],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: 2.0,
        ),
      ],
    );
  }

  _buildUserPositions(innerWidth) {
    return GestureDetector(
      child: Container(
        width: innerWidth * .95,
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
          title: Text(translations[localeName]!['general.positions']!),
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
            return ShowUserPositions(
              userPositions: this._userPositions,
            );
          },
        );
      },
    );
  }

  _buildUserLocation(innerWidth) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0,),
      child: Text(
        translations[localeName]!['profile.usuallyPlay']! + ' ' + this._userLocation!.formattedAddress,
        overflow: TextOverflow.clip,
        textAlign: TextAlign.center,
      ),
    );
  }

  _buildInviteButton() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 20.0),
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
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        width: MediaQuery.of(context).size.width * .40,
        height: 50.0,
        child: TextButton(
          onPressed: () async {
            await showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              enableDrag: true,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return ShowMyCreatedMatches(
                  userToInvite: this._user!,
                );
              },
            );
          },
          child: Text(
            translations[localeName]!['general.invite']!.toUpperCase(),
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

  _userInformation(double innerWidth) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 75.0),
        _buildUserNickname(innerWidth),
        // SizedBox(height: 15.0),
        // _buildUserReviews(innerWidth),
        SizedBox(height: 45.0),
        _buildUserLocation(innerWidth),
        SizedBox(height: 45.0),
        _buildUserPositions(innerWidth),
        Expanded(child: Container()),
        widget.calledFromMatch ? Container() : _buildInviteButton(),
        SizedBox(height: 55.0),
      ],
    );
  }

  _userInformationNew(double innerWidth, double innerHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 75.0),
        Container(
          height: 25.0,
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0,),
          padding: EdgeInsets.only(left: 20.0,),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
          child: Text(
            translations[localeName]!['profile.nickname']!,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          height: 8.0,
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0,),
          padding: EdgeInsets.only(left: 30.0,),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
          child: Text(
            '@${this._user!.nickname}',
            overflow: TextOverflow.clip,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 25.0,
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0,),
          padding: EdgeInsets.only(left: 20.0,),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
          child: Text(
            translations[localeName]!['profile.usuallyPlay']!,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          height: 8.0,
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0,),
          padding: EdgeInsets.only(left: 30.0,),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
          child: Text(
            this._userLocation!.formattedAddress,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 25.0,
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0,),
          padding: EdgeInsets.only(left: 20.0,),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
          child: Text(
            translations[localeName]!['general.positions']!,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.left,
          ),
        ),
        // go throw this._userPositions and build a row with each position
        Container(
          height: 8.0,
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0,),
          padding: EdgeInsets.only(left: 30.0,),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var position in this._userPositions!)
                Text(
                  position.id == 1
                      ? translations[localeName]!['general.positions.gk']!
                      : position.id == 2
                      ? translations[localeName]!['general.positions.def']!
                      : position.id == 3
                      ? translations[localeName]![
                  'general.positions.mid']!
                      : translations[localeName]![
                  'general.positions.for']!,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),

            ],
          ),
        ),
        Container(
          height: 25.0,
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2.0,
                color: Colors.green[600]!,
              ),
            ),
          ),
        ),
        Expanded(child: Container()),
        widget.calledFromMatch ? Container() : _buildInviteButton(),
        SizedBox(height: 55.0),
      ],
    );
  }

}

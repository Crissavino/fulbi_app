import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/position_db.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/show_my_created_matches.dart';
import 'package:fulbito_app/widgets/show_user_positions.dart';

// ignore: must_be_immutable
class PublicProfileScreen extends StatefulWidget {
  int userId;
  bool calledFromMatch;

  PublicProfileScreen({
    required this.userId,
    this.calledFromMatch = false,
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
                          backwardsCompatibility: false,
                          systemOverlayStyle:
                          SystemUiOverlayStyle(statusBarColor: Colors.white),
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
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
                      value: SystemUiOverlayStyle.light,
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
                                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(height: 75.0),
                                          _buildUserNickname(innerWidth),
                                          SizedBox(height: 15.0),
                                          _buildUserReviews(innerWidth),
                                          SizedBox(height: 45.0),
                                          _buildUserLocation(innerWidth),
                                          SizedBox(height: 45.0),
                                          _buildUserPositions(innerWidth),
                                          Expanded(child: Container()),
                                          widget.calledFromMatch ? Container() : _buildInviteButton(),
                                          SizedBox(height: 55.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Center(
                                      child: this.profileImagePath == ''
                                          ? CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 60,
                                        backgroundImage: AssetImage(
                                          'assets/profile-default.png',
                                        ),
                                      )
                                          : CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 60,
                                        backgroundImage: AssetImage(
                                          this.profileImagePath,
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
                        ),
                      ),
                      preferredSize: new Size(
                        MediaQuery.of(context).size.width,
                        70.0,
                      ),
                    ),
                    resizeToAvoidBottomInset: false,
                    body: AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle.light,
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
                                        backgroundImage: AssetImage(
                                            'assets/profile-default.png',
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
      child: Text(
        translations[localeName]!['profile.usuallyPlay']! + ' ' + this._userLocation!.formattedAddress,
        style: TextStyle(),
        overflow: TextOverflow.clip,
      ),
    );
  }

  _buildInviteButton() {
    return Container(
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
      child: Center(
        child: TextButton(
          onPressed: () async {
            await showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              enableDrag: true,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return ShowMyCreatedMatches(
                  user: this._user!,
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

}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/position_db.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/screens/players/players_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/your_location.dart';
import 'package:fulbito_app/widgets/your_positions.dart';
import 'package:fulbito_app/widgets/your_settings.dart';

class PrivateProfileScreen extends StatefulWidget {
  const PrivateProfileScreen({Key? key}) : super(key: key);

  @override
  _PrivateProfileScreenState createState() => _PrivateProfileScreenState();
}

class _PrivateProfileScreenState extends State<PrivateProfileScreen> {
  Future? _future;
  User? _currentUser;
  List<PositionDB>? _userPositions;
  Location? _userLocation;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    this._future = getUserData();
  }

  Future<dynamic> getUserData() async {
    final response = await UserRepository.getAllCurrentUserData();
    if (response['success']) {
      this._currentUser = response['user'];
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
                return SafeArea(
                  top: false,
                  bottom: false,
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle.light,
                      child: Center(
                        child: Container(
                          height: _height,
                          decoration: horizontalGradient,
                          padding: EdgeInsets.only(top: 25.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double innerHeight = constraints.maxHeight;
                              double innerWidth = constraints.maxWidth;

                              return SafeArea(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Positioned(
                                      bottom: 0.0,
                                      left: 0.0,
                                      right: 0.0,
                                      child: Container(
                                        height: innerHeight * 0.87,
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
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(height: 55.0),
                                            _buildUserName(),
                                            SizedBox(height: 5.0),
                                            _buildUserReviews(innerWidth),
                                            SizedBox(height: 5.0),
                                            _buildUserPositions(innerWidth),
                                            // SizedBox(height: 5.0),
                                            // _buildUserSettings(innerWidth),
                                            SizedBox(height: 5.0),
                                            _buildUserLocation(innerWidth),
                                            SizedBox(height: 5.0),
                                            _buildUserSettings(innerWidth),
                                            SizedBox(height: 10.0),
                                            _buildLogOutButton(),
                                            SizedBox(height: 10.0),
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
                                          radius: 60,
                                          backgroundImage: AssetImage(
                                              'assets/profile_cs.jpg'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    bottomNavigationBar: _buildBottomNavigationBarRounded(),
                  ),
                );
              } else {
                return SafeArea(
                  top: false,
                  bottom: false,
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle.light,
                      child: Center(
                        child: Container(
                          height: _height,
                          decoration: horizontalGradient,
                          padding: EdgeInsets.only(top: 25.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double innerHeight = constraints.maxHeight;
                              double innerWidth = constraints.maxWidth;

                              return SafeArea(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Positioned(
                                      bottom: 0.0,
                                      left: 0.0,
                                      right: 0.0,
                                      child: Container(
                                        height: innerHeight * 0.87,
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
                                          radius: 60,
                                          backgroundImage: null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    bottomNavigationBar: _buildBottomNavigationBarRounded(),
                  ),
                );
              }
            }),
      ],
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

  _buildUserName() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        this._currentUser!.name,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Nunito',
          fontSize: 30.0,
        ),
        overflow: TextOverflow.clip,
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
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
          title: Text('Posiciones'),
          trailing: Icon(
            Icons.keyboard_arrow_up_outlined,
            size: 40.0,
          ),
        ),
      ),
      onTap: () async {
        final wasSavedData = await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return YourPositions(
              userPositions: this._userPositions,
            );
          },
        );

        if (wasSavedData == true) {
          this._userPositions = await UserRepository.getUserPositions();
        }
      },
    );
  }

  _buildUserLocation(innerWidth) {
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
          title: Text('Lugar donde jugas'),
          trailing: Icon(
            Icons.keyboard_arrow_up_outlined,
            size: 40.0,
          ),
        ),
      ),
      onTap: () async {
        final wasSavedData = await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return YourLocation(
              userLocation: this._userLocation,
            );
          },
        );

        if (wasSavedData == true) {
          this._userLocation = await UserRepository().getUserLocation();
        }
      },
    );
  }

  _buildUserSettings(innerWidth) {
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
          title: Text(translations[localeName]!['profile.config']!),
          trailing: Icon(
            Icons.keyboard_arrow_up_outlined,
            size: 40.0,
          ),
        ),
      ),
      onTap: () async {
        final user = await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return YourSettings(
              user: this._currentUser
            );
          },
        );

        if (user != null) {
          this._currentUser = user;
        }
      },
    );
  }

  _buildLogOutButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextButton(
          onPressed: _logout,
          child: Text(
            translations[localeName]!['profile.logout']!,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void _logout() async {
    if (await UserRepository().logout()) {
      Navigator.pushReplacementNamed(context, 'login');
    } else {
      print('Error con el logout');
    }
  }

  void _navigateToSection(index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => PlayersScreen(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => MatchesScreen(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        break;
      default:
        return;
    }
  }

  Widget _buildBottomNavigationBarRounded() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0.0,
      iconSize: 30,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.green[400],
      unselectedItemColor: Colors.green[900],
      backgroundColor: Colors.white,
      currentIndex: 2,
      onTap: (index) {
        if (index != 2) {
          _navigateToSection(index);
        }
        print(index);
        // Navigator.pushReplacementNamed(context, 'profile');
      },
      items: [
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Jugadores'),
          icon: Icon(Icons.groups_outlined),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Partidos'),
          icon: Icon(
            Icons.sports_soccer,
          ),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Perfil'),
          icon: Icon(Icons.person_outline),
        ),
      ],
    );
  }
}

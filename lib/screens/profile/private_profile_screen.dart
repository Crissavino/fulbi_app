import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/position_db.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/screens/players/players_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/your_location.dart';
import 'package:fulbito_app/widgets/your_positions.dart';
import 'package:fulbito_app/widgets/your_settings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  File? _image;
  final picker = ImagePicker();
  String? profileImagePath;
  bool isLoading = false;
  StreamController userStreamController = StreamController.broadcast();

  Future updateProfileImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      final fileName = basename(_image!.path);
      final File localImage = await _image!.copy('$appDocPath/$fileName');

      final response = await UserRepository().updateProfilePicture(
          localImage
      );

      if (response['success']) {
        User user = response['user'];
        this.profileImagePath = user.profileImage;
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        await localStorage.setString('privateProfileScreen.profileImagePath', json.encode(this.profileImagePath.toString()));
      }

      setState(() {});
    } else {
      //User canceled the picker. You need do something here, or just add return
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    loadFromLocalStorage();
    getUserData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userStreamController.close();
  }

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('privateProfileScreen.currentUser') &&
        localStorage.containsKey('privateProfileScreen.userPositions') &&
        localStorage.containsKey('privateProfileScreen.userLocation') &&
        localStorage.containsKey('privateProfileScreen.profileImagePath')) {

      this._currentUser = User.fromJson(json.decode(localStorage.getString('privateProfileScreen.currentUser')!));

      var posDB = json.decode(json.decode(localStorage.getString('privateProfileScreen.userPositions')!));
      List pos = posDB;
      List<PositionDB>? positions = pos.map((position) => PositionDB.fromJson(position)).toList();
      this._userPositions = positions;

      this._userLocation = Location.fromJson(json.decode(localStorage.getString('privateProfileScreen.userLocation')!));
      this.profileImagePath = json.decode(localStorage.getString('privateProfileScreen.profileImagePath')!);

      var streamData = {
        'currentUser': this._currentUser,
        'userPositions': this._userPositions,
        'userLocation': this._userLocation,
        'profileImagePath': this.profileImagePath
      };
      if (!userStreamController.isClosed)
        userStreamController.sink.add(
          streamData,
        );
    }
  }

  Future<dynamic> getUserData() async {
    final response = await UserRepository.getAllCurrentUserData();
    if (response['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      this._currentUser = response['user'];
      await localStorage.setString('privateProfileScreen.currentUser', json.encode(this._currentUser!.toJson()));

      this._userPositions = response['positions'];
      var userPosition = this._userPositions!.map((e) => json.encode(e)).toList();
      await localStorage.setString('privateProfileScreen.userPositions', json.encode(userPosition.toString()));

      this._userLocation = response['location'];
      await localStorage.setString('privateProfileScreen.userLocation', json.encode(this._userLocation!.toJson()));

      if(this._currentUser!.profileImage != null) {
        this.profileImagePath = this._currentUser!.profileImage!;
      } else {
        this.profileImagePath = '';
      }
      await localStorage.setString('privateProfileScreen.profileImagePath', json.encode(this.profileImagePath.toString()));

      var streamData = {
        'currentUser': this._currentUser,
        'userPositions': this._userPositions,
        'userLocation': this._userLocation,
        'profileImagePath': this.profileImagePath
      };
      if (!userStreamController.isClosed)
        userStreamController.sink.add(
            streamData,
        );
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        StreamBuilder(
          stream: userStreamController.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // final _width = MediaQuery.of(context).size.width;
            // final _height = MediaQuery.of(context).size.height;

            if (!snapshot.hasData) {
              this.isLoading = true;

              return SafeArea(
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
                        height: _height,
                        decoration: horizontalGradient,
                        padding: EdgeInsets.only(top: 25.0),
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
                                  top: 15.0,
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
                  bottomNavigationBar: _buildBottomNavigationBarRounded(context),
                ),
              );
            }

            this.isLoading = false;

            User? currentUser = snapshot.data['currentUser'];
            List<PositionDB>? userPositions = snapshot.data['userPositions'];
            Location? userLocation = snapshot.data['userLocation'];
            String? profileImagePath = snapshot.data['profileImagePath'];

            return SafeArea(
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
                      height: _height,
                      decoration: horizontalGradient,
                      padding: EdgeInsets.only(top: 25.0),
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
                                      _buildUserName(currentUser),
                                      SizedBox(height: 5.0),
                                      // _buildUserReviews(innerWidth),
                                      // SizedBox(height: 5.0),
                                      _buildUserPositions(innerWidth, context, userPositions),
                                      // SizedBox(height: 5.0),
                                      // _buildUserSettings(innerWidth),
                                      SizedBox(height: 5.0),
                                      _buildUserLocation(innerWidth, context, userLocation),
                                      SizedBox(height: 5.0),
                                      _buildUserSettings(innerWidth, context, currentUser),
                                      SizedBox(height: 10.0),
                                      _buildLogOutButton(context, currentUser),
                                      SizedBox(height: 10.0),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 15.0,
                                left: 0.0,
                                right: 0.0,
                                child: Center(
                                  child: profileImagePath == ''
                                      ? CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 60,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.green[700],
                                      size: 100.0,
                                    ),
                                  )
                                      : CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 60,
                                    backgroundImage: NetworkImage(profileImagePath!),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 90.0,
                                left: 80.0,
                                right: 0.0,
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: Container(
                                      child: IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue,),
                                        onPressed: updateProfileImage,
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
                bottomNavigationBar: _buildBottomNavigationBarRounded(context),
              ),
            );
          },
        ),
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
                      Icons.star_half,
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

  _buildUserName(User? currentUser) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        currentUser!.name,
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

  _buildUserPositions(innerWidth, BuildContext context, List<PositionDB>? userPositions) {
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
        final wasSavedData = await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return YourPositions(
              userPositions: userPositions,
            );
          },
        );

        if (wasSavedData == true) {
          this._userPositions = await UserRepository.getUserPositions();
          SharedPreferences localStorage = await SharedPreferences.getInstance();
          var userPosition = this._userPositions!.map((e) => json.encode(e)).toList();
          await localStorage.setString('privateProfileScreen.userPositions', json.encode(userPosition.toString()));

          var streamData = {
            'currentUser': this._currentUser,
            'userPositions': this._userPositions,
            'userLocation': this._userLocation,
            'profileImagePath': this.profileImagePath
          };
          if (!userStreamController.isClosed)
            userStreamController.sink.add(
              streamData,
            );
        }
      },
    );
  }

  _buildUserLocation(innerWidth, BuildContext context, Location? userLocation) {
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
          title: Text(translations[localeName]!['profile.wherePlay']!),
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
              userLocation: userLocation,
            );
          },
        );

        if (wasSavedData == true) {
          this._userLocation = await UserRepository().getUserLocation();
          SharedPreferences localStorage = await SharedPreferences.getInstance();
          await localStorage.setString('privateProfileScreen.userLocation', json.encode(this._userLocation!.toJson()));

          var streamData = {
            'currentUser': this._currentUser,
            'userPositions': this._userPositions,
            'userLocation': this._userLocation,
            'profileImagePath': this.profileImagePath
          };
          if (!userStreamController.isClosed)
            userStreamController.sink.add(
              streamData,
            );
        }
      },
    );
  }

  _buildUserSettings(innerWidth, BuildContext context, User? currentUser) {
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
              user: currentUser
            );
          },
        );

        if (user != null) {
          this._currentUser = user;
          SharedPreferences localStorage = await SharedPreferences.getInstance();
          await localStorage.setString('privateProfileScreen.currentUser', json.encode(this._currentUser!.toJson()));

          var streamData = {
            'currentUser': this._currentUser,
            'userPositions': this._userPositions,
            'userLocation': this._userLocation,
            'profileImagePath': this.profileImagePath
          };
          if (!userStreamController.isClosed)
            userStreamController.sink.add(
              streamData,
            );
        }
      },
    );
  }

  _buildLogOutButton(BuildContext context, User? currentUser) {
    return Center(
      child: Container(
        width: 150.0,
        height: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
          ),
          onPressed: () => _logout(context, currentUser),
          child: Text(
            translations[localeName]!['profile.logout']!,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context, User? currentUser) async {
    if (await UserRepository().logout(currentUser!.id)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      print('Error con el logout');
    }
  }

  void _navigateToSection(index, BuildContext context) {
    if (this.isLoading) {
      return;
    }
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

  Widget _buildBottomNavigationBarRounded(BuildContext context) {
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
          _navigateToSection(index, context);
        }
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

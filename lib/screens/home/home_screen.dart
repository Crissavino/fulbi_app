import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/screens/bookings/bookings_screen.dart';
import 'package:fulbito_app/screens/home/news_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/booking.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../../utils/translations.dart';
import '../../widgets/user_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic search = '';
  bool isLoading = false;
  List<User?> players = [];


  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Widget _buildSearchTF() {
      final width = MediaQuery.of(context).size.width;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 16.0, right: 8.0),
            height: 30.0,
            width: width * 0.95,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: -3),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                hintText: translations[localeName]!['search']!,
                hintStyle: kHintTextStyle,
              ),
              onChanged: (val) async {
                val = val.toLowerCase();

              },
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          SafeArea(
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
                    decoration: horizontalGradient,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: horizontalGradient,
                                padding: EdgeInsets.only(left: 10.0, top: 33.0),
                                alignment: Alignment.center,
                                child: _buildSearchTF(),
                              ),
                            ),
                            Positioned(
                              top: 80.0,
                              left: 0.0,
                              right: 0.0,
                              bottom: -20.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6.0,
                                      offset: Offset(0, -2),
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: screenBorders,
                                ),
                                padding: EdgeInsets.only(
                                    bottom: 20.0, left: 20.0, right: 20.0),
                                margin: EdgeInsets.only(top: 20.0),
                                width: _width,
                                height: _height,
                                child: ListView(
                                  padding: EdgeInsets.only(top: 10.0),
                                  children: [
                                    // latest news
                                    LatestNewsSection(),
                                    // book this fields
                                    BookThisFieldsSection(),
                                    // play this matches
                                    PlayThisMatchesSection(),
                                    SizedBox(height: 30.0),
                                  ],
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
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // allow the user to create a math or book a field
                },
                child: Icon(
                  Icons.add,
                  size: 30.0,
                ),
                backgroundColor: Colors.green[500],
                foregroundColor: Colors.white,
              ),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: UserMenu(
                isLoading: this.isLoading,
                currentIndex: 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget LatestNewsSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest News',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => NewsScreen(),
                        transitionDuration: Duration(seconds: 0),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: AssetImage('assets/cancha-futbol-5.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget aliquam luctus, nisl nisl aliquet nisl, euismod.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '12/12/2021',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget BookThisFieldsSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.0),
          Text(
            'Book This Fields',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {

                // check if is the last index
                bool isLastIndex = index == 2;
                if (isLastIndex) {
                  return GestureDetector(
                    onTap: () {
                      // navigate to the fields list
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => BookingsScreen(),
                          transitionDuration: Duration(seconds: 0),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10.0),
                      width: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: AssetImage('assets/cancha-futbol-5.jpeg'),
                          fit: BoxFit.cover,
                          opacity: 0.5,
                        ),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Ver más...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage('assets/cancha-futbol-5.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // field.name,
                                'Cancha de futbol 5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                // field.address,
                                'Av. Siempre viva 123',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          top: 10.0,
                          right: 20.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              // type.vs!,
                              '9 vs 9',
                              style: TextStyle(
                                // add a RGB color #8B9586
                                color: Color(0xFF8B9586),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget BookThisFieldsSection_old() {

    DecorationImage decorationImage = DecorationImage(
      image: AssetImage('assets/cancha-futbol-5.jpeg'),
      fit: BoxFit.cover,
    );
    // if (field.image.isNotEmpty) {
    //   decorationImage = DecorationImage(
    //     image: NetworkImage(field.image),
    //     fit: BoxFit.cover,
    //   );
    // }

    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book This Fields',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            width: MediaQuery.of(context).size.width,
            // occupy the necessary height
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: decorationImage,
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
                              ),
                              height: 85.0,
                            ),
                            Positioned(
                                top: 10.0,
                                right: 10.0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                  ),
                                  child: Text(
                                    // type.vs!,
                                    '9 vs 9',
                                    style: TextStyle(
                                      // add a RGB color #8B9586
                                      color: Color(0xFF8B9586),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
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
                            color: Colors.green[400],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                          ),
                          height: 75.0,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  // field.name,
                                  'Cancha de futbol 5',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: decorationImage,
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
                              ),
                              height: 85.0,
                            ),
                            Positioned(
                                top: 10.0,
                                right: 10.0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                  ),
                                  child: Text(
                                    // type.vs!,
                                    '9 vs 9',
                                    style: TextStyle(
                                      // add a RGB color #8B9586
                                      color: Color(0xFF8B9586),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
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
                            color: Colors.green[400],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                          ),
                          height: 75.0,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  // field.name,
                                  'Cancha de futbol 5',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );

  }

  Widget PlayThisMatchesSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.0),
          Text(
            'Play Now!',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {

                // check if is the last index
                bool isLastIndex = index == 2;
                if (isLastIndex) {
                  return GestureDetector(
                    onTap: () {
                      // navigate to the fields list
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => MatchesScreen(),
                          transitionDuration: Duration(seconds: 0),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10.0),
                      width: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: AssetImage('assets/match_info_header.png'),
                          fit: BoxFit.cover,
                          opacity: 0.5,
                        ),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Ver más...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage('assets/match_info_header.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        // '${DateFormat('HH:mm').format(match.whenPlay)} hs',
                                        '21:00 hs',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        // '${DateFormat('MMMMd').format(match.whenPlay)}',
                                        'July 22',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        translations[localeName]!['match.missing']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '6',
                                            // (match.numPlayers - match.participants!.length).toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 4.0),
                                          Icon(
                                            Icons.group_outlined,
                                            color: Colors.white,
                                            size: 18.0,
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                // field.name,
                                'Cancha de futbol 5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                // field.address,
                                'Av. Siempre viva 123',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          top: 10.0,
                          right: 20.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                            child: Text(
                              // type.vs!,
                              '9 vs 9',
                              style: TextStyle(
                                // add a RGB color #8B9586
                                color: Color(0xFF8B9586),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget PlayThisMatchesSection_old() {

    BoxDecoration boxDecoration = BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/cancha-futbol-5.jpeg'),
        fit: BoxFit.cover,
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
    //Booking? booking = match.booking;
    // String? imageUrl = booking?.field!.image;
    // if (imageUrl != null) {
    //   boxDecoration = BoxDecoration(
    //     image: DecorationImage(
    //       image: NetworkImage(imageUrl),
    //       fit: BoxFit.cover,
    //     ),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.green[100]!,
    //         blurRadius: 6.0,
    //         offset: Offset(0, 8),
    //       ),
    //     ],
    //     borderRadius: BorderRadius.only(
    //       topLeft: Radius.circular(10.0),
    //       topRight: Radius.circular(10.0),
    //     ),
    //   );
    // }

    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Play now!',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Container(
              width: MediaQuery.of(context).size.width,
              // occupy the necessary height
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: boxDecoration,
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 85.0,
                              ),
                              Positioned(
                                top: 10.0,
                                right: 10.0,
                                child: Container(
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
                                    // match.type.vs!,
                                    '9 vs 9',
                                    style: TextStyle(
                                      // add a RGB color #8B9586
                                      color: Color(0xFF8B9586),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
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
                              color: Colors.green[400],
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 80.0,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // (booking != null)
                                      (false)
                                          ? Row(
                                        children: [
                                          // Text(
                                          //   booking.field!.name,
                                          //   style: TextStyle(
                                          //     color: Colors.white,
                                          //     fontSize: 12.0,
                                          //     fontWeight: FontWeight.bold,
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   width: 5.0,
                                          // ),
                                          // Text(
                                          //   booking.field!.address,
                                          //   style: TextStyle(
                                          //     color: Colors.white,
                                          //     fontSize: 12.0,
                                          //     fontWeight: FontWeight.normal,
                                          //   ),
                                          // ),
                                        ],
                                      ) : Row(
                                        children: [
                                          Text(
                                            // (match.location != null)
                                            (false)
                                                ? 'asdas'
                                            // ? match.location!.city
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
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
                                              // '${DateFormat('HH:mm').format(match.whenPlay)} hs',
                                              '21:00 hs',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              // '${DateFormat('MMMMd').format(match.whenPlay)}',
                                              'July 22',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.0,
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
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '6',
                                                  // (match.numPlayers - match.participants!.length).toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 4.0),
                                                Icon(
                                                  Icons.group_outlined,
                                                  color: Colors.white,
                                                  size: 18.0,
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
                          SizedBox(height: 12.0)
                        ],
                      )
                  ),
                  GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: boxDecoration,
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 85.0,
                              ),
                              Positioned(
                                top: 10.0,
                                right: 10.0,
                                child: Container(
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
                                    // match.type.vs!,
                                    '9 vs 9',
                                    style: TextStyle(
                                      // add a RGB color #8B9586
                                      color: Color(0xFF8B9586),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
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
                              color: Colors.green[400],
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 80.0,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // (booking != null)
                                      (false)
                                          ? Row(
                                        children: [
                                          // Text(
                                          //   booking.field!.name,
                                          //   style: TextStyle(
                                          //     color: Colors.white,
                                          //     fontSize: 12.0,
                                          //     fontWeight: FontWeight.bold,
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   width: 5.0,
                                          // ),
                                          // Text(
                                          //   booking.field!.address,
                                          //   style: TextStyle(
                                          //     color: Colors.white,
                                          //     fontSize: 12.0,
                                          //     fontWeight: FontWeight.normal,
                                          //   ),
                                          // ),
                                        ],
                                      ) : Row(
                                        children: [
                                          Text(
                                            // (match.location != null)
                                            (false)
                                                ? 'asdas'
                                            // ? match.location!.city
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
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
                                              // '${DateFormat('HH:mm').format(match.whenPlay)} hs',
                                              '21:00 hs',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              // '${DateFormat('MMMMd').format(match.whenPlay)}',
                                              'July 22',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.0,
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
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '6',
                                                  // (match.numPlayers - match.participants!.length).toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 4.0),
                                                Icon(
                                                  Icons.group_outlined,
                                                  color: Colors.white,
                                                  size: 18.0,
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
                          SizedBox(height: 12.0)
                        ],
                      )
                  )
                ],
              )
          ),
        ],
      ),
    );
  }
}

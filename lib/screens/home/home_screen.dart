import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/field.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/repositories/home_repository.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/screens/bookings/bookings_screen.dart';
import 'package:fulbito_app/screens/home/news_screen.dart';
import 'package:fulbito_app/screens/home/search_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fulbito_app/models/booking.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/user_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic search = '';
  bool isLoading = false;
  List<User?> players = [];
  List<Match?> matches = [];
  List<Field?> fields = [];
  List news = [];

  @override
  void initState() {
    super.initState();
    getHomeInfo();
  }

  Future getHomeInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (
      localStorage.containsKey('homeInfo-news') &&
      localStorage.containsKey('homeInfo-fields') &&
      localStorage.containsKey('homeInfo-matches')
    ) {

      final _news = json.decode(localStorage.getString('homeInfo-news')!);

      var thisFields = json.decode(localStorage.getString('homeInfo-fields')!);
      List fields = thisFields;
      thisFields = fields.map((match) => Field.fromJson(match)).toList();

      var thisMatches = json.decode(localStorage.getString('homeInfo-matches')!);
      List matches = thisMatches;
      thisMatches = matches.map((match) => Match.fromJson(match)).toList();

      setState(() {
        this.matches = thisMatches;
        this.fields = thisFields;
        this.news = _news;
      });

    } else {
      // get info from api
      final response = await HomeRepository().getInfo();

      if (response['message'] == 'Unauthenticated.') {
        return Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }

      if (response['success']) {
        setState(() {
          this.news = response['news'];
          this.fields = response['fields'];
          this.matches = response['matches'];
        });
      }
    }

  }

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
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => SearchScreen(),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
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
                                    bottom: 20.0, left: 10.0),
                                margin: EdgeInsets.only(top: 20.0),
                                width: _width,
                                height: _height,
                                child: ListView(
                                  padding: EdgeInsets.only(top: 10.0),
                                  children: [
                                    // latest news
                                    LatestNewsSection(),
                                    // play this matches
                                    PlayThisMatchesSection(),
                                    // book this fields
                                    BookThisFieldsSection(),
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

    bool showFields = false;

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
          showFields ? Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {

                if (this.fields.isEmpty) {
                  return Container();
                }
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

                DecorationImage decorationImage = DecorationImage(
                  image: AssetImage('assets/cancha-futbol-5.jpeg'),
                  fit: BoxFit.cover,
                );
                if (this.fields[index]!.image.isNotEmpty) {
                  decorationImage = DecorationImage(
                    image: NetworkImage(this.fields[index]!.image),
                    fit: BoxFit.cover,
                  );
                }

                Type? type = Type()
                    .matchTypes
                    .where(
                        (element) => element.id == this.fields[index]!.type!.id)
                    .first;

                return GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: decorationImage,
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
                                this.fields[index]!.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                this.fields[index]!.address,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: false,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                              type.vs!,
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
          ) : Container(
            margin: EdgeInsets.only(right: 10.0),
            height: 200.0,
            width: MediaQuery.of(context).size.width,
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
              child: Container(
                height: 200.0,
                child: Center(
                  child: Text(
                    'Coming soon...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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

                if (this.matches == []) {
                  return Container();
                }

                if (this.matches.length == 0) {
                  return Container();
                }

                Booking? booking = this.matches[index]!.booking;
                BoxDecoration boxDecoration = BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: AssetImage('assets/match_info_header.png'),
                    fit: BoxFit.cover,
                  ),
                );
                String? imageUrl = booking?.field!.image;
                if (imageUrl != null) {
                  boxDecoration = BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchInfoScreen(
                          match: this.matches[index]!,
                          calledFromMatchInfo: false,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10.0),
                        width: 200.0,
                        decoration: boxDecoration,
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
                              (booking != null)
                                  ? Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.field!.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      booking.field!.address,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              )
                                  : Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (this.matches[index]!.location != null)
                                          ? this.matches[index]!.location!.city
                                          : "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${DateFormat('HH:mm').format(this.matches[index]!.whenPlay)} hs',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('MMMMd').format(this.matches[index]!.whenPlay)}',
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
                                            (this.matches[index]!.numPlayers - this.matches[index]!.participants!.length).toString(),
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
                              this.matches[index]!.type.vs!,
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

}

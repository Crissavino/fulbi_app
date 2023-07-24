import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/field.dart';
import 'package:fulbito_app/models/player.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/home_repository.dart';
import 'package:fulbito_app/screens/home/home_screen.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/profile/public_profile_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Timer? _debounce;
  List<User?> users = [];
  List<Match?> matches = [];
  List<Field?> fields = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    Container _buildBackArrow(BuildContext context) {
      return Container(
        margin: EdgeInsets.only(
          top: 50.0,
          left: 10.0,
        ),
        child: IconButton(
          onPressed: () {
            // navigate to home screen
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => HomeScreen(),
                transitionDuration: Duration(seconds: 0),
              ),
            );
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      );
    }

    Widget _buildSearchInput() {
      final width = MediaQuery.of(context).size.width;

      return Container(
        height: 50.0,
        margin: EdgeInsets.only(top: 50.0, left: 60.0, right: 20.0),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 5),
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
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
            hintText: "${translations[localeName]!['search']!}...",
            hintStyle: kHintTextStyle,
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                this.users = [];
                this.fields = [];
                this.matches = [];
              });
              return;
            }
            setState(() {
              this.isLoading = true;
            });

            if (_debounce?.isActive ?? false) _debounce!.cancel();

            _debounce = Timer(const Duration(milliseconds: 1500), () async {
              final response = await HomeRepository().search(value);
              if (response['success']) {
                setState(() {
                  this.isLoading = false;
                  this.users = response['users'];
                  this.fields = response['fields'];
                  this.matches = response['matches'];
                });
              }

            });

          },
        ),
      );

    }

    _buildSearchResults() {
      if (this.isLoading) {
        return Container(
          margin: EdgeInsets.only(top: 110.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
              strokeWidth: 2.0,
            ),
          ),
        );
      }

      if (this.users.isEmpty && this.matches.isEmpty && this.fields.isEmpty) {
        return Container(
          margin: EdgeInsets.only(top: 110.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Text(
              'No results found',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        );
      }

      return Container(
        margin: EdgeInsets.only(top: 110.0),
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          padding: EdgeInsets.only(top: 20.0),
          children: [
            _buildFieldsResults(),
            _buildMatchesResults(),
            _buildPlayersResults(),
          ],
        ),
      );

    }

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            margin: EdgeInsets.only(top: 20.0),
            child: Stack(
              children: [
                _buildBackArrow(context),
                _buildSearchInput(),
                _buildSearchResults(),
              ],
            ),
          ),
        ),
      ),
    );

  }

  Column _buildFieldsResults() {

    if (this.fields.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fields',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0,),
          Center(
            child: Text(
              'No fields found',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fields',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: [
            // Field 1
            for (var field in this.fields) GestureDetector(
              onTap: () {},
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24.0,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/cancha-futbol-5.jpeg'),
                ),
                title: Text(field!.name),
                subtitle: Text(field.address),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column _buildMatchesResults() {

    if (this.matches.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translations[localeName]!['menu.matches']!,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0,),
          Center(
            child: Text(
              'No matches found',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translations[localeName]!['menu.matches']!,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: [
            // Field 1
            for (var match in this.matches) GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchInfoScreen(
                      match: match!,
                      calledFromMatchInfo: false,
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24.0,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/match_info_header.png'),
                ),
                title: Text(match!.name!),
                subtitle: Text(match.location!.city),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column _buildPlayersResults() {

    if (this.users.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translations[localeName]!['menu.players']!,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0,),
          Center(
            child: Text(
              'No players found',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translations[localeName]!['menu.players']!,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: [
            // Field 1
            for (var user in this.users) GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PublicProfileScreen(
                      userId: user!.id,
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24.0,
                  backgroundColor: Colors.white,
                  child: user!.profileImage == null
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
                title: Text(user.name),
                subtitle: Text(user.nickname),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/map_box_search_response.dart';
import 'package:fulbito_app/repositories/location_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/search/search_location_match.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';

class CompleteRegisterScreen extends StatefulWidget {
  const CompleteRegisterScreen({Key? key}) : super(key: key);

  @override
  _CompleteRegisterScreenState createState() => _CompleteRegisterScreenState();
}

class _CompleteRegisterScreenState extends State<CompleteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String localeName = Platform.localeName.split('_')[0];
  bool _male = false;
  bool _female = false;
  String userLocationDesc = '';
  var userLocationDetails;
  UserRepository _userRepository = UserRepository();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget _buildSearchLocationBar() {
      return GestureDetector(
        onTap: () async {
          final currentPosition = await LocationRepository().determinePosition();

          final Feature? result = await showSearch<Feature?>(
            context: context,
            delegate: SearchLocationMatch(
                calledFromCreate: true,
                myCurrentLocation: LatLng(currentPosition.latitude, currentPosition.longitude)
            ),
          );

          if (result != null) {
            final Feature place = result;
            final double latitude = result.center[1].toDouble();
            final double longitude = result.center[0].toDouble();
            var cityContext = place.context.firstWhereOrNull((Context con) {
              if (con.id!.contains('place')) {
                return true;
              } else if (con.id!.contains('district')) {
                return true;
              } else {
                return false;
              }
            });
            var city = place.placeName.split(',')[0];
            if (cityContext != null) {
              city = cityContext.text!;
            }
            final province = place.context
                .firstWhere((Context con) => con.id!.contains('region'))
                .text;
            final country = place.context
                .firstWhere((Context con) => con.id!.contains('country'))
                .text;

            this.userLocationDetails = {
              'lat': latitude,
              'lng': longitude,
              'formatted_address': place.placeName,
              'place_name': place.placeName,
              'place_id': null,
              'city': city,
              'province': province,
              'province_code': null,
              'country': country,
              'country_code': null,
              'is_by_lat_lng': true,
            };

            userLocationDesc = place.placeName;
            setState(() {});
          }
        },
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 50.0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 13.0,
            ),
            width: double.infinity,
            child: Text(
              userLocationDesc.isEmpty ? '${translations[localeName]!['general.location']!}...' : userLocationDesc,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    Widget _buildWhereToPlay() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 200.0,
                    child: Text(
                      translations[localeName]!['general.selectWhereToPlay']!,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    padding: EdgeInsets.only(
                      left: 15.0,
                    ),
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                    onPressed: () {
                      showAlert(
                        context,
                        translations[localeName]!['general.information']!,
                        translations[localeName]!['general.information.completeProfile.wherePlay']!,
                      );
                    },
                  ),
                ),
                _buildSearchLocationBar(),
              ],
            ),
          ),
        ],
      );
    }

    Widget _buildGender() {

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                ListTile(
                  leading: Text(
                    translations[localeName]!['general.genre']!,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    padding: EdgeInsets.only(
                      left: 15.0,
                    ),
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                    onPressed: () {
                      showAlert(
                        context,
                        translations[localeName]!['general.information']!,
                        translations[localeName]!['general.information.completeProfile.genre']!,
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          translations[localeName]!['general.genres.male']!,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GFCheckbox(
                      size: 35,
                      activeBgColor: Colors.green[400]!,
                      inactiveBorderColor: Colors.green[700]!,
                      activeBorderColor: Colors.green[700]!,
                      type: GFCheckboxType.circle,
                      value: _male,
                      inactiveIcon: null,
                      activeIcon: Icon(
                        Icons.sports_soccer,
                        size: 25,
                        color: Colors.white,
                      ),
                      onChanged: (value) {
                        if (!_female && !value) {
                          setState(() {
                            _male = true;
                          });
                        } else {
                          setState(() {
                            _male = !_male;
                            _female = false;
                          });
                        }
                      },
                    ),
                    SizedBox(width: 15.0,)
                  ],
                ),
                SizedBox(height: 20.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          translations[localeName]!['general.genres.female']!,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GFCheckbox(
                      size: 35,
                      activeBgColor: Colors.green[400]!,
                      inactiveBorderColor: Colors.green[700]!,
                      activeBorderColor: Colors.green[700]!,
                      type: GFCheckboxType.circle,
                      value: _female,
                      inactiveIcon: null,
                      activeIcon: Icon(
                        Icons.sports_soccer,
                        size: 25,
                        color: Colors.white,
                      ),
                      onChanged: (value) {
                        if (!_male && !value) {
                          setState(() {
                            _female = true;
                          });
                        } else {
                          setState(() {
                            _female = !_female;
                            _male = false;
                          });
                        }
                      },
                    ),
                    SizedBox(width: 15.0,)
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: Platform.isIOS
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                decoration: verticalGradient,
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 30.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // _buildPage1Title(),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildWhereToPlay(),
                            SizedBox(height: 20.0),
                            _buildGender(),
                          ],
                        ),
                      ),
                      SizedBox(height: 80.0),
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        width: mediaQuery.size.width * .40,
                        height: 50.0,
                        child: Center(
                          child: TextButton(
                            onPressed: this.isLoading ? null : () async {

                              if (userLocationDesc.isEmpty){
                                return showAlert(
                                  context,
                                  translations[localeName]!['attention']!,
                                  translations[localeName]!['attention.selectPlace']!,
                                );
                              } else if (!_male && !_female){
                                return showAlert(
                                  context,
                                  translations[localeName]!['attention']!,
                                  translations[localeName]!['attention.selectSex']!,
                                );
                              }

                              setState(() {
                                this.isLoading = true;
                              });

                              bool isMale = _male;
                              var genreId;
                              if(isMale) {
                                genreId = 1;
                              } else {
                                genreId = 2;
                              }

                              final completeUserProfileResponse = await _userRepository.completeUserProfile(
                                  userLocationDetails,
                                  genreId
                              );

                              if (completeUserProfileResponse['success'] == true) {
                                Navigator.pushReplacementNamed(context, 'intro');
                              } else {
                                setState(() {
                                  this.isLoading = false;
                                });
                                return showAlert(
                                  context,
                                  translations[localeName]!['error']!,
                                  translations[localeName]!['error.completeProfile']!,
                                );
                              }

                            },
                            child: this.isLoading ? circularLoading : Text(
                              translations[localeName]!['general.done']!.toUpperCase(),
                              style: TextStyle(
                                color: Color(0xFF527DAA),
                                letterSpacing: 1.5,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

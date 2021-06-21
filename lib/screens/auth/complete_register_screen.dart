import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/complete_profile/complete_profile_bloc.dart';
import 'package:fulbito_app/models/user_location.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/search/search_location.dart';
import 'package:fulbito_app/services/place_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

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
  late UserLocation userLocationDetails;
  UserRepository _userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget _buildSearchLocationBar() {
      return GestureDetector(
        onTap: () async {
          final Suggestion? result =
          await showSearch<Suggestion?>(context: context, delegate: SearchLocation());

          BlocProvider.of<CompleteProfileBloc>(context).add(
              ProfileCompleteUserLocationLoadedEvent()
          );

          if (result != null) {
            setState(() {
              userLocationDesc = result.description!;
              userLocationDetails = result.details!;
              userLocationDetails.placeId = result.placeId;
              userLocationDetails.formattedAddress = result.description;
            });
          }

        },
        child: BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
          builder: (BuildContext context, state) {

            if (state is ProfileCompleteLoadingUserLocationState) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    circularLoading
                  ],
                ),
              );
            }

            return Container(
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
            );
          },
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
        value: SystemUiOverlayStyle.light,
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
                            onPressed: () async {

                              BlocProvider.of<CompleteProfileBloc>(context).add(
                                  ProfileCompleteLoadingEvent()
                              );

                              if (userLocationDesc.isEmpty){
                                BlocProvider.of<CompleteProfileBloc>(context).add(
                                    ProfileCompleteErrorEvent()
                                );
                                return showAlert(
                                  context,
                                  'Atencion!',
                                  'Debes seleccionar algun lugar en el que usualmente juegas',
                                );
                              } else if (!_male && !_female){
                                BlocProvider.of<CompleteProfileBloc>(context).add(
                                    ProfileCompleteErrorEvent()
                                );
                                return showAlert(
                                  context,
                                  'Atencion!',
                                  'Debes seleccionar tu sexo',
                                );
                              }

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

                                BlocProvider.of<CompleteProfileBloc>(context).add(
                                    ProfileCompletedEvent()
                                );
                              } else {
                                BlocProvider.of<CompleteProfileBloc>(context).add(
                                    ProfileCompleteErrorEvent()
                                );
                                return showAlert(
                                  context,
                                  'Error!',
                                  'Ocurrió un error al completar el perfil!',
                                );
                              }

                            },
                            child: Text(
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

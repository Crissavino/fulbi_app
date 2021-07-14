import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/profile/profile_bloc.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/user_location.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/search/search_location.dart';
import 'package:fulbito_app/services/place_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';

// ignore: must_be_immutable
class YourLocation extends StatefulWidget {

  Location? userLocation;
  YourLocation({required this.userLocation});

  @override
  _YourLocationState createState() => _YourLocationState();
}

class _YourLocationState extends State<YourLocation> {
  String? userLocationDesc;
  UserLocation? userLocationDetails;

  @override
  void initState() {
    this.userLocationDesc = widget.userLocation!.formattedAddress;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    Widget _buildSearchLocationBar() {
      return GestureDetector(
        onTap: () async {
          final Suggestion? result =
          await showSearch<Suggestion?>(context: context, delegate: SearchLocation());

          BlocProvider.of<ProfileBloc>(context).add(
              ProfileUserLocationLoadedEvent()
          );
          if (result != null) {
            setState(() {
              userLocationDesc = result.description;
              userLocationDetails = result.details;
              userLocationDetails!.placeId = result.placeId;
              userLocationDetails!.formattedAddress = result.description;
            });
          }
        },
        child: Container(
          margin: EdgeInsets.only(top: 20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[600]!,
                Colors.blue[500]!,
                Colors.blue[500]!,
                Colors.blue[600]!,
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue[100]!,
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
            color: Colors.blue[400],
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          width: _width * .60,
          height: 50.0,
          child: Center(
            child: Text(
              'Cambiar ubicacion',
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

    return Container(
        height: _height / 1.1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
          ),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (BuildContext context, state) {

              if (state is ProfileLoadingState) {
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

              return Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // SizedBox(height: 30.0,),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        margin: EdgeInsets.only(
                          top: 40.0,
                        ),
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            userLocationDesc!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      // SizedBox(height: 50.0,),
                      _buildSearchLocationBar(),
                      Container(
                        height: 250.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
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
                              width: _width * .40,
                              height: 50.0,
                              child: Center(
                                child: TextButton(
                                  onPressed: () async {

                                    if (userLocationDetails == null) {
                                      return Navigator.pop(context);
                                    }

                                    BlocProvider.of<ProfileBloc>(context).add(
                                        ProfileLoadingEvent()
                                    );
                                    final editUserLocationResponse =
                                    await UserRepository().editUserLocation(
                                      userLocationDetails,
                                    );

                                    if (editUserLocationResponse['success'] == true) {
                                      Navigator.pop(context, true);

                                      BlocProvider.of<ProfileBloc>(context).add(
                                          ProfileCompleteEvent()
                                      );
                                    } else {
                                      BlocProvider.of<ProfileBloc>(context).add(
                                          ProfileErrorEvent()
                                      );
                                      return showAlert(
                                        context,
                                        'Error!',
                                        'Ocurrió un error al guardar tu ubicacion!',
                                      );
                                    }
                                  },
                                  child: Text(
                                    translations[localeName]!['general.save']!.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'OpenSans',
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  ModalTopBar()
                ],
              );
            },
          ),
        ),
    );
  }
}

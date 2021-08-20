import 'package:flutter/material.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/map_box_search_response.dart';
import 'package:fulbito_app/repositories/location_repository.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/search/search_location_match.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';

// ignore: must_be_immutable
class YourLocation extends StatefulWidget {

  Location? userLocation;
  YourLocation({required this.userLocation});

  @override
  _YourLocationState createState() => _YourLocationState();
}

class _YourLocationState extends State<YourLocation> {
  String? userLocationDesc;
  var userLocationDetails;
  bool isLoading = false;

  @override
  void initState() {
    this.userLocationDesc = widget.userLocation!.formattedAddress;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    Widget _buildSearchLocationBar() {
      return GestureDetector(
        onTap: () async {
          final currentPosition = await LocationRepository().determinePosition();

          Feature? result;
          if (currentPosition is Position) {
            result = await showSearch<Feature?>(
              context: context,
              delegate: SearchLocationMatch(
                calledFromCreate: true,
                myCurrentLocation: LatLng(currentPosition.latitude, currentPosition.longitude),
              ),
            );
          } else {
            result = await showSearch<Feature?>(
              context: context,
              delegate: SearchLocationMatch(
                calledFromCreate: true,
              ),
            );
          }

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
            final province = place.context.firstWhere((Context con) => con.id!.contains('region')).text;
            final country = place.context.firstWhere((Context con) => con.id!.contains('country')).text;

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
              translations[localeName]!['profile.location.change']!,
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
          child: Stack(
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
                            onPressed: this.isLoading ? null : () async {
                              if (userLocationDetails == null) {
                                return Navigator.pop(context);
                              }

                              setState(() {
                                this.isLoading = true;
                              });

                              final editUserLocationResponse =
                                  await UserRepository().editUserLocation(
                                userLocationDetails,
                              );

                              if (editUserLocationResponse['success'] == true) {
                                Navigator.pop(context, true);
                              } else {
                                setState(() {
                                  this.isLoading = false;
                                });
                                return showAlert(
                                  context,
                                  translations[localeName]!['error']!,
                                  translations[localeName]!['error.ops.saveLocation']!,
                                );
                              }
                            },
                            child: this.isLoading ? whiteCircularLoading : Text(
                              translations[localeName]!['general.save']!
                                  .toUpperCase(),
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
        ),
      ),
    );
  }
}

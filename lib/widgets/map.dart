import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fulbito_app/models/map_box_search_response.dart';
import 'package:fulbito_app/repositories/location_repository.dart';
import 'package:fulbito_app/screens/matches/create_match_screen.dart';
import 'package:fulbito_app/screens/matches/edit_match_screen.dart';
import 'package:fulbito_app/screens/search/search_location_match.dart';
import 'package:fulbito_app/services/map_box_service.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/manual_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fulbito_app/models/match.dart';

// ignore: must_be_immutable
class Map extends StatefulWidget {
  var currentPosition;
  bool calledFromCreate;
  Match? match;
  var editedValues;

  Map({
    Key? key,
    required this.currentPosition,
    required this.calledFromCreate,
    this.match,
    this.editedValues,
  }) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? centerPosition;
  late LatLng target;
  String userLocationDesc = '';
  var userLocationDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.target = LatLng(
        widget.currentPosition['latitude'],
        widget.currentPosition['longitude']
    );
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    Future<void> moveCamera(newLatLng) async {
      final GoogleMapController controller = await _controller.future;
      final cameraUpdate = CameraUpdate.newLatLng(newLatLng);
      controller.animateCamera(cameraUpdate);
    }

    GoogleMap _buildGoogleMap() {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
            target: this.target,
            zoom: 15.0
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onCameraMove: (CameraPosition position) {
          this.centerPosition = position.target;
        },
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
      );
    }

    Container _buildBackArrow(BuildContext context) {
      return Container(
        margin: EdgeInsets.only(top: 50.0, left: 10.0,),
        child: IconButton(
          onPressed: () {
            if (widget.match != null) {
              Match editedMatch = widget.match!;
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      EditMatchScreen(
                        match: editedMatch,
                        editedValues: widget.editedValues,
                      ),
                  transitionDuration: Duration(seconds: 0),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      CreateMatchScreen(),
                  transitionDuration: Duration(seconds: 0),
                ),
              );
            }
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      );
    }

    GestureDetector _buildSearchInput(context) {
      return GestureDetector(
        child: Container(
          margin: EdgeInsets.only(top: 50.0, left: 60.0, right: 20.0),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          width: double.infinity,
          child: Text(translations[localeName!]!['search']! + '...', style: TextStyle( color: Colors.black87 )),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 5))
              ]
          ),
        ),
        onTap: () async {
          final myLatLong = await LocationRepository().determinePosition();

          final Feature? result = await showSearch<Feature?>(
            context: context,
            delegate: SearchLocationMatch(
                calledFromCreate: true,
                myCurrentLocation: LatLng(myLatLong.latitude, myLatLong.longitude)
            ),
          );

          if (result != null) {
            setState(() {
              final double latitude = result.center[1].toDouble();
              final double longitude = result.center[0].toDouble();

              this.centerPosition = LatLng(latitude, longitude);

              moveCamera(this.centerPosition);
            });
          }
        },
      );
    }

    Positioned _buildSelectButton() {
      return Positioned(
        bottom: 50,
        left: 100,
        right: 100,
        child: Container(
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
          child: Center(
            child: TextButton(
              onPressed: () async {

                final MapBoxSearchResponse result = await MapBoxService().searchPlaceByQuery(
                  '${this.centerPosition?.longitude.toString()}, ${this.centerPosition?.latitude.toString()}',
                  LatLng(
                      widget.currentPosition['latitude'],
                      widget.currentPosition['longitude']
                  ),
                );

                if (result != null) {
                  final Feature place = result.features[0];
                  final double latitude = place.center[1].toDouble();
                  final double longitude = place.center[0].toDouble();

                  final city = place.context.firstWhere((Context con) => con.id.contains('place')).text;
                  final province = place.context.firstWhere((Context con) => con.id.contains('region')).text;
                  final country = place.context.firstWhere((Context con) => con.id.contains('country')).text;

                  this.userLocationDetails = {
                    'lat': latitude,
                    'lng': longitude,
                    'formatted_address': place.text,
                    'place_name': place.placeName,
                    'place_id': null,
                    'city': city,
                    'province': province,
                    'province_code': null,
                    'country': country,
                    'country_code': null,
                    'is_by_lat_lng': true,
                  };

                  if (widget.calledFromCreate) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            CreateMatchScreen(
                              manualSelection: true,
                              userLocationDesc: place.text,
                              userLocationDetails: this.userLocationDetails,
                            ),
                        transitionDuration: Duration(seconds: 0),
                      ),
                    );
                  } else {

                    if (widget.match != null) {
                      Match editedMatch = widget.match!;
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              EditMatchScreen(
                                match: editedMatch,
                                editedValues: widget.editedValues,
                                manualSelection: true,
                                userLocationDesc: place.text,
                                userLocationDetails: this.userLocationDetails,
                              ),
                          transitionDuration: Duration(seconds: 0),
                        ),
                      );
                    }

                  }
                }

              },
              child: Text(
                translations[localeName]!['general.select']!.toUpperCase(),
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
      );
    }

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            _buildGoogleMap(),
            ManualLocation(),
            _buildBackArrow(context),
            _buildSearchInput(context),
            _buildSelectButton(),
          ],
        ),
      ),
    );
  }

}
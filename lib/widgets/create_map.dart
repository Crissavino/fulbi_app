import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fulbito_app/screens/matches/create_match_screen.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/manual_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: must_be_immutable
class CreateMap extends StatefulWidget {
  Position currentPosition;
  bool calledFromCreate;

  CreateMap({Key? key, required this.currentPosition, required this.calledFromCreate}) : super(key: key);

  @override
  _CreateMapState createState() => _CreateMapState();
}

class _CreateMapState extends State<CreateMap> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? centerPosition;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      widget.currentPosition.latitude,
                      widget.currentPosition.longitude
                  ),
                  zoom: 15.0
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMove: (CameraPosition position) {
                this.centerPosition = position.target;
                print(position.target);
              },
            ),
            ManualLocation(),
            Container(
              margin: EdgeInsets.only(top: 20.0, left: 10.0,),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios),
              ),
            ),
            Positioned(
              bottom: 20,
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
                      if (widget.calledFromCreate) {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1,
                                animation2) =>
                                CreateMatchScreen(),
                            transitionDuration:
                            Duration(seconds: 0),
                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}
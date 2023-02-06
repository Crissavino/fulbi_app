import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/booking.dart';
import 'package:fulbito_app/models/field.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/repositories/booking_repository.dart';
import 'package:fulbito_app/screens/bookings/bookings_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/maps_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class BookingInfoScreen extends StatefulWidget {
  Booking booking;
  bool calledFromMyBookings;

  BookingInfoScreen({
    Key? key,
    required this.booking,
    required this.calledFromMyBookings,
  }) : super(key: key);

  @override
  State<BookingInfoScreen> createState() => _BookingInfoScreenState();
}

class _BookingInfoScreenState extends State<BookingInfoScreen> {
  StreamController bookingStreamController = StreamController.broadcast();
  StreamController notificationStreamController = StreamController.broadcast();
  Completer<GoogleMapController> _mapController = Completer();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    this.loadFromLocalStorage();
    this.getFutureData();
  }

  @override
  void dispose() {
    super.dispose();
    notificationStreamController.close();
    bookingStreamController.close();
  }

  void silentNotificationListener() {
    PushNotificationService.messageStream.listen((notificationData) {
      if (notificationData.containsKey('silentUpdateMatch')) {
        if (!bookingStreamController.isClosed)
          // response need to be Booking object
          bookingStreamController.sink.add(
            notificationData['response'],
          );
      }
      if (notificationData.containsKey('silentUpdateChat')) {
        if (!notificationStreamController.isClosed)
          notificationStreamController.sink.add(
            true,
          );
      }
    });
  }

  StreamBuilder<dynamic> buildNotificationStreamBuilder() {
    return StreamBuilder(
      initialData: widget.booking.haveNotifications,
      stream: notificationStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Stack(
            children: [
              Icon(Icons.chat_bubble_outline),
            ],
          );
        }

        bool areNotifications = snapshot.data;

        if (!areNotifications) {
          return Stack(
            children: [
              Icon(Icons.chat_bubble_outline),
            ],
          );
        }

        return Stack(
          children: [
            Icon(Icons.chat_bubble_outline),
            Positioned(
              top: 0.0,
              right: 0.0,
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future getFutureData() async {
    final response = await BookingRepository().getBooking(widget.booking.id);

    if (response['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('bookingInfo.booking.${widget.booking.id}',
          json.encode(json.encode(response['booking'])));

      Booking booking = response['booking'];
      if (!notificationStreamController.isClosed)
        notificationStreamController.sink.add(booking.haveNotifications);

      if (!bookingStreamController.isClosed)
        bookingStreamController.sink.add(booking);
    }

    return response;
  }

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    if (localStorage.containsKey('bookingInfo.booking.${widget.booking.id}')) {
      var thisBooking = json.decode(json.decode(
          localStorage.getString('bookingInfo.booking.${widget.booking.id}')!));
      Booking booking = Booking.fromJson(thisBooking);

      if (!bookingStreamController.isClosed)
        bookingStreamController.sink.add(booking);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              appBar: new PreferredSize(
                child: new Container(
                  decoration: horizontalGradient,
                  child: AppBar(
                    backwardsCompatibility: false,
                    systemOverlayStyle:
                        SystemUiOverlayStyle(statusBarColor: Colors.white),
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => BookingsScreen(),
                              ),
                            )
                            .then((_) => setState(() {}));
                      },
                      icon: Platform.isIOS
                          ? Icon(Icons.arrow_back_ios)
                          : Icon(Icons.arrow_back),
                      splashColor: Colors.transparent,
                    ),
                    title: Text(
                      'Reserva #${widget.booking.id}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [],
                  ),
                ),
                preferredSize: new Size(
                  MediaQuery.of(context).size.width,
                  70.0,
                ),
              ),
              resizeToAvoidBottomInset: false,
              body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: Platform.isIOS
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                child: Center(
                  child: _buildBookingStreamBuilder(),
                ),
              ),
              floatingActionButton: Container(
                margin: EdgeInsets.only(bottom: 50.0,),
                child: FloatingActionButton(
                  child: Icon(
                    (widget.booking.haveNotifications)
                        ? Icons.mark_chat_unread_outlined
                        : Icons.chat_bubble_outline,
                    size: 30.0,
                  ),
                  onPressed: () {},
                  backgroundColor: Colors.green[800]!,
                ),
              ),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
            ),
          )
        ],
      ),
    );
  }

  _buildBookingStreamBuilder() {
    return StreamBuilder(
      stream: bookingStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          this.isLoading = true;

          return Container(
            width: _width,
            height: _height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [circularLoading],
            ),
          );
        }

        this.isLoading = false;

        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return Container(
            width: _width,
            height: _height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [circularLoading],
            ),
          );
        }

        Booking booking = snapshot.data;
        if (booking.user == null) return Container();
        User user = booking.user!;
        Match match = booking.match!;
        Field field = booking.field!;
        String? currencySymbol = field.currency;

        this.isLoading = false;

        return Container(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 40.0,
                      bottom: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildBookingTitle(booking, field),
                        SizedBox(height: 20.0),
                        // _buildFirstRow(field),
                        _buildBookingPriceAndType(booking, field),
                        SizedBox(height: 20.0),
                        _buildBookingInfo(booking, field),
                        SizedBox(height: 10.0),
                        _buildBookingLocation(field),
                        Expanded(
                          child: Container(),
                        ),
                        _buildDeleteBooking(booking),
                        // _buildPlaysIn(location, _width),
                        // _buildPlaysOn(match),
                        // _buildMatchType(type),
                        // _buildMatchGenre(genre),
                        // _buildMatchCost(currencySymbol, match),
                        // _buildMatchSpots(spotsAvailable),
                        // _buildOwnerName(matchOwner),
                        // Expanded(
                        //   child: Container(),
                        // ),
                        // booking.message != null ? _buildMatchMessage(booking.message) : Container(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  _buildBookingLocation(Field field) {
    return Container(
      height: 300.0,
      child: GoogleMap(
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        // block the map
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            field.location!.lat,
            field.location!.lng,
          ),
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId(field.name),
            position: LatLng(
              field.location!.lat,
              field.location!.lng,
            ),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
      ),
    );
  }

  _buildFieldName(Field field) {
    return Container(
      child: Text(
        field.name,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  _buildFirstRow(Field field) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFieldName(field),
        Container(
          child: GestureDetector(
            onTap: () async {
              await MapsUtil.openMapApp(field.location!.lat, field.location!.lng);
            },
            child: Row(
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 20.0,
                  color: Colors.blueAccent,
                ),
                Text(
                  'Ver ruta',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildBookingTitle(Booking booking, Field field) {
    return Container(
      child: Text(
        'Reserva #${booking.id} | ${field.name}',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  _buildBookingInfo(Booking booking, Field field) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Icon(
                  Icons.watch_later_outlined,
                  size: 16.0,
                  color: Colors.black54,
                ),
              ),
              SizedBox(width: 5.0),
              Container(
                child: Text(
                  '${DateFormat('MMMMd').format(booking.when)} '
                      '| ${DateFormat('HH:mm').format(booking.when)}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              await MapsUtil.openMapApp(field.location!.lat, field.location!.lng);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.location_pin,
                  size: 16.0,
                  color: Colors.blueAccent,
                ),
                Text(
                  '${field.address}',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.blueAccent,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildBookingPriceAndType(Booking booking, Field field) {

    Type type = Type().matchTypes.where((type) => type.id == booking.type.id).first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Column(
            children: [
              Text(
                '${field.currency} ${booking.type.cost!.toDouble()}',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'valor total',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: [
              Text(
                '${type.vs}',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'modalidad',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildDeleteBooking(Booking booking) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: TextButton(
              onPressed: () async {
                // await _bookingService.deleteBooking(booking.id);
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar reserva',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

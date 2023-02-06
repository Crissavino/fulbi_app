import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/booking.dart';
import 'package:fulbito_app/models/field.dart';
import 'package:fulbito_app/repositories/booking_repository.dart';
import 'package:fulbito_app/repositories/field_repository.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/screens/bookings/booking_info_screen.dart';
import 'package:fulbito_app/screens/bookings/create_booking_screen.dart';
import 'package:fulbito_app/screens/bookings/field_filter.dart';
import 'package:fulbito_app/screens/bookings/field_info_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/custom_floating_action_button.dart';
import 'package:fulbito_app/widgets/user_menu.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<BookingsScreen> {
  List<Type> _searchedMatchType = Type().matchTypes;
  Map<String, double> _searchedRange = {'distance': 20.0};
  List fields = [];
  List myBookings = [];
  bool isLoading = false;
  StreamController fieldsStreamController = StreamController.broadcast();
  StreamController myBookingsStreamController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    loadFromLocalStorage();
    getMyBookings();
    getFieldsOffers(
      _searchedRange['distance']!.toInt(),
      _searchedMatchType.map((Type type) => type.id).toList(),
      true,
    );

    silentNotificationListener();
  }

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('bookingsScreen.fields') && localStorage.containsKey('bookingsScreen.areNotifications')) {
      var thisFields = json.decode(json.decode(localStorage.getString('bookingsScreen.fields')!));

      List fields = thisFields;
      thisFields = fields.map((field) => Field.fromJson(field)).toList();

      this.fields = thisFields;

      if (!fieldsStreamController.isClosed)
        fieldsStreamController.sink.add(
          this.fields,
        );
    }

    if (localStorage.containsKey('bookingsScreen.myBookings')) {
      var thisBookings = json.decode(json.decode(localStorage.getString('bookingsScreen.myBookings')!));

      List fields = thisBookings;
      thisBookings = fields.map((booking) => Booking.fromJson(booking)).toList();

      this.myBookings = thisBookings;

      if (!myBookingsStreamController.isClosed)
        myBookingsStreamController.sink.add(
          this.myBookings,
        );
    }
  }

  Future getMyBookings() async {
    final response = await BookingRepository().getMyBookings();
    if (response['success']) {
      setState(() {
        this.myBookings = response['bookings'];
      });
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var jsonBookings = this.myBookings.map((e) => json.encode(e)).toList();
      await localStorage.setString('matchesScreen.myBookings', json.encode(jsonBookings.toString()));

      if (!myBookingsStreamController.isClosed)
        myBookingsStreamController.sink.add(this.myBookings);

      return this.myBookings;
    }

    return response;
  }

  Future getFieldsOffers(int range, List<int?> types, calledFromInitState) async {
    final response = await FieldRepository().getFieldsOffers(range, types);
    if (response['message'] == 'Unauthenticated.') {
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }

    if (response['success']) {
      this.fields = response['fields'];

      await saveVariablesInLocalStorage();

      if (!fieldsStreamController.isClosed)
        fieldsStreamController.sink.add(
          this.fields,
        );
      return this.fields;
    }

    return response;
  }

  Future<void> saveVariablesInLocalStorage({bool isMyBooking = false}) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (isMyBooking) {
      var jsonMyBookings = this.myBookings.map((e) => json.encode(e)).toList();
      await localStorage.setString('bookingsScreen.myBookings', json.encode(jsonMyBookings.toString()));
    } else {
      var jsonFields = this.fields.map((e) => json.encode(e)).toList();
      await localStorage.setString('bookingsScreen.fields', json.encode(jsonFields.toString()));
    }
  }

  void silentNotificationListener() {
    PushNotificationService.messageStream.listen((notificationData) async {

      if (notificationData.containsKey('silentUpdateMyBookings')) {
        final int? bookingIdToDelete = int.tryParse(notificationData['bookingIdToDelete']);
        this.myBookings.removeWhere((booking) => booking!.id == bookingIdToDelete!);
        if (!myBookingsStreamController.isClosed)
          myBookingsStreamController.sink.add(this.myBookings);

        await saveVariablesInLocalStorage(isMyBooking: true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    fieldsStreamController.close();
    myBookingsStreamController.close();
  }

  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
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
                width: _width,
                height: _height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: 50.0,
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mis Reservas',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    buildMyBookingsStreamBuilder(),
                    Container(
                      margin: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Complejos',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildFilterButton(context)
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    buildFieldsStreamBuilder(),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: CustomFloatingActionButton(),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: UserMenu(
            isLoading: this.isLoading,
            currentIndex: 0,
          ),
        ),
      ),
    );
  }

  Container _buildFilterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(2, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 20.0,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(Icons.filter_list),
          iconSize: 24.0,
          color: Colors.black,
          onPressed: () async {
            List<Field?>? fields = await showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              enableDrag: true,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return FieldFilter(
                  searchedRange: this._searchedRange,
                  searchedMatchType: this._searchedMatchType,
                );
              },
            );

            if (fields != null) {
              this.fields = fields;
              if (!fieldsStreamController.isClosed)
                fieldsStreamController.sink.add(
                  this.fields,
                );
            }
          },
        ),
      ),
    );
  }

  buildFieldsStreamBuilder() {
    return StreamBuilder(
      stream: fieldsStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (snapshot.connectionState !=
            ConnectionState.done &&
            !snapshot.hasData) {

          this.isLoading = true;

          return Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              child: Container(
                width: _width,
                height: _height,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [circularLoading],
                ),
              ),
            ),
          );
        }

        this.isLoading = false;

        if (snapshot.connectionState ==
            ConnectionState.done &&
            !snapshot.hasData) {
          return Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              height: _height,
              child: Container(
                width: _width,
                height: _height,
                child: Center(
                    child:
                    Text(translations[localeName]!['general.noMatches']!)),
              ),
            ),
          );
        }

        List fields = snapshot.data;

        if (fields.isEmpty) {
          return Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              height: _height,
              child: Container(
                width: _width,
                height: _height,
                child: Center(
                    child:
                    Text(translations[localeName]!['general.noMatches']!)),
              ),
            ),
          );
        }

        List fieldsWithType = [];
        fields.forEach((field) {
          List types = field.types;
          types.forEach((type) {
            List fieldWithType = [];
            fieldWithType.add(field);
            _searchedMatchType.forEach((Type searchedType) {
              if (searchedType.id == type.id) {
                searchedType.cost = type.cost;
                fieldWithType.add(searchedType);
              }
            });

            fieldsWithType.add(fieldWithType);
          });
        });


        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
            ),
            width: _width,
            child: RefreshIndicator(
              onRefresh: () => this.getRefreshData(
                  this
                      ._searchedRange['distance']!
                      .toInt(),
                  this
                      ._searchedMatchType
                      .map((Type type) => type.id)
                      .toList(),
                  true
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: fieldsWithType.length,
                itemBuilder: (BuildContext _, int index) {
                  return _buildFieldRow(fieldsWithType[index][0], fieldsWithType[index][1]);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> getRefreshData(
      range,
      types,
      calledFromInitState
      ) async {

    final response = await FieldRepository().getFieldsOffers(range, types);

    if (response['success']) {
      this.fields = response['fields'];
      await saveVariablesInLocalStorage();

      if (!fieldsStreamController.isClosed)
        fieldsStreamController.sink.add(
          this.fields,
        );
    }
  }

  Widget _buildFieldRow(Field field, Type type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldInfoScreen(
              field: field,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: field.image != null
                    ? AssetImage(field.image)
                    : AssetImage('assets/cancha-futbol-5.jpeg'),
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
            ),
            width: MediaQuery.of(context).size.width,
            height: 85.0,
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
            width: MediaQuery.of(context).size.width,
            height: 75.0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (field.name != null) ? field.name : 'Cancha 1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              (field.address != null) ? field.address : 'Calle false 123',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
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
                            type.vs!,
                            style: TextStyle(
                              // add a RGB color #8B9586
                              color: Color(0xFF8B9586),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      ),
    );
  }

  buildMyBookingsStreamBuilder() {
    return StreamBuilder(
      stream: myBookingsStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (snapshot.connectionState !=
            ConnectionState.done &&
            !snapshot.hasData) {

          this.isLoading = true;

          return Container(
            width: _width,
            height: 100.0,
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              child: Container(
                width: _width,
                height: _height,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [circularLoading],
                ),
              ),
            ),
          );
        }

        this.isLoading = false;

        if (snapshot.connectionState ==
            ConnectionState.done &&
            !snapshot.hasData) {
          return Container(
            width: _width,
            height: 100.0,
            child: Container(
              padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              margin: EdgeInsets.only(top: 20.0),
              width: _width,
              child: Container(
                width: _width,
                height: _height,
                child: Center(
                    child:
                    Text(translations[localeName]!['general.noMatches']!)),
              ),
            ),
          );
        }

        List bookings = snapshot.data;

        if (bookings.isEmpty) {
          return Container(
            width: 260.0,
            height: 100.0,
            margin: EdgeInsets.only(left: 20.0),
            child: _buildMyBookingCardPlaceHolder(),
          );
        }

        return Container(
          width: _width,
          margin: EdgeInsets.only(left: 20.0),
          height: 100.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bookings.length,
            itemBuilder: (BuildContext _, int index) {
              return _buildMyBookingCard(bookings[index]);
            },
          ),
        );

      },
    );
  }

  Widget _buildMyBookingCardPlaceHolder() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              CreateBookingScreen(),
          transitionDuration: Duration(seconds: 0),
        ),);
      },
      child: Container(
        margin: EdgeInsets.only(
          right: 20.0,
          bottom: 20.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[500]!,
              Colors.green[400]!,
              Colors.green[400]!,
              Colors.green[500]!,
            ],
            stops: [0.1, 0.4, 0.7, 0.9],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(10, 6),
            ),
          ],
          color: Colors.green[400],
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        width: 260.0,
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Text('Crear reserva',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                Icons.add,
                color: Colors.white,
                size: 30.0,
              ),
              SizedBox(width: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyBookingCard(Booking booking) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingInfoScreen(
              booking: booking,
              calledFromMyBookings: false,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              right: 20.0,
              top: 5.0,
            ),
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
                  blurRadius: 8.0,
                  offset: Offset(6, 4),
                ),
              ],
              color: Colors.green[400],
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            height: 80.0,
            width: 260.0,
            child: Container(
              child: Row(
                children: [
                  SizedBox(width: 20.0),
                  CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.green[700],
                      size: 40.0,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${DateFormat('MMMd').format(booking.when)} '
                          '| ${DateFormat('HH:mm').format(booking.when)}',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          booking.haveNotifications ? _buildNotification() : Container(),
        ],
      ),
    );
  }

  Positioned _buildNotification() {
    return Positioned(
      top: 0.0,
      right: 14.0,
      child: Container(
        width: 30.0,
        height: 30.0,
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
    );
  }

}
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/currency.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/location.dart';
import 'package:fulbito_app/models/user_location.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/screens/matches/create_match_sex_modal.dart';
import 'package:fulbito_app/screens/matches/create_match_type_modal.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:fulbito_app/widgets/map.dart';

// ignore: must_be_immutable
class EditMatchScreen extends StatefulWidget {
  bool? manualSelection;
  String? userLocationDesc;
  var userLocationDetails;
  Match match;
  var editedValues;

  EditMatchScreen({
    Key? key,
    required this.match,
    this.manualSelection,
    this.userLocationDesc,
    this.userLocationDetails,
    this.editedValues,
  }) : super(key: key);

  @override
  _EditMatchScreenState createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends State<EditMatchScreen> {
  String userLocationDesc = '';
  var userLocationDetails;
  UserLocation? userLocation;
  String whenPlay = '';
  String description = '';
  List<Genre> matchGender = Genre().genres;
  List<Type> matchType = Type().matchTypes;
  double matchCost = 0.0;
  int playersForMatch = 0;
  List<Currency> currencies = Currency().currencies;
  String? currencySelected;
  Future? _future;
  bool isLoading = false;
  bool isFreeMatch = false;

  // controllers
  final _myNumPlayersController = TextEditingController();
  final _myMatchCostController = TextEditingController();
  final _descriptionController = TextEditingController();
  StreamController matchStreamController = StreamController.broadcast();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this._future = getMatch();
    if (widget.manualSelection == null) {
      this.matchType[0].checked = false;
      this.matchType[1].checked = false;
      this.matchType[2].checked = false;
      this.matchType[3].checked = false;

      this.matchGender[0].checked = false;
      this.matchGender[1].checked = false;
      this.matchGender[2].checked = false;
    }

    this._myNumPlayersController.text = widget.match.numPlayers.toString();
    this._myNumPlayersController.addListener(_printLatestPlayerForMatchValue);

    this._myMatchCostController.text = widget.match.cost.toString();
    this._myMatchCostController.addListener(_printLatestMatchCostValue);

    this._descriptionController.text = widget.match.description == null ? '' : widget.match.description.toString();
    this._descriptionController.addListener(_printDescriptionValue);
  }

  @override
  void dispose() {
    _myNumPlayersController.dispose();
    _myMatchCostController.dispose();
    _descriptionController.dispose();
    matchStreamController.close();
    super.dispose();
  }

  Future getMatch() async {
    final response = await MatchRepository().getMatch(widget.match.id);
    if (response['success'] && widget.manualSelection == null) {

      Location location = response['location'];
      // this.userLocationDesc = location.formattedAddress;
      this.userLocationDesc = '${location.lat.toStringAsFixed(3)} - ${location.lng.toStringAsFixed(3)}';
      this.userLocationDetails = {
        'lat': location.lat,
        'lng': location.lng,
        'formatted_address': location.formattedAddress,
        'place_name': location.formattedAddress,
        'place_id': null,
        'city': location.city,
        'province': location.province,
        'province_code': null,
        'country': location.country,
        'country_code': null,
        'is_by_lat_lng': true,
      };
      this.userLocation = UserLocation(
          country: location.country,
          countryCode: location.countryCode,
          province: location.province,
          provinceCode: location.provinceCode,
          placeId: location.placeId,
          formattedAddress: location.formattedAddress,
          city: location.city,
          lat: location.lat,
          lng: location.lng,
          isByLatLng: location.isByLatLng != null ? location.isByLatLng : false
      );
      Match match = response['match'];
      this.whenPlay = DateFormat('dd/MM/yyyy HH:mm').format(match.whenPlay);
      Genre genre = response['genre'];
      this.matchGender
          .firstWhereOrNull((gender) => gender.id == genre.id!)!
          .checked = true;
      Type type = response['type'];
      this.matchType.firstWhereOrNull((mType) => mType.id == type.id!)!.checked =
      true;
      this.currencySelected = response['currency'];

      dynamic toStream = {
        'match': match,
        'matchGender': this.matchGender,
        'matchType': this.matchType,
        'currencySelected': this.currencySelected,
        'userLocationDesc': this.userLocationDesc,
        'userLocationDetails': this.userLocationDetails,
        'userLocation': this.userLocation,
        'whenPlay': this.whenPlay,
        'playersForMatch': null,
      };

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add(
          toStream,
        );
    } else if (widget.manualSelection != null) {

      Match match = widget.match;
      this._descriptionController.text = match.description != null ? match.description! : '';
      this.isFreeMatch = widget.editedValues['isFreeMatch'];
      this.matchCost = widget.editedValues['matchCost'];
      this.matchGender = widget.editedValues['matchGender'];
      this.matchType = widget.editedValues['matchType'];
      this.userLocationDesc = widget.userLocationDesc!;
      this.userLocationDetails = widget.userLocationDetails!;
      this.userLocation = UserLocation(
          country: this.userLocationDetails['country'],
          countryCode: null,
          province: this.userLocationDetails['province'],
          provinceCode: null,
          placeId: null,
          formattedAddress: this.userLocationDetails['formatted_address'],
          city: this.userLocationDetails['city'],
          lat: this.userLocationDetails['lat'],
          lng: this.userLocationDetails['lng'],
          isByLatLng: true
      );
      this.currencySelected = widget.editedValues['currencySelected'];
      this.whenPlay = widget.editedValues['whenPlay'];
      this._myMatchCostController.text = this.matchCost.toString();
      this.playersForMatch = int.parse(widget.editedValues['playersForMatch']);
      this._myNumPlayersController.text = this.playersForMatch.toString();

      dynamic toStream = {
        'match': match,
        'matchGender': this.matchGender,
        'matchType': this.matchType,
        'currencySelected': this.currencySelected,
        'userLocationDesc': this.userLocationDesc,
        'userLocationDetails': this.userLocationDetails,
        'userLocation': this.userLocation,
        'whenPlay': this.whenPlay,
        'playersForMatch': this.playersForMatch,
      };

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add(
          toStream,
        );
    } else {
      dynamic toStream = {
        'error': true,
        'message': 'Something happened',
      };

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add(
          toStream,
        );
    }

  }

  StreamBuilder<dynamic> buildMatchStreamBuilder() {
    return StreamBuilder(
      stream: matchStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final _width = MediaQuery.of(context).size.width;
        final _height = MediaQuery.of(context).size.height;

        if (!snapshot.hasData) {
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

        bool? error = snapshot.data['error'];

        if (snapshot.error != null || error != null) {
          return Container(
            width: _width,
            height: _height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text(snapshot.data['message'])],
            ),
          );
        }

        List<Currency> currencies = Currency().currencies;

        Match match = snapshot.data['match'];
        widget.match = match;
        List<Genre> matchGender = snapshot.data['matchGender'];
        List<Type> matchType = snapshot.data['matchType'];
        String? currencySelected = snapshot.data['currencySelected'];
        String userLocationDesc = snapshot.data['userLocationDesc'];
        UserLocation? userLocation = snapshot.data['userLocation'];
        String whenPlay = snapshot.data['whenPlay'];
        int playersForMatch = snapshot.data['playersForMatch'] ?? 0;

        int playersEnrolled = match.participants!.length;

        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWherePlay(
                userLocationDesc,
                userLocation,
                playersForMatch,
                match,
                whenPlay,
                matchGender,
                matchType,
                currencySelected,
              ),
              _buildWhenPlay(context, match, whenPlay),
              _buildMatchSex(matchGender),
              _buildMatchType(matchType),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMatchCost(playersEnrolled, match, currencies, currencySelected),
                  _buildIsFreeMatch(playersEnrolled, match, currencies, currencySelected)
                ],
              ),
              _buildPlayerForMatch(),
              _buildMatchDescription(),
              SizedBox(height: 30.0,),
              _buildEditMatchButton(match)
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
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
                    title: Text(
                      translations[localeName]!['match.editMatch']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                  child: Container(
                    width: _width,
                    height: _height,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: (MediaQuery.of(context).viewInsets.bottom),
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: buildMatchStreamBuilder(),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWherePlay(
    userLocationDesc,
    userLocation,
    playersForMatch,
    Match match,
    whenPlay,
    matchGender,
    matchType,
    currencySelected,
  ) {
    final _width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () async {
        final myLatLong = {
          "latitude": userLocation!.lat,
          "longitude": userLocation!.lng
        };

        final playerForMatch = playersForMatch.toString() == '0'
            ? this._myNumPlayersController.text
            : playersForMatch.toString();

        final editedValues = {
          'isFreeMatch': match.isFreeMatch,
          'whenPlay': whenPlay,
          'matchGender': matchGender,
          'matchType': matchType,
          'matchCost': match.cost.toDouble(),
          'currencySelected': currencySelected,
          'playersForMatch': playerForMatch,
        };

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (
                context,
                animation1,
                animation2,
                ) =>
                Map(
                  match: match,
                  editedValues: editedValues,
                  currentPosition: myLatLong,
                  calledFromCreate: false,
                ),
            transitionDuration: Duration(
              seconds: 0,
            ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        width: _width,
        margin: EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        height: 60.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 13.0,
          ),
          width: _width,
          child: Row(
            children: [
              SizedBox(
                width: 20.0,
              ),
              Icon(
                Icons.location_on,
                size: 30.0,
                color: Colors.green[400],
              ),
              SizedBox(
                width: 20.0,
              ),
              userLocationDesc.isEmpty
                  ? Text(
                translations[localeName]!['match.wherePlay']!,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              )
                  : Expanded(
                child: Text(
                  userLocationDesc,
                  style: TextStyle(fontSize: 16.0),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _selectDate(BuildContext context, DateTime whenPlay) async {

    final DateTime today = whenPlay;

    final DateTime? picked = await showDatePicker(
      locale: Locale(localeName!),
      context: context,
      initialDate: today,
      firstDate: DateTime(2021, today.month),
      lastDate: DateTime(today.year + 1),
    );
    if (picked != null) {
      return picked;
    } else {
      return false;
    }
  }

  Future<dynamic> _selectTime(BuildContext context, DateTime whenPlay) async {

    TimeOfDay timeNow = TimeOfDay(
      hour: whenPlay.hour,
      minute: whenPlay.minute,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeNow,
    );
    if (picked != null) {
      return picked;
    } else {
      return false;
    }
  }

  Widget _buildWhenPlay(context, Match match, whenPlay) {
    final _width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        _selectDate(context, match.whenPlay).then((value) {
          if (value != false) {
            DateTime selectedDate = value;
            final day = selectedDate.day.toString().length == 1
                ? '0${selectedDate.day}'
                : selectedDate.day;
            final month = selectedDate.month.toString().length == 1
                ? '0${selectedDate.month}'
                : selectedDate.month;
            _selectTime(context, match.whenPlay).then((value) {
              if (value != false) {
                TimeOfDay selectedTime = value;
                final hour = selectedTime.hour.toString().length == 1
                    ? '0${selectedTime.hour}'
                    : selectedTime.hour;
                final minute = selectedTime.minute.toString().length == 1
                    ? '0${selectedTime.minute}'
                    : selectedTime.minute;

                this.whenPlay = '$day/$month/${selectedDate.year} $hour:$minute';
                dynamic toStream = {
                  'match': match,
                  'matchGender': this.matchGender,
                  'matchType': this.matchType,
                  'currencySelected': this.currencySelected,
                  'userLocationDesc': this.userLocationDesc,
                  'userLocationDetails': this.userLocationDetails,
                  'userLocation': this.userLocation,
                  'whenPlay': this.whenPlay,
                  'playersForMatch': this.playersForMatch,
                };

                if (!matchStreamController.isClosed)
                  matchStreamController.sink.add(
                    toStream,
                  );
              }
            });
          }
        });
      },
      child: Container(
        alignment: Alignment.centerLeft,
        width: _width,
        margin: EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        height: 60.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 13.0,
          ),
          width: _width,
          child: Row(
            children: [
              SizedBox(
                width: 20.0,
              ),
              Icon(
                Icons.calendar_today,
                size: 30.0,
                color: Colors.green[400],
              ),
              SizedBox(
                width: 20.0,
              ),
              whenPlay.isEmpty
                  ? Text(
                translations[localeName]!['match.whenPlay']!,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              )
                  : Expanded(
                child: Text(
                  whenPlay,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchSex(matchGender) {
    final _width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Container(
        width: _width,
        margin: EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Container(
            margin: EdgeInsets.only(
              left: 20.0,
            ),
            child: Text(
              translations[localeName]!['match.whichGenre']!,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_up_outlined,
            size: 40.0,
          ),
        ),
      ),
      onTap: () async {
        await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return CreateMatchSexModal(
              matchGender: matchGender,
            );
          },
        );
      },
    );
  }

  Widget _buildMatchType(matchType) {
    final _width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Container(
        width: _width,
        margin: EdgeInsets.only(top: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Container(
            margin: EdgeInsets.only(
              left: 20.0,
            ),
            child: Text(
              translations[localeName]!['match.whichTypes']!,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_up_outlined,
            size: 40.0,
          ),
        ),
      ),
      onTap: () async {
        await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          enableDrag: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return CreateMatchTypeModal(
              matchTypes: matchType,
            );
          },
        );
      },
    );
  }

  Widget _buildMatchCost(playersEnrolled, match, currencies, currencySelected) {
    final _width = MediaQuery.of(context).size.width;
    final allFree = match.isFreeMatch && currencySelected == null && match.cost.toDouble() == 0.0;
    Widget currencyWidget;

    if (allFree && playersEnrolled > 0) {
      currencySelected = currencies.first.code;
      print(currencySelected);
      currencyWidget = currencySelectBlocked(currencySelected!);
    } else if(allFree) {
      currencySelected = currencies.first.code;
      print(currencySelected);
      currencyWidget = currencySelectBlocked(currencySelected!);
    } else {
      currencyWidget = currencySelect(currencySelected, currencies);
    }

    return Container(
      alignment: Alignment.centerLeft,
      width: _width * .5,
      margin: EdgeInsets.only(top: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 60.0,
      child: Container(
        margin: EdgeInsets.only(
          left: 25.0,
        ),
        width: _width,
        child: Container(
          child: TextFormField(
            controller: this._myMatchCostController,
            enabled: playersEnrolled > 0 || match.isFreeMatch
                ? false
                : true,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: currencyWidget,
              ),
              hintText: translations[localeName]!['match.create.cost']!,
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ),
    );
  }

  void _printLatestMatchCostValue() {
    if (this._myMatchCostController.text.isNotEmpty) {
      if (this._myMatchCostController.text.contains(',')) {
        this.matchCost = double.parse(this._myMatchCostController.text.replaceFirst(RegExp(','), '.'));
      } else {
        this.matchCost = double.parse(this._myMatchCostController.text);
      }

      Match match = widget.match;
      match.cost = this.matchCost;
      if (this.currencySelected == null) {
        this.currencySelected = this.currencies.first.code;
        match.currencyId = this.currencies.first.id;
      }

      dynamic toStream = {
        'match': match,
        'matchGender': this.matchGender,
        'matchType': this.matchType,
        'currencySelected': this.currencySelected,
        'userLocationDesc': this.userLocationDesc,
        'userLocationDetails': this.userLocationDetails,
        'userLocation': this.userLocation,
        'whenPlay': this.whenPlay,
        'playersForMatch': this.playersForMatch,
      };

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add(
          toStream,
        );
    } else {
      this.matchCost = 0.0;
    }
  }

  Widget currencySelectBlocked(String currencySelected) {
    return DropdownButton<String>(
      value: currencySelected,
      iconSize: 20,
      elevation: 16,
      style: TextStyle(color: Colors.green[400], fontSize: 30.0),
      underline: Container(
        height: 0,
        color: Colors.transparent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          currencySelected = newValue!;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: currencySelected,
          child: Text(currencySelected),
        )
      ],
    );
  }

  Widget currencySelect(currencySelected, currencies) {
    return DropdownButton<String>(
      value: currencySelected,
      iconSize: 20,
      elevation: 16,
      style: TextStyle(color: Colors.green[400], fontSize: 30.0),
      underline: Container(
        height: 0,
        color: Colors.transparent,
      ),
      onChanged: (String? newValue) {
        currencySelected = newValue!;
        this.currencySelected = newValue;
        setState(() {});
      },
      items: currencies.map<DropdownMenuItem<String>>((Currency currency) {
        return DropdownMenuItem<String>(
          value: currency.code,
          child: Text(currency.code!),
        );
      }).toList(),
    );
  }

  Widget _buildIsFreeMatch(playersEnrolled, match, currencies, currencySelected) {
    final _width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.centerLeft,
      width: _width * .35,
      margin: EdgeInsets.only(top: 20.0, right: 10.0),
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            translations[localeName]!['general.free']!,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          GFCheckbox(
            size: 35,
            activeBgColor: Colors.green[400]!,
            inactiveBorderColor: Colors.green[700]!,
            activeBorderColor: Colors.green[700]!,
            type: GFCheckboxType.circle,
            activeIcon: Icon(
              Icons.sports_soccer,
              size: 25,
              color: Colors.white,
            ),
            onChanged: (value) {
              if (playersEnrolled > 0) return;
              match.isFreeMatch = value;
              if (!match.isFreeMatch && currencySelected == null) {
                currencySelected = currencies.first.code;
              }
              if (match.isFreeMatch) {
                this._myMatchCostController.text = '0.0';
                match.cost = 0.0;
                currencySelected = currencies.first.code;
              }

              dynamic toStream = {
                'match': match,
                'matchGender': this.matchGender,
                'matchType': this.matchType,
                'currencySelected': currencySelected,
                'userLocationDesc': this.userLocationDesc,
                'userLocationDetails': this.userLocationDetails,
                'userLocation': this.userLocation,
                'whenPlay': this.whenPlay,
                'playersForMatch': this.playersForMatch,
              };

              if (!matchStreamController.isClosed)
                matchStreamController.sink.add(
                  toStream,
                );
            },
            value: match.isFreeMatch,
            inactiveIcon: null,
          )
        ],
      ),
    );
  }

  Widget _buildPlayerForMatch() {
    final _width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.centerLeft,
      width: _width,
      margin: EdgeInsets.only(top: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 60.0,
      child: Container(
        margin: EdgeInsets.only(
          left: 25.0,
        ),
        width: _width,
        child: Container(
          child: TextFormField(
            controller: this._myNumPlayersController,
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Container(
                margin: EdgeInsets.only(left: 10.0, right: 20.0),
                child: Icon(
                  Icons.person_add,
                  size: 30.0,
                  color: Colors.green[400],
                ),
              ),
              hintText:
              translations[localeName]!['match.create.playerForMatch']!,
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ),
    );
  }

  void _printLatestPlayerForMatchValue() {
    if (this._myNumPlayersController.text.isNotEmpty) {
      this.playersForMatch = int.parse(this._myNumPlayersController.text);

      Match match = widget.match;

      dynamic toStream = {
        'match': match,
        'matchGender': this.matchGender,
        'matchType': this.matchType,
        'currencySelected': this.currencySelected,
        'userLocationDesc': this.userLocationDesc,
        'userLocationDetails': this.userLocationDetails,
        'userLocation': this.userLocation,
        'whenPlay': this.whenPlay,
        'playersForMatch': this.playersForMatch,
      };

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add(
          toStream,
        );
    } else {
      this.playersForMatch = 0;
    }
  }

  Widget _buildMatchDescription() {
    final _width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.centerLeft,
      width: _width,
      margin: EdgeInsets.only(top: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 100.0,
      child: Container(
        margin: EdgeInsets.only(
          left: 25.0,
        ),
        width: _width,
        height: 160.0,
        child: Container(
          child: TextFormField(
            controller: this._descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              hintText:
              '${translations[localeName]!['match.create.otherInfo']!} (${translations[localeName]!['general.optional']!})',
              hintStyle: kHintTextStyle,
            ),
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() {
                  this.description = val;
                });
              } else {
                setState(() {
                  this.description = '';
                });
              }
            },
          ),
        ),
      ),
    );
  }

  void _printDescriptionValue() {
    if (this._descriptionController.text.isNotEmpty) {
      this.description = this._descriptionController.text;

      widget.match.description = this.description;
      Match match = widget.match;

      dynamic toStream = {
        'match': match,
        'matchGender': this.matchGender,
        'matchType': this.matchType,
        'currencySelected': this.currencySelected,
        'userLocationDesc': this.userLocationDesc,
        'userLocationDetails': this.userLocationDetails,
        'userLocation': this.userLocation,
        'whenPlay': this.whenPlay,
        'playersForMatch': this.playersForMatch,
      };

      if (!matchStreamController.isClosed)
        matchStreamController.sink.add(
          toStream,
        );
    } else {
      this.description = '0';
    }
  }

  Widget _buildEditMatchButton(Match match) {
    final _width = MediaQuery.of(context).size.width;

    return Container(
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
            if (this.userLocationDesc == '') {
              return showAlert(
                context,
                translations[localeName]!['attention']!,
                translations[localeName]!['attention.selectMatchPlace']!,
              );
            }

            if (this.whenPlay == '') {
              return showAlert(
                context,
                translations[localeName]!['attention']!,
                translations[localeName]!['attention.selectMatchDate']!,
              );
            }

            if (!match.isFreeMatch && match.cost.round() == 0) {
              return showAlert(
                context,
                translations[localeName]!['attention']!,
                translations[localeName]!['attention.match.cost']!,
              );
            }

            if (this._myNumPlayersController.text.toString() == '0' || this._myNumPlayersController.text.isEmpty) {
              return showAlert(
                context,
                translations[localeName]!['attention']!,
                translations[localeName]!['attention.match.atLeastOnePlayer']!,
              );
            }

            setState(() {
              this.isLoading = true;
            });

            int? genreId = this.matchGender.firstWhereOrNull((Genre genre) {
              bool? isChecked = genre.checked;
              if (isChecked == null) {
                return false;
              }
              return isChecked;
            })!.id;

            int? typeId = this.matchType.firstWhereOrNull((Type type) {
              bool? isChecked = type.checked;
              if (isChecked == null) {
                return false;
              }
              return isChecked;
            })!.id;

            int? currencyId = this
                .currencies
                .firstWhereOrNull((Currency currency) =>
            currency.code == this.currencySelected)!
                .id;

            final response = await MatchRepository().edit(
              match.id,
              this.userLocationDetails,
              this.whenPlay,
              genreId!,
              typeId!,
              currencyId!,
              match.cost,
              int.parse(this._myNumPlayersController.text),
              match.isFreeMatch,
              this._descriptionController.text.isEmpty ? null : this._descriptionController.text
            );

            if (response['success']) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyMatchesScreen(),
                ),
              );
            } else {
              setState(() {
                this.isLoading = false;
              });
              return showAlert(
                context,
                translations[localeName]!['error']!,
                translations[localeName]!['error.ops']!,
              );
            }
          },
          child: this.isLoading ? whiteCircularLoading : Text(
            translations[localeName]!['general.edit']!.toUpperCase(),
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
}

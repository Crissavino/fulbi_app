
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
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(
    hour: DateTime.now().hour,
    minute: DateTime.now().minute,
  );
  String whenPlay = '';
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
      this._myNumPlayersController.text = widget.match.numPlayers.toString();
      this._myNumPlayersController.addListener(_printLatestPlayerForMatchValue);

      this._myMatchCostController.text = widget.match.cost.toString();
      this._myMatchCostController.addListener(_printLatestMatchCostValue);

    }
  }

  @override
  void dispose() {
    _myNumPlayersController.dispose();
    _myMatchCostController.dispose();
    super.dispose();
  }

  Future getMatch() async {
    final response = await MatchRepository().getMatch(widget.match.id);
    if (response['success'] && widget.manualSelection == null) {
      setState(() {
        Location location = response['location'];
        this.userLocationDesc = location.formattedAddress;
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
        this.isFreeMatch = match.isFreeMatch;
        this.whenPlay = DateFormat('dd/MM/yyyy HH:mm').format(match.whenPlay);
        Genre genre = response['genre'];
        this
            .matchGender
            .firstWhereOrNull((gender) => gender.id == genre.id!)!
            .checked = true;

        Type type = response['type'];
        this.matchType.firstWhereOrNull((mType) => mType.id == type.id!)!.checked =
            true;

        String currencySymbol = response['currency'];
        this.currencySelected = currencySymbol;
        this.matchCost = match.cost.toDouble();
      });
    } else if (widget.manualSelection != null) {
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
      this.isFreeMatch = widget.editedValues['isFreeMatch'];
      this.whenPlay = widget.editedValues['whenPlay'];
      this.matchGender = widget.editedValues['matchGender'];
      this.matchType = widget.editedValues['matchType'];
      this.matchCost = widget.editedValues['matchCost'];
      this._myMatchCostController.text = this.matchCost.toString();
      this.currencySelected = widget.editedValues['currencySelected'];
      this.playersForMatch = int.parse(widget.editedValues['playersForMatch']);
      this._myNumPlayersController.text = this.playersForMatch.toString();
    }

    return response;
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
                      child: FutureBuilder(
                        future: this._future,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
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

                          int playersEnrolled =
                              widget.match.participants!.length;

                          return SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                _buildWherePlay(),
                                _buildWhenPlay(context),
                                _buildMatchSex(),
                                _buildMatchType(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildMatchCost(playersEnrolled),
                                    _buildIsFreeMatch(playersEnrolled)
                                  ],
                                ),
                                _buildPlayerForMatch(),
                                SizedBox(height: 30.0,),
                                _buildEditMatchButton(widget.match.id)
                              ],
                            ),
                          );
                        },
                      ),
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

  Widget _buildWherePlay() {
    final _width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () async {
        final myLatLong = {
          "latitude": userLocation!.lat,
          "longitude": userLocation!.lng
        };

        final playerForMatch = this.playersForMatch.toString() == '0'
            ? this._myNumPlayersController.text
            : this.playersForMatch.toString();

        final editedValues = {
          'isFreeMatch': this.isFreeMatch,
          'whenPlay': this.whenPlay,
          'matchGender': this.matchGender,
          'matchType': this.matchType,
          'matchCost': this.matchCost,
          'currencySelected': this.currencySelected,
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
              match: widget.match,
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

  Future<bool> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: Locale(localeName!),
      context: context,
      initialDate: this.selectedDate,
      firstDate: DateTime(2021, this.selectedDate.month),
      lastDate: DateTime(this.selectedDate.year + 1),
    );
    if (picked != null) {
      setState(() {
        this.selectedDate = picked;
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: this.selectedTime,
    );
    if (picked != null) {
      setState(() {
        this.selectedTime = picked;
      });
      return true;
    } else {
      return false;
    }
  }

  Widget _buildWhenPlay(context) {
    final _width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () async {
        _selectDate(context).then((value) {
          if (value) {
            _selectTime(context).then((value) {
              if (value) {
                final day = this.selectedDate.day.toString().length == 1
                    ? '0${this.selectedDate.day}'
                    : this.selectedDate.day;
                final month = this.selectedDate.month.toString().length == 1
                    ? '0${this.selectedDate.month}'
                    : this.selectedDate.month;
                final hour = this.selectedTime.hour.toString().length == 1
                    ? '0${this.selectedTime.hour}'
                    : this.selectedTime.hour;
                final minute = this.selectedTime.minute.toString().length == 1
                    ? '0${this.selectedTime.minute}'
                    : this.selectedTime.minute;

                this.whenPlay =
                    '$day/$month/${this.selectedDate.year} $hour:$minute';
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
              this.whenPlay.isEmpty
                  ? Text(
                      translations[localeName]!['match.whenPlay']!,
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    )
                  : Expanded(
                      child: Text(
                        this.whenPlay,
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

  Widget _buildMatchSex() {
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
              matchGender: this.matchGender,
            );
          },
        );
      },
    );
  }

  Widget _buildMatchType() {
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
              matchTypes: this.matchType,
            );
          },
        );
      },
    );
  }

  void _printLatestMatchCostValue() {
    if (this._myMatchCostController.text.isNotEmpty) {
      if (this._myMatchCostController.text.contains(',')) {
        this.matchCost = double.parse(this._myMatchCostController.text.replaceFirst(RegExp(','), '.'));
      } else {
        this.matchCost = double.parse(this._myMatchCostController.text);
      }
    } else {
      this.matchCost = 0;
    }
    print('this.matchCost');
    print(this.matchCost);
  }

  Widget _buildMatchCost(playersEnrolled) {
    final _width = MediaQuery.of(context).size.width;
    final allFree = this.isFreeMatch && this.currencySelected == null && this.matchCost == 0.0;
    Widget currencyWidget;

    if (allFree && playersEnrolled > 0) {
      this.currencySelected = this.currencies.first.code;
      currencyWidget = currencySelectBlocked();
    } else if(allFree) {
      this.currencySelected = this.currencies.first.code;
      currencyWidget = currencySelectBlocked();
    } else {
      currencyWidget = currencySelect();
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
            enabled: playersEnrolled > 0 || this.isFreeMatch
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

  Widget currencySelectBlocked() {
    return DropdownButton<String>(
        value: this.currencySelected,
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
            value: this.currencySelected,
            child: Text(this.currencySelected!),
          )
        ],
    );
  }

  Widget currencySelect() {
    return DropdownButton<String>(
      value: this.currencySelected,
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
      items: this.currencies.map<DropdownMenuItem<String>>((Currency currency) {
        return DropdownMenuItem<String>(
          value: currency.code,
          child: Text(currency.code!),
        );
      }).toList(),
    );
  }

  Widget _buildIsFreeMatch(playersEnrolled) {
    final _width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.centerLeft,
      width: _width * .35,
      margin: EdgeInsets.only(top: 20.0, right: 10.0),
      height: 60.0,
      child: GFCheckboxListTile(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              translations[localeName]!['general.free']!,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        size: 35,
        activeBgColor: Colors.green[400]!,
        inactiveBorderColor: Colors.green[700]!,
        activeBorderColor: Colors.green[700]!,
        type: GFCheckboxType.circle,
        padding: EdgeInsets.all(0),
        activeIcon: Icon(
          Icons.sports_soccer,
          size: 25,
          color: Colors.white,
        ),
        onChanged: (value) {
          if (playersEnrolled > 0) return;
          this.isFreeMatch = !this.isFreeMatch;
          if (!this.isFreeMatch && this.currencySelected == null) {
            this.currencySelected = this.currencies.first.code;
          }
          if (this.isFreeMatch) {
            this._myMatchCostController.text = '0.0';
            this.matchCost = 0.0;
            this.currencySelected = this.currencies.first.code;
          }
          setState(() {});
        },
        value: this.isFreeMatch,
        inactiveIcon: null,
      ),
    );
  }

  void _printLatestPlayerForMatchValue() {
    if (this._myNumPlayersController.text.isNotEmpty) {
      this.playersForMatch = int.parse(this._myNumPlayersController.text);
    } else {
      this.playersForMatch = 0;
    }
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

  Widget _buildEditMatchButton(matchId) {
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

            if (!this.isFreeMatch && this.matchCost.round() == 0) {
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
              matchId,
              this.userLocationDetails,
              this.whenPlay,
              genreId!,
              typeId!,
              currencyId!,
              this.matchCost,
              int.parse(this._myNumPlayersController.text),
              this.isFreeMatch,
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

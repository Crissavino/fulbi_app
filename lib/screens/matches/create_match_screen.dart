
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/complete_profile/complete_profile_bloc.dart';
import 'package:fulbito_app/models/currency.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:fulbito_app/models/user_location.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/screens/matches/create_match_sex_modal.dart';
import 'package:fulbito_app/screens/matches/create_match_type_modal.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/screens/search/search_location.dart';
import 'package:fulbito_app/services/place_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:collection/collection.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({Key? key}) : super(key: key);

  @override
  _CreateMatchScreenState createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  String userLocationDesc = '';
  UserLocation? userLocationDetails;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.matchType[1].checked = false;
    this.matchType[2].checked = false;
    this.matchType[3].checked = false;
    this.currencySelected = currencies.first.code;
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
                      'Crear partido',
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
                value: SystemUiOverlayStyle.light,
                child: Center(
                  child: Container(
                    width: _width,
                    height: _height,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: (MediaQuery.of(context).viewInsets.bottom)),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildWherePlay(),
                            _buildWhenPlay(),
                            _buildMatchSex(),
                            _buildMatchType(),
                            _buildMatchCost(),
                            _buildPlayerForMatch(),
                            SizedBox(height: 30.0,),
                            _buildCreateMatchButton()
                          ],
                        ),
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
        final Suggestion? result = await showSearch<Suggestion?>(
            context: context, delegate: SearchLocation());

        BlocProvider.of<CompleteProfileBloc>(context)
            .add(ProfileCompleteUserLocationLoadedEvent());

        if (result != null) {
          setState(() {
            this.userLocationDesc = result.description != null
                ? result.description!
                : '${result.details!.lat.toString()} ${result.details!.lng.toString()}';
            this.userLocationDetails = result.details!;
            this.userLocationDetails!.isByLatLng = result.description != null
                ? false
                : true;
            this.userLocationDetails!.placeId = result.placeId;
            this.userLocationDetails!.formattedAddress = result.description;
          });
        }
      },
      child: Container(
        alignment: Alignment.centerLeft,
        width: _width * .95,
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
      print(picked);
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

  Widget _buildWhenPlay() {
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
        width: _width * .95,
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
        width: _width * .95,
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
        width: _width * .95,
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

  Widget _buildMatchCost() {
    final _width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.centerLeft,
      width: _width * .95,
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
        margin: EdgeInsets.only(left: 25.0,),
        width: _width,
        child: Container(
          child: TextFormField(
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
                child: currencySelect(),
              ),
              hintText: translations[localeName]!['match.create.aproxCost']!,
              hintStyle: kHintTextStyle,
            ),
            onChanged: (val) {
              if (val.contains(',')) val = val.replaceFirst(RegExp(','), '.');
              if (val.isNotEmpty) {
                setState(() {
                  this.matchCost = double.parse(val);
                });
              } else {
                this.matchCost = 0.0;
              }
            },
          ),
        ),
      ),
    );
  }

  currencySelect() {
    return DropdownButton<String>(
      value: currencySelected,
      iconSize: 20,
      elevation: 16,
      style: TextStyle(
          color: Colors.green[400],
        fontSize: 30.0
      ),
      underline: Container(
        height: 0,
        color: Colors.transparent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          currencySelected = newValue!;
        });
      },
      items: this.currencies
          .map<DropdownMenuItem<String>>((Currency currency) {
          return DropdownMenuItem<String>(
            value: currency.code,
            child: Text(currency.code!),
          );
      }).toList(),
    );
  }

  Widget _buildPlayerForMatch() {
    final _width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.centerLeft,
      width: _width * .95,
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
        margin: EdgeInsets.only(left: 25.0,),
        width: _width,
        child: Container(
          child: TextFormField(
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
              hintText: translations[localeName]!['match.create.playerForMatch']!,
              hintStyle: kHintTextStyle,
            ),
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() {
                  this.playersForMatch = int.parse(val);
                });
              } else {
                setState(() {
                  this.playersForMatch = 0;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCreateMatchButton() {
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
          onPressed: () async {
            if (this.userLocationDesc == '') {
              return showAlert(
                context,
                'Atencion!',
                'Debes indicar el lugar donde se juega el partido',
              );
            }

            if (this.whenPlay == '') {
              return showAlert(
                context,
                'Atencion!',
                'Debes indicar cuando se va a jugar el partido',
              );
            }

            if (this.matchCost.round() == 0) {
              return showAlert(
                context,
                'Atencion!',
                'Debes indicar el costo aproximado',
              );
            }

            if (this.playersForMatch == 0) {
              return showAlert(
                context,
                'Atencion!',
                'Debes indicar al menos un jugador para el partido',
              );
            }

            final locationData = {
              'lat': this.userLocationDetails!.lat,
              'lng': this.userLocationDetails!.lng,
              'formatted_address': this.userLocationDetails!.formattedAddress == null
                  ? this.userLocationDesc
                  : this.userLocationDetails!.formattedAddress,
              'place_id': this.userLocationDetails!.placeId,
              'city': this.userLocationDetails!.city,
              'province': this.userLocationDetails!.province,
              'province_code': this.userLocationDetails!.provinceCode,
              'country': this.userLocationDetails!.country,
              'country_code': this.userLocationDetails!.countryCode,
              'is_by_lat_lng': this.userLocationDetails!.isByLatLng,
            };

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

            int? currencyId = this.currencies.firstWhereOrNull((Currency currency) => currency.code == this.currencySelected)!.id;

            final response = await MatchRepository().create(
              locationData,
              this.whenPlay,
              genreId!,
              typeId!,
              currencyId!,
              this.matchCost,
              this.playersForMatch,
            );

            if (response['success']) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyMatchesScreen(),
                ),
              );
            } else {
              return showAlert(
                context,
                'Error',
                'Ooops, ocurrió un error',
              );
            }
          },
          child: Text(
            translations[localeName]!['general.create']!.toUpperCase(),
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

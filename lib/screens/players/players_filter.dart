import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:fulbito_app/models/position.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/players/players_filter_positions.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

// ignore: must_be_immutable
class PlayersFilter extends StatefulWidget {
  List<Position> searchedPositions;
  List<Genre> searchedGender;
  Map<String, double> searchedRange;

  PlayersFilter({
    required this.searchedPositions,
    required this.searchedGender,
    required this.searchedRange,
  });

  @override
  _PlayersFilterState createState() => _PlayersFilterState();
}

class _PlayersFilterState extends State<PlayersFilter> {
  // text field state
  String localeName = Platform.localeName.split('_')[0];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Container(
        height: _height / 1.1,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 10.0),
                _buildName(),
                // SizedBox(height: 5.0),
                _buildFilterDistance(),
                // SizedBox(height: 5.0),
                _buildFilterBySex(),
                SizedBox(height: 5.0),
                // _buildFilterDaysAvailable(),
                // SizedBox(height: 5.0),
                _buildFilterPositions(),
                // SizedBox(height: 5.0),
                _buildFilterButton(),
                SizedBox(height: 10.0),
              ],
            ),
            ModalTopBar()
          ],
        ));
  }

  _buildName() {
    return Text(
      translations[localeName]!['players.filterPlayer']!,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Nunito',
        fontSize: 30.0,
      ),
    );
  }

  _buildFilterDistance() {
    return Column(
      children: [
        SizedBox(
          height: 10.0,
        ),
        Text(
          translations[localeName]!['general.distance']!,
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(
          height: 5.0,
        ),
        Center(
          child: Text('${widget.searchedRange['distance']} km'),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.green[700],
            inactiveTrackColor: Colors.green[100],
            trackShape: RoundedRectSliderTrackShape(),
            trackHeight: 4.0,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
            thumbColor: Colors.green,
            overlayColor: Colors.green.withAlpha(32),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
            tickMarkShape: RoundSliderTickMarkShape(),
            activeTickMarkColor: Colors.green[700],
            inactiveTickMarkColor: Colors.green[100],
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: Colors.green,
            valueIndicatorTextStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          child: Slider(
            value: widget.searchedRange['distance']!,
            min: 0,
            max: 50,
            divisions: 10,
            label: widget.searchedRange['distance'].toString(),
            onChanged: (value) {
              setState(
                () {
                  widget.searchedRange['distance'] = value;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  _buildFilterBySex() {
    return Column(
      children: [
        Text(
          translations[localeName]!['general.genre']!,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    widget.searchedGender[0].name!,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                GFCheckbox(
                  size: 35,
                  activeBgColor: Colors.green[400]!,
                  inactiveBorderColor: Colors.green[700]!,
                  activeBorderColor: Colors.green[700]!,
                  type: GFCheckboxType.circle,
                  value: widget.searchedGender[0].checked!,
                  inactiveIcon: null,
                  activeIcon: Icon(
                    Icons.sports_soccer,
                    size: 25,
                    color: Colors.white,
                  ),
                  onChanged: (value) {
                    widget.searchedGender[0].checked =
                        !widget.searchedGender[0].checked!;
                    if (!widget.searchedGender[0].checked! &&
                        !widget.searchedGender[1].checked!) {
                      widget.searchedGender[0].checked = true;
                    }
                    widget.searchedGender[2].checked = false;
                    // if (!widget.searchedGender[0].checked! && !value) {
                    //   widget.searchedGender[1].checked = true;
                    // } else {
                    //   widget.searchedGender[1].checked = false;
                    //   widget.searchedGender[2].checked = false;
                    // }
                    setState(() {});
                  },
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    widget.searchedGender[1].name!,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                GFCheckbox(
                  size: 35,
                  activeBgColor: Colors.green[400]!,
                  inactiveBorderColor: Colors.green[700]!,
                  activeBorderColor: Colors.green[700]!,
                  type: GFCheckboxType.circle,
                  value: widget.searchedGender[1].checked!,
                  inactiveIcon: null,
                  activeIcon: Icon(
                    Icons.sports_soccer,
                    size: 25,
                    color: Colors.white,
                  ),
                  onChanged: (value) {
                    widget.searchedGender[1].checked =
                        !widget.searchedGender[1].checked!;
                    if (!widget.searchedGender[0].checked! &&
                        !widget.searchedGender[1].checked!) {
                      widget.searchedGender[1].checked = true;
                    }
                    widget.searchedGender[2].checked = false;
                    // if (!widget.searchedGender[1].checked! && !value) {
                    //   widget.searchedGender[0].checked = true;
                    // } else {
                    //   widget.searchedGender[0].checked = false;
                    //   widget.searchedGender[2].checked = false;
                    // }
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  _buildFilterPositions() {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width * .95,
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
          title: Text(translations[localeName]!['general.positions']!),
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
            return PlayersFilterPositions(
              searchedPositions: widget.searchedPositions,
            );
          },
        );
      },
    );
  }

  _buildFilterButton() {
    return GestureDetector(
      onTap: this.isLoading
          ? null
          : () async {
              bool noPositionSelected =
                  (!widget.searchedPositions[0].checked! &&
                      !widget.searchedPositions[1].checked! &&
                      !widget.searchedPositions[2].checked! &&
                      !widget.searchedPositions[3].checked!);

              if (noPositionSelected) {
                return showAlert(
                  context,
                  translations[localeName]!['attention']!,
                  translations[localeName]!['attention.selectOnePosition']!,
                );
              } else {
                setState(() {
                  this.isLoading = true;
                });

                Iterable<Genre> genders =
                    widget.searchedGender.where((Genre genre) {
                  bool? isChecked = genre.checked;
                  if (isChecked == null) {
                    return false;
                  }
                  return isChecked;
                });

                Iterable<Position> positions =
                    widget.searchedPositions.where((Position position) {
                  bool? isChecked = position.checked;
                  if (isChecked == null) {
                    return false;
                  }
                  return isChecked;
                });

                dynamic filterResponse = await UserRepository().getUserOffers(
                  widget.searchedRange['distance']!.toInt(),
                  genders.map((Genre genre) => genre.id).toList(),
                  positions.map((Position position) => position.id).toList(),
                );

                if (filterResponse['success']) {
                  List<User?> players = filterResponse['players'];
                  Navigator.pop(context, players);
                } else {
                  setState(() {
                    this.isLoading = false;
                  });
                  return showAlert(
                    context,
                    translations[localeName]!['error']!,
                    translations[localeName]!['error.ops.loadPlayers']!,
                  );
                }
              }
            },
      child: Container(
        margin: EdgeInsets.only(top: 20.0),
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
        width: MediaQuery.of(context).size.width * .40,
        height: 50.0,
        child: Center(
          child: this.isLoading
              ? whiteCircularLoading
              : Text(
                  translations[localeName]!['general.filter']!.toUpperCase(),
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

// _buildFilterDaysAvailable() {
//   return GestureDetector(
//     child: Container(
//       width: MediaQuery.of(context).size.width * .95,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6.0,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         title: Text('Disponibilidad'),
//         trailing: Icon(
//           Icons.keyboard_arrow_up_outlined,
//           size: 40.0,
//         ),
//       ),
//     ),
//     onTap: () async {
//       final filterDays = await showModalBottomSheet(
//         backgroundColor: Colors.transparent,
//         context: context,
//         enableDrag: true,
//         isScrollControlled: true,
//         builder: (BuildContext context) {
//           return FilterUsersAvailability(
//             userDaysAvailable: widget.searchedDaysAvailable,
//           );
//         },
//       );
//
//       if (filterDays != null) {
//         widget.searchedDaysAvailable = filterDays;
//       }
//     },
//   );
// }
}

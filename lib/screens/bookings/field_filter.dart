import 'package:flutter/material.dart';
import 'package:fulbito_app/models/field.dart';
import 'package:fulbito_app/repositories/field_repository.dart';
import 'package:fulbito_app/screens/matches/match_type_filter.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:fulbito_app/models/type.dart';

// ignore: must_be_immutable
class FieldFilter extends StatefulWidget {
  Map<String, double>? searchedRange;
  List<Type> searchedMatchType;

  FieldFilter({
    Key? key,
    this.searchedRange,
    required this.searchedMatchType,
  }) : super(key: key);

  @override
  State<FieldFilter> createState() => _FieldFilterState();
}

class _FieldFilterState extends State<FieldFilter> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height / 1.5,
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
              _buildFilterDistance(),
              SizedBox(height: 5.0),
              _buildFilterMatchType(),
              SizedBox(height: 5.0),
              // SizedBox(height: 5.0),
              _buildFilterButton(),
              SizedBox(height: 10.0),
            ],
          ),
          ModalTopBar()
        ],
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
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Center(
          child: Text('${widget.searchedRange!['distance']} km'),
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
            value: widget.searchedRange!['distance']!.round().toDouble(),
            min: 1.0,
            max: 50.0,
            divisions: 49,
            label: widget.searchedRange!['distance']?.round().toString(),
            onChanged: (value) {
              setState(
                    () {
                  widget.searchedRange!['distance'] = value.round().toDouble();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  _buildFilterMatchType() {
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
          title: Text(
            translations[localeName]!['general.matchType']!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
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
            return MatchTypeFilter(searchedMatchType: widget.searchedMatchType);
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
        setState(() {
          this.isLoading = true;
        });

        Iterable<Type> types =
        widget.searchedMatchType.where((Type type) {
          bool? isChecked = type.checked;
          if (isChecked == null) {
            return false;
          }
          return isChecked;
        });

        dynamic filterResponse = await FieldRepository().getFieldsOffers(
          widget.searchedRange!['distance']!.toInt(),
          types.map((Type type) => type.id).toList(),
        );

        if (filterResponse['success']) {
          List<Field?> fields = filterResponse['fields'];
          Navigator.pop(context, fields);
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
}

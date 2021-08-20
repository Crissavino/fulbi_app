import 'package:flutter/material.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';
import 'package:fulbito_app/models/type.dart';

// ignore: must_be_immutable
class MatchTypeFilter extends StatefulWidget {
  List<Type> searchedMatchType;

  MatchTypeFilter({Key? key, required this.searchedMatchType}) : super(key: key);

  @override
  _MatchTypeFilterState createState() => _MatchTypeFilterState();
}

class _MatchTypeFilterState extends State<MatchTypeFilter> {

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height / 1.15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              left: 0.0,
              right: 80.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    GFCheckboxListTile(
                      title: Center(
                        child: Text(
                          widget.searchedMatchType[0].name!,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                        setState(() {
                          widget.searchedMatchType[0].checked = !widget.searchedMatchType[0].checked!;
                        });
                      },
                      value: widget.searchedMatchType[0].checked!,
                      inactiveIcon: null,
                    ),
                    SizedBox(height: 20.0,),
                    GFCheckboxListTile(
                      title: Center(
                        child: Text(
                          widget.searchedMatchType[1].name!,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                        setState(() {
                          widget.searchedMatchType[1].checked = !widget.searchedMatchType[1].checked!;
                        });
                      },
                      value: widget.searchedMatchType[1].checked!,
                      inactiveIcon: null,
                    ),
                    SizedBox(height: 20.0,),
                    GFCheckboxListTile(
                      title: Center(
                        child: Text(
                          widget.searchedMatchType[2].name!,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                        setState(() {
                          widget.searchedMatchType[2].checked = !widget.searchedMatchType[2].checked!;
                        });
                      },
                      value: widget.searchedMatchType[2].checked!,
                      inactiveIcon: null,
                    ),
                    SizedBox(height: 20.0,),
                    GFCheckboxListTile(
                      title: Center(
                        child: Text(
                          widget.searchedMatchType[3].name!,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                        setState(() {
                          widget.searchedMatchType[3].checked = !widget.searchedMatchType[3].checked!;
                        });
                      },
                      value: widget.searchedMatchType[3].checked!,
                      inactiveIcon: null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ModalTopBar()
        ],
      ),
    );
  }
}

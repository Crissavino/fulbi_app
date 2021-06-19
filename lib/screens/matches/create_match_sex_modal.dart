import 'package:flutter/material.dart';
import 'package:fulbito_app/models/genre.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

// ignore: must_be_immutable
class CreateMatchSexModal extends StatefulWidget {
  List<Genre> matchGender;
  CreateMatchSexModal({required this.matchGender});

  @override
  _CreateMatchSexModalState createState() => _CreateMatchSexModalState();
}

class _CreateMatchSexModalState extends State<CreateMatchSexModal> {
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height / 1.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Container(
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
                      widget.matchGender[0].name!,
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
                    widget.matchGender[0].checked =
                    !widget.matchGender[0].checked!;
                    if (!widget.matchGender[0].checked! && !value) {
                      widget.matchGender[1].checked = true;
                    } else {
                      widget.matchGender[1].checked = false;
                      widget.matchGender[2].checked = false;
                    }
                    setState(() {});
                  },
                  value: widget.matchGender[0].checked!,
                  inactiveIcon: null,
                ),
                SizedBox(height: 20.0,),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      widget.matchGender[1].name!,
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
                    widget.matchGender[1].checked =
                    !widget.matchGender[1].checked!;

                    if (!widget.matchGender[1].checked! && !value) {
                      widget.matchGender[0].checked = true;
                    } else {
                      widget.matchGender[0].checked = false;
                      widget.matchGender[2].checked = false;
                    }

                    setState(() {});
                  },
                  value: widget.matchGender[1].checked!,
                  inactiveIcon: null,
                ),
                SizedBox(height: 20.0,),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      widget.matchGender[2].name!,
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
                    widget.matchGender[2].checked =
                    !widget.matchGender[2].checked!;
                    if (!widget.matchGender[2].checked! && !value) {
                      widget.matchGender[0].checked = true;
                    } else {
                      widget.matchGender[0].checked = false;
                      widget.matchGender[1].checked = false;
                    }
                    setState(() {});
                  },
                  value: widget.matchGender[2].checked!,
                  inactiveIcon: null,
                ),
                SizedBox(height: 20.0,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

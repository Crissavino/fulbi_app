import 'package:flutter/material.dart';
import 'package:fulbito_app/models/type.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

// ignore: must_be_immutable
class CreateMatchTypeModal extends StatefulWidget {
  List<Type> matchTypes;
  
  CreateMatchTypeModal({required this.matchTypes});

  @override
  _CreateMatchTypeModalState createState() => _CreateMatchTypeModalState();
}

class _CreateMatchTypeModalState extends State<CreateMatchTypeModal> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
                      widget.matchTypes[0].name!,
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
                    widget.matchTypes[0].checked = !widget.matchTypes[0].checked!;

                    if (!widget.matchTypes[0].checked! && !value) {
                      widget.matchTypes[1].checked = true;
                    } else {
                      widget.matchTypes[1].checked = false;
                      widget.matchTypes[2].checked = false;
                      widget.matchTypes[3].checked = false;
                    }
                    setState(() {});
                  },
                  value: widget.matchTypes[0].checked!,
                  inactiveIcon: null,
                ),
                SizedBox(height: 20.0,),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      widget.matchTypes[1].name!,
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
                    widget.matchTypes[1].checked = !widget.matchTypes[1].checked!;

                    if (!widget.matchTypes[1].checked! && !value) {
                      widget.matchTypes[0].checked = true;
                    } else {
                      widget.matchTypes[0].checked = false;
                      widget.matchTypes[2].checked = false;
                      widget.matchTypes[3].checked = false;
                    }
                    setState(() {});
                  },
                  value: widget.matchTypes[1].checked!,
                  inactiveIcon: null,
                ),
                SizedBox(height: 20.0,),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      widget.matchTypes[2].name!,
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
                    widget.matchTypes[2].checked = !widget.matchTypes[2].checked!;

                    if (!widget.matchTypes[2].checked! && !value) {
                      widget.matchTypes[0].checked = true;
                    } else {
                      widget.matchTypes[0].checked = false;
                      widget.matchTypes[1].checked = false;
                      widget.matchTypes[3].checked = false;
                    }

                    setState(() {});
                  },
                  value: widget.matchTypes[2].checked!,
                  inactiveIcon: null,
                ),
                SizedBox(height: 20.0,),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      widget.matchTypes[3].name!,
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
                    widget.matchTypes[3].checked = !widget.matchTypes[3].checked!;

                    if (!widget.matchTypes[3].checked! && !value) {
                      widget.matchTypes[0].checked = true;
                    } else {
                      widget.matchTypes[0].checked = false;
                      widget.matchTypes[1].checked = false;
                      widget.matchTypes[2].checked = false;
                    }

                    setState(() {});
                  },
                  value: widget.matchTypes[3].checked!,
                  inactiveIcon: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fulbito_app/models/position_db.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

// ignore: must_be_immutable
class ShowUserPositions extends StatefulWidget {
  List<PositionDB>? userPositions;
  ShowUserPositions({required this.userPositions});

  @override
  _ShowUserPositionsState createState() => _ShowUserPositionsState();
}

class _ShowUserPositionsState extends State<ShowUserPositions> {

  bool _gkPos = false;
  bool _defPos = false;
  bool _mfPos = false;
  bool _forPos = false;

  @override
  void initState() {
    widget.userPositions!.forEach((PositionDB element) {
      if (element.id == 1) {
        this._gkPos = true;
      }

      if (element.id == 2) {
        this._defPos = true;
      }

      if (element.id == 3) {
        this._mfPos = true;
      }

      if (element.id == 4) {
        this._forPos = true;
      }
    });
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
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      translations[localeName]!['general.positions.gk']!,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  avatar: GFAvatar(
                    backgroundImage: AssetImage(
                        'assets/icons/primary/007-goalkeeper.png'),
                    size: 45.0,
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
                  onChanged: (val) {},
                  value: _gkPos,
                  inactiveIcon: null,
                ),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      translations[localeName]!['general.positions.def']!,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  avatar: GFAvatar(
                    backgroundImage:
                    AssetImage('assets/icons/primary/005-pads.png'),
                    size: 45.0,
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
                  onChanged: (val) {},
                  value: _defPos,
                  inactiveIcon: null,
                ),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      translations[localeName]!['general.positions.mid']!,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  avatar: GFAvatar(
                    backgroundImage: AssetImage(
                        'assets/icons/primary/006-footwear.png'),
                    size: 45.0,
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
                  onChanged: (val) {},
                  value: _mfPos,
                  inactiveIcon: null,
                ),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      translations[localeName]!['general.positions.for']!,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  avatar: GFAvatar(
                    backgroundImage: AssetImage(
                        'assets/icons/primary/013-football-1.png'),
                    size: 45.0,
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
                  onChanged: (val) {},
                  value: _forPos,
                  inactiveIcon: null,
                ),
              ],
            ),
            ModalTopBar()
          ],
        ),
      ),
    );
  }
}

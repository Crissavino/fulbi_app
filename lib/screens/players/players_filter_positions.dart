import 'package:flutter/material.dart';
import 'package:fulbito_app/models/position.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

// ignore: must_be_immutable
class PlayersFilterPositions extends StatefulWidget {
  List<Position> searchedPositions;

  PlayersFilterPositions({Key? key, required this.searchedPositions}) : super(key: key);

  @override
  _PlayersFilterPositionsState createState() => _PlayersFilterPositionsState();
}

class _PlayersFilterPositionsState extends State<PlayersFilterPositions> {

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
          left: 20.0,
          right: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                ListTile(
                  leading: Text(
                    'Que posiciones buscas?',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    padding: EdgeInsets.only(
                      left: 15.0,
                    ),
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                    onPressed: () {
                      showAlert(
                        context,
                        'Informacion',
                        'Selecciona la/las posiciones que estas buscando',
                      );
                    },
                  ),
                ),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      'Arquero',
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
                  onChanged: (value) {
                    setState(() {
                      widget.searchedPositions[0].checked = !widget.searchedPositions[0].checked!;
                    });
                  },
                  value: widget.searchedPositions[0].checked!,
                  inactiveIcon: null,
                ),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      'Defensor',
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
                  onChanged: (value) {
                    setState(() {
                      widget.searchedPositions[1].checked = !widget.searchedPositions[1].checked!;
                    });
                  },
                  value: widget.searchedPositions[1].checked!,
                  inactiveIcon: null,
                ),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      'Mediocampista',
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
                  onChanged: (value) {
                    setState(() {
                      widget.searchedPositions[2].checked = !widget.searchedPositions[2].checked!;
                    });
                  },
                  value: widget.searchedPositions[2].checked!,
                  inactiveIcon: null,
                ),
                GFCheckboxListTile(
                  title: Center(
                    child: Text(
                      'Delantero',
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
                  onChanged: (value) {
                    setState(() {
                      widget.searchedPositions[3].checked = !widget.searchedPositions[3].checked!;
                    });
                  },
                  value: widget.searchedPositions[3].checked!,
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

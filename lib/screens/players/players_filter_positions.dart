import 'package:flutter/material.dart';
import 'package:fulbito_app/models/position.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
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
    final _width = MediaQuery.of(context).size.width;
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
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: _width * .7,
                        child: Text(
                          // 'translationstranslationstranslationstranslations',
                          translations[localeName]!['filter.players.whichPositions']!,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                            translations[localeName]!['information']!,
                            translations[localeName]!['information.selectSearchedPositions']!,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.0,),
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
            ModalTopBar()
          ],
        ),
      ),
    );
  }
}

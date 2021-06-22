import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/profile/profile_bloc.dart';
import 'package:fulbito_app/models/position_db.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

// ignore: must_be_immutable
class YourPositions extends StatefulWidget {

  List<PositionDB>? userPositions;
  YourPositions({required this.userPositions});

  @override
  _YourPositionsState createState() => _YourPositionsState();
}

class _YourPositionsState extends State<YourPositions> {
  bool _gkPos = false;
  bool _defPos = false;
  bool _mfPos = false;
  bool _forPos = false;
  List? newPositions;

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
    final _width = MediaQuery.of(context).size.width;

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
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (BuildContext context, state) {

            if (state is ProfileLoadingState) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    circularLoading
                  ],
                ),
              );
            }

            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: Text(
                        'Cual es tu pisicion?',
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
                            'Selecciona la/las posiciones en la que sueles jugar',
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
                          _gkPos = !_gkPos;
                        });
                      },
                      value: _gkPos,
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
                          _defPos = !_defPos;
                        });
                      },
                      value: _defPos,
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
                          _mfPos = !_mfPos;
                        });
                      },
                      value: _mfPos,
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
                          _forPos = !_forPos;
                        });
                      },
                      value: _forPos,
                      inactiveIcon: null,
                    ),
                    Container(
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
                      width: _width * .40,
                      height: 50.0,
                      child: Center(
                        child: TextButton(
                          onPressed: () async {
                            bool noPositionSelected = (!_gkPos && !_defPos && !_mfPos && !_forPos);

                            if(noPositionSelected) {
                              BlocProvider.of<ProfileBloc>(context).add(
                                  ProfileErrorEvent()
                              );
                              return showAlert(
                                context,
                                'Atencion!',
                                'Debes seleccionar alguna posicion en la que usualmente juegas',
                              );
                            } else {

                              List positionsIds = [];
                              if (_gkPos) positionsIds.add(1);
                              if (_defPos) positionsIds.add(2);
                              if (_mfPos) positionsIds.add(3);
                              if (_forPos) positionsIds.add(4);

                              BlocProvider.of<ProfileBloc>(context).add(
                                  ProfileLoadingEvent()
                              );

                              final editUserPositionsResponse = await UserRepository().editUserPositions(positionsIds);

                              if (editUserPositionsResponse['success'] == true) {
                                Navigator.pop(context, true);
                                BlocProvider.of<ProfileBloc>(context).add(
                                    ProfileCompleteEvent()
                                );
                              } else {
                                BlocProvider.of<ProfileBloc>(context).add(
                                    ProfileErrorEvent()
                                );
                                return showAlert(
                                  context,
                                  'Error!',
                                  'Ocurrió un error al guardar las posiciones!',
                                );
                              }
                            }
                          },
                          child: Text(
                            translations[localeName]!['general.save']!.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ModalTopBar()
              ],
            );
          },
        ),
      ),
    );
  }
}

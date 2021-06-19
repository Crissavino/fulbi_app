import 'package:flutter/material.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/match_repository.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ShowMyCreatedMatches extends StatefulWidget {
  User user;
  ShowMyCreatedMatches({required this.user});

  @override
  _ShowMyCreatedMatchesState createState() => _ShowMyCreatedMatchesState();
}

class _ShowMyCreatedMatchesState extends State<ShowMyCreatedMatches> {

  Future? _future;
  List<Match?> matches = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    this._future = getMyCreatedMatches();
  }

  Future getMyCreatedMatches() async {
    final response = await MatchRepository().getMyCreatedMatches();
    if (response['success']) {
      setState(() {
        this.matches = response['matches'];
      });
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
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
      child: Center(
        child: Container(
          child: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints constraints) {
              return Container(
                padding: EdgeInsets.only(
                    bottom: 20.0, left: 20.0, right: 20.0),
                margin: EdgeInsets.only(top: 20.0),
                width: _width,
                child: FutureBuilder(
                  future: this._future,
                  builder: (BuildContext context,
                      AsyncSnapshot<dynamic> snapshot) {
                    dynamic response = snapshot.data;

                    if (!snapshot.hasData) {
                      return Container(
                        width: _width,
                        height: _height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [circularLoading],
                        ),
                      );
                    }

                    if (!response['success']) {
                      return showAlert(
                          context, 'Error', 'Oops, ocurrió un error');
                    }

                    if (this.matches.isEmpty) {
                      return Container(
                        width: _width,
                        height: _height,
                        child: Center(
                          child: Text(
                            translations[localeName]!['general.noMatches']!,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemBuilder: (
                          BuildContext context,
                          int index,
                          ) {
                        return _buildMatchRow(this.matches[index]!);
                      },
                      itemCount: this.matches.length,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMatchRow(Match match) {
    return GestureDetector(
      onTap: () async {
        await showAlertWithEvent(
          context,
          translations[localeName]!['general.areYouGoingToInvite']! + ' ${widget.user.name} ' + translations[localeName]!['general.toYourMatch']!,
              () async {
            final response = await MatchRepository().sendInvitationToUser(widget.user.id, match.id);
            if (response['success']) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyMatchesScreen(),
                ),
              );
            } else {
              Navigator.pop(context);
              showAlert(context, 'Error', 'Oooops ocurrio un error');
            }
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
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
              offset: Offset(0, 8),
            ),
          ],
          color: Colors.green[400],
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: 80.0,
        child: Center(
          child: ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.sports_soccer,
                color: Colors.green[700],
                size: 40.0,
              ),
            ),
            title: Text(
              DateFormat('dd/MM HH:mm').format(match.whenPlay),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            trailing: Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 40.0,
            ),
          ),
        ),
      ),
    );
  }

}

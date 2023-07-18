import 'package:flutter/material.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/modal_top_bar.dart';

// ignore: must_be_immutable
class YourSettings extends StatefulWidget {
  User? user;
  YourSettings({required this.user});

  @override
  _YourSettingsState createState() => _YourSettingsState();
}

class _YourSettingsState extends State<YourSettings> {
  bool cantSeePassword = true;
  String? newNickname;
  String newPassword = '';
  String confirmNewPassword = '';
  bool isChangeNameLoading = false;
  bool isChangePassLoading = false;

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                top: 40.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Center(
                child: Container(
                  height: _height / 1.3,
                  padding: EdgeInsets.only(bottom: (MediaQuery.of(context).viewInsets.bottom)),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //_buildNickname(),
                        //SizedBox(height: 40.0,),
                        _buildPassword(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ModalTopBar()
          ],
        ),
      ),
    );
  }

  Widget _buildNickname() {
    final _width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Text(translations[localeName]!['profile.nickname']!, style: TextStyle(fontSize: 18.0),),
        Container(
          alignment: Alignment.centerLeft,
          width: _width * .95,
          margin: EdgeInsets.only(top: 20.0),
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
          height: 60.0,
          child: Container(
            margin: EdgeInsets.only(left: 25.0,),
            width: _width,
            child: Container(
              child: TextFormField(
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'OpenSans',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0),
                  hintText: translations[localeName]!['profile.nickname']!,
                  hintStyle: kHintTextStyle,
                ),
                initialValue: widget.user!.nickname,
                onChanged: (val) {
                  this.newNickname = val;
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 20.0,),
        _buildSaveNicknameButton(),
      ],
    );
  }

  Widget _buildSaveNicknameButton() {
    final _width = MediaQuery.of(context).size.width;

    return Container(
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
          onPressed: this.isChangeNameLoading ? null : () async {
            if (this.newNickname == '' || this.newNickname == null) {
              return showAlert(
                context,
                translations[localeName]!['attention']!,
                translations[localeName]!['attention.mandatoryNick']!,
              );
            }

            setState(() {
              this.isChangeNameLoading = true;
            });

            final response = await UserRepository().changeNickname(
              this.newNickname
            );

            if (response['success']) {
              Navigator.pop(context, response['user']);
            } else {
              setState(() {
                this.isChangeNameLoading = false;
              });
              return showAlert(
                context,
                translations[localeName]!['error']!,
                translations[localeName]![response['messageKey']]!,
              );
            }
          },
          child: this.isChangeNameLoading ? whiteCircularLoading : Text(
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
    );
  }

  Widget _buildPassword() {
    final _width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Text(translations[localeName]!['password']!, style: TextStyle(fontSize: 18.0),),
        Container(
          alignment: Alignment.centerLeft,
          width: _width * .95,
          margin: EdgeInsets.only(top: 20.0),
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
          height: 60.0,
          child: Container(
            margin: EdgeInsets.only(left: 25.0,),
            width: _width,
            child: Container(
              child: TextFormField(
                obscureText: cantSeePassword,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'OpenSans',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (cantSeePassword) {
                          cantSeePassword = false;
                        } else {
                          cantSeePassword = true;
                        }
                      });
                    },
                  ),
                  hintText: translations[localeName]!['profile.changePass']!,
                  hintStyle: kHintTextStyle,
                ),
                onChanged: (val) {
                    newPassword = val;
                },
              ),
            ),
          ),
        ),
        _buildConfirmPassword(),
        SizedBox(height: 20.0,),
        _buildSavePasswordButton()
      ],
    );

  }

  Widget _buildConfirmPassword() {
    final _width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.centerLeft,
      width: _width * .95,
      margin: EdgeInsets.only(top: 20.0),
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
      height: 60.0,
      child: Container(
        margin: EdgeInsets.only(left: 25.0,),
        width: _width,
        child: Container(
          child: TextFormField(
            obscureText: cantSeePassword,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (cantSeePassword) {
                      cantSeePassword = false;
                    } else {
                      cantSeePassword = true;
                    }
                  });
                },
              ),
              hintText: translations[localeName]!['profile.changePassConfirm']!,
              hintStyle: kHintTextStyle,
            ),
            onChanged: (val) {
                confirmNewPassword = val;
            },
          ),
        ),
      ),
    );

  }

  Widget _buildSavePasswordButton() {
    final _width = MediaQuery.of(context).size.width;

    return Container(
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
          onPressed: this.isChangePassLoading ? null : () async {
            if (this.newPassword == '' || this.confirmNewPassword == '') {
              return showAlert(
                context,
                translations[localeName]!['attention']!,
                translations[localeName]!['mandatoryPass']!,
              );
            } else if(this.newPassword.length < 6 || this.confirmNewPassword.length < 6) {
              return showAlert(
                context,
                translations[localeName]!['attention']!,
                translations[localeName]!['passNotMatch']!,
              );
            } else if(this.newPassword != this.confirmNewPassword) {
              return showAlert(
                context,
                translations[localeName]!['attention']!,
                translations[localeName]!['passNotMatch']!,
              );
            }

            setState(() {
              this.isChangePassLoading = true;
            });

            final response = await UserRepository().changePassword(
              this.newPassword
            );

            if (response['success']) {
              await showAlert(
                context,
                translations[localeName]!['passChanged']!,
                translations[localeName]!['passChangedSuccess']!,
              );
              Navigator.pop(context, response['user']);
            } else {
              setState(() {
                this.isChangePassLoading = false;
              });
              return showAlert(
                context,
                translations[localeName]!['error']!,
                translations[localeName]!['error.ops']!,
              );
            }
          },
          child: this.isChangePassLoading ? whiteCircularLoading : Text(
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
    );
  }

}

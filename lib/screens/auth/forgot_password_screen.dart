import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  UserRepository _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';

  bool _loading = false;

  Text _buildPageTitle() {
    return Text(
      translations[localeName]!['recoverPassword']!,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'OpenSans',
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          translations[localeName]!['email']!,
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.grey,
              ),
              hintText: translations[localeName]!['enterEmail']!,
              hintStyle: kHintTextStyle,
            ),
            initialValue: email,
            onChanged: (val) {
              setState(() => email = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecoverBtn(_width) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
      ),
      width: _width * .40,
      height: 50.0,
      child: TextButton(
        onPressed: () async {
          await postSignIn();
        },
        child: Text(
          translations[localeName]!['recover']!.toUpperCase(),
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Future<void> postSignIn() async {
    if (email.isEmpty) {
      return showAlert(
          context,
          translations[localeName]!['recoverFails']!,
          translations[localeName]!['mandatoryEmail']!
      );
    }

    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if (!emailValid) {
      return showAlert(
          context,
          translations[localeName]!['recoverFails']!,
          translations[localeName]!['mandatoryEmail']!
      );
    } else {
      FocusScope.of(context).unfocus();
      await _recover();
    }
  }

  Future<void> _recover() async {
    setState(() {
      this._loading = true;
    });

    final Map res = await _userRepository.recoverPassword(email);

    if (res.containsKey('success') && res['success'] == true) {
      Navigator.pushReplacementNamed(context, 'login');
    } else {
      setState(() {
        this._loading = false;
      });

      showAlert(
        context,
        translations[localeName]!['loginFails']!,
        res['message'],
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                decoration: verticalGradient,
                height: availableHeight,
                padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
                child: Padding(
                  padding: EdgeInsets.only(bottom: (MediaQuery.of(context).viewInsets.bottom)),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildPageTitle(),
                        SizedBox(height: 30.0),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildEmailTF(),
                              SizedBox(
                                height: 30.0,
                              ),
                              _buildRecoverBtn(mediaQuery.size.width),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(left: 10.0, top: 0.0),
                  alignment: Alignment.center,
                  child: Container(
                    child: AppBar(
                      backwardsCompatibility: false,
                      systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarColor: Colors.white),
                      backgroundColor: Colors.transparent,
                      elevation: 0.0,
                      leading: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1,
                                  animation2) =>
                                  LoginScreen(),
                              transitionDuration:
                              Duration(seconds: 0),
                            ),
                          );
                        },
                        icon: Icon(Icons.arrow_back_ios),
                        splashColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/register/register_bloc.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/auth/complete_register_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool isLoading = false;
  UserRepository _userRepository = UserRepository();

  // text field state
  String fullName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  // bool _rememberMe = false;
  bool cantSeePassword = true;
  bool cantSeeConfirmPassword = true;

  Text _buildPageTitle() {
    return Text(
      translations[localeName]!['signUp']!,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'OpenSans',
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFullNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          translations[localeName]!['fullName']!,
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.grey,
              ),
              hintText: translations[localeName]!['enterFullName']!,
              hintStyle: kHintTextStyle,
            ),
            onChanged: (val) {
              setState(() => fullName = val);
            },
          ),
        ),
      ],
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
          child: Focus(
            child: BlocBuilder<RegisterBloc, RegisterState>(
              builder: (BuildContext context, state) {
                return TextFormField(
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
                );

              },
            ),
            onFocusChange: (hasFocus) {
              if (!hasFocus && email != '') {
                BlocProvider.of<RegisterBloc>(context).add(
                    EnterEmail(email)
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          translations[localeName]!['password']!,
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            obscureText: cantSeePassword,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'OpenSans',
            ),
            onChanged: (val) {
              setState(() {
                password = val;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.grey,
              ),
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
              hintText: translations[localeName]!['enterPass']!,
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          translations[localeName]!['confirmPassword']!,
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            obscureText: cantSeeConfirmPassword,
            style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'OpenSans',
            ),
            onChanged: (val) {
              setState(() => confirmPassword = val);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.grey,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (cantSeeConfirmPassword) {
                      cantSeeConfirmPassword = false;
                    } else {
                      cantSeeConfirmPassword = true;
                    }
                  });
                },
              ),
              hintText: translations[localeName]!['enterConfirmPassword']!,
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(2.0),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.white,
          ),
          child: TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
            ),
            onPressed: this.isLoading ? () {} : () async {
              if (fullName.isEmpty) {
                showAlert(
                  context,
                  translations[localeName]!['registerFails']!,
                  translations[localeName]!['mandatoryFullName']!,
                );
              } else if (email.isEmpty) {
                showAlert(
                  context,
                  translations[localeName]!['registerFails']!,
                  translations[localeName]!['mandatoryEmail']!,
                );
              } else if (password.isEmpty) {
                showAlert(
                  context,
                  translations[localeName]!['registerFails']!,
                  translations[localeName]!['mandatoryPass']!,
                );
              } else if (password.length < 6) {
                showAlert(
                  context,
                  translations[localeName]!['registerFails']!,
                  translations[localeName]!['passWithMoreSix']!,
                );
              } else if (confirmPassword.isEmpty) {
                showAlert(
                  context,
                  translations[localeName]!['registerFails']!,
                  translations[localeName]!['mandatoryConfirmPass']!,
                );
              } else if (confirmPassword.length < 6) {
                showAlert(
                  context,
                  translations[localeName]!['registerFails']!,
                  translations[localeName]!['passWithMoreSix']!,
                );
              } else if (password != confirmPassword) {
                showAlert(
                  context,
                  translations[localeName]!['registerFails']!,
                  translations[localeName]!['passNotMatch']!,
                );
              } else {
                setState(() {
                  this.isLoading = true;
                });
                FocusScope.of(context).unfocus();
                await _register();
              }
            },
            child: this.isLoading ? circularLoading : Text(
              translations[localeName]!['signUp']!.toUpperCase(),
              style: TextStyle(
                color: Color(0xFF527DAA),
                letterSpacing: 1.5,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {

    final Map res = await _userRepository.register(email, password, confirmPassword, fullName);

    if (res.containsKey('success') && res['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CompleteRegisterScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        this.isLoading = false;
      });
      showAlert(
        context,
        translations[localeName]!['registerFails']!,
        res['message'],
      );
    }
  }

  Widget _buildSignInBtn() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, 'login'),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: translations[localeName]!['doHaveAccount']!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: translations[localeName]!['signIn']!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                decoration: verticalGradient,
                height: double.infinity,
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
                              _buildFullNameTF(),
                              SizedBox(height: 10.0),
                              _buildEmailTF(),
                              SizedBox(height: 10.0),
                              _buildPasswordTF(),
                              SizedBox(height: 10.0),
                              _buildConfirmPasswordTF(),
                              SizedBox(height: 20.0),
                              // _buildRememberMeCheckbox(),
                              _buildRegisterBtn(),
                              SizedBox(height: 10.0),
                              _buildSignInBtn()
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

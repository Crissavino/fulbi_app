import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/login/login_bloc.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;
  UserRepository _userRepository = UserRepository();

  // text field state
  String email = '';
  String password = '';
  // bool _rememberMe = false;
  bool cantSeePassword = true;
  String? localeName = Platform.localeName.split('_')[0];

  Text _buildPageTitle() {
    return Text(
      translations[localeName]!['signIn']!,
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
              setState(() => password = val);
            },
            initialValue: password,
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

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        child: Container(
          padding: EdgeInsets.only(right: 0.0),
          child: Text(
            translations[localeName]!['forgotPass']!,
            style: kLabelStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          await postSignIn();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          translations[localeName]!['signIn']!.toUpperCase(),
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
      showAlert(
          context,
          translations[localeName]!['loginFails']!,
          translations[localeName]!['mandatoryEmail']!
      );
    } else if (password.isEmpty) {
      showAlert(
        context,
        translations[localeName]!['loginFails']!,
        translations[localeName]!['mandatoryPass']!,
      );
    } else if (password.length < 6) {
      showAlert(
        context,
        translations[localeName]!['loginFails']!,
        translations[localeName]!['passWithMoreSix']!,
      );
    } else {
      FocusScope.of(context).unfocus();
      await _login();
    }
  }

  Future<void> _login() async {
    BlocProvider.of<LoginBloc>(context).add(
        LoggingInEvent()
    );

    final Map res = await _userRepository.login(email, password);

    if (res.containsKey('success') && res['success'] == true) {
      User user = res['user'];
      if (user.isFullySet) {
        Navigator.pushReplacementNamed(context, 'matches');
      } else {
        Navigator.pushReplacementNamed(context, 'complete_profile');
      }
      BlocProvider.of<LoginBloc>(context).add(
          LoggedInEvent()
      );
    } else {
      BlocProvider.of<LoginBloc>(context).add(
          LogInErrorEvent()
      );
      showAlert(
        context,
        translations[localeName]!['loginFails']!,
        res['message'],
      );
    }

  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        // Text(
        //   '- OR -',
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontWeight: FontWeight.w400,
        //   ),
        // ),
        // SizedBox(height: 20.0),
        Text(
          translations[localeName]!['signInWith']!,
          style: kLabelStyle,
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function()? onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
                () => print('Login with Apple'),
            AssetImage(
              'assets/logos/apple.png',
            ),
          ),
          _buildSocialBtn(
                () => print('Login with Google'),
            AssetImage(
              'assets/logos/google.png',
            ),
          ),
          _buildSocialBtn(
                () => print('Login with Facebook'),
            AssetImage(
              'assets/logos/facebook.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpBtn() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, 'register'),
      // onTap: () {
      // Navigator.pushReplacement(
      //   context,
      //   PageRouteBuilder(
      //     pageBuilder: (_, __, ___) => SignupScreen(),
      //     transitionDuration: Duration(milliseconds: 0),
      //   ),
      // );
      // },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: translations[localeName]!['dontAccount']!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
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
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (BuildContext context, state) {

                    if (state is LoggingInState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          whiteCircularLoading
                        ],
                      );
                    }

                    return Padding(
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
                                  _buildPasswordTF(),
                                  _buildForgotPasswordBtn(),
                                  // _buildRememberMeCheckbox(),
                                  _buildLoginBtn(),
                                  _buildSignInWithText(),
                                  _buildSocialBtnRow(),
                                  _buildSignUpBtn(),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

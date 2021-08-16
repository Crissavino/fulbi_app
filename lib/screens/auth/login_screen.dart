import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fulbito_app/bloc/login/login_bloc.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/screens/auth/complete_register_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/services/apple_singin_service.dart';
import 'package:fulbito_app/services/google_signin_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/show_alert.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool isLoading = false;
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
        onPressed: () =>
            Navigator.pushReplacementNamed(context, 'forgot_password'),
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
            onPressed: this.isLoading ? null : () async {
              await postSignIn();
            },
            child: this.isLoading ? circularLoading : Text(
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
        ),
      ),
    );
  }

  Future<void> postSignIn() async {
    if (email.isEmpty) {
      showAlert(context, translations[localeName]!['loginFails']!,
          translations[localeName]!['mandatoryEmail']!);
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
      setState(() {
        this.isLoading = true;
      });
      FocusScope.of(context).unfocus();
      await _login();
    }
  }

  Future<void> _login() async {
    BlocProvider.of<LoginBloc>(context).add(LoggingInEvent());

    final Map res = await _userRepository.login(email, password);

    if (res.containsKey('success') && res['success'] == true) {
      User user = res['user'];
      if (user.isFullySet) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MatchesScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CompleteRegisterScreen()),
              (Route<dynamic> route) => false,
        );
      }
      BlocProvider.of<LoginBloc>(context).add(LoggedInEvent());
    } else {
      BlocProvider.of<LoginBloc>(context).add(LogInErrorEvent());
      setState(() {
        this.isLoading = false;
      });
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
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: logo,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRowForIos() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
                () async {
              BlocProvider.of<LoginBloc>(context).add(LoggingInEvent());

              final res = await AppleSignInService.signIn();

              if (res is SignInWithAppleAuthorizationException) {
                BlocProvider.of<LoginBloc>(context).add(LogInErrorEvent());
              } else if (res!.containsKey('success') && res['success'] == true) {
                User user = res['user'];
                if (user.isFullySet) {
                  Navigator.pushReplacementNamed(context, 'matches');
                } else {
                  Navigator.pushReplacementNamed(context, 'complete_profile');
                }
                BlocProvider.of<LoginBloc>(context).add(LoggedInEvent());
              } else if ((res!.containsKey('canceled') && res['canceled'] == true) || (res!.containsKey('code') && res['code'] == 'AuthorizationErrorCode.unknown')){
                BlocProvider.of<LoginBloc>(context).add(LogInErrorEvent());
              } else {
                BlocProvider.of<LoginBloc>(context).add(LogInErrorEvent());
                showAlert(
                  context,
                  translations[localeName]!['loginFails']!,
                  res['message'] ?? "",
                );
              }
            },
            AssetImage(
              'assets/logos/apple.png',
            ),
          ),
          _buildSocialBtn(
                () async {
              BlocProvider.of<LoginBloc>(context).add(LoggingInEvent());

              final res = await GoogleSignInService.singInWithGoogle();

              if (res!.containsKey('success') && res['success'] == true) {
                User user = res['user'];
                if (user.isFullySet) {
                  Navigator.pushReplacementNamed(context, 'matches');
                } else {
                  Navigator.pushReplacementNamed(context, 'complete_profile');
                }
                BlocProvider.of<LoginBloc>(context).add(LoggedInEvent());
              } else if(res.containsKey('canceled') && res['canceled'] == true) {
                BlocProvider.of<LoginBloc>(context).add(LogInErrorEvent());
              } else {
                BlocProvider.of<LoginBloc>(context).add(LogInErrorEvent());
                showAlert(
                  context,
                  translations[localeName]!['loginFails']!,
                  res['message'],
                );
              }
            },
            AssetImage(
              'assets/logos/google.png',
            ),
          ),
          // _buildSocialBtn(
          //   () => print('Login with Facebook'),
          //   AssetImage(
          //     'assets/logos/facebook.jpg',
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSocialBtnRowForAndroid() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildSocialBtn(
                () async {
              BlocProvider.of<LoginBloc>(context).add(LoggingInEvent());

              final res = await GoogleSignInService.singInWithGoogle();

              if (res!.containsKey('success') && res['success'] == true) {
                User user = res['user'];
                if (user.isFullySet) {
                  Navigator.pushReplacementNamed(context, 'matches');
                } else {
                  Navigator.pushReplacementNamed(context, 'complete_profile');
                }
                BlocProvider.of<LoginBloc>(context).add(LoggedInEvent());
              } else if(res.containsKey('canceled') && res['canceled'] == true) {
                BlocProvider.of<LoginBloc>(context).add(LogInErrorEvent());
              } else {
                BlocProvider.of<LoginBloc>(context).add(LogInErrorEvent());
                showAlert(
                  context,
                  translations[localeName]!['loginFails']!,
                  res['message'],
                );
              }
            },
            AssetImage(
              'assets/logos/google.png',
            ),
          ),
          // _buildSocialBtn(
          //   () => print('Login with Facebook'),
          //   AssetImage(
          //     'assets/logos/facebook.jpg',
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSignUpBtn() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, 'register'),
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
              text: translations[localeName]!['signUp']!,
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
                height: availableHeight,
                padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (BuildContext context, state) {
                    if (state is LoggingInState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [whiteCircularLoading],
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: (MediaQuery.of(context).viewInsets.bottom)),
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
                                  Platform.isIOS
                                      ? _buildSocialBtnRowForIos()
                                      : _buildSocialBtnRowForAndroid(),
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

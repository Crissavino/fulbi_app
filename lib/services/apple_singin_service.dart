import 'dart:convert';
import 'dart:math';

import 'dart:io';

import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AppleSignInService {

  static Future signIn1() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
        clientId:
        'com.crissavino.fulbito.signinservice',
        redirectUri: Uri.parse(
          'https://4a1a558b3ff6.ngrok.io/api/login-with-apple',
        ),
      ),
    );

    print(credential);

    // This is the endpoint that will convert an authorization code obtained
    // via Sign in with Apple into a session in your system
    final signInWithAppleEndpoint = Uri(
      scheme: 'https',
      host: '4a1a558b3ff6.ngrok.io',
      path: '/login-with-apple',
      queryParameters: <String, String>{
        'code': credential.authorizationCode,
        if (credential.givenName != null)
          'firstName': credential.givenName!,
        if (credential.familyName != null)
          'lastName': credential.familyName!,
        'useBundleId':
        Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
        if (credential.state != null) 'state': credential.state!,
      },
    );

    final session = await http.Client().post(
      signInWithAppleEndpoint,
    );

    print(session);
  }
  static Future signIn() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final String code = credential.authorizationCode;
    final String? firstName = (credential.givenName != null ) ? credential.givenName! : null;
    final String? lastName = (credential.familyName != null ) ? credential.familyName! : null;
    final String? useBundleId = Platform.isIOS || Platform.isMacOS ? 'true' : 'false';
    final String? state = (credential.state != null ) ? credential.state! : null;
    return await UserRepository().loginWithApple(code, firstName, lastName, useBundleId, state,);

  }
}
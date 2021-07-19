import 'dart:io';

import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInService {

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
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email'
    ],
  );

  static Future<Map?> singInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return {'canceled': true};
      final googleKey = await account.authentication;
      return await UserRepository().loginWithGoogle(googleKey.idToken);
      // return account;
    } catch (e) {
      print('Error en Google Singin');
      print(e);
      return null;
    }
  }

}

import 'package:fulbito_app/screens/auth/complete_register_screen.dart';
import 'package:fulbito_app/screens/auth/forgot_password_screen.dart';
import 'package:fulbito_app/screens/auth/login_screen.dart';
import 'package:fulbito_app/screens/auth/register_screen.dart';
import 'package:fulbito_app/screens/bookings/bookings_screen.dart';
import 'package:fulbito_app/screens/intro/intro_screen.dart';
import 'package:fulbito_app/screens/matches/create_match_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';

final routes = {
  'login': (_) => LoginScreen(),
  'register': (_) => RegisterScreen(),
  'forgot_password': (_) => ForgotPasswordScreen(),
  'complete_profile': (_) => CompleteRegisterScreen(),
  'matches': (_) => MatchesScreen(),
  'bookings': (_) => BookingsScreen(),
  'create_match': (_) => CreateMatchScreen(),
  'my_matches': (_) => MyMatchesScreen(),
  'intro': (_) => IntroScreen(),
};
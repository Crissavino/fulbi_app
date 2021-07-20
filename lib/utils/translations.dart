import 'dart:io';

String? localeName = Platform.localeName.split('_')[0];

const Map<String?, Map<String?, String?>> translations = {
  'en': {
    'general.select': 'Select',
    'search': 'Search',
    'myLocation': 'My location',
    'manualSelection': 'Manual selection',
    'recoverPassword': 'Recover Password',
    'recover': 'Recover',
    'signIn': 'Sign In',
    'email': 'Email',
    'enterEmail': 'Enter your email',
    'password': 'Password',
    'enterPass': 'Enter your password',
    'forgotPass': 'Forgor password?',
    'rememberMe': 'Remember me',
    'signInWith': 'Sign in with',
    'dontAccount': 'Don\'t have an account? ',
    'loginFails': 'Login failed',
    'recoverFails': 'Recover failed',
    'mandatoryPass': 'The password is required',
    'passWithMoreSix': 'Enter a password with more than 6 characters',
    'checkCredentials': 'Check yours credentials',
    'signUp': 'Sign Up',
    'fullName': 'Full name',
    'enterFullName': 'Enter your full name',
    'confirmPassword': 'Confirm password',
    'enterConfirmPassword': 'Confirm password',
    'registerFails': 'Register failed',
    'mandatoryFullName': 'Full name is required',
    'mandatoryEmail': 'The email is required',
    'mandatoryConfirmPass': 'Password confirmation is mandatory',
    'passNotMatch': 'Passwords do not match',
    'invalidCredentials': 'Your credentials are not valid',
    'general.prev': 'Prev',
    'general.next': 'Next',
    'general.information': 'Information',
    'general.information.completeProfile.genre': 'Select your gender (This information you will not be able to change)',
    'general.information.completeProfile.wherePlay': 'Select the city where you usually play (Then you can change this setting in your profile)',
    'general.save': 'Save',
    'general.location': 'Location',
    'general.types.f5': 'Five-a-side',
    'general.types.f7': 'Seven-a-side',
    'general.types.f9': 'Nine-a-side',
    'general.types.f11': 'Eleven-a-side',
    'general.positions': 'Positions',
    'general.positions.gk': 'Goalkeeper',
    'general.positions.def': 'Defense',
    'general.positions.mid': 'Middle',
    'general.positions.for': 'Forward',
    'general.genre': 'Genre',
    'general.genres.male': 'Male',
    'general.genres.males': 'Males',
    'general.genres.female': 'Female',
    'general.genres.females': 'Females',
    'general.genres.mix': 'Mix',
    'general.distance': 'Distance',
    'general.filter': 'Filter',
    'general.matchType': 'Match type',
    'general.selectWhereToPlay': 'Select the city where you want to play',
    'match.info': 'Information',
    'match.itPlayedIn': 'It is played in',
    'match.isMatchType': "It's a match of",
    'match.aproxCost': 'It has an approximate cost of',
    'match.join': 'You are going to join the match, do you want to continue?',
    'match.chat.join': 'To see the chat you must join to the match, do you want to join?',
    'match.leave': 'You are going to leave the match, do you want to continue?',
    'match.delete': 'You are going to delete the match, do you want to continue?',
    'general.players': 'Players',
    'general.cancel': 'Cancel',
    'general.accept': 'Accept',
    'general.for': 'For',
    'general.myMatches': 'My Matches',
    'general.createMatch': 'Create Match',
    'general.noMatches': 'No matches available',
    'general.noParticipants': 'There are no registered players',
    'match.chat.send': 'Send',
    'match.chat.sendMessage': 'Send message...',
    'general.noPlayers': 'No players available',
    'players.filterPlayer': 'Filter players',
    'general.done': 'Done',
    'profile.usuallyPlay': 'Usually play in',
    'profile.logout': 'Log out',
    'profile.nickname': 'Nickname',
    'profile.config': 'Personal configuration',
    'profile.changePass': 'Change your password',
    'profile.changePassConfirm': 'Confirm changed password',
    'general.invite': 'Invite',
    'general.areYouGoingToInvite': 'You are going to invite',
    'general.toYourMatch': 'to your match, do you want to continue?',
    'match.wherePlay': 'In which city is it played?',
    'match.whenPlay': 'When is it played?',
    'match.whichGenre': 'What genre plays?',
    'match.whichTypes': 'What type of match is it?',
    'match.create.aproxCost': 'Approximate cost',
    'match.create.playerForMatch': 'Players missing for the match',
    'general.create': 'Create',
    'general.edit': 'Edit',
  },
  'es': {
    'general.select': 'Elegir',
    'search': 'Buscar',
    'myLocation': 'Mi ubicación',
    'manualSelection': 'Selección manual',
    'recoverPassword': 'Recuperar constraseña',
    'recover': 'Recuperar',
    'signIn': 'Iniciar sesión',
    'email': 'Email',
    'enterEmail': 'Ingresá tu correo',
    'password': 'Contraseña',
    'enterPass': 'Ingresá tu contrseña',
    'forgotPass': 'Olvidaste tu contrseña?',
    'rememberMe': 'Recordarme',
    'signInWith': 'Iniciar sesión con',
    'dontAccount': 'No tenes un usuario? ',
    'loginFails': 'Login incorrecto',
    'recoverFails': 'Recuperación incorrecta',
    'mandatoryPass': 'La contraseña es obligatoria',
    'passWithMoreSix': 'Ingresá una contraseña con mas de 6 caracteres',
    'checkCredentials': 'Revise su credenciales',
    'signUp': 'Registro',
    'fullName': 'Nombre completo',
    'enterFullName': 'Ingrese su nombre completo',
    'confirmPassword': 'Confirmar contraseña',
    'enterConfirmPassword': 'Confirmar contraseña',
    'registerFails': 'Registro incorrecto',
    'mandatoryFullName': 'El nombre completo es obligatorio',
    'mandatoryEmail': 'El email es obligatorio',
    'mandatoryConfirmPass': 'La confirmacion de la contraseña es obligatoria',
    'passNotMatch': 'Las contraseñas no coinciden',
    'invalidCredentials': 'Sus credenciales no son validas',
    'general.prev': 'Prev',
    'general.next': 'Sig',
    'general.information': 'Información',
    'general.information.completeProfile.genre': 'Selecciona tu género (Esta información no vas a poder cambiarla)',
    'general.information.completeProfile.wherePlay': 'Selecciona la ciudad en la que habitualmente juegas (Despues podras cambiar esta configuración en tu perfil)',
    'general.save': 'Guardar',
    'general.location': 'Ubicación',
    'general.distance': 'Distancia',
    'general.types.f5': 'Futbol 5',
    'general.types.f7': 'Futbol 7',
    'general.types.f9': 'Futbol 9',
    'general.types.f11': 'Futbol 11',
    'general.positions': 'Posiciones',
    'general.positions.gk': 'Arquero',
    'general.positions.def': 'Defensor',
    'general.positions.mid': 'Medio',
    'general.positions.for': 'Delantero',
    'general.genre': 'Género',
    'general.genres.male': 'Hombre',
    'general.genres.males': 'Hombres',
    'general.genres.female': 'Mujere',
    'general.genres.females': 'Mujeres',
    'general.genres.mix': 'Mixto',
    'general.filter': 'Filtrar',
    'general.matchType': 'Tipo de partido',
    'general.selectWhereToPlay': 'Selecciona la ciudad donde quieres jugar',
    'match.info': 'Información',
    'match.itPlayedIn': 'Se juega en',
    'match.isMatchType': "Es un partido de",
    'match.aproxCost': 'Tiene un costo aproximado de',
    'match.join': 'Vas a unirte al partido, deseas continuar?',
    'match.chat.join': 'Para ver el chat debes estar inscription en el partido, deseas inscribirte?',
    'match.leave': 'Vas a abandonar el partido, deseas continuar?',
    'match.delete': 'Vas a eliminar el partido, deseas continuar?',
    'general.players': 'Jugadores',
    'general.cancel': 'Cancelar',
    'general.accept': 'Aceptar',
    'general.for': 'Para',
    'general.myMatches': 'Mis Partidos',
    'general.createMatch': 'Crear Partido',
    'general.noMatches': 'No hay partidos disponibles',
    'general.noParticipants': 'No hay jugadores inscriptos',
    'match.chat.send': 'Enviar',
    'match.chat.sendMessage': 'Enviar mensaje...',
    'general.noPlayers': 'No hay jugadores disponibles',
    'players.filterPlayer': 'Filtrar jugadores',
    'general.done': 'Listo',
    'profile.usuallyPlay': 'Suele jugar en',
    'profile.logout': 'Cerrar sesión',
    'profile.config': 'Configuración personal',
    'profile.nickname': 'Nickname',
    'profile.changePass': 'Cambia tu password',
    'profile.changePassConfirm': 'Confirmá tu nueva password',
    'general.invite': 'Invitar',
    'general.areYouGoingToInvite': 'Vas a invitar a',
    'general.toYourMatch': 'a tu partido, deseas continuar?',
    'match.wherePlay': 'En qué ciudad se juega?',
    'match.whenPlay': 'Cuando se juega?',
    'match.whichGenre': 'Que género juega?',
    'match.whichTypes': 'Que tipo de partido es?',
    'match.create.aproxCost': 'Costo aproximado',
    'match.create.playerForMatch': 'Jugadores faltantes para el partido',
    'general.create': 'Crear',
    'general.edit': 'Editar',
  }
};
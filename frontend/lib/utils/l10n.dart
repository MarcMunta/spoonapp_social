import 'dart:ui';

class L10n {
  static const supportedLocales = [Locale('en'), Locale('es')];

  static const _localizedStrings = {
    'en': {
      'feed': 'Feed',
      'notifications': 'Notifications',
      'chats': 'Chats',
      'profile': 'Profile',
      'login': 'Login',
      'signup': 'Sign Up',
      'settings': 'Settings',
      'language': 'Language',
      'edit_profile': 'Edit Profile',
      'friend_requests': 'Friend Requests',
      'blocked_users': 'Blocked Users',
      'search_users': 'Search Users',
      'logout': 'Log out',
      'dark_theme': 'Dark theme',
      'not_authenticated': 'Not authenticated',
    },
    'es': {
      'feed': 'Inicio',
      'notifications': 'Notificaciones',
      'chats': 'Chats',
      'profile': 'Perfil',
      'login': 'Iniciar sesión',
      'signup': 'Registrarse',
      'settings': 'Configuración',
      'language': 'Idioma',
      'edit_profile': 'Editar perfil',
      'friend_requests': 'Solicitudes de amistad',
      'blocked_users': 'Usuarios bloqueados',
      'search_users': 'Buscar usuarios',
      'logout': 'Cerrar sesión',
      'dark_theme': 'Tema oscuro',
      'not_authenticated': 'No autenticado',
    },
  };

  static String of(Locale locale, String key) {
    final lang = _localizedStrings[locale.languageCode] ?? _localizedStrings['en']!;
    return lang[key] ?? key;
  }
}

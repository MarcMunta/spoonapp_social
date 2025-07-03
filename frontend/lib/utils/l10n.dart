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
      'hidden_stories': 'Hidden stories',
      'search_users': 'Search Users',
      'categories': 'Categories',
      'new_post': 'New Post',
      'new_story': 'New Story',
      'publish': 'Publish',
      'save': 'Save',
      'accept': 'Accept',
      'chat': 'Chat',
      'all': 'All',
      'title': 'Title',
      'image_url': 'Image URL',
      'image_url_optional': 'Image URL (optional)',
      'bio': 'Bio',
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
      'hidden_stories': 'Historias ocultas',
      'search_users': 'Buscar usuarios',
      'categories': 'Categorías',
      'new_post': 'Nuevo post',
      'new_story': 'Nueva historia',
      'publish': 'Publicar',
      'save': 'Guardar',
      'accept': 'Aceptar',
      'chat': 'Chat',
      'all': 'Todas',
      'title': 'Título',
      'image_url': 'URL de la imagen',
      'image_url_optional': 'URL de la imagen (opcional)',
      'bio': 'Biografía',
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

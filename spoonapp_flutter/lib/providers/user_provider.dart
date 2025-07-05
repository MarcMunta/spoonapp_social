import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {

  User currentUser = User(
    name: 'Alice',
    profileImage: 'https://picsum.photos/50/50',
    email: 'alice@example.com',
  );

  void setUserByLogin(String email) {
    if (email == 'alice@example.com') {
      currentUser = User(
        name: 'Alice',
        profileImage: 'https://picsum.photos/50/50',
        email: 'alice@example.com',
      );
    } else if (email == 'marc') {
      currentUser = User(
        name: 'Marc',
        // Imagen de Unsplash, permite CORS y es estable
        profileImage: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=256&h=256&facepad=2&q=80',
        email: 'marc@spoonapp.com',
      );
    }
    notifyListeners();
  }

  String? _token;

  String get token => _token ?? '';

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
}

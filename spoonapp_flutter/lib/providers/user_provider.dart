import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User currentUser = User(
    name: 'Alice',
    profileImage: 'https://picsum.photos/50/50',
    email: 'alice@example.com',
  );
}

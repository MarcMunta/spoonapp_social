import 'package:flutter/material.dart';

class MenuProvider extends ChangeNotifier {
  bool _leftOpen = false;
  bool _rightOpen = false;

  bool get leftOpen => _leftOpen;
  bool get rightOpen => _rightOpen;

  void toggleLeft() {
    _leftOpen = !_leftOpen;
    notifyListeners();
  }

  void toggleRight() {
    _rightOpen = !_rightOpen;
    notifyListeners();
  }
}

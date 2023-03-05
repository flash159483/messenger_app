import 'package:flutter/material.dart';

class NaviagationProvider with ChangeNotifier {
  int _index = 0;
  int get index => _index;

  // update the current index of the bottom navigation
  updateCurPage(int index) {
    _index = index;
    notifyListeners();
  }
}

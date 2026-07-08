import 'package:flutter/material.dart';

class ParentViewModel extends ChangeNotifier {
  int _index = 0;

  int get currentIndex => _index;

  void changeIndex(int index) {
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }

  void onCenterButtonTap() {
    // TODO: Navigate to scanner screen.
  }
}

import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _profileRefreshToken = 0;

  int get currentIndex => _currentIndex;
  int get profileRefreshToken => _profileRefreshToken;

  void selectTab(int index, {bool refreshProfile = false}) {
    _currentIndex = index;
    if (refreshProfile || index == 2) {
      _profileRefreshToken++;
    }
    notifyListeners();
  }
}

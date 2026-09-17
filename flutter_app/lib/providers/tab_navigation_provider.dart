import 'package:flutter/material.dart';

class TabNavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  PageController? _pageController;

  int get currentIndex => _currentIndex;
  PageController? get pageController => _pageController;

  void setPageController(PageController controller) {
    _pageController = controller;
  }

  void selectTab(int index) {
    _currentIndex = index;
    notifyListeners();

    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void updateIndexFromSwipe(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}

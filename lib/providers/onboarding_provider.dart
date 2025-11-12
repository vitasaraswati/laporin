import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider with ChangeNotifier {
  int _currentPage = 0;
  bool _isLastPage = false;

  int get currentPage => _currentPage;
  bool get isLastPage => _isLastPage;

  void setCurrentPage(int page, int totalPages) {
    _currentPage = page;
    _isLastPage = page == totalPages - 1;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  void reset() {
    _currentPage = 0;
    _isLastPage = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

enum AppScene { totem, storeRedemption, dashboard }

class AppCoordinator extends ChangeNotifier {
  AppScene _currentScene = AppScene.totem;
  String? _lastGeneratedCouponCode;

  AppScene get currentScene => _currentScene;
  String? get lastGeneratedCouponCode => _lastGeneratedCouponCode;

  void navigateToTotem() {
    _currentScene = AppScene.totem;
    notifyListeners();
  }

  void navigateToStoreRedemption({String? prefilledCouponCode}) {
    if (prefilledCouponCode != null) {
      _lastGeneratedCouponCode = prefilledCouponCode;
    }
    _currentScene = AppScene.storeRedemption;
    notifyListeners();
  }

  void navigateToDashboard() {
    _currentScene = AppScene.dashboard;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';

class AppCoordinator extends ChangeNotifier {
  int currentTab = 0; // 0 = Totem, 1 = Loja, 2 = Dashboard
  String? prefilledStoreCode;

  void navigateToTotem() {
    currentTab = 0;
    notifyListeners();
  }

  void navigateToStore() {
    currentTab = 1;
    notifyListeners();
  }

  void navigateToStoreWithCode(String code) {
    prefilledStoreCode = code;
    currentTab = 1; // Vai para a aba da Loja
    notifyListeners();
  }

  void navigateToDashboard() {
    currentTab = 2;
    notifyListeners();
  }
}
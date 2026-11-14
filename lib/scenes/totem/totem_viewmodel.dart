import 'package:flutter/material.dart';
import '../../data/models/coupon_feedback_model.dart';
import '../../data/repositories/intelligence_repository.dart';
import '../shell/app_coordinator.dart';

class TotemViewModel extends ChangeNotifier {
  final IIntelligenceRepository repository;
  final AppCoordinator coordinator;

  int step = 0;
  bool lgpdAccepted = false;
  String selectedAgeGroup = '25 a 34 anos';
  String selectedCategory = 'Gastronomia';
  String selectedEventFormat = 'Festival Gastronômico & Música na Praça';
  String selectedSatisfaction = 'Excelentes';
  CouponFeedbackModel? generatedCoupon;

  TotemViewModel({required this.repository, required this.coordinator});

  List<String> get categories => repository.getCategories();
  List<String> get ageGroups => repository.getAgeGroups();

  void toggleLgpd(bool value) {
    lgpdAccepted = value;
    notifyListeners();
  }

  void startSurvey() {
    if (!lgpdAccepted) return;
    step = 1;
    notifyListeners();
  }

  void selectAgeGroup(String age) {
    selectedAgeGroup = age;
    notifyListeners();
  }

  void selectCategoryAndAdvance(String category) {
    selectedCategory = category;
    step = 2;
    notifyListeners();
  }

  void selectEventFormatAndAdvance(String format) {
    selectedEventFormat = format;
    step = 3;
    notifyListeners();
  }

  void selectSatisfactionAndAdvance(String satisfaction) {
    selectedSatisfaction = satisfaction;
    step = 4;
    notifyListeners();
  }

  void previousStep() {
    if (step > 0) {
      step--;
      notifyListeners();
    }
  }

  Future<void> completeWheelAndIssueCoupon() async {
    generatedCoupon = await repository.createFeedbackAndGenerateCoupon(
      ageGroup: selectedAgeGroup,
      interestCategory: selectedCategory,
      preferredEventFormat: selectedEventFormat,
      generalSatisfaction: selectedSatisfaction,
      discountBenefit: '10% OFF',
    );
    step = 5;
    notifyListeners();
  }

  void resetFlow() {
    step = 0;
    lgpdAccepted = false;
    generatedCoupon = null;
    notifyListeners();
  }

  void goToStoreSimulation() {
    coordinator.navigateToStoreRedemption(
      prefilledCouponCode: generatedCoupon?.code,
    );
  }
}
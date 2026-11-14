import 'package:flutter/material.dart';
import '../../data/models/coupon_feedback_model.dart';
import '../../data/repositories/intelligence_repository.dart';
import '../shell/app_coordinator.dart';

class StoreRedemptionViewModel extends ChangeNotifier {
  final IIntelligenceRepository repository;
  final AppCoordinator coordinator;

  late String selectedStore;
  String? statusMessage;
  bool isSuccess = false;

  // Estado de carregamento: evita duplo toque no kiosk e da retorno visual
  // enquanto o resgate e registrado.
  bool isSubmitting = false;

  StoreRedemptionViewModel({
    required this.repository,
    required this.coordinator,
  }) {
    selectedStore = repository.getParticipatingStores().keys.first;
  }

  Map<String, String> get stores => repository.getParticipatingStores();
  List<CouponFeedbackModel> get recentCoupons => repository.getAllFeedbacks();

  void setStore(String store) {
    selectedStore = store;
    notifyListeners();
  }

  Future<void> redeemCode(String rawCode) async {
    if (rawCode.trim().isEmpty) {
      isSuccess = false;
      statusMessage = 'Informe o código do cupom para registrar o resgate.';
      notifyListeners();
      return;
    }

    isSubmitting = true;
    statusMessage = null;
    notifyListeners();

    try {
      final redeemed = await repository.redeemCoupon(
        code: rawCode,
        storeName: selectedStore,
      );
      isSuccess = true;
      statusMessage =
          'Resgate registrado com sucesso! O cupom ${redeemed.code} (${redeemed.interestCategory}) foi vinculado à loja "$selectedStore".';
    } catch (e) {
      isSuccess = false;
      statusMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isSubmitting = false;
    }
    notifyListeners();
  }
}

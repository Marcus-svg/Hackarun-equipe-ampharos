import 'package:flutter/material.dart';
import '../../data/models/coupon_feedback_model.dart';
import '../../data/repositories/intelligence_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final IIntelligenceRepository repository;

  DashboardViewModel({required this.repository});

  List<CouponFeedbackModel> get feedbacks => repository.getAllFeedbacks();
  List<String> get categories => repository.getCategories();
  Map<String, int> get storeClients =>
      repository.getStoreRegisteredClientsByCategory();
  List> get googlePerceptions =>
      repository.getGoogleBusinessPerceptions();
  List> get publicTrends => repository.getPublicTrends();

  int get totalIssued => feedbacks.length;
  int get totalRedeemed => feedbacks.where((f) => f.isRedeemed).length;

  int get redemptionRatePercent {
    if (totalIssued == 0) return 0;
    return ((totalRedeemed / totalIssued) * 100).round();
  }

  int get totalStoreClients =>
      storeClients.values.fold<int>(0, (sum, v) => sum + v);

  Map<String, int> get redemptionsByStore {
    final Map<String, int> map = {};
    for (final item in feedbacks) {
      if (item.isRedeemed && item.redeemedStoreName != null) {
        map[item.redeemedStoreName!] = (map[item.redeemedStoreName!] ?? 0) + 1;
      }
    }
    return map;
  }
}
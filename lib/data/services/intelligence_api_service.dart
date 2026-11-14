import 'dart:math';
import '../models/coupon_feedback_model.dart';

class IntelligenceApiService {
  final List<CouponFeedbackModel> _remoteDatabase = [
    CouponFeedbackModel(
      code: 'CD-4821',
      ageGroup: '25 a 34 anos',
      interestCategory: 'Gastronomia',
      preferredEventFormat: 'Festival Gastronômico & Música na Praça',
      generalSatisfaction: 'Excelentes',
      discountBenefit: '10% OFF',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRedeemed: true,
      redeemedStoreName: 'Outback / Praça Alimentação',
    ),
    CouponFeedbackModel(
      code: 'CD-9104',
      ageGroup: '18 a 24 anos',
      interestCategory: 'Tecnologia',
      preferredEventFormat: 'Arena Games, Tecnologia & Robótica',
      generalSatisfaction: 'Boas',
      discountBenefit: '10% OFF',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRedeemed: true,
      redeemedStoreName: 'iPlace / Kalunga',
    ),
    CouponFeedbackModel(
      code: 'CD-3319',
      ageGroup: '35 a 49 anos',
      interestCategory: 'Música',
      preferredEventFormat: 'Festival Gastronômico & Música na Praça',
      generalSatisfaction: 'Excelentes',
      discountBenefit: 'Mimo Exclusivo',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRedeemed: false,
    ),
    CouponFeedbackModel(
      code: 'CD-7740',
      ageGroup: '25 a 34 anos',
      interestCategory: 'Esportes',
      preferredEventFormat: 'Ativações Esportivas & Bem-Estar',
      generalSatisfaction: 'Excelentes',
      discountBenefit: '10% OFF',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRedeemed: true,
      redeemedStoreName: 'Centauro / Artigos Esportivos',
    ),
    CouponFeedbackModel(
      code: 'CD-5512',
      ageGroup: '35 a 49 anos',
      interestCategory: 'Gastronomia',
      preferredEventFormat: 'Festival Gastronômico & Música na Praça',
      generalSatisfaction: 'Boas',
      discountBenefit: '5% OFF',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      isRedeemed: true,
      redeemedStoreName: 'Outback / Praça Alimentação',
    ),
    CouponFeedbackModel(
      code: 'CD-8832',
      ageGroup: '25 a 34 anos',
      interestCategory: 'Moda',
      preferredEventFormat: 'Moda, Desfiles & Promoções Sazonais',
      generalSatisfaction: 'Excelentes',
      discountBenefit: '10% OFF',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRedeemed: true,
      redeemedStoreName: 'Renner / Vestuário',
    ),
  ];

  List<CouponFeedbackModel> fetchFeedbacks() =>
      List.unmodifiable(_remoteDatabase);

  Future<CouponFeedbackModel> postFeedback({
    required String ageGroup,
    required String interestCategory,
    required String preferredEventFormat,
    required String generalSatisfaction,
    required String discountBenefit,
  }) async {
    final code = 'CD-${1000 + Random().nextInt(8999)}';
    final model = CouponFeedbackModel(
      code: code,
      ageGroup: ageGroup,
      interestCategory: interestCategory,
      preferredEventFormat: preferredEventFormat,
      generalSatisfaction: generalSatisfaction,
      discountBenefit: discountBenefit,
      createdAt: DateTime.now(),
    );
    _remoteDatabase.insert(0, model);
    return model;
  }

  Future<CouponFeedbackModel> patchRedeemCoupon({
    required String code,
    required String storeName,
  }) async {
    final normalized = code.trim().toUpperCase();
    final idx = _remoteDatabase.indexWhere((c) => c.code == normalized);
    if (idx == -1) {
      throw Exception('Código de cupom "$normalized" não localizado.');
    }
    _remoteDatabase[idx].isRedeemed = true;
    _remoteDatabase[idx].redeemedStoreName = storeName;
    return _remoteDatabase[idx];
  }
}
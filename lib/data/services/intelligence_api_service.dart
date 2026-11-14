import 'dart:math';
import '../models/coupon_feedback_model.dart';

class IntelligenceApiService {
  final int baseHistoricalConsumers = 1242;
  final List<int> baseWeeklyParticipations = [260, 294, 318, 370];

  final List<CouponFeedbackModel> _liveDatabase = [
    CouponFeedbackModel(
      code: 'CD-4821',
      ageGroup: '25 a 34 anos',
      interestCategory: 'Gastronomia',
      preferredEventFormat: 'Festival Gastronomico & Degustacoes',
      generalSatisfaction: 'Excelentes',
      discountBenefit: '10% OFF',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRedeemed: true,
      redeemedStoreName: 'Outback / Praca de Alimentacao',
    ),
    CouponFeedbackModel(
      code: 'CD-9104',
      ageGroup: '18 a 24 anos',
      interestCategory: 'Musica',
      preferredEventFormat: 'Shows Acusticos & Palco Cultural',
      generalSatisfaction: 'Excelentes',
      discountBenefit: '10% OFF',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRedeemed: true,
      redeemedStoreName: 'Palco Praca Gourmet',
    ),
    CouponFeedbackModel(
      code: 'CD-3319',
      ageGroup: '25 a 34 anos',
      interestCategory: 'Tecnologia',
      preferredEventFormat: 'Experiencias Digitais & Arena Games',
      generalSatisfaction: 'Boas',
      discountBenefit: 'Mimo Exclusivo',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRedeemed: false,
    ),
    CouponFeedbackModel(
      code: 'CD-7740',
      ageGroup: '35 a 44 anos',
      interestCategory: 'Gastronomia',
      preferredEventFormat: 'Festival Gastronomico & Degustacoes',
      generalSatisfaction: 'Excelentes',
      discountBenefit: '10% OFF',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRedeemed: true,
      redeemedStoreName: 'Outback / Praca de Alimentacao',
    ),
    CouponFeedbackModel(
      code: 'CD-5512',
      ageGroup: '45 anos ou mais',
      interestCategory: 'Cultura',
      preferredEventFormat: 'Feira Cultural & Artesanato Regional',
      generalSatisfaction: 'Boas',
      discountBenefit: '5% OFF',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      isRedeemed: true,
      redeemedStoreName: 'Livraria / Espaco Cultural',
    ),
    CouponFeedbackModel(
      code: 'CD-8832',
      ageGroup: '18 a 24 anos',
      interestCategory: 'Entretenimento',
      preferredEventFormat: 'Sessoes Especiais & Lazer',
      generalSatisfaction: 'Excelentes',
      discountBenefit: '10% OFF',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRedeemed: true,
      redeemedStoreName: 'Cinemark / Lazer',
    ),
  ];

  List<CouponFeedbackModel> fetchFeedbacks() =>
      List.unmodifiable(_liveDatabase);

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
    _liveDatabase.insert(0, model);
    return model;
  }

  Future<CouponFeedbackModel> patchRedeemCoupon({
    required String code,
    required String storeName,
  }) async {
    final normalized = code.trim().toUpperCase();
    final idx = _liveDatabase.indexWhere((c) => c.code == normalized);
    if (idx == -1) {
      throw Exception('Codigo de cupom "$normalized" nao encontrado.');
    }
    _liveDatabase[idx].isRedeemed = true;
    _liveDatabase[idx].redeemedStoreName = storeName;
    return _liveDatabase[idx];
  }
}
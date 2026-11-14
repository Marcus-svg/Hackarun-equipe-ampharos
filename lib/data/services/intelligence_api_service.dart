import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/coupon_feedback_model.dart';

class IntelligenceApiService {
  // URL do backend FastAPI (pode ser sobrescrita no build com --dart-define=API_BASE_URL=...)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  final int baseHistoricalConsumers = 1242;
  final List<int> baseWeeklyParticipations = [260, 294, 318, 370];

  bool isBackendOnline = false;
  int backendObservationsCount = 0;
  int backendTrendPointsCount = 0;
  int backendPlaceLocationsCount = 0;
  int backendRegionalEventsCount = 0;
  String googleTrendsStatus = 'offline_until_csv_import';
  String googlePlacesStatus = 'pending_credentials';

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

  IntelligenceApiService() {
    syncWithBackend();
  }

  /// Sincroniza com o backend Python/FastAPI (SQLite hackarun.db) se estiver disponível
  Future<void> syncWithBackend() async {
    try {
      final summaryResp = await http
          .get(Uri.parse('$baseUrl/dashboard/summary'))
          .timeout(const Duration(seconds: 3));

      if (summaryResp.statusCode == 200) {
        final data = jsonDecode(summaryResp.body);
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        isBackendOnline = true;
        backendObservationsCount = (summary['observations'] as num?)?.toInt() ?? 0;
        backendTrendPointsCount = (summary['trend_points'] as num?)?.toInt() ?? 0;
        backendPlaceLocationsCount = (summary['place_locations'] as num?)?.toInt() ?? 0;
        backendRegionalEventsCount = (summary['regional_events'] as num?)?.toInt() ?? 0;

        final sourceStatus = summary['source_status'] as Map<String, dynamic>? ?? {};
        googleTrendsStatus = sourceStatus['google_trends']?.toString() ?? 'functional';
        googlePlacesStatus = sourceStatus['google_places']?.toString() ?? 'pending_credentials';
      }

      final totemResp = await http
          .get(Uri.parse('$baseUrl/totem/feedbacks'))
          .timeout(const Duration(seconds: 3));

      if (totemResp.statusCode == 200) {
        final data = jsonDecode(totemResp.body);
        final items = (data['items'] as List<dynamic>? ?? []);
        for (final raw in items.reversed) {
          final map = raw as Map<String, dynamic>;
          final code = (map['code'] ?? '').toString();
          if (code.isEmpty) continue;
          final existingIdx = _liveDatabase.indexWhere((c) => c.code == code);
          final model = CouponFeedbackModel(
            code: code,
            ageGroup: (map['age_group'] ?? '25 a 34 anos').toString(),
            interestCategory: (map['interest_category'] ?? 'Gastronomia').toString(),
            preferredEventFormat: (map['preferred_event_format'] ?? '').toString(),
            generalSatisfaction: (map['general_satisfaction'] ?? 'Excelentes').toString(),
            discountBenefit: (map['discount_benefit'] ?? '10% OFF').toString(),
            createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()) ?? DateTime.now(),
            isRedeemed: map['is_redeemed'] == true,
            redeemedStoreName: map['redeemed_store_name']?.toString(),
          );
          if (existingIdx == -1) {
            _liveDatabase.insert(0, model);
          } else {
            _liveDatabase[existingIdx] = model;
          }
        }
      }
    } catch (_) {
      // Fallback silencioso para operação offline/Vercel estático
      isBackendOnline = false;
    }
  }

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

    try {
      final resp = await http
          .post(
        Uri.parse('$baseUrl/totem/feedbacks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'age_group': ageGroup,
          'interest_category': interestCategory,
          'preferred_event_format': preferredEventFormat,
          'general_satisfaction': generalSatisfaction,
          'discount_benefit': discountBenefit,
        }),
      )
          .timeout(const Duration(seconds: 3));

      if (resp.statusCode == 200) {
        isBackendOnline = true;
      }
    } catch (_) {
      // Mantém salvo em memória caso o backend local esteja desligado
    }

    return model;
  }

  Future<CouponFeedbackModel> patchRedeemCoupon({
    required String code,
    required String storeName,
  }) async {
    final normalized = code.trim().toUpperCase();
    final idx = _liveDatabase.indexWhere((c) => c.code == normalized);

    // Tenta validar e persistir no backend FastAPI primeiro
    try {
      final resp = await http
          .patch(
        Uri.parse('$baseUrl/totem/feedbacks/$normalized/redeem'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'store_name': storeName}),
      )
          .timeout(const Duration(seconds: 3));

      if (resp.statusCode == 200) {
        isBackendOnline = true;
        final item = (jsonDecode(resp.body)['item'] as Map<String, dynamic>);
        final updated = CouponFeedbackModel(
          code: (item['code'] ?? normalized).toString(),
          ageGroup: (item['age_group'] ?? '25 a 34 anos').toString(),
          interestCategory: (item['interest_category'] ?? 'Gastronomia').toString(),
          preferredEventFormat: (item['preferred_event_format'] ?? '').toString(),
          generalSatisfaction: (item['general_satisfaction'] ?? 'Excelentes').toString(),
          discountBenefit: (item['discount_benefit'] ?? '10% OFF').toString(),
          createdAt: DateTime.tryParse((item['created_at'] ?? '').toString()) ?? DateTime.now(),
          isRedeemed: true,
          redeemedStoreName: storeName,
        );
        if (idx != -1) {
          _liveDatabase[idx] = updated;
        } else {
          _liveDatabase.insert(0, updated);
        }
        return updated;
      }
    } catch (_) {
      // Fallback para o banco em memória se o backend não estiver rodando
    }

    if (idx == -1) {
      throw Exception(
          'Código de cupom "$normalized" não encontrado. Confira o código e tente novamente.');
    }
    _liveDatabase[idx].isRedeemed = true;
    _liveDatabase[idx].redeemedStoreName = storeName;
    return _liveDatabase[idx];
  }
}
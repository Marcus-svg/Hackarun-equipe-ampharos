import '../models/coupon_feedback_model.dart';
import '../services/intelligence_api_service.dart';

abstract class IIntelligenceRepository {
  List<String> getCategories();
  List<String> getAgeGroups();
  Map<String, String> getParticipatingStores();
  List<CouponFeedbackModel> getAllFeedbacks();

  int getTotalConsumersCount();
  List<int> getWeeklyParticipations();
  List<CategoryMetricModel> getCategoryMetrics();
  CategoryMetricModel getCategoryDetail(String categoryName);
  List<AudienceProfileModel> getAudienceProfiles();
  List<GooglePerceptionModel> getGoogleBusinessPerceptions();

  // Telemetria e Sincronização com o Backend Python/FastAPI (OSINT + SQLite)
  bool get isBackendOnline;
  int get backendObservationsCount;
  int get backendTrendPointsCount;
  int get backendPlaceLocationsCount;
  int get backendRegionalEventsCount;
  String get googleTrendsStatus;
  String get googlePlacesStatus;
  Future<void> syncBackend();

  Future<CouponFeedbackModel> createFeedbackAndGenerateCoupon({
    required String ageGroup,
    required String interestCategory,
    required String preferredEventFormat,
    required String generalSatisfaction,
    required String discountBenefit,
  });

  Future<CouponFeedbackModel> redeemCoupon({
    required String code,
    required String storeName,
  });
}

class IntelligenceRepositoryImpl implements IIntelligenceRepository {
  final IntelligenceApiService apiService;

  IntelligenceRepositoryImpl({required this.apiService});

  @override
  bool get isBackendOnline => apiService.isBackendOnline;

  @override
  int get backendObservationsCount => apiService.backendObservationsCount;

  @override
  int get backendTrendPointsCount => apiService.backendTrendPointsCount;

  @override
  int get backendPlaceLocationsCount => apiService.backendPlaceLocationsCount;

  @override
  int get backendRegionalEventsCount => apiService.backendRegionalEventsCount;

  @override
  String get googleTrendsStatus => apiService.googleTrendsStatus;

  @override
  String get googlePlacesStatus => apiService.googlePlacesStatus;

  @override
  Future<void> syncBackend() => apiService.syncWithBackend();

  @override
  List<String> getCategories() => const [
    'Gastronomia',
    'Musica',
    'Entretenimento',
    'Tecnologia',
    'Moda',
    'Cultura',
    'Esportes',
  ];

  @override
  List<String> getAgeGroups() => const [
    '18 a 24 anos',
    '25 a 34 anos',
    '35 a 44 anos',
    '45 anos ou mais',
  ];

  @override
  Map<String, String> getParticipatingStores() => const {
    'Outback / Praca de Alimentacao': 'Gastronomia',
    'Palco Praca Gourmet': 'Musica',
    'Cinemark / Lazer': 'Entretenimento',
    'iPlace / Kalunga': 'Tecnologia',
    'Renner / Vestuario': 'Moda',
    'Livraria / Espaco Cultural': 'Cultura',
    'Centauro / Artigos Esportivos': 'Esportes',
  };

  @override
  List<CouponFeedbackModel> getAllFeedbacks() => apiService.fetchFeedbacks();

  @override
  int getTotalConsumersCount() {
    return apiService.baseHistoricalConsumers +
        apiService.fetchFeedbacks().length;
  }

  @override
  List<int> getWeeklyParticipations() {
    final base = List<int>.from(apiService.baseWeeklyParticipations);
    base[3] += apiService.fetchFeedbacks().length;
    return base;
  }

  @override
  List<CategoryMetricModel> getCategoryMetrics() {
    final live = apiService.fetchFeedbacks();
    int extra(String cat) =>
        live.where((f) => f.interestCategory == cat).length;

    return [
      CategoryMetricModel(
        name: 'Gastronomia',
        baseInterestedCount: 772 + extra('Gastronomia'),
        augustPercentage: 58,
        monthlyTrendJunToSep: const [52, 55, 58, 62],
        ageGroupAffinity: const {
          '18 a 24 anos': 48,
          '25 a 34 anos': 72,
          '35 a 44 anos': 65,
          '45 anos ou mais': 60,
        },
        opportunityTitle: 'Sabores que aproximam',
        opportunityDescription:
        'Considere festivais e degustações para o público de 25 a 34 anos.',
      ),
      CategoryMetricModel(
        name: 'Musica',
        baseInterestedCount: 673 + extra('Musica'),
        augustPercentage: 50,
        monthlyTrendJunToSep: const [45, 48, 50, 54],
        ageGroupAffinity: const {
          '18 a 24 anos': 68,
          '25 a 34 anos': 56,
          '35 a 44 anos': 44,
          '45 anos ou mais': 38,
        },
        opportunityTitle: 'Palco ao entardecer',
        opportunityDescription:
        'Shows acústicos e programação musical atraem fortemente o público de 18 a 24 anos.',
      ),
      CategoryMetricModel(
        name: 'Entretenimento',
        baseInterestedCount: 573 + extra('Entretenimento'),
        augustPercentage: 44,
        monthlyTrendJunToSep: const [40, 42, 44, 46],
        ageGroupAffinity: const {
          '18 a 24 anos': 58,
          '25 a 34 anos': 49,
          '35 a 44 anos': 42,
          '45 anos ou mais': 31,
        },
        opportunityTitle: 'Lazer em família e amigos',
        opportunityDescription:
        'Atrações interativas e sessões especiais elevam o tempo de permanência.',
      ),
      CategoryMetricModel(
        name: 'Tecnologia',
        baseInterestedCount: 436 + extra('Tecnologia'),
        augustPercentage: 27,
        monthlyTrendJunToSep: const [24, 26, 27, 35],
        ageGroupAffinity: const {
          '18 a 24 anos': 52,
          '25 a 34 anos': 41,
          '35 a 44 anos': 28,
          '45 anos ou mais': 18,
        },
        opportunityTitle: 'Experiências digitais em alta',
        opportunityDescription:
        'Maior crescimento do mês (+8 p.p.). Considere arenas games e demonstrações.',
      ),
      CategoryMetricModel(
        name: 'Moda',
        baseInterestedCount: 374 + extra('Moda'),
        augustPercentage: 31,
        monthlyTrendJunToSep: const [29, 30, 31, 30],
        ageGroupAffinity: const {
          '18 a 24 anos': 34,
          '25 a 34 anos': 36,
          '35 a 44 anos': 29,
          '45 anos ou mais': 24,
        },
        opportunityTitle: 'Lançamentos de estação',
        opportunityDescription:
        'Combine vitrines sazonais com benefícios cruzados nas lojas de vestuário.',
      ),
      CategoryMetricModel(
        name: 'Cultura',
        baseInterestedCount: 323 + extra('Cultura'),
        augustPercentage: 24,
        monthlyTrendJunToSep: const [21, 23, 24, 26],
        ageGroupAffinity: const {
          '18 a 24 anos': 22,
          '25 a 34 anos': 25,
          '35 a 44 anos': 28,
          '45 anos ou mais': 42,
        },
        opportunityTitle: 'Identidade regional e leitura',
        opportunityDescription:
        'Principal interesse do público 45+. Explore exposições e feiras regionais.',
      ),
      CategoryMetricModel(
        name: 'Esportes',
        baseInterestedCount: 262 + extra('Esportes'),
        augustPercentage: 20,
        monthlyTrendJunToSep: const [18, 19, 20, 21],
        ageGroupAffinity: const {
          '18 a 24 anos': 26,
          '25 a 34 anos': 28,
          '35 a 44 anos': 19,
          '45 anos ou mais': 14,
        },
        opportunityTitle: 'Vida ativa e bem-estar',
        opportunityDescription:
        'Retirada de kits de corridas e ativações esportivas geram fluxo qualificado.',
      ),
    ];
  }

  @override
  CategoryMetricModel getCategoryDetail(String categoryName) {
    final all = getCategoryMetrics();
    return all.firstWhere(
          (c) => c.name == categoryName,
      orElse: () => all.first,
    );
  }

  @override
  List<AudienceProfileModel> getAudienceProfiles() {
    final live = apiService.fetchFeedbacks();
    int extraAge(String age) => live.where((f) => f.ageGroup == age).length;

    return [
      AudienceProfileModel(
        ageGroup: '18 a 24 anos',
        baseConsumers: 347 + extraAge('18 a 24 anos'),
        topInterest: 'Musica',
      ),
      AudienceProfileModel(
        ageGroup: '25 a 34 anos',
        baseConsumers: 447 + extraAge('25 a 34 anos'),
        topInterest: 'Gastronomia',
      ),
      AudienceProfileModel(
        ageGroup: '35 a 44 anos',
        baseConsumers: 274 + extraAge('35 a 44 anos'),
        topInterest: 'Gastronomia',
      ),
      AudienceProfileModel(
        ageGroup: '45 anos ou mais',
        baseConsumers: 174 + extraAge('45 anos ou mais'),
        topInterest: 'Cultura',
      ),
    ];
  }

  @override
  List<GooglePerceptionModel> getGoogleBusinessPerceptions() => const [
    GooglePerceptionModel(
      theme: 'Conforto Térmico e Estrutura',
      sentiment: '92% Positivo',
      detail: 'Visitantes destacam o ambiente climatizado e seguro.',
    ),
    GooglePerceptionModel(
      theme: 'Praça de Alimentação e Eventos',
      sentiment: '88% Positivo',
      detail: 'Atrações musicais e gastronômicas elevam a nota média (4.6).',
    ),
    GooglePerceptionModel(
      theme: 'Lazer Familiar e Conveniência',
      sentiment: '85% Positivo',
      detail: 'Forte aprovação em programações de fim de semana.',
    ),
  ];

  @override
  Future<CouponFeedbackModel> createFeedbackAndGenerateCoupon({
    required String ageGroup,
    required String interestCategory,
    required String preferredEventFormat,
    required String generalSatisfaction,
    required String discountBenefit,
  }) {
    return apiService.postFeedback(
      ageGroup: ageGroup,
      interestCategory: interestCategory,
      preferredEventFormat: preferredEventFormat,
      generalSatisfaction: generalSatisfaction,
      discountBenefit: discountBenefit,
    );
  }

  @override
  Future<CouponFeedbackModel> redeemCoupon({
    required String code,
    required String storeName,
  }) {
    return apiService.patchRedeemCoupon(code: code, storeName: storeName);
  }
}
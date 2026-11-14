import '../models/coupon_feedback_model.dart';
import '../services/intelligence_api_service.dart';

abstract class IIntelligenceRepository {
  List<String> getCategories();
  List<String> getAgeGroups();
  Map<String, String> getParticipatingStores();
  List<CouponFeedbackModel> getAllFeedbacks();
  Map<String, int> getStoreRegisteredClientsByCategory();
  List> getGoogleBusinessPerceptions();
  List> getPublicTrends();

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
  List<String> getCategories() => const [
        'Gastronomia',
        'Música',
        'Tecnologia',
        'Moda',
        'Esportes',
        'Cultura',
        'Entretenimento',
      ];

  @override
  List<String> getAgeGroups() => const [
        '18 a 24 anos',
        '25 a 34 anos',
        '35 a 49 anos',
        '50+ anos',
      ];

  @override
  Map<String, String> getParticipatingStores() => const {
        'Outback / Praça Alimentação': 'Gastronomia',
        'Cinemark / Lazer': 'Entretenimento',
        'Centauro / Artigos Esportivos': 'Esportes',
        'Renner / Vestuário': 'Moda',
        'iPlace / Kalunga': 'Tecnologia',
        'Livraria / Espaço Cultural': 'Cultura',
        'Palco Praça Gourmet': 'Música',
      };

  @override
  List<CouponFeedbackModel> getAllFeedbacks() => apiService.fetchFeedbacks();

  @override
  Map<String, int> getStoreRegisteredClientsByCategory() => const {
        'Gastronomia': 420,
        'Moda': 390,
        'Entretenimento': 310,
        'Esportes': 240,
        'Tecnologia': 210,
        'Música': 180,
        'Cultura': 150,
      };

  @override
  List> getGoogleBusinessPerceptions() => const [
        {
          'tema': 'Climatização & Conforto Térmico',
          'sentimento': '92% Positivo',
          'detalhe': 'Principal atrativo em horários de calor intenso em Palmas.'
        },
        {
          'tema': 'Atrações na Praça de Alimentação',
          'sentimento': '87% Positivo',
          'detalhe': 'Eventos musicais e gastronômicos elevam a permanência.'
        },
        {
          'tema': 'Programação Familiar & Pet Friendly',
          'sentimento': '84% Positivo',
          'detalhe': 'Forte engajamento aos fins de semana em ações recreativas.'
        },
      ];

  @override
  List> getPublicTrends() => const [
        {
          'categoria': 'Gastronomia & Música',
          'tendencia': '+44% nas buscas locais',
          'oportunidade': 'Festival Gastronômico Tocantinense com shows acústicos.'
        },
        {
          'categoria': 'Esportes & Bem-Estar',
          'tendencia': '+38% em interesse',
          'oportunidade': 'Aulões e entrega de kits de corridas/eventos esportivos.'
        },
        {
          'categoria': 'Tecnologia & Cultura Pop',
          'tendencia': '+31% público jovem',
          'oportunidade': 'Arena Games e Robótica no período de férias.'
        },
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
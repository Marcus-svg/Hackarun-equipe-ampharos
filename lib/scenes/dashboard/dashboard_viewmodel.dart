import 'package:flutter/material.dart';
import '../../data/models/coupon_feedback_model.dart';
import '../../data/repositories/intelligence_repository.dart';

enum AdminTab { visaoGeral, publicos, interesses, tendencias, relatorios }

class DashboardViewModel extends ChangeNotifier {
  final IIntelligenceRepository repository;

  // Controla se o gestor está na tela 01 (Acesso/Login) ou dentro do Painel (02 a 06)
  bool isAuthenticated = true;

  // Aba ativa do Painel Administrativo (02 a 06)
  AdminTab currentTab = AdminTab.visaoGeral;

  // Filtros e seleções interativas das telas 03, 04, 05 e 06
  String selectedAgeFilter = 'Todas as idades';
  String selectedCategoryName = 'Gastronomia';
  String selectedReportFormat = 'PDF';
  String? reportFeedbackMessage;

  final generatedReports = [
  {
  'titulo': 'Resumo de agosto',
  'data': '31 ago. 2026',
  'formato': 'PDF',
  'acao': 'Baixar PDF',
  },
  {
  'titulo': 'Resumo de julho',
  'data': '31 jul. 2026',
  'formato': 'CSV',
  'acao': 'Baixar CSV',
  },
  ];

  DashboardViewModel({required this.repository});

  // Dados brutos e métricas consolidadas do Repositório
  List<CouponFeedbackModel> get feedbacks => repository.getAllFeedbacks();
  List<String> get categories => repository.getCategories();
  List<CategoryMetricModel> get categoryMetrics =>
      repository.getCategoryMetrics();
  List<AudienceProfileModel> get audienceProfiles =>
      repository.getAudienceProfiles();
  List<GooglePerceptionModel> get googlePerceptions =>
      repository.getGoogleBusinessPerceptions();
  List<int> get weeklyParticipations => repository.getWeeklyParticipations();

  int get totalConsumers => repository.getTotalConsumersCount();

  String get totalConsumersFormatted {
    final s = totalConsumers.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
  }

  // Indicadores de Cupons (Fonte 1 + Fonte 2)
  int get totalIssued => feedbacks.length;
  int get totalRedeemed => feedbacks.where((f) => f.isRedeemed).length;

  int get redemptionRatePercent {
    if (totalIssued == 0) return 0;
    return ((totalRedeemed / totalIssued) * 100).round();
  }

  Map<String, int> get redemptionsByStore {
    final Map<String, int> map = {};
    for (final item in feedbacks) {
      if (item.isRedeemed && item.redeemedStoreName != null) {
        map[item.redeemedStoreName!] = (map[item.redeemedStoreName!] ?? 0) + 1;
      }
    }
    return map;
  }

  CategoryMetricModel get selectedCategoryDetail =>
      repository.getCategoryDetail(selectedCategoryName);

  int getCategoryPercentage(CategoryMetricModel model) {
    final total = totalConsumers == 0 ? 1 : totalConsumers;
    return ((model.baseInterestedCount / total) * 100).round().clamp(1, 100);
  }

  // Ações de Navegação e Interação
  void login() {
    isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    isAuthenticated = false;
    notifyListeners();
  }

  void setTab(AdminTab tab) {
    currentTab = tab;
    reportFeedbackMessage = null;
    notifyListeners();
  }

  void selectCategory(String category) {
    selectedCategoryName = category;
    notifyListeners();
  }

  void setAgeFilter(String filter) {
    selectedAgeFilter = filter;
    notifyListeners();
  }

  void setReportFormat(String format) {
    selectedReportFormat = format;
    notifyListeners();
  }

  void generateNewReport() {
    generatedReports.insert(0, {
      'titulo': 'Resumo de setembro (Atualizado)',
      'data': 'Set. 2026',
      'formato': selectedReportFormat,
      'acao': 'Baixar $selectedReportFormat',
    });
    reportFeedbackMessage =
    'Relatório em formato $selectedReportFormat gerado com sucesso com base nos$totalConsumersFormatted consumidores!';
    notifyListeners();
  }
}
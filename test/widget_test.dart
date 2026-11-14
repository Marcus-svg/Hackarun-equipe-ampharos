import 'package:flutter_test/flutter_test.dart';
import 'package:totem_capim_dourado/data/repositories/intelligence_repository.dart';
import 'package:totem_capim_dourado/data/services/intelligence_api_service.dart';
import 'package:totem_capim_dourado/scenes/dashboard/dashboard_viewmodel.dart';
import 'package:totem_capim_dourado/scenes/shell/app_coordinator.dart';
import 'package:totem_capim_dourado/scenes/totem/totem_viewmodel.dart';

void main() {
  group('Capim Dourado Experience Intelligence - Testes Unitários MVVM', () {
    late IIntelligenceRepository repository;
    late AppCoordinator coordinator;
    late TotemViewModel totemViewModel;
    late DashboardViewModel dashboardViewModel;

    setUp(() {
      repository = IntelligenceRepositoryImpl(
        apiService: IntelligenceApiService(),
      );
      coordinator = AppCoordinator();
      totemViewModel = TotemViewModel(
        repository: repository,
        coordinator: coordinator,
      );
      dashboardViewModel = DashboardViewModel(repository: repository);
    });

    test('LGPD: Bloqueia inicio da pesquisa sem consentimento explicito', () {
      expect(totemViewModel.step, 0);
      totemViewModel.startSurvey();
      expect(totemViewModel.step, 0);

      totemViewModel.toggleLgpd(true);
      totemViewModel.startSurvey();
      expect(totemViewModel.step, 1);
    });

    test('Fluxo do Cupom: Emissao no Totem e Resgate na Loja atualizam Dashboard', () async {
      final totalInicial = dashboardViewModel.totalIssued;
      final resgatesIniciais = dashboardViewModel.totalRedeemed;

      totemViewModel.selectAgeGroup('18 a 24 anos');
      totemViewModel.selectCategoryAndAdvance('Tecnologia');
      await totemViewModel.completeWheelAndIssueCoupon();

      final novoCupom = totemViewModel.generatedCoupon;
      expect(novoCupom, isNotNull);
      expect(dashboardViewModel.totalIssued, totalInicial + 1);
      expect(novoCupom!.isRedeemed, isFalse);

      await repository.redeemCoupon(
        code: novoCupom.code,
        storeName: 'iPlace / Kalunga',
      );

      expect(dashboardViewModel.totalRedeemed, resgatesIniciais + 1);
    });
  });
}
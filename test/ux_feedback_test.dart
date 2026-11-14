import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_capim_dourado/core/di/service_locator.dart';
import 'package:totem_capim_dourado/data/repositories/intelligence_repository.dart';
import 'package:totem_capim_dourado/data/services/intelligence_api_service.dart';
import 'package:totem_capim_dourado/main.dart';
import 'package:totem_capim_dourado/scenes/shell/app_coordinator.dart';
import 'package:totem_capim_dourado/scenes/store_redemption/store_view.dart';
import 'package:totem_capim_dourado/scenes/store_redemption/store_viewmodel.dart';
import 'package:totem_capim_dourado/scenes/totem/totem_view.dart';
import 'package:totem_capim_dourado/scenes/totem/totem_viewmodel.dart';

/// Cobre estados de feedback (sucesso/erro/vazio), acessibilidade e alvos de
/// toque introduzidos nesta rodada de melhorias de UX/UI.
void main() {
  IIntelligenceRepository buildRepository() =>
      IntelligenceRepositoryImpl(apiService: IntelligenceApiService());

  group('Loja - estados de feedback do resgate', () {
    Future<StoreRedemptionViewModel> pumpStore(WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final coordinator = AppCoordinator();
      ServiceLocator.coordinator = coordinator;
      ServiceLocator.repository = buildRepository();

      final vm = StoreRedemptionViewModel(
        repository: ServiceLocator.repository,
        coordinator: coordinator,
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StoreRedemptionView(viewModel: vm))),
      );
      return vm;
    }

    testWidgets('Código vazio mostra orientação clara (estado de erro)',
        (tester) async {
      await pumpStore(tester);

      await tester.tap(find.text('Registrar Resgate pelo Código'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text('Informe o código do cupom para registrar o resgate.'),
        findsOneWidget,
      );
      // O erro não depende apenas da cor: há ícone associado.
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Resgate válido mostra sucesso com ícone e mensagem revisada',
        (tester) async {
      await pumpStore(tester);

      await tester.enterText(
        find.byType(TextField),
        'CD-3319',
      );
      await tester.tap(find.text('Registrar Resgate pelo Código'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.textContaining('vinculado à loja'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Totem - acessibilidade e ergonomia', () {
    testWidgets('Consentimento LGPD expõe estado marcado/desmarcado',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final handle = tester.ensureSemantics();
      addTearDown(handle.dispose);

      final coordinator = AppCoordinator();
      final vm = TotemViewModel(
        repository: buildRepository(),
        coordinator: coordinator,
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: TotemView(viewModel: vm))),
      );

      final lgpdRow = find.ancestor(
        of: find.text('Privacidade Garantida (Sem CPF ou Nome)'),
        matching: find.byType(MergeSemantics),
      );
      expect(lgpdRow, findsOneWidget);

      expect(tester.getSemantics(lgpdRow).hasCheckedState, isTrue);
      expect(tester.getSemantics(lgpdRow).isChecked, isFalse);

      await tester.tap(find.text('Privacidade Garantida (Sem CPF ou Nome)'));
      await tester.pump();

      expect(tester.getSemantics(lgpdRow).isChecked, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Abas do cabeçalho têm alvo de toque de pelo menos 44px',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      ServiceLocator.coordinator = AppCoordinator();
      ServiceLocator.repository = buildRepository();

      await tester.pumpWidget(const MaterialApp(home: ShellView()));
      await tester.pump();

      for (final label in ['1. Totem', '2. Loja', '3. Dashboard']) {
        final target = find
            .ancestor(of: find.text(label), matching: find.byType(Material))
            .first;
        expect(
          tester.getSize(target).height,
          greaterThanOrEqualTo(44),
          reason: 'Alvo de toque da aba "$label" abaixo de 44px',
        );
      }
    });
  });
}

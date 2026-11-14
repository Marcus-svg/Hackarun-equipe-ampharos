import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_capim_dourado/core/di/service_locator.dart';
import 'package:totem_capim_dourado/data/repositories/intelligence_repository.dart';
import 'package:totem_capim_dourado/data/services/intelligence_api_service.dart';
import 'package:totem_capim_dourado/main.dart';
import 'package:totem_capim_dourado/scenes/shell/app_coordinator.dart';

/// Garante que nenhuma das telas principais estoura horizontalmente em
/// larguras de celular. Overflow horizontal e a causa raiz de elementos
/// ficarem fora da tela (e, portanto, nao clicaveis) no mobile.
void main() {
  testWidgets('Telas principais nao estouram em largura de celular',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ServiceLocator.coordinator = AppCoordinator();
    ServiceLocator.repository = IntelligenceRepositoryImpl(
      apiService: IntelligenceApiService(),
    );

    await tester.pumpWidget(const MaterialApp(home: ShellView()));
    await tester.pump(const Duration(milliseconds: 100));

    for (final label in ['1. Totem', '2. Loja', '3. Dashboard']) {
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Qualquer overflow horizontal (RenderFlex) e reportado pelo framework
      // como excecao pendente e reprova o teste.
      expect(
        tester.takeException(),
        isNull,
        reason: 'Overflow horizontal na tela "$label" em largura de celular',
      );
    }
  });
}

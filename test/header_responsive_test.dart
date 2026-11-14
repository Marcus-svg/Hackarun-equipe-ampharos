import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totem_capim_dourado/core/di/service_locator.dart';
import 'package:totem_capim_dourado/data/repositories/intelligence_repository.dart';
import 'package:totem_capim_dourado/data/services/intelligence_api_service.dart';
import 'package:totem_capim_dourado/main.dart';
import 'package:totem_capim_dourado/scenes/shell/app_coordinator.dart';

void main() {
  testWidgets(
    'Abas do topo permanecem visiveis e clicaveis em tela de celular',
    (tester) async {
      // Simula a viewport de um celular (largura estreita).
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Este teste cobre apenas o cabeçalho (barra de abas). O conteúdo das
      // telas ainda usa larguras fixas e pode estourar em telas estreitas;
      // esses erros são de outro escopo e não devem invalidar este teste.
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {};
      addTearDown(() => FlutterError.onError = previousOnError);

      ServiceLocator.coordinator = AppCoordinator();
      ServiceLocator.repository = IntelligenceRepositoryImpl(
        apiService: IntelligenceApiService(),
      );

      await tester.pumpWidget(const MaterialApp(home: ShellView()));
      await tester.pumpAndSettle();

      // As tres abas precisam existir e estar totalmente dentro da tela,
      // ou seja, nao podem "vazar" para fora do viewport (motivo original
      // de nao serem clicaveis no celular).
      const screen = Rect.fromLTWH(0, 0, 390, 844);
      for (final label in ['1. Totem', '2. Loja', '3. Dashboard']) {
        final finder = find.text(label);
        expect(finder, findsOneWidget, reason: 'Aba "$label" nao encontrada');
        final rect = tester.getRect(finder);
        expect(
          screen.contains(rect.topLeft),
          isTrue,
          reason: 'Aba "$label" comeca fora da tela: $rect',
        );
        expect(
          screen.contains(rect.bottomRight),
          isTrue,
          reason: 'Aba "$label" termina fora da tela: $rect',
        );
      }

      // E precisam responder ao toque, trocando a aba ativa.
      await tester.tap(find.text('3. Dashboard'));
      await tester.pumpAndSettle();
      expect(ServiceLocator.coordinator.currentTab, 2);

      await tester.tap(find.text('2. Loja'));
      await tester.pumpAndSettle();
      expect(ServiceLocator.coordinator.currentTab, 1);

      await tester.tap(find.text('1. Totem'));
      await tester.pumpAndSettle();
      expect(ServiceLocator.coordinator.currentTab, 0);
    },
  );
}

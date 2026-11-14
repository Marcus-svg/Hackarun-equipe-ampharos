import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'design_system/theme/app_colors.dart';
import 'scenes/dashboard/dashboard_factory.dart';
import 'scenes/shell/app_coordinator.dart';
import 'scenes/store_redemption/store_factory.dart';
import 'scenes/totem/totem_factory.dart';
import 'data/repositories/intelligence_repository.dart';
import 'data/services/intelligence_api_service.dart';

void main() {
  // Inicialização manual e segura do ServiceLocator para evitar qualquer LateInitializationError
  ServiceLocator.coordinator = AppCoordinator();
  ServiceLocator.repository = IntelligenceRepositoryImpl(
    apiService: IntelligenceApiService(),
  );

  runApp(const CapimDouradoApp());
}

class CapimDouradoApp extends StatelessWidget {
  const CapimDouradoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capim Dourado Experience Intelligence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cream,
        fontFamily: 'Roboto',
      ),
      home: const ShellView(),
    );
  }
}

class ShellView extends StatelessWidget {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final coord = ServiceLocator.coordinator;

    return ListenableBuilder(
      listenable: coord,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(coord),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: _buildCurrentScene(coord.currentTab),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Cabeçalho responsivo: em telas largas o título e as abas ficam lado a lado;
  // em telas estreitas (celular) o título sobe e as abas ganham uma linha
  // própria, garantindo que continuem visíveis e clicáveis.
  Widget _buildHeader(AppCoordinator coord) {
    final title = const Text(
      'CAPIM DOURADO EXPERIENCE INTELLIGENCE (MVVM)',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );

    final navButtons = Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _navButton(
          label: '1. Totem',
          active: coord.currentTab == 0,
          onTap: coord.navigateToTotem,
        ),
        _navButton(
          label: '2. Loja',
          active: coord.currentTab == 1,
          onTap: coord.navigateToStore,
        ),
        _navButton(
          label: '3. Dashboard',
          active: coord.currentTab == 2,
          onTap: coord.navigateToDashboard,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFF1E2229),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 10),
                navButtons,
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: title),
              const SizedBox(width: 16),
              navButtons,
            ],
          );
        },
      ),
    );
  }

  Widget _navButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.gold : Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScene(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return TotemFactory.create();
      case 1:
        return StoreRedemptionFactory.create(
          initialCode: ServiceLocator.coordinator.prefilledStoreCode,
        );
      case 2:
        return DashboardFactory.create();
      default:
        return TotemFactory.create();
    }
  }
}
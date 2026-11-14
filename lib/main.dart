import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'design_system/theme/app_colors.dart';
import 'scenes/dashboard/dashboard_factory.dart';
import 'scenes/shell/app_coordinator.dart';
import 'scenes/store_redemption/store_factory.dart';
import 'scenes/totem/totem_factory.dart';

void main() {
  ServiceLocator.setup();
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
        scaffoldBackgroundColor: AppColors.darkBg,
        fontFamily: 'Roboto',
      ),
      home: ListenableBuilder(
        listenable: ServiceLocator.coordinator,
        builder: (context, _) {
          final coord = ServiceLocator.coordinator;
          return Scaffold(
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: AppColors.surfaceDark,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'CAPIM DOURADO EXPERIENCE INTELLIGENCE (MVVM)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _navBtn(
                            label: '1. Totem',
                            active: coord.currentScene == AppScene.totem,
                            onTap: coord.navigateToTotem,
                          ),
                          const SizedBox(width: 8),
                          _navBtn(
                            label: '2. Loja',
                            active:
                                coord.currentScene == AppScene.storeRedemption,
                            onTap: coord.navigateToStoreRedemption,
                          ),
                          const SizedBox(width: 8),
                          _navBtn(
                            label: '3. Dashboard',
                            active: coord.currentScene == AppScene.dashboard,
                            onTap: coord.navigateToDashboard,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: switch (coord.currentScene) {
                        AppScene.totem => TotemFactory.create(),
                        AppScene.storeRedemption =>
                          StoreRedemptionFactory.create(),
                        AppScene.dashboard => DashboardFactory.create(),
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _navBtn({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.gold : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? AppColors.textPrimary : Colors.white70,
          ),
        ),
      ),
    );
  }
}
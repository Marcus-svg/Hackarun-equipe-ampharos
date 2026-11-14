import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import 'store_view.dart';
import 'store_viewmodel.dart';

class StoreRedemptionFactory {
  static Widget create() {
    final vm = StoreRedemptionViewModel(
      repository: ServiceLocator.repository,
      coordinator: ServiceLocator.coordinator,
    );
    return StoreRedemptionView(
      viewModel: vm,
      initialCode: ServiceLocator.coordinator.lastGeneratedCouponCode,
    );
  }
}
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import 'dashboard_view.dart';
import 'dashboard_viewmodel.dart';

class DashboardFactory {
  static Widget create() {
    final vm = DashboardViewModel(repository: ServiceLocator.repository);
    return DashboardView(viewModel: vm);
  }
}

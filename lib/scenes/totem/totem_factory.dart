import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import 'totem_view.dart';
import 'totem_viewmodel.dart';

class TotemFactory {
  static Widget create() {
    final viewModel = TotemViewModel(
      repository: ServiceLocator.repository,
      coordinator: ServiceLocator.coordinator,
    );
    return TotemView(viewModel: viewModel);
  }
}

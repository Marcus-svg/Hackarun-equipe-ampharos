import '../../data/repositories/intelligence_repository.dart';
import '../../data/services/intelligence_api_service.dart';
import '../../scenes/shell/app_coordinator.dart';

class ServiceLocator {
  static late IIntelligenceRepository repository;
  static late AppCoordinator coordinator;

  static void setup() {
    final apiService = IntelligenceApiService();
    repository = IntelligenceRepositoryImpl(apiService: apiService);
    coordinator = AppCoordinator();
  }
}
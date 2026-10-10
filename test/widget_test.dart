import 'package:flutter_test/flutter_test.dart';
import 'package:neon_wave/src/app.dart';
import 'package:neon_wave/src/core/di/service_locator.dart';
import 'package:neon_wave/src/core/repositories/auth_repository.dart';
import 'package:neon_wave/src/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App builds smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
    if (getIt.isRegistered<AuthRepository>()) {
      getIt.unregister<AuthRepository>();
    }
    getIt.registerLazySingleton<AuthRepository>(
      () => LocalAuthRepository(storage: getIt<LocalStorageService>()),
    );

    await tester.pumpWidget(const NeonWaveApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NeonWaveApp), findsOneWidget);
  });
}

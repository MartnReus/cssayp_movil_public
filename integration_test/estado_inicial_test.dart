import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cssayp_movil/main.dart';
import 'package:cssayp_movil/auth/auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen Navigation Tests', () {
    late FlutterSecureStorage secureStorage;
    late SharedPreferences prefs;

    setUpAll(() async {
      secureStorage = const FlutterSecureStorage();
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    tearDownAll(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    testWidgets('Debe mantener SplashScreen visible durante la carga inicial', (tester) async {
      await tester.pumpWidget(ProviderScope(child: const MyApp()));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('Debe navegar a /login cuando no hay token (usuario no autenticado)', (tester) async {
      // No hay token, no hay preferencias

      await tester.pumpWidget(ProviderScope(child: const MyApp()));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Esperar a que se complete la verificación del estado
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);

      expect(find.text('Inicio de sesión'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('Debe navegar a /home cuando hay token válido y biometría DESHABILITADA', (tester) async {
      // Setear estado autenticado SIN biometría
      await secureStorage.write(key: 'token', value: 'fake_valid_token_123');
      await prefs.setBool('utilizar_biometria', false);
      await secureStorage.write(key: 'username', value: 'usuario_test');

      await tester.pumpWidget(ProviderScope(child: const MyApp()));

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('Debe navegar a /login con biometría cuando hay token válido y biometría HABILITADA', (tester) async {
      // Setear estado autenticado CON biometría
      await secureStorage.write(key: 'token', value: 'fake_valid_token_456');
      await prefs.setBool('utilizar_biometria', true);

      await secureStorage.write(key: 'username', value: 'usuario_biometrico');

      await tester.pumpWidget(ProviderScope(child: const MyApp()));

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);

      expect(find.text('Inicio de sesión'), findsOneWidget);
    });

    // TODO: Modificar el test para tener en cuenta que el token ahora se valida
    testWidgets('Navega a /home incluso con token "corrupto" (sin validación)', (tester) async {
      // Setear token inválido
      await secureStorage.write(key: 'token', value: 'token_falso');
      await prefs.setBool('utilizar_biometria', false);

      await tester.pumpWidget(ProviderScope(child: const MyApp()));

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}

/// Helper para limpiar completamente el estado entre tests
Future<void> _limpiarTodoElEstado(FlutterSecureStorage secureStorage, SharedPreferences prefs) async {
  try {
    await secureStorage.deleteAll();
    await prefs.clear();

    // Esperar un momento para asegurar que la limpieza se complete
    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    print('Warning: Error limpiando estado: $e');
  }
}

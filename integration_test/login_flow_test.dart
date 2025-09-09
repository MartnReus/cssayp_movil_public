import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:cssayp_movil/main.dart';
import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/shared/screens/main_navigation_screen.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

import "../test/auth/data/datasources/usuario_data_source_test.mocks.dart";
import '../test/auth/presentation/providers/auth_provider_test.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Tests', () {
    late FlutterSecureStorage secureStorage;
    late SharedPreferences prefs;

    final successLoginResponseBody = json.encode({
      'nro_afiliado': 999,
      'apellido_nombres': 'Perez, Juan',
      'token': '1234567890',
      'cambiar_password': 0,
    });
    const successLoginResponseStatus = 200;

    final invalidPasswordResponseBody = json.encode({'nro_afiliado': 0, 'mensaje': 'Datos incorrectos'});
    const invalidPasswordResponseStatus = 200;

    setUpAll(() async {
      secureStorage = const FlutterSecureStorage();
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    tearDown(() async {
      // await Future.delayed(const Duration(seconds: 5));
    });

    tearDownAll(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    testWidgets('Debe navegar a /home cuando el usuario y contraseña son correctos', (tester) async {
      final mockClient = MockClient();
      final mockUsuarioRepository = MockUsuarioRepository();
      final mockPreferenciasRepository = MockPreferenciasRepository();

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      final testUser = UsuarioEntity(
        nroAfiliado: 999,
        apellidoNombres: 'Perez, Juan',
        cambiarPassword: false,
        username: 'valid_user',
      );

      when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => false);

      when(mockUsuarioRepository.autenticar('valid_user', 'valid_pass')).thenAnswer((_) async {
        when(mockUsuarioRepository.estaAutenticado()).thenAnswer((_) async => true);
        when(mockUsuarioRepository.obtenerUsuarioActual()).thenAnswer((_) async => testUser);
        return testUser;
      });

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => Future.value(mockUsuarioRepository)),
          preferenciasRepositoryProvider.overrideWith((ref) => Future.value(mockPreferenciasRepository)),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('¡Bienvenido!'), findsOneWidget);
      expect(find.text('CSSAyP Móvil'), findsOneWidget);
    });

    testWidgets('Debe mostrar un mensaje de error cuando el usuario y contraseña son incorrectos', (tester) async {
      final mockClient = MockClient();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(invalidPasswordResponseBody, invalidPasswordResponseStatus));

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'user');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid_pass');

      await tester.tap(find.byType(ElevatedButton));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text(json.decode(invalidPasswordResponseBody)['mensaje']), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainNavigationScreen), findsNothing);
    });

    testWidgets('Debe mostrar error de validacion del form cuando no se ingresa usuario y contraseña', (tester) async {
      await tester.pumpWidget(ProviderScope(child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.tap(find.byType(ElevatedButton));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('El usuario es requerido'), findsOneWidget);
      expect(find.text('La contraseña es requerida'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainNavigationScreen), findsNothing);
    });

    testWidgets(
      'Debe mostrar error de validacion si la longitud del usuario es menor a 3 caracteres o la contraseña es menor a 4 caracteres',
      (tester) async {
        await tester.pumpWidget(ProviderScope(child: const MyApp()));

        await _esperarLoginScreen(tester);

        await tester.enterText(find.byType(TextFormField).at(0), 'us');
        await tester.enterText(find.byType(TextFormField).at(1), 'pas');

        await tester.tap(find.byType(ElevatedButton));

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.text('El usuario debe tener al menos 3 caracteres'), findsOneWidget);
        expect(find.text('La contraseña debe tener al menos 4 caracteres'), findsOneWidget);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(MainNavigationScreen), findsNothing);
      },
    );

    testWidgets('Debe mostrar un mensaje de error cuando no es posible conectarse con el servidor', (tester) async {
      final mockClient = MockClient();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenThrow(TimeoutException('Connection timeout'));

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'user');
      await tester.enterText(find.byType(TextFormField).at(1), 'pass');

      await tester.tap(find.byType(ElevatedButton));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Error en la conexión con el servidor'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainNavigationScreen), findsNothing);
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

Future<void> _esperarLoginScreen(WidgetTester tester) async {
  expect(find.byType(SplashScreen), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.byType(SplashScreen), findsNothing);
  expect(find.byType(MainNavigationScreen), findsNothing);

  expect(find.text('Inicio de sesión'), findsOneWidget);
  expect(find.text('Iniciar Sesión'), findsOneWidget);
}

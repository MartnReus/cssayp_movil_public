import 'dart:convert';
import 'dart:async';
import 'dart:io';

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
import 'package:cssayp_movil/shared/providers/app_providers.dart';

import "../test/auth/data/datasources/usuario_data_source_test.mocks.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cambiar Password Flow Tests', () {
    late FlutterSecureStorage secureStorage;
    late SharedPreferences prefs;

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

    testWidgets('Debe navegar a /cambiar-password cuando la respuesta del login lo requiere', (tester) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      expect(find.byType(CambiarPasswordScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('Debe navegar a /password-actualizada cuando la contraseña es cambiada correctamente', (tester) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      final successCambiarPasswordResponseBody = json.encode({
        'estado': '1',
        'mensaje': 'Se asignó correctamente la nueva contraseña',
      });
      const successCambiarPasswordResponseStatus = 200;

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(successCambiarPasswordResponseBody, successCambiarPasswordResponseStatus),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'old_pass');
      await tester.enterText(find.byType(TextFormField).at(1), 'new_pass');
      await tester.enterText(find.byType(TextFormField).at(2), 'new_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordActualizadaScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(CambiarPasswordScreen), findsNothing);

      expect(find.text('Contraseña actualizada'), findsOneWidget);
      expect(
        find.text('Su contraseña ha sido actualizada con éxito. Presione “Continuar” para ir a la página principal'),
        findsOneWidget,
      );
    });

    testWidgets('Debe mostrar un mensaje de error cuando la contraseña actual es incorrecta', (tester) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      final invalidOldPasswordResponseBody = json.encode({
        'estado': '0',
        'mensaje': 'La contraseña actual es incorrecta',
      });
      const invalidOldPasswordResponseStatus = 200;

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(invalidOldPasswordResponseBody, invalidOldPasswordResponseStatus));

      await tester.enterText(find.byType(TextFormField).at(0), 'wrong_old_pass');
      await tester.enterText(find.byType(TextFormField).at(1), 'new_pass');
      await tester.enterText(find.byType(TextFormField).at(2), 'new_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(CambiarPasswordScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(PasswordActualizadaScreen), findsNothing);

      expect(find.text('La contraseña actual es incorrecta'), findsOneWidget);
    });

    testWidgets('Debe mostrar un mensaje de error cuando no es posible conectarse con el servidor (timeout)', (
      tester,
    ) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenThrow(TimeoutException('Connection timeout'));

      await tester.enterText(find.byType(TextFormField).at(0), 'old_pass');
      await tester.enterText(find.byType(TextFormField).at(1), 'new_pass');
      await tester.enterText(find.byType(TextFormField).at(2), 'new_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(CambiarPasswordScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(PasswordActualizadaScreen), findsNothing);

      expect(find.text('Error en la conexión con el servidor'), findsOneWidget);
    });

    testWidgets('Debe mostrar un mensaje de error cuando no es posible conectarse con el servidor (socket exception)', (
      tester,
    ) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenThrow(SocketException('Connection error'));

      await tester.enterText(find.byType(TextFormField).at(0), 'old_pass');
      await tester.enterText(find.byType(TextFormField).at(1), 'new_pass');
      await tester.enterText(find.byType(TextFormField).at(2), 'new_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(CambiarPasswordScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(PasswordActualizadaScreen), findsNothing);

      expect(find.text('Error en la conexión con el servidor'), findsOneWidget);
    });

    testWidgets('Debe mostrar un mensaje de error cuando la nueva contraseña no coincide con la confirmación', (
      tester,
    ) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      await tester.enterText(find.byType(TextFormField).at(0), 'old_pass');
      await tester.enterText(find.byType(TextFormField).at(1), 'new_pass');
      await tester.enterText(find.byType(TextFormField).at(2), 'wrong_new_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(CambiarPasswordScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(PasswordActualizadaScreen), findsNothing);

      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('Debe mostrar un mensaje de error cuando la nueva contraseña es muy corta (menor a 4 caracteres)', (
      tester,
    ) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      await tester.enterText(find.byType(TextFormField).at(0), 'old_pass');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.enterText(find.byType(TextFormField).at(2), '123');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(CambiarPasswordScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(PasswordActualizadaScreen), findsNothing);

      expect(find.text('La contraseña debe tener al menos 4 caracteres'), findsExactly(2));
    });

    testWidgets('Debe mostrar un mensaje de error cuando los campos están vacíos', (tester) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.enterText(find.byType(TextFormField).at(2), '');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(CambiarPasswordScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(PasswordActualizadaScreen), findsNothing);

      expect(find.text('La contraseña es requerida'), findsNWidgets(3));
    });

    testWidgets('Debe navegar a /home al presionar el botón de continuar en la pantalla de password actualizada', (
      tester,
    ) async {
      final mockClient = MockClient();

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarCambiarPasswordScreen(tester, container, mockClient);

      final successCambiarPasswordResponseBody = json.encode({
        'estado': '1',
        'mensaje': 'Se asignó correctamente la nueva contraseña',
      });
      const successCambiarPasswordResponseStatus = 200;

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(successCambiarPasswordResponseBody, successCambiarPasswordResponseStatus),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'old_pass');
      await tester.enterText(find.byType(TextFormField).at(1), 'new_pass');
      await tester.enterText(find.byType(TextFormField).at(2), 'new_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordActualizadaScreen), findsOneWidget);

      expect(find.text('Contraseña actualizada'), findsOneWidget);
      expect(
        find.text('Su contraseña ha sido actualizada con éxito. Presione “Continuar” para ir a la página principal'),
        findsOneWidget,
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(PasswordActualizadaScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(CambiarPasswordScreen), findsNothing);
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

Future<void> _esperarCambiarPasswordScreen(
  WidgetTester tester,
  ProviderContainer container,
  MockClient mockClient,
) async {
  expect(find.byType(SplashScreen), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.byType(SplashScreen), findsNothing);
  expect(find.byType(HomeScreen), findsNothing);

  expect(find.text('Inicio de sesión'), findsOneWidget);
  expect(find.text('Iniciar Sesión'), findsOneWidget);

  final successLoginResponseBody = json.encode({
    'nro_afiliado': 999,
    'apellido_nombres': 'Perez, Juan',
    'token': '1234567890',
    'cambiar_password': 1,
  });
  const successLoginResponseStatus = 200;

  when(
    mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
  ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

  await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
  await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

  await tester.tap(find.byType(ElevatedButton));

  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  expect(find.byType(CambiarPasswordScreen), findsOneWidget);
}

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
import 'package:cssayp_movil/shared/providers/app_providers.dart';

import "../test/auth/data/datasources/usuario_data_source_test.mocks.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Recuperación de Contraseña Flow Tests', () {
    late FlutterSecureStorage secureStorage;
    late SharedPreferences prefs;

    final successRecoveryResponseBody = json.encode({'success': true, 'statusCode': 200});
    const successRecoveryResponseStatus = 200;

    final invalidCredentialsResponseBody = json.encode({
      'success': false,
      'error': 'El número de documento no coincide con el que se encuentra en el sistema',
    });
    const invalidCredentialsResponseStatus = 400;

    final genericErrorResponseBody = json.encode({
      'success': false,
      'statusCode': 500,
      'error': 'Error inesperado al recuperar contraseña',
    });
    const genericErrorResponseStatus = 500;

    setUpAll(() async {
      secureStorage = const FlutterSecureStorage();
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    tearDown(() async {
      await Future.delayed(const Duration(seconds: 5));
    });

    tearDownAll(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    testWidgets('Debe navegar a /enviar-email cuando los datos son correctos', (tester) async {
      final mockClient = MockClient();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successRecoveryResponseBody, successRecoveryResponseStatus));

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      // Navegar a la pantalla de recuperación de contraseña
      await tester.tap(find.text('¿Olvidó su contraseña?'));
      await tester.pumpAndSettle();

      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);
      expect(find.text('Recuperación de Contraseña'), findsOneWidget);

      // Llenar el formulario con datos válidos
      await tester.enterText(find.byType(TextFormField).at(0), '12345'); // Nro de Afiliado
      await tester.enterText(find.byType(TextFormField).at(1), '12345678'); // Nro de Documento
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com'); // Email

      await tester.tap(find.text('Confirmar'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(EnvioEmailScreen), findsOneWidget);
      expect(find.byType(RecuperarPasswordScreen), findsNothing);
      expect(find.text('Recuperación de contraseña'), findsOneWidget);
      expect(
        find.text(
          'Hemos enviado un email con su contraseña temporal a la dirección registrada. Presione “Continuar” para volver a la página de Inicio de Sesión',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Debe mostrar un mensaje de error cuando los datos son incorrectos', (tester) async {
      final mockClient = MockClient();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(invalidCredentialsResponseBody, invalidCredentialsResponseStatus));

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      // Navegar a la pantalla de recuperación de contraseña
      await tester.tap(find.text('¿Olvidó su contraseña?'));
      await tester.pumpAndSettle();

      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);

      // Llenar el formulario con datos inválidos
      await tester.enterText(find.byType(TextFormField).at(0), '99999');
      await tester.enterText(find.byType(TextFormField).at(1), '87654321');
      await tester.enterText(find.byType(TextFormField).at(2), 'invalid@example.com');

      await tester.tap(find.text('Confirmar'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // El error se muestra en un SnackBar, por lo que necesitamos buscar el texto en el SnackBar
      expect(find.text('El número de documento no coincide con el que se encuentra en el sistema'), findsOneWidget);
      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);
      expect(find.byType(EnvioEmailScreen), findsNothing);
    });

    testWidgets('Debe mostrar errores de validación cuando no se ingresan datos', (tester) async {
      await tester.pumpWidget(ProviderScope(child: const MyApp()));

      await _esperarLoginScreen(tester);

      // Navegar a la pantalla de recuperación de contraseña
      await tester.tap(find.text('¿Olvidó su contraseña?'));
      await tester.pumpAndSettle();

      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);

      // Intentar enviar sin datos
      await tester.tap(find.text('Confirmar'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('El número de afiliado es requerido'), findsOneWidget);
      expect(find.text('El número de documento es requerido'), findsOneWidget);
      expect(find.text('El correo electrónico es requerido'), findsOneWidget);
      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);
      expect(find.byType(EnvioEmailScreen), findsNothing);
    });

    testWidgets('Debe mostrar errores de validación para formato incorrecto', (tester) async {
      await tester.pumpWidget(ProviderScope(child: const MyApp()));

      await _esperarLoginScreen(tester);

      // Navegar a la pantalla de recuperación de contraseña
      await tester.tap(find.text('¿Olvidó su contraseña?'));
      await tester.pumpAndSettle();

      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);

      // Llenar con datos con formato incorrecto
      await tester.enterText(find.byType(TextFormField).at(0), 'abc'); // Nro de Afiliado con letras
      await tester.enterText(find.byType(TextFormField).at(1), '12345'); // Nro de Documento muy largo
      await tester.enterText(find.byType(TextFormField).at(2), 'invalid-email'); // Email inválido

      await tester.tap(find.text('Confirmar'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('El número de afiliado es requerido'), findsOneWidget);
      expect(find.text('El número de documento debe tener entre 7 y 8 dígitos'), findsOneWidget);
      expect(find.text('Ingrese un correo electrónico válido'), findsOneWidget);
      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);
      expect(find.byType(EnvioEmailScreen), findsNothing);
    });

    testWidgets('Debe mostrar un mensaje de error cuando no es posible conectarse con el servidor', (tester) async {
      final mockClient = MockClient();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenThrow(TimeoutException('Connection timeout'));

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      // Navegar a la pantalla de recuperación de contraseña
      await tester.tap(find.text('¿Olvidó su contraseña?'));
      await tester.pumpAndSettle();

      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);

      // Llenar el formulario con datos válidos
      await tester.enterText(find.byType(TextFormField).at(0), '12345');
      await tester.enterText(find.byType(TextFormField).at(1), '12345678');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');

      await tester.tap(find.text('Confirmar'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // El error se muestra en un SnackBar
      expect(find.text('Error en la conexión con el servidor'), findsOneWidget);
      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);
      expect(find.byType(EnvioEmailScreen), findsNothing);
    });

    testWidgets('Debe mostrar un mensaje de error genérico del servidor', (tester) async {
      final mockClient = MockClient();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(genericErrorResponseBody, genericErrorResponseStatus));

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      // Navegar a la pantalla de recuperación de contraseña
      await tester.tap(find.text('¿Olvidó su contraseña?'));
      await tester.pumpAndSettle();

      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);

      // Llenar el formulario con datos válidos
      await tester.enterText(find.byType(TextFormField).at(0), '12345');
      await tester.enterText(find.byType(TextFormField).at(1), '12345678');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');

      await tester.tap(find.text('Confirmar'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // El error se muestra en un SnackBar
      expect(find.text('Error inesperado al recuperar contraseña'), findsOneWidget);
      expect(find.byType(RecuperarPasswordScreen), findsOneWidget);
      expect(find.byType(EnvioEmailScreen), findsNothing);
    });

    testWidgets('Debe navegar de vuelta al login desde la pantalla de envío de email', (tester) async {
      final mockClient = MockClient();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successRecoveryResponseBody, successRecoveryResponseStatus));

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      // Navegar a la pantalla de recuperación de contraseña
      await tester.tap(find.text('¿Olvidó su contraseña?'));
      await tester.pumpAndSettle();

      // Llenar el formulario y enviar
      await tester.enterText(find.byType(TextFormField).at(0), '12345');
      await tester.enterText(find.byType(TextFormField).at(1), '12345678');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de envío de email
      expect(find.byType(EnvioEmailScreen), findsOneWidget);

      // Hacer clic en "Continuar" para volver al login
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(EnvioEmailScreen), findsNothing);
      expect(find.text('Inicio de sesión'), findsOneWidget);
    });

    testWidgets('Debe mostrar el botón de reenviar email en la pantalla de envío', (tester) async {
      final mockClient = MockClient();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successRecoveryResponseBody, successRecoveryResponseStatus));

      final container = ProviderContainer(overrides: [httpClientProvider.overrideWith((ref) => mockClient)]);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      // Navegar a la pantalla de recuperación de contraseña
      await tester.tap(find.text('¿Olvidó su contraseña?'));
      await tester.pumpAndSettle();

      // Llenar el formulario y enviar
      await tester.enterText(find.byType(TextFormField).at(0), '12345');
      await tester.enterText(find.byType(TextFormField).at(1), '12345678');
      await tester.enterText(find.byType(TextFormField).at(2), 'test@example.com');

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de envío de email
      expect(find.byType(EnvioEmailScreen), findsOneWidget);
      expect(find.text('¿No recibiste el email?'), findsOneWidget);
      expect(find.text('Reenviar email'), findsOneWidget);
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

  expect(find.text('Inicio de sesión'), findsOneWidget);
  expect(find.text('Iniciar Sesión'), findsOneWidget);
}

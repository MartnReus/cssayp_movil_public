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
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';

import "../test/auth/data/datasources/usuario_data_source_test.mocks.dart";
import '../test/auth/presentation/providers/auth_provider_test.mocks.dart';

Future<void> pumpFrames(
  WidgetTester tester, {
  int frames = 10,
  Duration frameDuration = const Duration(milliseconds: 100),
}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(frameDuration);
  }
}

/// Mock personalizado para SecureStorageDataSource que simula el almacenamiento del token
class MockSecureStorageDataSource extends Mock implements SecureStorageDataSource {
  String? _storedToken;

  @override
  Future<void> guardarToken(String token) async {
    _storedToken = token;
  }

  @override
  Future<String?> obtenerToken() async {
    return _storedToken;
  }

  @override
  Future<void> eliminarToken() async {
    _storedToken = null;
  }
}

/// Mock personalizado para JwtTokenService que simula la extracción de campos del JWT
class MockJwtTokenService extends Mock implements JwtTokenService {
  @override
  Future<String?> obtenerDigito() async {
    return '5'; // Dígito del JWT generado
  }

  @override
  Future<String?> obtenerNumeroAfiliado() async {
    return '999'; // Número de afiliado del JWT generado
  }

  @override
  Future<String?> obtenerCampo(String campo) async {
    switch (campo) {
      case 'dig':
        return '5';
      case 'naf':
        return '999';
      case 'cir':
        return 'Santa Fe';
      case 'sex':
        return 'M';
      case 'val':
        return 'true';
      default:
        return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> obtenerPayloadCompleto() async {
    return {'naf': 999, 'dig': '5', 'cir': 'Santa Fe', 'sex': 'M', 'val': true};
  }
}

/// Mock personalizado para UsuarioRepository que simula el comportamiento completo
class MockUsuarioRepositoryComplete extends Mock implements UsuarioRepository {
  final MockSecureStorageDataSource _secureStorage;
  UsuarioEntity? _currentUser;

  MockUsuarioRepositoryComplete(this._secureStorage);

  @override
  Future<bool> estaAutenticado() async {
    final token = await _secureStorage.obtenerToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UsuarioEntity?> autenticar(String username, String password) async {
    if (username == 'valid_user' && password == 'valid_pass') {
      await _secureStorage.guardarToken(_generateValidJwtToken());
      _currentUser = UsuarioEntity(
        nroAfiliado: 999,
        apellidoNombres: 'Perez, Juan',
        cambiarPassword: false,
        username: username,
      );
      return _currentUser;
    }
    return null;
  }

  @override
  Future<UsuarioEntity?> obtenerUsuarioActual() async {
    final token = await _secureStorage.obtenerToken();
    if (token != null && token.isNotEmpty) {
      return _currentUser;
    }
    return null;
  }

  @override
  Future<void> cerrarSesion() async {
    await _secureStorage.eliminarToken();
    _currentUser = null;
  }

  @override
  Future<RecuperarResponseModel> recuperarPassword(String tipoDocumento, String nroDocumento, String email) async {
    throw UnimplementedError();
  }

  @override
  Future<CambiarPasswordResponseModel> cambiarPassword(String passwordActual, String passwordNueva) async {
    throw UnimplementedError();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Crear Boleta Fin Flow Tests', () {
    late FlutterSecureStorage secureStorage;
    late SharedPreferences prefs;

    final validJwtToken = _generateValidJwtToken();

    final successLoginResponseBody = json.encode({
      'nro_afiliado': 999,
      'apellido_nombres': 'Perez, Juan',
      'token': validJwtToken,
      'cambiar_password': 0,
    });
    const successLoginResponseStatus = 200;

    final successBoletasInicioPagadasResponseBody = json.encode({
      'data': [
        {
          'id_boleta_generada': '12345',
          'caratula': 'Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios',
          'monto': '21000.00',
          'fecha_impresion': '2024-01-15T10:30:00Z',
          'dias_vencimiento': '30',
          'fecha_pago': '2024-01-20T10:30:00Z',
        },
      ],
      'meta': {'current_page': 1, 'last_page': 1, 'total': 1, 'per_page': 10},
    });
    const successBoletasInicioPagadasResponseStatus = 200;

    final successCrearBoletaFinResponseBody = json.encode({
      'id_boleta': '67890',
      'monto_entero': 4200,
      'monto_decimal': 0,
      'fecha_impresion': '2024-01-15T10:30:00Z',
      'fecha_vencimiento': '30',
    });
    const successCrearBoletaFinResponseStatus = 201;

    final errorCrearBoletaFinResponseBody = json.encode({
      'error': 'Error al crear la boleta de finalización',
      'mensaje': 'No se pudo procesar la solicitud',
    });
    const errorCrearBoletaFinResponseStatus = 400;

    setUpAll(() async {
      secureStorage = const FlutterSecureStorage();
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    tearDown(() async {
      await Future.delayed(const Duration(seconds: 3));
    });

    tearDownAll(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    testWidgets('Debe completar el flujo completo de crear boleta de fin exitosamente', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaFin')) {
          return http.Response(successCrearBoletaFinResponseBody, successCrearBoletaFinResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      // Después del login exitoso, debería navegar a MainNavigationScreen que contiene HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.byType(CrearBoletaScreen), findsOneWidget);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.byType(Paso1BoletaFinScreen), findsOneWidget);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester);

      // Esperar a que se carguen las boletas
      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester);

      // Seleccionar la primera carátula disponible
      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await pumpFrames(tester);

      // Completar campos opcionales
      await tester.enterText(find.byType(TextFormField).at(0), '12345');
      await tester.enterText(find.byType(TextFormField).at(1), '2024');
      await tester.enterText(find.byType(TextFormField).at(2), '98765');

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.byType(Paso2BoletaFinScreen), findsOneWidget);

      // Seleccionar fecha de regulación
      await _seleccionarFechaEnDatePicker(tester);

      // Ingresar cantidad JUS - buscar específicamente el campo de cantidad JUS
      // Primero intentar encontrar el campo por su posición (debería ser el segundo TextFormField)
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), '10');
      } else if (textFields.evaluate().isNotEmpty) {
        // Fallback: usar el último TextFormField disponible
        await tester.enterText(textFields.last, '10');
      }

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      // Esperar un poco más para que se complete la validación y navegación
      await tester.pump(const Duration(milliseconds: 1000));
      await pumpFrames(tester);

      // Debug: verificar qué pantalla estamos viendo
      if (find.byType(Paso3BoletaFinScreen).evaluate().isEmpty) {
        print('No se encontró Paso3BoletaFinWidget, verificando qué pantalla está visible...');
        if (find.byType(Paso2BoletaFinScreen).evaluate().isNotEmpty) {
          print('Aún estamos en Paso2BoletaFinWidget');
        }
        if (find.text('Campo obligatorio').evaluate().isNotEmpty) {
          print('Hay mensajes de validación visibles');
        }
        // Si aún estamos en paso 2, intentar nuevamente
        if (find.byType(Paso2BoletaFinScreen).evaluate().isNotEmpty) {
          await tester.pump(const Duration(milliseconds: 500));
          await pumpFrames(tester);
        }
      }

      expect(find.byType(Paso3BoletaFinScreen), findsOneWidget);

      await tester.tap(find.text('GENERAR'), warnIfMissed: false);
      await pumpFrames(tester);

      // Confirmar en el diálogo
      await tester.tap(find.text('SÍ'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      expect(find.byType(BoletaCreadaScreen), findsOneWidget);
      expect(find.text('Boleta generada con éxito'), findsOneWidget);
    });

    testWidgets('Debe mostrar error de validación en paso 1 cuando no se selecciona carátula', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.byType(Paso1BoletaFinScreen), findsOneWidget);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.text('Campo obligatorio'), findsAtLeastNWidgets(1));
      expect(find.byType(Paso1BoletaFinScreen), findsOneWidget);
      expect(find.byType(Paso2BoletaFinScreen), findsNothing);
    });

    testWidgets('Debe mostrar error de validación en paso 2 cuando la fecha no está seleccionada', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester);

      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester);

      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await pumpFrames(tester);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.byType(Paso2BoletaFinScreen), findsOneWidget);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.text('Campo obligatorio'), findsAtLeastNWidgets(1));
      expect(find.byType(Paso2BoletaFinScreen), findsOneWidget);
      expect(find.byType(Paso3BoletaFinScreen), findsNothing);
    });

    testWidgets('Debe mostrar error de validación en paso 2 cuando la cantidad JUS está vacía', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester);

      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester);

      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await pumpFrames(tester);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar fecha
      await _seleccionarFechaEnDatePicker(tester);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.text('Campo obligatorio'), findsAtLeastNWidgets(1));
      expect(find.byType(Paso2BoletaFinScreen), findsOneWidget);
      expect(find.byType(Paso3BoletaFinScreen), findsNothing);
    });

    testWidgets('Debe mostrar error de validación en paso 2 cuando se ingresan caracteres inválidos en cantidad JUS', (
      tester,
    ) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester);

      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester);

      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await pumpFrames(tester);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar fecha
      await _seleccionarFechaEnDatePicker(tester);

      // Ingresar cantidad JUS inválida
      // Primero intentar encontrar el campo por su posición (debería ser el segundo TextFormField)
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), 'abc');
      } else if (textFields.evaluate().isNotEmpty) {
        // Fallback: usar el último TextFormField disponible
        await tester.enterText(textFields.last, 'abc');
      }

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.text('Solo números permitidos'), findsAtLeastNWidgets(1));
      expect(find.byType(Paso2BoletaFinScreen), findsOneWidget);
      expect(find.byType(Paso3BoletaFinScreen), findsNothing);
    });

    testWidgets('Debe mostrar error cuando falla la creación de la boleta en el servidor', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaFin')) {
          return http.Response(errorCrearBoletaFinResponseBody, errorCrearBoletaFinResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester);

      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester);

      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await pumpFrames(tester);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar fecha
      await _seleccionarFechaEnDatePicker(tester);

      // Ingresar cantidad JUS - buscar específicamente el campo de cantidad JUS
      // Primero intentar encontrar el campo por su posición (debería ser el segundo TextFormField)
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), '10');
      } else if (textFields.evaluate().isNotEmpty) {
        // Fallback: usar el último TextFormField disponible
        await tester.enterText(textFields.last, '10');
      }

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('GENERAR'), warnIfMissed: false);
      await pumpFrames(tester);

      // Confirmar en el diálogo
      await tester.tap(find.text('SÍ'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(Paso3BoletaFinScreen), findsOneWidget);
      expect(find.byType(BoletaCreadaScreen), findsNothing);
    });

    testWidgets('Debe mostrar error cuando no es posible conectarse con el servidor', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaFin')) {
          throw TimeoutException('Connection timeout');
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester);

      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester);

      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await pumpFrames(tester);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar fecha
      await _seleccionarFechaEnDatePicker(tester);

      // Ingresar cantidad JUS - buscar específicamente el campo de cantidad JUS
      // Primero intentar encontrar el campo por su posición (debería ser el segundo TextFormField)
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), '10');
      } else if (textFields.evaluate().isNotEmpty) {
        // Fallback: usar el último TextFormField disponible
        await tester.enterText(textFields.last, '10');
      }

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('GENERAR'), warnIfMissed: false);
      await pumpFrames(tester);

      // Confirmar en el diálogo
      await tester.tap(find.text('SÍ'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(Paso3BoletaFinScreen), findsOneWidget);
      expect(find.byType(BoletaCreadaScreen), findsNothing);
    });

    testWidgets('Debe permitir navegar entre pasos usando los botones Volver', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester);

      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester);

      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await pumpFrames(tester);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.byType(Paso2BoletaFinScreen), findsOneWidget);

      await tester.tap(find.text('Volver'));
      await pumpFrames(tester);

      expect(find.byType(Paso1BoletaFinScreen), findsOneWidget);
      // Verificar que estamos de vuelta en el paso 1
      expect(find.text('Seleccione una carátula'), findsOneWidget);
    });

    testWidgets('Debe cancelar la generación cuando se presiona NO en el diálogo de confirmación', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester);

      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester);

      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await pumpFrames(tester);

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      // Seleccionar fecha
      await _seleccionarFechaEnDatePicker(tester);

      // Ingresar cantidad JUS - buscar específicamente el campo de cantidad JUS
      // Primero intentar encontrar el campo por su posición (debería ser el segundo TextFormField)
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), '10');
      } else if (textFields.evaluate().isNotEmpty) {
        // Fallback: usar el último TextFormField disponible
        await tester.enterText(textFields.last, '10');
      }

      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('GENERAR'), warnIfMissed: false);
      await pumpFrames(tester);

      await tester.tap(find.text('NO'), warnIfMissed: false);
      await pumpFrames(tester);

      expect(find.byType(Paso3BoletaFinScreen), findsOneWidget);
      expect(find.byType(BoletaCreadaScreen), findsNothing);
    });
  });
}

Future<void> _limpiarTodoElEstado(FlutterSecureStorage secureStorage, SharedPreferences prefs) async {
  try {
    await secureStorage.deleteAll();
    await prefs.clear();

    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    // Error limpiando estado - ignorar
  }
}

Future<void> _esperarLoginScreen(WidgetTester tester) async {
  expect(find.byType(SplashScreen), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 500));
  await pumpFrames(tester);

  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.byType(SplashScreen), findsNothing);
  expect(find.byType(HomeScreen), findsNothing);

  expect(find.text('Inicio de sesión'), findsOneWidget);
  expect(find.text('Iniciar Sesión'), findsOneWidget);
}

Future<void> _seleccionarFechaEnDatePicker(WidgetTester tester) async {
  // Buscar el campo de fecha por texto directamente
  await tester.tap(find.text('Seleccione fecha'), warnIfMissed: false);
  await pumpFrames(tester);

  // Esperar a que aparezca el date picker
  await tester.pump(const Duration(milliseconds: 500));
  await pumpFrames(tester);

  // Intentar encontrar y hacer tap en el botón de confirmar
  final confirmButton = find.byWidgetPredicate(
    (widget) => widget is TextButton && widget.child is Text && (widget.child as Text).data == 'OK',
  );

  if (confirmButton.evaluate().isNotEmpty) {
    await tester.tap(confirmButton, warnIfMissed: false);
  } else {
    // Buscar cualquier botón que pueda ser de confirmar
    final anyButton = find.byType(ElevatedButton);
    if (anyButton.evaluate().isNotEmpty) {
      await tester.tap(anyButton.last, warnIfMissed: false);
    } else {
      // Buscar botones de texto que puedan ser de confirmar
      final textButtons = find.byType(TextButton);
      if (textButtons.evaluate().isNotEmpty) {
        await tester.tap(textButtons.last, warnIfMissed: false);
      }
    }
  }

  await pumpFrames(tester);
}

String _generateValidJwtToken() {
  final header = {'alg': 'HS256', 'typ': 'JWT'};

  final payload = {
    'naf': 999,
    'dig': '5',
    'cir': 'Santa Fe',
    'sex': 'M',
    'val': true,
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'exp': DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000,
  };

  final headerEncoded = base64Url.encode(utf8.encode(json.encode(header))).replaceAll('=', '');
  final payloadEncoded = base64Url.encode(utf8.encode(json.encode(payload))).replaceAll('=', '');

  final signature = base64Url.encode(utf8.encode('test-signature')).replaceAll('=', '');

  return '$headerEncoded.$payloadEncoded.$signature';
}

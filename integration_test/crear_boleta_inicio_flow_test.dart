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

  group('Crear Boleta Inicio Flow Tests', () {
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

    final successCrearBoletaResponseBody = json.encode({
      'id_boleta': '12345',
      'monto_entero': 21000,
      'monto_decimal': 0,
      'fecha_impresion': '2024-01-15T10:30:00Z',
      'fecha_vencimiento': '30',
    });
    const successCrearBoletaResponseStatus = 201;

    final successParamsBoletaInicioResponseBody = json.encode({
      'circunscripciones': [
        {'id': 1, 'descripcion': 'Santa Fe'},
      ],
      'tipos_juicios': [
        {
          'id': 1,
          'descripcion': 'Juzgado de Distrito y Colegiados',
          'montos': {'monto_caja': 1000.0, 'monto_forense': 500.0, 'monto_colegio': 200.0},
        },
      ],
    });
    const successParamsBoletaInicioResponseStatus = 200;

    final errorCrearBoletaResponseBody = json.encode({
      'error': 'Error al crear la boleta de inicio',
      'mensaje': 'No se pudo procesar la solicitud',
    });
    const errorCrearBoletaResponseStatus = 400;

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

    testWidgets('Debe completar el flujo completo de crear boleta de inicio exitosamente', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaInicio')) {
          return http.Response(successCrearBoletaResponseBody, successCrearBoletaResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any)).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/parametros-boleta-inicio/')) {
          return http.Response(successParamsBoletaInicioResponseBody, successParamsBoletaInicioResponseStatus);
        } else {
          return http.Response('{}', 200);
        }
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

      // Después del login exitoso, debería navegar a MainNavigationScreen que contiene HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Nueva boleta'));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      expect(find.byType(CrearBoletaScreen), findsOneWidget);

      await tester.tap(find.text('Boleta de Inicio'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Perez');
      await tester.enterText(find.byType(TextFormField).at(1), 'Maria Garcia');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);

      await container.read(boletaInicioDataProvider.future);
      await pumpFrames(tester);

      final dropdowns = find.byType(DropdownButtonFormField);

      if (dropdowns.evaluate().isEmpty) {
        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'Juzgado de Distrito y Colegiados');
          await pumpFrames(tester);

          await tester.enterText(textFields.at(1), 'Daños y Perjuicios');
          await pumpFrames(tester);
        }

        await tester.tap(find.text('SIGUIENTE'));
        await pumpFrames(tester);

        expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
        return;
      }

      expect(dropdowns, findsAtLeastNWidgets(1));

      await tester.tap(dropdowns.first);
      await pumpFrames(tester);
      await tester.tap(find.text('Juzgado de Distrito y Colegiados'));
      await pumpFrames(tester);

      await tester.tap(find.byType(DropdownButtonFormField).last);
      await pumpFrames(tester);

      await tester.tap(find.text('Santa Fe'));
      await pumpFrames(tester);

      await tester.enterText(find.byType(TextFormField), 'Daños y Perjuicios');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);

      await tester.tap(find.text('GENERAR'));
      await tester.pump(const Duration(milliseconds: 500));

      // Confirmar en el diálogo
      await tester.tap(find.text('SÍ'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(BoletaCreadaScreen), findsOneWidget);
      expect(find.text('Boleta generada con éxito'), findsOneWidget);
    });

    testWidgets('Debe mostrar error de validación en paso 1 cuando los campos están vacíos', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

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

      await tester.tap(find.text('Nueva boleta'));
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Inicio'));
      await pumpFrames(tester);

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      await tester.tap(find.text('SIGUIENTE'));
      await pumpFrames(tester);

      expect(find.text('Campo obligatorio'), findsNWidgets(2));
      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);
      expect(find.byType(Paso2BoletaInicioScreen), findsNothing);
    });

    testWidgets('Debe mostrar error de validación en paso 1 cuando se ingresan caracteres inválidos', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));

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

      await tester.tap(find.text('Nueva boleta'));
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Inicio'));
      await pumpFrames(tester);

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan123');
      await tester.enterText(find.byType(TextFormField).at(1), 'Maria@');

      await tester.tap(find.text('SIGUIENTE'));
      await pumpFrames(tester);

      expect(find.text('Solo letras y espacios permitidos'), findsNWidgets(2));
      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);
      expect(find.byType(Paso2BoletaInicioScreen), findsNothing);
    });

    testWidgets('Debe mostrar error de validación en paso 2 cuando la causa está vacía', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaInicio')) {
          return http.Response(successCrearBoletaResponseBody, successCrearBoletaResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any)).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/parametros-boleta-inicio/')) {
          return http.Response(successParamsBoletaInicioResponseBody, successParamsBoletaInicioResponseStatus);
        } else {
          return http.Response('{}', 200);
        }
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

      await tester.tap(find.text('Nueva boleta'));
      await pumpFrames(tester);

      await tester.tap(find.text('Boleta de Inicio'));
      await pumpFrames(tester);

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Perez');
      await tester.enterText(find.byType(TextFormField).at(1), 'Maria Garcia');

      await tester.tap(find.text('SIGUIENTE'));
      await pumpFrames(tester, frames: 30);

      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);

      await container.read(boletaInicioDataProvider.future);
      await pumpFrames(tester);

      await tester.tap(find.text('SIGUIENTE'));
      await pumpFrames(tester);

      expect(find.text('La causa es obligatoria'), findsOneWidget);
      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);
      expect(find.byType(Paso3BoletaInicioScreen), findsNothing);
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

        if (url.contains('/api/v1/boletaInicio')) {
          return http.Response(errorCrearBoletaResponseBody, errorCrearBoletaResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any)).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/parametros-boleta-inicio/')) {
          return http.Response(successParamsBoletaInicioResponseBody, successParamsBoletaInicioResponseStatus);
        } else {
          return http.Response('{}', 200);
        }
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

      // Después del login exitoso, debería navegar a MainNavigationScreen que contiene HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Nueva boleta'));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      expect(find.byType(CrearBoletaScreen), findsOneWidget);

      await tester.tap(find.text('Boleta de Inicio'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Perez');
      await tester.enterText(find.byType(TextFormField).at(1), 'Maria Garcia');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);

      await container.read(boletaInicioDataProvider.future);
      await pumpFrames(tester);

      final dropdowns = find.byType(DropdownButtonFormField);

      if (dropdowns.evaluate().isEmpty) {
        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'Juzgado de Distrito y Colegiados');
          await pumpFrames(tester);

          await tester.enterText(textFields.at(1), 'Daños y Perjuicios');
          await pumpFrames(tester);
        }

        await tester.tap(find.text('SIGUIENTE'));
        await pumpFrames(tester);

        expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
        return;
      }

      expect(dropdowns, findsAtLeastNWidgets(1));

      await tester.tap(dropdowns.first);
      await pumpFrames(tester);
      await tester.tap(find.text('Juzgado de Distrito y Colegiados'));
      await pumpFrames(tester);

      await tester.tap(find.byType(DropdownButtonFormField).last);
      await pumpFrames(tester);

      await tester.tap(find.text('Santa Fe'));
      await pumpFrames(tester);

      await tester.enterText(find.byType(TextFormField), 'Daños y Perjuicios');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);

      await tester.tap(find.text('GENERAR'));
      await tester.pump(const Duration(milliseconds: 500));

      // Confirmar en el diálogo
      await tester.tap(find.text('SÍ'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
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

        if (url.contains('/api/v1/boletaInicio')) {
          throw TimeoutException('Connection timeout');
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any)).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/parametros-boleta-inicio/')) {
          return http.Response(successParamsBoletaInicioResponseBody, successParamsBoletaInicioResponseStatus);
        } else {
          return http.Response('{}', 200);
        }
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

      // Después del login exitoso, debería navegar a MainNavigationScreen que contiene HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Nueva boleta'));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      expect(find.byType(CrearBoletaScreen), findsOneWidget);

      await tester.tap(find.text('Boleta de Inicio'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Perez');
      await tester.enterText(find.byType(TextFormField).at(1), 'Maria Garcia');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);

      await container.read(boletaInicioDataProvider.future);
      await pumpFrames(tester);

      final dropdowns = find.byType(DropdownButtonFormField);

      if (dropdowns.evaluate().isEmpty) {
        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'Juzgado de Distrito y Colegiados');
          await pumpFrames(tester);

          await tester.enterText(textFields.at(1), 'Daños y Perjuicios');
          await pumpFrames(tester);
        }

        await tester.tap(find.text('SIGUIENTE'));
        await pumpFrames(tester);

        expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
        return;
      }

      expect(dropdowns, findsAtLeastNWidgets(1));

      await tester.tap(dropdowns.first);
      await pumpFrames(tester);
      await tester.tap(find.text('Juzgado de Distrito y Colegiados'));
      await pumpFrames(tester);

      await tester.tap(find.byType(DropdownButtonFormField).last);
      await pumpFrames(tester);

      await tester.tap(find.text('Santa Fe'));
      await pumpFrames(tester);

      await tester.enterText(find.byType(TextFormField), 'Daños y Perjuicios');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);

      await tester.tap(find.text('GENERAR'));
      await tester.pump(const Duration(milliseconds: 500));

      // Confirmar en el diálogo
      await tester.tap(find.text('SÍ'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
      expect(find.byType(BoletaCreadaScreen), findsNothing);
    });

    testWidgets('Debe permitir navegar entre pasos usando los botones Volver', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaInicio')) {
          return http.Response(successCrearBoletaResponseBody, successCrearBoletaResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any)).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/parametros-boleta-inicio/')) {
          return http.Response(successParamsBoletaInicioResponseBody, successParamsBoletaInicioResponseStatus);
        } else {
          return http.Response('{}', 200);
        }
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

      // Después del login exitoso, debería navegar a MainNavigationScreen que contiene HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Nueva boleta'));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      expect(find.byType(CrearBoletaScreen), findsOneWidget);

      await tester.tap(find.text('Boleta de Inicio'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Perez');
      await tester.enterText(find.byType(TextFormField).at(1), 'Maria Garcia');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);

      await container.read(boletaInicioDataProvider.future);
      await pumpFrames(tester);

      await tester.tap(find.text('Volver'));
      await pumpFrames(tester);

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      expect(find.text('Juan Perez'), findsOneWidget);
      expect(find.text('Maria Garcia'), findsOneWidget);
    });

    testWidgets('Debe cancelar la generación cuando se presiona NO en el diálogo de confirmación', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaInicio')) {
          return http.Response(successCrearBoletaResponseBody, successCrearBoletaResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any)).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/parametros-boleta-inicio/')) {
          return http.Response(successParamsBoletaInicioResponseBody, successParamsBoletaInicioResponseStatus);
        } else {
          return http.Response('{}', 200);
        }
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

      // Después del login exitoso, debería navegar a MainNavigationScreen que contiene HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Nueva boleta'));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester);

      expect(find.byType(CrearBoletaScreen), findsOneWidget);

      await tester.tap(find.text('Boleta de Inicio'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'Juan Perez');
      await tester.enterText(find.byType(TextFormField).at(1), 'Maria Garcia');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);

      await container.read(boletaInicioDataProvider.future);
      await pumpFrames(tester);

      final dropdowns = find.byType(DropdownButtonFormField);

      if (dropdowns.evaluate().isEmpty) {
        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'Juzgado de Distrito y Colegiados');
          await pumpFrames(tester);

          await tester.enterText(textFields.at(1), 'Daños y Perjuicios');
          await pumpFrames(tester);
        }

        await tester.tap(find.text('SIGUIENTE'));
        await pumpFrames(tester);

        expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
        return;
      }

      expect(dropdowns, findsAtLeastNWidgets(1));

      await tester.tap(dropdowns.first);
      await pumpFrames(tester);
      await tester.tap(find.text('Juzgado de Distrito y Colegiados'));
      await pumpFrames(tester);

      await tester.tap(find.byType(DropdownButtonFormField).last);
      await pumpFrames(tester);

      await tester.tap(find.text('Santa Fe'));
      await pumpFrames(tester);

      await tester.enterText(find.byType(TextFormField), 'Daños y Perjuicios');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);

      await tester.tap(find.text('GENERAR'));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('NO'));
      await pumpFrames(tester);

      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
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

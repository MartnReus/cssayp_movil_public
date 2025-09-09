import 'dart:convert';

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

  group('Crear Boleta Fin Flow Simple Tests', () {
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

    testWidgets('Debe navegar correctamente entre los pasos de crear boleta de fin', (tester) async {
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
      await tester.pumpAndSettle();

      // Después del login exitoso, debería navegar a MainNavigationScreen que contiene HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(CrearBoletaScreen), findsOneWidget);

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(Paso1BoletaFinScreen), findsOneWidget);

      // Seleccionar carátula
      await tester.tap(find.text('Seleccione una carátula'));
      await tester.pumpAndSettle();

      // Esperar a que se carguen las boletas
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Seleccionar la primera carátula disponible
      await tester.tap(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'));
      await tester.pumpAndSettle();

      // Completar campos opcionales
      await tester.enterText(find.byType(TextFormField).at(0), '12345');
      await tester.enterText(find.byType(TextFormField).at(1), '2024');
      await tester.enterText(find.byType(TextFormField).at(2), '98765');

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pumpAndSettle();

      expect(find.byType(Paso2BoletaFinScreen), findsOneWidget);

      // Verificar que estamos en el paso 2
      expect(find.text('Ingrese los datos de regulación final'), findsOneWidget);
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
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Boleta de Finalización'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(Paso1BoletaFinScreen), findsOneWidget);

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pumpAndSettle();

      expect(find.text('Campo obligatorio'), findsAtLeastNWidgets(1));
      expect(find.byType(Paso1BoletaFinScreen), findsOneWidget);
      expect(find.byType(Paso2BoletaFinScreen), findsNothing);
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
  await tester.pumpAndSettle();

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

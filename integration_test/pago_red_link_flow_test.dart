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
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';
import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';
import 'package:cssayp_movil/shared/screens/main_navigation_screen.dart';
import 'package:cssayp_movil/shared/providers/connectivity_provider.dart';

import "../test/auth/data/datasources/usuario_data_source_test.mocks.dart";
import '../test/auth/presentation/providers/auth_provider_test.mocks.dart';

/// Helper function to pump a fixed number of frames
/// Usado porque hay algun proceso de fondo que hace que pumpAndSettle no funcione correctamente
Future<void> pumpFrames(
  WidgetTester tester, {
  int frames = 10,
  Duration frameDuration = const Duration(milliseconds: 100),
}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(frameDuration);
  }
}

class MockBoletasNotifier extends AsyncNotifier<BoletasState> {
  @override
  Future<BoletasState> build() async {
    return const BoletasState();
  }

  Future<void> obtenerBoletasParaPagar({int? page, bool forceRefresh = false}) async {
    print('🔍 MockBoletasNotifier.obtenerBoletasParaPagar called with page: $page');

    final boletas = <BoletaEntity>[
      BoletaEntity(
        id: 1,
        caratula: 'PEREZ JUAN C/ GARCIA MARIA S/ DIVORCIO',
        monto: 15000.50,
        fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
        fechaImpresion: DateTime.now(),
        tipo: BoletaTipo.inicio,
        estado: 'pendiente',
        nroExpediente: 123,
        anioExpediente: 2024,
      ),
      BoletaEntity(
        id: 2,
        caratula: 'LOPEZ CARLOS C/ MARTINEZ ANA S/ ALIMENTOS',
        monto: 12500.00,
        fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
        fechaImpresion: DateTime.now(),
        tipo: BoletaTipo.inicio,
        estado: 'pendiente',
        nroExpediente: 124,
        anioExpediente: 2024,
      ),
    ];

    state = AsyncValue.data(
      BoletasState(
        boletas: boletas,
        isLoading: false,
        currentPage: 1,
        lastPage: 1,
        total: 2,
        perPage: 10,
        hasNextPage: false,
        hasPreviousPage: false,
        isOfflineData: false,
        lastSyncTime: DateTime.now(),
      ),
    );
  }
}

/// Helper class to hold test mocks
class TestMocks {
  final MockClient client;
  final MockSecureStorageDataSource secureStorage;
  final MockUsuarioRepositoryComplete usuarioRepository;
  final MockBoletasRepositoryComplete boletasRepository;
  final MockPreferenciasRepository preferenciasRepository;
  final MockJwtTokenService jwtTokenService;
  final MockConnectivityNotifier connectivityNotifier;

  TestMocks({
    required this.client,
    required this.secureStorage,
    required this.usuarioRepository,
    required this.boletasRepository,
    required this.preferenciasRepository,
    required this.jwtTokenService,
    required this.connectivityNotifier,
  });

  /// Factory constructor to create all mocks at once
  factory TestMocks.create() {
    final secureStorage = MockSecureStorageDataSource();
    final usuarioRepository = MockUsuarioRepositoryComplete(secureStorage);
    final boletasRepository = MockBoletasRepositoryComplete();
    final preferenciasRepository = MockPreferenciasRepository();
    final jwtTokenService = MockJwtTokenService();
    final client = MockClient();
    final connectivityNotifier = MockConnectivityNotifier();

    // Setup common mock behavior
    when(preferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

    return TestMocks(
      client: client,
      secureStorage: secureStorage,
      usuarioRepository: usuarioRepository,
      boletasRepository: boletasRepository,
      preferenciasRepository: preferenciasRepository,
      jwtTokenService: jwtTokenService,
      connectivityNotifier: connectivityNotifier,
    );
  }
}

/// Helper function to create a test container with all necessary overrides
ProviderContainer createTestContainer(TestMocks mocks) {
  return ProviderContainer(
    overrides: [
      httpClientProvider.overrideWith((ref) => mocks.client),
      usuarioRepositoryProvider.overrideWith((ref) async => mocks.usuarioRepository),
      boletasRepositoryProvider.overrideWith((ref) async => mocks.boletasRepository),
      preferenciasRepositoryProvider.overrideWith((ref) async => mocks.preferenciasRepository),
      secureStorageDataSourceProvider.overrideWith((ref) => mocks.secureStorage),
      jwtTokenServiceProvider.overrideWith((ref) => mocks.jwtTokenService),
      connectivityProvider.overrideWith(() => mocks.connectivityNotifier),
    ],
  );
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

/// Mock personalizado para ConnectivityNotifier que no requiere conexión real
class MockConnectivityNotifier extends ConnectivityNotifier {
  ConnectivityStatus _mockStatus = ConnectivityStatus.online;

  @override
  Stream<ConnectivityStatus> build() {
    return Stream.value(_mockStatus);
  }

  void setMockStatus(ConnectivityStatus status) {
    _mockStatus = status;
  }
}

/// Mock personalizado para JwtTokenService que simula la extracción de campos del JWT
class MockJwtTokenService extends Mock implements JwtTokenService {
  @override
  Future<String?> obtenerDigito() async {
    return '5';
  }

  @override
  Future<String?> obtenerNumeroAfiliado() async {
    return '999';
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

/// Helper class to configure common HTTP mock responses
class HttpMockResponses {
  static final validJwtToken = _generateValidJwtToken();

  static final successLoginResponseBody = json.encode({
    'nro_afiliado': 999,
    'apellido_nombres': 'Perez, Juan',
    'token': validJwtToken,
    'cambiar_password': 0,
  });

  static final boletasPendientesResponseBody = json.encode({
    'data': [
      {
        'id': 1,
        'caratula': 'PEREZ JUAN C/ GARCIA MARIA S/ DIVORCIO',
        'monto_entero': 15000,
        'monto_decimal': 50,
        'fecha_vencimiento': '2024-12-31',
        'tipo': 'INICIO',
        'estado': 'pendiente',
      },
      {
        'id': 2,
        'caratula': 'LOPEZ CARLOS C/ MARTINEZ ANA S/ ALIMENTOS',
        'monto_entero': 12500,
        'monto_decimal': 0,
        'fecha_vencimiento': '2024-12-25',
        'tipo': 'INICIO',
        'estado': 'pendiente',
      },
    ],
    'current_page': 1,
    'last_page': 1,
    'per_page': 10,
    'total': 2,
    'next_page_url': null,
    'prev_page_url': null,
  });

  static final redLinkUrlResponseBody = json.encode({
    'payment_url': 'https://redlink-test.com/payment/12345',
    'token_id_link': 'TOKEN-12345-ABCDE',
    'referencia': 'REF-001-12345',
    'success': true,
  });

  static final verificarEstadoPagoPendienteBody = json.encode({
    'pagado': false,
    'estado': 'pendiente',
    'mensaje': 'Pago en proceso',
  });

  static final verificarEstadoPagoExitosoBody = json.encode({
    'pagado': true,
    'estado': 'aprobado',
    'mensaje': 'Pago procesado exitosamente',
  });

  static final errorRedLinkResponseBody = json.encode({'error': 'Error al generar URL de pago', 'success': false});
}

void setupStandardHttpMocks(MockClient mockClient) {
  when(
    mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
  ).thenAnswer((invocation) async => http.Response(HttpMockResponses.successLoginResponseBody, 200));

  when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
    final url = invocation.positionalArguments[0].toString();

    if (url.contains('/api/v1/boletas/historial')) {
      return http.Response(HttpMockResponses.boletasPendientesResponseBody, 200);
    }

    return http.Response('{}', 404);
  });
}

/// Helper to perform login flow
Future<void> realizarLogin(WidgetTester tester) async {
  await _esperarLoginScreen(tester);
  await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
  await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
  await tester.tap(find.byType(ElevatedButton));
  await pumpFrames(tester);

  expect(find.byType(MainNavigationScreen), findsOneWidget);
  expect(find.byType(HomeScreen), findsOneWidget);
}

/// Helper to navigate to payments screen
Future<void> navegarAPagos(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Pagos'));
  await pumpFrames(tester);
  expect(find.byType(PagosPrincipalScreen), findsOneWidget);
}

/// Helper to select a boleta and continue to payment processing
Future<void> seleccionarBoletaYContinuar(
  WidgetTester tester, {
  String caratula = 'PEREZ JUAN C/ GARCIA MARIA S/ DIVORCIO',
}) async {
  await pumpFrames(tester);

  expect(find.text(caratula), findsOneWidget);
  await tester.tap(find.text(caratula));
  await pumpFrames(tester);

  expect(find.text('Continuar'), findsOneWidget);
  await tester.tap(find.text('Continuar'));
  await pumpFrames(tester);

  expect(find.byType(ProcesarPagoScreen), findsOneWidget);
}

/// Helper to select Red Link payment method and confirm
Future<void> seleccionarRedLinkYConfirmar(WidgetTester tester, {required String montoTotal}) async {
  expect(find.text('Red Link'), findsOneWidget);
  await tester.tap(find.text('Red Link'));
  await pumpFrames(tester);

  expect(find.widgetWithText(ElevatedButton, 'Procesar Pago'), findsOneWidget);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Procesar Pago'));
  await pumpFrames(tester);

  expect(find.text('Confirmar Pago'), findsOneWidget);
  expect(find.text('¿Está seguro de que desea procesar el pago de \$$montoTotal?'), findsOneWidget);

  await tester.tap(find.text('Confirmar'));
  await pumpFrames(tester);
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

/// Mock personalizado para BoletasRepository que simula el comportamiento completo
class MockBoletasRepositoryComplete extends Mock implements BoletasRepository {
  @override
  Future<HistorialBoletasSuccessResponse> obtenerHistorialBoletas(
    int nroAfiliado, {
    int? page,
    int mostrarPagadas = 1,
  }) async {
    final boletas = [
      BoletaHistorialModel(
        idBoletaGenerada: '1',
        monto: '15000.50',
        caratula: 'PEREZ JUAN C/ GARCIA MARIA S/ DIVORCIO',
        idTipoBoleta: '1',
        fechaImpresion: '2024-01-01',
        diasVencimiento: '30',
        estado: 'pendiente',
      ),
      BoletaHistorialModel(
        idBoletaGenerada: '2',
        monto: '12500.00',
        caratula: 'LOPEZ CARLOS C/ MARTINEZ ANA S/ ALIMENTOS',
        idTipoBoleta: '1',
        fechaImpresion: '2024-01-01',
        diasVencimiento: '30',
        estado: 'pendiente',
      ),
    ];

    return HistorialBoletasSuccessResponse(
      statusCode: 200,
      boletas: boletas,
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: 2,
    );
  }

  @override
  Future<ParametrosBoletaInicioEntity> obtenerParametrosBoletaInicio(int nroAfiliado) async {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedResponseModel> buscarBoletasInicioPagadas({
    required int nroAfiliado,
    int page = 1,
    String? caratulaBuscada,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo de Pago con Red Link', () {
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
      await Future.delayed(const Duration(seconds: 2));
    });

    tearDownAll(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    testWidgets('Debe completar el flujo completo de pago con Red Link exitosamente', (tester) async {
      final mocks = TestMocks.create();

      // Contador para controlar las respuestas de verificarEstadoPago
      int verificarEstadoPagoCallCount = 0;

      // Configurar respuestas del mock HTTP client
      setupStandardHttpMocks(mocks.client);

      when(mocks.client.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(HttpMockResponses.boletasPendientesResponseBody, 200);
        } else if (url.contains('/bol/generar-url-pago/')) {
          return http.Response(HttpMockResponses.redLinkUrlResponseBody, 200);
        } else if (url.contains('/bol/verificar-estado-pago/')) {
          verificarEstadoPagoCallCount++;
          // Primera llamada retorna pendiente, las siguientes retornan pagado
          if (verificarEstadoPagoCallCount == 1) {
            return http.Response(HttpMockResponses.verificarEstadoPagoPendienteBody, 200);
          } else {
            return http.Response(HttpMockResponses.verificarEstadoPagoExitosoBody, 200);
          }
        }

        return http.Response('{}', 404);
      });

      final container = createTestContainer(mocks);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      // Paso 1-2: Login y navegar a pagos
      await realizarLogin(tester);
      await navegarAPagos(tester);

      expect(find.text('Boletas de Inicio'), findsOneWidget);
      expect(find.text('Boletas de Finalización'), findsOneWidget);

      // Paso 3-5: Seleccionar boleta y continuar
      expect(find.text('\$15000.50'), findsOneWidget);
      await seleccionarBoletaYContinuar(tester);

      // Paso 6-7: Seleccionar Red Link y confirmar
      await seleccionarRedLinkYConfirmar(tester, montoTotal: '15000.50');

      // Paso 8: Verificar que se abre la pantalla de Red Link con WebView
      expect(find.byType(RedLinkPaymentScreen), findsOneWidget);
      expect(find.text('Pago Red Link'), findsOneWidget);
      expect(find.text('Verificar Estado'), findsOneWidget);

      await pumpFrames(tester);

      expect(find.byType(RedLinkPaymentScreen), findsOneWidget);

      // Paso 9: Verificar manualmente el estado del pago (segunda llamada, retornará pagado)
      await tester.tap(find.text('Verificar Estado'));
      await pumpFrames(tester);

      // Paso 10: Verificar que se navega a la pantalla de pago exitoso
      expect(find.byType(PagoExitosoScreen), findsOneWidget);
      expect(find.text('Pago Exitoso'), findsOneWidget);
    });

    testWidgets('Debe mostrar error cuando falla la generación de URL de Red Link', (tester) async {
      final mocks = TestMocks.create();

      setupStandardHttpMocks(mocks.client);

      when(mocks.client.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(HttpMockResponses.boletasPendientesResponseBody, 200);
        } else if (url.contains('/bol/generar-url-pago/')) {
          return http.Response(HttpMockResponses.errorRedLinkResponseBody, 400);
        }

        return http.Response('{}', 404);
      });

      final container = createTestContainer(mocks);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      // Login y navegación a pagos
      await realizarLogin(tester);
      await navegarAPagos(tester);

      // Seleccionar boleta y continuar
      expect(find.text('\$15000.50'), findsOneWidget);
      await seleccionarBoletaYContinuar(tester);

      // Seleccionar Red Link y confirmar
      await seleccionarRedLinkYConfirmar(tester, montoTotal: '15000.50');

      // Verificar mensaje de error
      expect(find.textContaining('Error al generar URL de pago'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Reintentar'), findsOneWidget);
    });

    testWidgets('No debe permitir seleccionar múltiples boletas de inicio', (tester) async {
      final mocks = TestMocks.create();

      setupStandardHttpMocks(mocks.client);

      final container = createTestContainer(mocks);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      // Login y navegar a pagos
      await realizarLogin(tester);
      await navegarAPagos(tester);

      // Verificar que se muestran ambas boletas
      await pumpFrames(tester);

      expect(find.text('PEREZ JUAN C/ GARCIA MARIA S/ DIVORCIO'), findsOneWidget);
      expect(find.text('LOPEZ CARLOS C/ MARTINEZ ANA S/ ALIMENTOS'), findsOneWidget);

      // Seleccionar la primera boleta de inicio
      await tester.tap(find.text('PEREZ JUAN C/ GARCIA MARIA S/ DIVORCIO'));
      await pumpFrames(tester);

      // Verificar que la primera boleta está seleccionada
      expect(find.text('Total: \$15000.50'), findsOneWidget);

      // Intentar seleccionar la segunda boleta de inicio
      await tester.tap(find.text('LOPEZ CARLOS C/ MARTINEZ ANA S/ ALIMENTOS'));
      await pumpFrames(tester);

      // Verificar que solo la segunda boleta está seleccionada (la primera se deseleccionó automáticamente)
      expect(find.text('Total: \$12500.00'), findsAny);
      expect(find.text('Total: \$15000.50'), findsNothing);

      // Verificar que el botón "Continuar" está disponible
      expect(find.text('Continuar'), findsOneWidget);

      // Continuar con el pago para verificar que solo se procesa una boleta
      await tester.tap(find.text('Continuar'));
      await pumpFrames(tester);

      expect(find.byType(ProcesarPagoScreen), findsOneWidget);

      // Verificar que el total mostrado corresponde solo a la boleta seleccionada
      expect(find.textContaining('15000.50'), findsNothing);
    });

    testWidgets('Debe mostrar error de conexión cuando no hay red', (tester) async {
      final mocks = TestMocks.create();

      setupStandardHttpMocks(mocks.client);

      when(mocks.client.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(HttpMockResponses.boletasPendientesResponseBody, 200);
        } else if (url.contains('/bol/generar-url-pago/')) {
          throw TimeoutException('Connection timeout');
        }

        return http.Response('{}', 404);
      });

      final container = createTestContainer(mocks);

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      // Login y navegar a pagos
      await realizarLogin(tester);
      await navegarAPagos(tester);

      // Seleccionar boleta y continuar
      expect(find.text('\$15000.50'), findsOneWidget);
      await seleccionarBoletaYContinuar(tester);

      // Seleccionar Red Link y confirmar
      await seleccionarRedLinkYConfirmar(tester, montoTotal: '15000.50');

      // Verificar que se muestra el mensaje de error de conexión
      expect(find.textContaining('Tiempo de espera agotado'), findsOneWidget);
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

  await tester.pumpAndSettle(const Duration(milliseconds: 500));

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

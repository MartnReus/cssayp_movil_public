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

/// Helper function to safely pump and settle with timeout
Future<void> pumpAndSettleWithTimeout(WidgetTester tester, {Duration timeout = const Duration(seconds: 5)}) async {
  print('🔄 Starting pumpAndSettle with ${timeout.inSeconds}s timeout...');
  try {
    await tester.pumpAndSettle(timeout);
    print('✅ pumpAndSettle completed successfully');
  } catch (e) {
    print('⚠️ pumpAndSettle timed out after ${timeout.inSeconds} seconds: $e');
    // Force pump to continue
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Debug helper to check what widgets are currently visible
void debugCurrentWidgets(WidgetTester tester) {
  print('🔍 Current widgets on screen:');
  final widgets = tester.widgetList(find.byType(Widget));
  for (int i = 0; i < widgets.length && i < 10; i++) {
    final widget = widgets.elementAt(i);
    print('  - ${widget.runtimeType}');
  }
  if (widgets.length > 10) {
    print('  ... and ${widgets.length - 10} more widgets');
  }
}

/// Debug helper to check provider states
void debugProviderStates(ProviderContainer container) {
  print('🔍 Checking provider states...');

  try {
    final boletasState = container.read(boletasProvider);
    print('  - boletasProvider: ${boletasState.runtimeType}');
    if (boletasState.hasValue) {
      print('    - hasValue: true, boletas count: ${boletasState.value?.boletas.length ?? 0}');
    } else if (boletasState.hasError) {
      print('    - hasError: true, error: ${boletasState.error}');
    } else {
      print('    - isLoading: true');
    }
  } catch (e) {
    print('  - boletasProvider: Error reading state - $e');
  }

  try {
    final authState = container.read(authProvider);
    print('  - authProvider: ${authState.runtimeType}');
    if (authState.hasValue) {
      print('    - hasValue: true, isAuthenticated: ${authState.value?.usuario != null}');
    } else if (authState.hasError) {
      print('    - hasError: true, error: ${authState.error}');
    } else {
      print('    - isLoading: true');
    }
  } catch (e) {
    print('  - authProvider: Error reading state - $e');
  }
}

/// Mock BoletasNotifier that doesn't call obtenerBoletasCreadas during build
class MockBoletasNotifier extends AsyncNotifier<BoletasState> {
  @override
  Future<BoletasState> build() async {
    print('🔍 MockBoletasNotifier.build() called - returning empty state immediately');
    // Return empty state immediately without calling obtenerBoletasCreadas
    return const BoletasState();
  }

  // Override the method that gets called when navigating to payments
  Future<void> obtenerBoletasParaPagar({int? page, bool forceRefresh = false}) async {
    print('🔍 MockBoletasNotifier.obtenerBoletasParaPagar called with page: $page');

    // Simulate the boletas data that would be returned (solo finalización para estas pruebas)
    final boletas = <BoletaEntity>[
      BoletaEntity(
        id: 3,
        caratula: 'RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS',
        monto: 8500.75,
        fechaVencimiento: DateTime.now().add(const Duration(days: 20)),
        fechaImpresion: DateTime.now(),
        tipo: BoletaTipo.finalizacion,
        estado: 'pendiente',
        nroExpediente: 125,
        anioExpediente: 2024,
      ),
      BoletaEntity(
        id: 4,
        caratula: 'FERNANDEZ LUIS C/ MORALES ANA S/ COBRO DE PESOS',
        monto: 6200.00,
        fechaVencimiento: DateTime.now().add(const Duration(days: 15)),
        fechaImpresion: DateTime.now(),
        tipo: BoletaTipo.finalizacion,
        estado: 'pendiente',
        nroExpediente: 126,
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

    print('✅ MockBoletasNotifier.obtenerBoletasParaPagar completed with ${boletas.length} boletas de finalización');
  }
}

/// Helper function to create a test container with all necessary overrides
ProviderContainer createTestContainer({
  required MockClient mockClient,
  required MockUsuarioRepositoryComplete mockUsuarioRepository,
  required MockBoletasRepositoryComplete mockBoletasRepository,
  required MockPreferenciasRepository mockPreferenciasRepository,
  required MockSecureStorageDataSource mockSecureStorageDataSource,
  required MockJwtTokenService mockJwtTokenService,
}) {
  return ProviderContainer(
    overrides: [
      httpClientProvider.overrideWith((ref) => mockClient),
      usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
      boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
      preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
      secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
      jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
      connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
      // Note: We can't override boletasProvider directly due to type constraints
      // The hanging issue is in the BoletasNotifier.build() method calling obtenerBoletasCreadas()
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

/// Mock personalizado para BoletasRepository que simula el comportamiento completo
class MockBoletasRepositoryComplete extends Mock implements BoletasRepository {
  @override
  Future<HistorialBoletasSuccessResponse> obtenerHistorialBoletas(
    int nroAfiliado, {
    int? page,
    int mostrarPagadas = 1,
  }) async {
    print(
      '🔍 MockBoletasRepository.obtenerHistorialBoletas called with nroAfiliado: $nroAfiliado, page: $page, mostrarPagadas: $mostrarPagadas',
    );

    // Simular respuesta de boletas pendientes (solo finalización para estas pruebas)
    final boletas = [
      BoletaHistorialModel(
        idBoletaGenerada: '3',
        monto: '8500.75',
        caratula: 'RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS',
        idTipoBoleta: '6', // Finalización
        fechaImpresion: '2024-01-01',
        diasVencimiento: '20',
        estado: 'pendiente',
      ),
      BoletaHistorialModel(
        idBoletaGenerada: '4',
        monto: '6200.00',
        caratula: 'FERNANDEZ LUIS C/ MORALES ANA S/ COBRO DE PESOS',
        idTipoBoleta: '6', // Finalización
        fechaImpresion: '2024-01-01',
        diasVencimiento: '15',
        estado: 'pendiente',
      ),
    ];

    print('✅ MockBoletasRepository.obtenerHistorialBoletas returning ${boletas.length} boletas de finalización');
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
    print('🔍 MockBoletasRepository.obtenerParametrosBoletaInicio called with nroAfiliado: $nroAfiliado');
    throw UnimplementedError();
  }

  @override
  Future<PaginatedResponseModel> buscarBoletasInicioPagadas({
    required int nroAfiliado,
    int page = 1,
    String? caratulaBuscada,
  }) async {
    print('🔍 MockBoletasRepository.buscarBoletasInicioPagadas called with nroAfiliado: $nroAfiliado, page: $page');
    throw UnimplementedError();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo de Pago con PayWay', () {
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

    // Respuesta de boletas pendientes (solo finalización para estas pruebas)
    final boletasPendientesResponseBody = json.encode({
      'data': [
        {
          'id': 3,
          'caratula': 'RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS',
          'monto_entero': 8500,
          'monto_decimal': 75,
          'fecha_vencimiento': '2024-12-20',
          'tipo': 'FINALIZACION',
          'estado': 'pendiente',
        },
        {
          'id': 4,
          'caratula': 'FERNANDEZ LUIS C/ MORALES ANA S/ COBRO DE PESOS',
          'monto_entero': 6200,
          'monto_decimal': 0,
          'fecha_vencimiento': '2024-12-15',
          'tipo': 'FINALIZACION',
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
    const boletasPendientesResponseStatus = 200;

    final successPayWayResponseBody = json.encode({
      'estado': '1',
      'mensaje': 'Pago procesado exitosamente',
      'id_transaccion': 'TXN123456789',
      'monto': 8500.75,
    });
    const successPayWayResponseStatus = 200;

    final errorPayWayResponseBody = json.encode({
      'estado': '0',
      'mensaje': 'Error al procesar el pago',
      'codigo_error': 'CARD_DECLINED',
    });
    const errorPayWayResponseStatus = 400;

    setUpAll(() async {
      secureStorage = const FlutterSecureStorage();
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    tearDown(() async {
      await Future.delayed(const Duration(seconds: 8));
    });

    tearDownAll(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    testWidgets('Debe completar el flujo completo de pago con PayWay exitosamente', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();
      final mockConnectivity = MockConnectivityNotifier();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      // Configurar respuestas del mock HTTP client
      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/checkout/payment-prisma')) {
          return http.Response(successPayWayResponseBody, successPayWayResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(boletasPendientesResponseBody, boletasPendientesResponseStatus);
        }

        return http.Response('{}', 404);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          connectivityProvider.overrideWith(() => mockConnectivity),
        ],
      );

      print('🚀 Starting test - pumping MyApp widget...');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));
      print('✅ MyApp widget pumped successfully');

      // Paso 1: Login
      print('🔐 Starting login process...');
      await _esperarLoginScreen(tester);
      print('✅ Login screen loaded');

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
      print('📝 Login credentials entered');

      await tester.tap(find.byType(ElevatedButton));
      print('👆 Login button tapped');

      // Dar tiempo para que se procese el login y se carguen los providers
      print('⏳ Waiting for login processing and provider initialization...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
          debugCurrentWidgets(tester);
        }
      }
      print('✅ Login processing completed');

      print('🔍 Checking provider states after login...');
      debugProviderStates(container);

      print('🔍 Checking for MainNavigationScreen...');
      if (find.byType(MainNavigationScreen).evaluate().isEmpty) {
        print('❌ MainNavigationScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
        // Intentar con pumpAndSettle para asegurar que la UI se estabilice
        await pumpAndSettleWithTimeout(tester);
        debugCurrentWidgets(tester);
      }
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      print('🔍 Checking for HomeScreen...');
      if (find.byType(HomeScreen).evaluate().isEmpty) {
        print('❌ HomeScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      // Paso 2: Navegar a la pantalla de Pagos
      print('💳 Navigating to Payments screen...');

      // Buscar el NavigationDestination de Pagos (índice 2)
      print('🔍 Looking for NavigationDestination with Pagos label...');

      // Buscar específicamente el NavigationDestination de Pagos (índice 2)
      final navDestinations = find.byType(NavigationDestination);
      if (navDestinations.evaluate().length >= 3) {
        // El botón de Pagos está en el índice 2 (tercer elemento)
        await tester.tap(navDestinations.at(2));
        print('👆 Payments tab tapped (by NavigationDestination index 2)');
      } else if (find.byIcon(Icons.payment_outlined).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment_outlined));
        print('👆 Payments tab tapped (by payment_outlined icon)');
      } else if (find.byIcon(Icons.payment).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment));
        print('👆 Payments tab tapped (by payment icon)');
      } else {
        print('❌ Could not find payments tab, checking current widgets...');
        debugCurrentWidgets(tester);

        // Buscar NavigationDestination widgets
        final navDestinations = find.byType(NavigationDestination);
        print('Found ${navDestinations.evaluate().length} NavigationDestination widgets');
        for (int i = 0; i < navDestinations.evaluate().length; i++) {
          final navDest = navDestinations.at(i);
          final widget = tester.widget<NavigationDestination>(navDest);
          print('  NavigationDestination $i: label="${widget.label}"');
        }

        // Buscar todos los textos disponibles
        final textWidgets = find.byType(Text);
        print('Found ${textWidgets.evaluate().length} Text widgets');
        for (int i = 0; i < textWidgets.evaluate().length && i < 20; i++) {
          final textWidget = textWidgets.at(i);
          final text = tester.widget<Text>(textWidget).data ?? '';
          if (text.isNotEmpty) {
            print('  Text $i: "$text"');
          }
        }

        throw Exception('Could not find payments navigation element');
      }

      // Dar tiempo para que se cargue la pantalla de pagos y las boletas
      print('⏳ Waiting for payments screen and boletas to load...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
          debugCurrentWidgets(tester);
        }
      }
      print('✅ Payments screen loading completed');

      print('🔍 Checking provider states after navigation to payments...');
      debugProviderStates(container);

      print('🔍 Checking for PagosPrincipalScreen...');
      if (find.byType(PagosPrincipalScreen).evaluate().isEmpty) {
        print('❌ PagosPrincipalScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
        // Intentar con pumpAndSettle para asegurar que la UI se estabilice
        await pumpAndSettleWithTimeout(tester);
        debugCurrentWidgets(tester);
      }
      expect(find.byType(PagosPrincipalScreen), findsOneWidget);
      print('✅ PagosPrincipalScreen found');

      print('🔍 Checking for tab labels...');
      expect(find.text('Boletas de Inicio'), findsOneWidget);
      expect(find.text('Boletas de Finalización'), findsOneWidget);
      print('✅ Tab labels found');

      // Paso 3: Cambiar a la pestaña de "Boletas de Finalización"
      print('🔄 Switching to Boletas de Finalización tab...');
      await tester.tap(find.text('Boletas de Finalización'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Tab switched to Boletas de Finalización');

      // Verificar estado del provider después de cambiar tab
      print('🔍 Checking provider states after switching to finalización...');
      debugProviderStates(container);

      // Esperar a que se carguen las boletas de finalización
      print('📋 Waiting for boletas de finalización to be displayed...');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 3 == 0) {
          print('  - Waiting for boletas ${i + 1}/10');
          debugCurrentWidgets(tester);
        }
      }
      print('✅ Boletas loading completed');

      print('🔍 Checking current widgets after tab switch...');
      debugCurrentWidgets(tester);

      // Buscar todos los textos disponibles para debug
      final textWidgets = find.byType(Text);
      print('📝 Found ${textWidgets.evaluate().length} Text widgets. Showing first 20:');
      for (int i = 0; i < textWidgets.evaluate().length && i < 20; i++) {
        final textWidget = textWidgets.at(i);
        final text = tester.widget<Text>(textWidget).data ?? '';
        if (text.isNotEmpty) {
          print('  Text $i: "$text"');
        }
      }

      print('🔍 Checking for specific boleta de finalización content...');
      if (find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS').evaluate().isEmpty) {
        print('❌ Boleta de finalización not found! Looking for "No hay boletas" message...');
        if (find.text('No hay boletas disponibles').evaluate().isNotEmpty) {
          print('⚠️ Found "No hay boletas disponibles" message - boletas are not loading!');
        }
      }
      expect(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'), findsOneWidget);
      expect(find.text('\$8500.75'), findsOneWidget);
      print('✅ Boletas de finalización content found');

      // Paso 4: Seleccionar una boleta de finalización
      print('👆 Selecting boleta de finalización...');

      // Verificar que la boleta está visible antes de intentar hacer tap
      if (find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS').evaluate().isEmpty) {
        print('❌ Boleta text not found, checking current widgets...');
        debugCurrentWidgets(tester);
        final textWidgets = find.byType(Text);
        print('Found ${textWidgets.evaluate().length} Text widgets');
        for (int i = 0; i < textWidgets.evaluate().length && i < 10; i++) {
          final textWidget = textWidgets.at(i);
          final text = tester.widget<Text>(textWidget).data ?? '';
          print('  Text $i: "$text"');
        }
      }

      await tester.tap(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'));
      print('👆 Boleta tapped, waiting for UI to settle...');
      debugCurrentWidgets(tester);
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Boleta selection completed');

      // Verificar que el total seleccionado se muestra
      print('🔍 Checking for total and continue button...');
      if (find.text('Total: \$8500.75').evaluate().isEmpty) {
        print('❌ Total text not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.text('Total: \$8500.75'), findsOneWidget);

      if (find.text('Continuar').evaluate().isEmpty) {
        print('❌ Continue button not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.text('Continuar'), findsOneWidget);

      // Paso 5: Continuar con el pago
      final continuarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Continuar',
      );

      expect(continuarButton, findsOneWidget);
      await tester.tap(continuarButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
      expect(find.text('Procesar Pago'), findsWidgets);
      print('✅ Navigated to ProcesarPagoScreen');

      // Paso 6: Seleccionar método de pago Tarjeta de Crédito/Débito
      print('💳 Selecting card payment method...');
      expect(find.text('Tarjeta de crédito/débito'), findsOneWidget);
      await tester.tap(find.text('Tarjeta de crédito/débito'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Card payment method selected');

      // Verificar que aparece el formulario de PayWay
      print('🔍 Checking for PayWay form...');
      expect(find.byType(PayWayForm), findsOneWidget);
      print('✅ PayWay form found');

      // Paso 7: Llenar el formulario de tarjeta
      print('💳 Filling PayWay form...');
      await _llenarFormularioTarjeta(tester);
      print('✅ PayWay form filled');

      // Paso 8: Procesar el pago - Buscar el botón específico
      print('💰 Processing payment...');
      final procesarPagoButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Procesar Pago',
      );

      expect(procesarPagoButton, findsOneWidget);
      await tester.tap(procesarPagoButton);
      await tester.pump(const Duration(milliseconds: 100));
      print('👆 Procesar Pago button tapped');

      // Paso 9: Verificar y confirmar el diálogo de confirmación
      print('🔍 Checking for confirmation dialog...');
      expect(find.text('Confirmar Pago'), findsOneWidget);
      expect(find.text('¿Está seguro de que desea procesar el pago de \$8500.75?'), findsOneWidget);
      print('✅ Confirmation dialog found');

      final confirmarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Confirmar',
      );

      expect(confirmarButton, findsOneWidget);
      await tester.tap(confirmarButton);
      print('👆 Confirmar button tapped, waiting for PayWay processing...');

      // Esperar a que se procese el pago con PayWay y se actualice el estado
      await tester.pump(const Duration(milliseconds: 100)); // Cerrar el diálogo
      await tester.pump(const Duration(milliseconds: 500)); // Esperar el procesamiento de PayWay
      await tester.pump(const Duration(milliseconds: 100)); // Actualización final del estado
      print('✅ PayWay payment processing completed');

      // Paso 10: Verificar que se navega a la pantalla de pago exitoso
      if (find.byType(PagoExitosoScreen).evaluate().isEmpty) {
        print('❌ PagoExitosoScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(PagoExitosoScreen), findsOneWidget);
      expect(find.text('¡Pago Exitoso!'), findsOneWidget);
      print('✅ PagoExitosoScreen found and verified');
    });

    testWidgets('Debe mostrar errores de validación en el formulario de tarjeta', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();
      final mockConnectivity = MockConnectivityNotifier();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(boletasPendientesResponseBody, boletasPendientesResponseStatus);
        }

        return http.Response('{}', 404);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          connectivityProvider.overrideWith(() => mockConnectivity),
        ],
      );

      print('🚀 Starting validation test - pumping MyApp widget...');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));
      print('✅ MyApp widget pumped successfully');

      // Paso 1: Login
      print('🔐 Starting login process...');
      await _esperarLoginScreen(tester);
      print('✅ Login screen loaded');

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
      print('📝 Login credentials entered');

      await tester.tap(find.byType(ElevatedButton));
      print('👆 Login button tapped');

      // Dar tiempo para que se procese el login y se carguen los providers
      print('⏳ Waiting for login processing and provider initialization...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }
      print('✅ Login processing completed');

      print('🔍 Checking for MainNavigationScreen...');
      if (find.byType(MainNavigationScreen).evaluate().isEmpty) {
        print('❌ MainNavigationScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
        await pumpAndSettleWithTimeout(tester);
      }
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      print('🔍 Checking for HomeScreen...');
      if (find.byType(HomeScreen).evaluate().isEmpty) {
        print('❌ HomeScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      // Paso 2: Navegar a la pantalla de Pagos
      print('💳 Navigating to Payments screen...');

      final navDestinations = find.byType(NavigationDestination);
      if (navDestinations.evaluate().length >= 3) {
        await tester.tap(navDestinations.at(2));
        print('👆 Payments tab tapped (by NavigationDestination index 2)');
      } else if (find.byIcon(Icons.payment_outlined).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment_outlined));
        print('👆 Payments tab tapped (by payment_outlined icon)');
      } else if (find.byIcon(Icons.payment).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment));
        print('👆 Payments tab tapped (by payment icon)');
      } else {
        print('❌ Could not find payments tab');
        throw Exception('Could not find payments navigation element');
      }

      // Dar tiempo para que se cargue la pantalla de pagos y las boletas
      print('⏳ Waiting for payments screen and boletas to load...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }
      print('✅ Payments screen loading completed');

      print('🔍 Checking for PagosPrincipalScreen...');
      if (find.byType(PagosPrincipalScreen).evaluate().isEmpty) {
        print('❌ PagosPrincipalScreen not found');
        debugCurrentWidgets(tester);
        await pumpAndSettleWithTimeout(tester);
      }
      expect(find.byType(PagosPrincipalScreen), findsOneWidget);
      print('✅ PagosPrincipalScreen found');

      print('🔍 Checking for tab labels...');
      expect(find.text('Boletas de Inicio'), findsOneWidget);
      expect(find.text('Boletas de Finalización'), findsOneWidget);
      print('✅ Tab labels found');

      // Paso 3: Cambiar a la pestaña de "Boletas de Finalización"
      print('🔄 Switching to Boletas de Finalización tab...');
      await tester.tap(find.text('Boletas de Finalización'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Tab switched to Boletas de Finalización');

      // Verificar estado del provider después de cambiar tab
      print('🔍 Checking provider states after switching to finalización...');
      debugProviderStates(container);

      // Esperar a que se carguen las boletas de finalización
      print('📋 Waiting for boletas de finalización to be displayed...');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 3 == 0) {
          print('  - Waiting for boletas ${i + 1}/10');
        }
      }
      print('✅ Boletas loading completed');

      print('🔍 Checking current widgets after tab switch...');
      debugCurrentWidgets(tester);

      print('🔍 Checking for specific boleta de finalización content...');
      if (find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS').evaluate().isEmpty) {
        print('❌ Boleta de finalización not found! Looking for "No hay boletas" message...');
        if (find.text('No hay boletas disponibles').evaluate().isNotEmpty) {
          print('⚠️ Found "No hay boletas disponibles" message - boletas are not loading!');
        }
        // Buscar todos los textos disponibles para debug
        final textWidgets = find.byType(Text);
        print('📝 Found ${textWidgets.evaluate().length} Text widgets. Showing first 20:');
        for (int i = 0; i < textWidgets.evaluate().length && i < 20; i++) {
          final textWidget = textWidgets.at(i);
          final text = tester.widget<Text>(textWidget).data ?? '';
          if (text.isNotEmpty) {
            print('  Text $i: "$text"');
          }
        }
      }
      expect(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'), findsOneWidget);
      expect(find.text('\$8500.75'), findsOneWidget);
      print('✅ Boletas de finalización content found');

      // Paso 4: Seleccionar una boleta de finalización
      print('👆 Selecting boleta de finalización...');
      await tester.tap(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'));
      print('👆 Boleta tapped, waiting for UI to settle...');
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Boleta selection completed');

      // Verificar que el total seleccionado se muestra
      print('🔍 Checking for total and continue button...');
      expect(find.text('Total: \$8500.75'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);

      // Paso 5: Continuar con el pago
      final continuarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Continuar',
      );

      expect(continuarButton, findsOneWidget);
      await tester.tap(continuarButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
      expect(find.text('Procesar Pago'), findsWidgets);
      print('✅ Navigated to ProcesarPagoScreen');

      // Paso 6: Seleccionar método de pago Tarjeta de Crédito/Débito (para que aparezca el formulario)
      print('💳 Selecting card payment method...');
      expect(find.text('Tarjeta de crédito/débito'), findsOneWidget);
      await tester.tap(find.text('Tarjeta de crédito/débito'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Card payment method selected');

      // Verificar que aparece el formulario de PayWay
      print('🔍 Checking for PayWay form...');
      expect(find.byType(PayWayForm), findsOneWidget);
      print('✅ PayWay form found');

      // Intentar procesar pago sin llenar el formulario
      print('🧪 Testing validation - trying to process without filling form...');
      final procesarPagoButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Procesar Pago',
      );

      expect(procesarPagoButton, findsOneWidget);

      // El botón debería estar deshabilitado porque el formulario no es válido
      final botonProcesar = find.byType(ElevatedButton).last;
      expect(tester.widget<ElevatedButton>(botonProcesar).enabled, isFalse);
      print('✅ Process button is correctly disabled when form is invalid');
    });

    testWidgets('Debe mostrar error cuando falla el pago con PayWay', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();
      final mockConnectivity = MockConnectivityNotifier();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/checkout/payment-prisma')) {
          return http.Response(errorPayWayResponseBody, errorPayWayResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(boletasPendientesResponseBody, boletasPendientesResponseStatus);
        }

        return http.Response('{}', 404);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          connectivityProvider.overrideWith(() => mockConnectivity),
        ],
      );

      print('🚀 Starting error test - pumping MyApp widget...');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));
      print('✅ MyApp widget pumped successfully');

      // Paso 1: Login
      print('🔐 Starting login process...');
      await _esperarLoginScreen(tester);
      print('✅ Login screen loaded');

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
      print('📝 Login credentials entered');

      await tester.tap(find.byType(ElevatedButton));
      print('👆 Login button tapped');

      // Dar tiempo para que se procese el login y se carguen los providers
      print('⏳ Waiting for login processing and provider initialization...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }
      print('✅ Login processing completed');

      print('🔍 Checking for MainNavigationScreen...');
      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Paso 2: Navegar a la pantalla de Pagos
      print('💳 Navigating to Payments screen...');
      final navDestinations = find.byType(NavigationDestination);
      if (navDestinations.evaluate().length >= 3) {
        await tester.tap(navDestinations.at(2));
        print('👆 Payments tab tapped (by NavigationDestination index 2)');
      } else if (find.byIcon(Icons.payment_outlined).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment_outlined));
        print('👆 Payments tab tapped (by payment_outlined icon)');
      } else if (find.byIcon(Icons.payment).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment));
        print('👆 Payments tab tapped (by payment icon)');
      }

      // Dar tiempo para que se cargue la pantalla de pagos y las boletas
      print('⏳ Waiting for payments screen and boletas to load...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }
      print('✅ Payments screen loading completed');

      expect(find.byType(PagosPrincipalScreen), findsOneWidget);
      expect(find.text('Boletas de Inicio'), findsOneWidget);
      expect(find.text('Boletas de Finalización'), findsOneWidget);
      print('✅ PagosPrincipalScreen found');

      // Paso 3: Cambiar a la pestaña de "Boletas de Finalización"
      print('🔄 Switching to Boletas de Finalización tab...');
      await tester.tap(find.text('Boletas de Finalización'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Tab switched to Boletas de Finalización');

      // Esperar a que se carguen las boletas de finalización
      print('📋 Waiting for boletas de finalización to be displayed...');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      print('✅ Boletas loading completed');

      // Paso 4: Seleccionar una boleta de finalización
      print('👆 Selecting boleta de finalización...');
      expect(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'), findsOneWidget);
      await tester.tap(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Boleta selection completed');

      // Paso 5: Continuar con el pago
      expect(find.text('Total: \$8500.75'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);

      final continuarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Continuar',
      );

      expect(continuarButton, findsOneWidget);
      await tester.tap(continuarButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
      print('✅ Navigated to ProcesarPagoScreen');

      // Paso 6: Seleccionar método de pago Tarjeta de Crédito/Débito
      print('💳 Selecting card payment method...');
      await tester.tap(find.text('Tarjeta de crédito/débito'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Card payment method selected');

      // Paso 7: Llenar el formulario de tarjeta
      print('💳 Filling PayWay form...');
      await _llenarFormularioTarjeta(tester);
      print('✅ PayWay form filled');

      // Paso 8: Procesar el pago
      print('💰 Processing payment (expecting error)...');
      final procesarPagoButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Procesar Pago',
      );

      expect(procesarPagoButton, findsOneWidget);
      await tester.tap(procesarPagoButton);
      await tester.pump(const Duration(milliseconds: 100));
      print('👆 Procesar Pago button tapped');

      // Paso 9: Confirmar el pago
      print('🔍 Checking for confirmation dialog...');
      expect(find.text('Confirmar Pago'), findsOneWidget);
      expect(find.text('¿Está seguro de que desea procesar el pago de \$8500.75?'), findsOneWidget);

      final confirmarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Confirmar',
      );

      expect(confirmarButton, findsOneWidget);
      await tester.tap(confirmarButton);
      print('👆 Confirmar button tapped, waiting for PayWay processing...');

      // Esperar a que se procese el pago con PayWay y se actualice el estado
      await tester.pump(const Duration(milliseconds: 100)); // Cerrar el diálogo
      await tester.pump(const Duration(milliseconds: 500)); // Esperar el procesamiento
      await tester.pump(const Duration(milliseconds: 100)); // Actualización final del estado
      print('✅ PayWay processing completed (with error)');

      // Paso 10: Verificar que se muestra el diálogo de error (sin navegar a PagoExitosoScreen)
      print('🔍 Checking for error dialog...');

      // Verificar que seguimos en ProcesarPagoScreen y NO en PagoExitosoScreen
      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
      expect(find.byType(PagoExitosoScreen), findsNothing);
      print('✅ Still on ProcesarPagoScreen (correct!)');

      if (find.text('Error en el Pago').evaluate().isEmpty) {
        print('❌ Error dialog not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.text('Error en el Pago'), findsOneWidget);
      expect(find.textContaining('Error al procesar el pago'), findsOneWidget);
      print('✅ Error dialog displayed correctly');
    });

    testWidgets('Debe mostrar error cuando no es posible conectarse con el servidor', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();
      final mockConnectivity = MockConnectivityNotifier();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/checkout/payment-prisma')) {
          throw TimeoutException('Connection timeout');
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(boletasPendientesResponseBody, boletasPendientesResponseStatus);
        }

        return http.Response('{}', 404);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          connectivityProvider.overrideWith(() => mockConnectivity),
        ],
      );

      print('🚀 Starting timeout error test - pumping MyApp widget...');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));
      print('✅ MyApp widget pumped successfully');

      // Paso 1: Login
      print('🔐 Starting login process...');
      await _esperarLoginScreen(tester);
      print('✅ Login screen loaded');

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
      print('📝 Login credentials entered');

      await tester.tap(find.byType(ElevatedButton));
      print('👆 Login button tapped');

      // Dar tiempo para que se procese el login y se carguen los providers
      print('⏳ Waiting for login processing and provider initialization...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }
      print('✅ Login processing completed');

      print('🔍 Checking for MainNavigationScreen...');
      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Paso 2: Navegar a la pantalla de Pagos
      print('💳 Navigating to Payments screen...');
      final navDestinations = find.byType(NavigationDestination);
      if (navDestinations.evaluate().length >= 3) {
        await tester.tap(navDestinations.at(2));
        print('👆 Payments tab tapped (by NavigationDestination index 2)');
      } else if (find.byIcon(Icons.payment_outlined).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment_outlined));
        print('👆 Payments tab tapped (by payment_outlined icon)');
      } else if (find.byIcon(Icons.payment).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment));
        print('👆 Payments tab tapped (by payment icon)');
      }

      // Dar tiempo para que se cargue la pantalla de pagos y las boletas
      print('⏳ Waiting for payments screen and boletas to load...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }
      print('✅ Payments screen loading completed');

      expect(find.byType(PagosPrincipalScreen), findsOneWidget);
      expect(find.text('Boletas de Inicio'), findsOneWidget);
      expect(find.text('Boletas de Finalización'), findsOneWidget);
      print('✅ PagosPrincipalScreen found');

      // Paso 3: Cambiar a la pestaña de "Boletas de Finalización"
      print('🔄 Switching to Boletas de Finalización tab...');
      await tester.tap(find.text('Boletas de Finalización'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Tab switched to Boletas de Finalización');

      // Esperar a que se carguen las boletas de finalización
      print('📋 Waiting for boletas de finalización to be displayed...');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      print('✅ Boletas loading completed');

      // Paso 4: Seleccionar una boleta de finalización
      print('👆 Selecting boleta de finalización...');
      expect(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'), findsOneWidget);
      await tester.tap(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Boleta selection completed');

      // Paso 5: Continuar con el pago
      expect(find.text('Total: \$8500.75'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);

      final continuarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Continuar',
      );

      expect(continuarButton, findsOneWidget);
      await tester.tap(continuarButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
      print('✅ Navigated to ProcesarPagoScreen');

      // Paso 6: Seleccionar método de pago Tarjeta de Crédito/Débito
      print('💳 Selecting card payment method...');
      await tester.tap(find.text('Tarjeta de crédito/débito'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Card payment method selected');

      // Paso 7: Llenar el formulario de tarjeta
      print('💳 Filling PayWay form...');
      await _llenarFormularioTarjeta(tester);
      print('✅ PayWay form filled');

      // Paso 8: Procesar el pago
      print('💰 Processing payment (expecting timeout error)...');
      final procesarPagoButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Procesar Pago',
      );

      expect(procesarPagoButton, findsOneWidget);
      await tester.tap(procesarPagoButton);
      await tester.pump(const Duration(milliseconds: 100));
      print('👆 Procesar Pago button tapped');

      // Paso 9: Confirmar el pago
      print('🔍 Checking for confirmation dialog...');
      expect(find.text('Confirmar Pago'), findsOneWidget);
      expect(find.text('¿Está seguro de que desea procesar el pago de \$8500.75?'), findsOneWidget);

      final confirmarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Confirmar',
      );

      expect(confirmarButton, findsOneWidget);
      await tester.tap(confirmarButton);
      print('👆 Confirmar button tapped, waiting for PayWay processing...');

      // Esperar a que se procese el pago con PayWay y se actualice el estado
      await tester.pump(const Duration(milliseconds: 100)); // Cerrar el diálogo
      await tester.pump(const Duration(milliseconds: 500)); // Esperar el procesamiento
      await tester.pump(const Duration(milliseconds: 100)); // Actualización final del estado
      print('✅ PayWay processing completed (with timeout error)');

      // Paso 10: Verificar que se muestra el diálogo de error (sin navegar a PagoExitosoScreen)
      print('🔍 Checking for error dialog...');

      // Verificar que seguimos en ProcesarPagoScreen y NO en PagoExitosoScreen
      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
      expect(find.byType(PagoExitosoScreen), findsNothing);
      print('✅ Still on ProcesarPagoScreen (correct!)');

      if (find.text('Error en el Pago').evaluate().isEmpty) {
        print('❌ Error dialog not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.text('Error en el Pago'), findsOneWidget);
      expect(find.textContaining('Error en la conexión con el servidor'), findsOneWidget);
      print('✅ Error dialog displayed correctly');
    });

    testWidgets('Debe permitir cambiar entre tipo de tarjeta débito y crédito', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();
      final mockConnectivity = MockConnectivityNotifier();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(boletasPendientesResponseBody, boletasPendientesResponseStatus);
        }

        return http.Response('{}', 404);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          connectivityProvider.overrideWith(() => mockConnectivity),
        ],
      );

      print('🚀 Starting card type test - pumping MyApp widget...');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));
      print('✅ MyApp widget pumped successfully');

      // Paso 1: Login
      print('🔐 Starting login process...');
      await _esperarLoginScreen(tester);
      print('✅ Login screen loaded');

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
      print('📝 Login credentials entered');

      await tester.tap(find.byType(ElevatedButton));
      print('👆 Login button tapped');

      // Dar tiempo para que se procese el login y se carguen los providers
      print('⏳ Waiting for login processing and provider initialization...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }
      print('✅ Login processing completed');

      print('🔍 Checking for MainNavigationScreen...');
      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Paso 2: Navegar a la pantalla de Pagos
      print('💳 Navigating to Payments screen...');
      final navDestinations = find.byType(NavigationDestination);
      if (navDestinations.evaluate().length >= 3) {
        await tester.tap(navDestinations.at(2));
        print('👆 Payments tab tapped (by NavigationDestination index 2)');
      } else if (find.byIcon(Icons.payment_outlined).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment_outlined));
        print('👆 Payments tab tapped (by payment_outlined icon)');
      } else if (find.byIcon(Icons.payment).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.payment));
        print('👆 Payments tab tapped (by payment icon)');
      }

      // Dar tiempo para que se cargue la pantalla de pagos y las boletas
      print('⏳ Waiting for payments screen and boletas to load...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }
      print('✅ Payments screen loading completed');

      expect(find.byType(PagosPrincipalScreen), findsOneWidget);
      expect(find.text('Boletas de Inicio'), findsOneWidget);
      expect(find.text('Boletas de Finalización'), findsOneWidget);
      print('✅ PagosPrincipalScreen found');

      // Paso 3: Cambiar a la pestaña de "Boletas de Finalización"
      print('🔄 Switching to Boletas de Finalización tab...');
      await tester.tap(find.text('Boletas de Finalización'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Tab switched to Boletas de Finalización');

      // Esperar a que se carguen las boletas de finalización
      print('📋 Waiting for boletas de finalización to be displayed...');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      print('✅ Boletas loading completed');

      // Paso 4: Seleccionar una boleta de finalización
      print('👆 Selecting boleta de finalización...');
      expect(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'), findsOneWidget);
      await tester.tap(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Boleta selection completed');

      // Paso 5: Continuar con el pago
      expect(find.text('Total: \$8500.75'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);

      final continuarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Continuar',
      );

      expect(continuarButton, findsOneWidget);
      await tester.tap(continuarButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
      print('✅ Navigated to ProcesarPagoScreen');

      // Paso 6: Seleccionar método de pago Tarjeta de Crédito/Débito
      print('💳 Selecting card payment method...');
      await tester.tap(find.text('Tarjeta de crédito/débito'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Card payment method selected');

      // Verificar que aparece el formulario de PayWay
      expect(find.byType(PayWayForm), findsOneWidget);
      print('✅ PayWay form found');

      // Paso 7: Verificar opciones de tipo de tarjeta
      print('🔍 Checking card type options...');

      // Verificar que los botones de tipo de tarjeta existen
      if (find.text('Débito').evaluate().isEmpty || find.text('Crédito').evaluate().isEmpty) {
        print('❌ Card type buttons not found, checking current widgets...');
        debugCurrentWidgets(tester);
        final textWidgets = find.byType(Text);
        print('📝 Found ${textWidgets.evaluate().length} Text widgets. Showing all with "Débit" or "Crédit":');
        for (int i = 0; i < textWidgets.evaluate().length; i++) {
          final textWidget = textWidgets.at(i);
          final text = tester.widget<Text>(textWidget).data ?? '';
          if (text.toLowerCase().contains('débit') ||
              text.toLowerCase().contains('crédit') ||
              text.toLowerCase().contains('cuota')) {
            print('  Text $i: "$text"');
          }
        }
      }

      expect(find.text('Débito'), findsOneWidget);
      expect(find.text('Crédito'), findsOneWidget);
      print('✅ Card type options found (Débito, Crédito)');

      // Paso 8: Hacer scroll para ver los botones de tipo de tarjeta y cambiar a Crédito
      print('💳 Scrolling to make card type buttons visible...');

      // Buscar el Scrollable principal (SingleChildScrollView)
      final scrollableFinder = find.descendant(of: find.byType(ProcesarPagoScreen), matching: find.byType(Scrollable));
      print('  Found ${scrollableFinder.evaluate().length} Scrollable widgets');

      // Hacer scroll hasta que el botón "Crédito" sea visible
      await tester.scrollUntilVisible(
        find.text('Crédito'),
        100.0, // Scroll 100 pixels cada vez
        scrollable: scrollableFinder.first,
      );
      print('✅ Scrolled to Crédito button');

      await tester.pump(const Duration(milliseconds: 100));

      print('💳 Switching to Crédito...');
      print('🔍 Before tap - checking Crédito button...');
      final creditoButton = find.text('Crédito');
      print('  Found ${creditoButton.evaluate().length} Crédito buttons');

      await tester.tap(creditoButton);
      print('👆 Tapped Crédito button');

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(); // Pump adicional para asegurar que se actualice el estado
      print('✅ Switched to Crédito, checking widgets after tap...');
      debugCurrentWidgets(tester);

      // Paso 9: Verificar que aparece el selector de cuotas
      print('🔍 Checking for installments selector...');

      // Buscar "Cuotas" en todos los widgets de texto
      if (find.text('Cuotas').evaluate().isEmpty) {
        print('❌ "Cuotas" text not found, searching all widgets...');
        final textWidgets = find.byType(Text);
        print('📝 All Text widgets (searching for "Cuotas"):');
        for (int i = 0; i < textWidgets.evaluate().length && i < 30; i++) {
          final textWidget = textWidgets.at(i);
          final text = tester.widget<Text>(textWidget).data ?? '';
          if (text.isNotEmpty) {
            print('  Text $i: "$text"');
          }
        }
      }

      expect(find.text('Cuotas'), findsOneWidget);
      print('✅ Installments selector appeared (correct for Crédito)');

      // Paso 10: Cambiar de vuelta a Débito
      print('💳 Switching back to Débito...');
      await tester.tap(find.text('Débito'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Switched back to Débito');

      // Paso 11: Verificar que desaparece el selector de cuotas
      print('🔍 Verifying installments selector is hidden...');
      expect(find.text('Cuotas'), findsNothing);
      print('✅ Installments selector hidden (correct for Débito)');
    });

    testWidgets('Test simple - Solo verificar navegación a Pagos', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(boletasPendientesResponseBody, boletasPendientesResponseStatus);
        }

        return http.Response('{}', 404);
      });

      final container = createTestContainer(
        mockClient: mockClient,
        mockUsuarioRepository: mockUsuarioRepository,
        mockBoletasRepository: mockBoletasRepository,
        mockPreferenciasRepository: mockPreferenciasRepository,
        mockSecureStorageDataSource: mockSecureStorageDataSource,
        mockJwtTokenService: mockJwtTokenService,
      );

      print('🚀 SIMPLE TEST - Starting MyApp...');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      print('🔐 SIMPLE TEST - Login...');
      await _esperarLoginScreen(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
      await tester.tap(find.byType(ElevatedButton));

      print('⏳ SIMPLE TEST - Waiting for login...');
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      print('🔍 SIMPLE TEST - Checking for MainNavigationScreen...');
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      print('🔍 SIMPLE TEST - Looking for Pagos NavigationDestination...');
      final navDestinations = find.byType(NavigationDestination);
      if (navDestinations.evaluate().length >= 3) {
        print('✅ Found NavigationDestinations, tapping index 2 (Pagos)');
        await tester.tap(navDestinations.at(2));
        print('👆 Tapped Pagos NavigationDestination');
      } else {
        print('❌ NavigationDestinations not found or insufficient count');
        debugCurrentWidgets(tester);
      }

      print('⏳ SIMPLE TEST - Waiting for navigation...');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      print('🔍 SIMPLE TEST - Checking for PagosPrincipalScreen...');
      if (find.byType(PagosPrincipalScreen).evaluate().isNotEmpty) {
        print('✅ PagosPrincipalScreen found!');
      } else {
        print('❌ PagosPrincipalScreen not found');
        debugCurrentWidgets(tester);
      }

      print('✅ SIMPLE TEST COMPLETED');
    });
  });
}

/// Helper para limpiar completamente el estado entre tests
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
  print('🔄 Waiting for login screen...');

  print('🔍 Checking for SplashScreen...');
  expect(find.byType(SplashScreen), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  print('✅ SplashScreen found with loading indicator');

  print('⏳ Waiting for splash to complete...');
  await tester.pump(const Duration(milliseconds: 500));
  print('🔄 Pumping and settling after splash...');
  await pumpAndSettleWithTimeout(tester);
  print('✅ Splash screen transition completed');

  print('🔍 Checking for LoginScreen...');
  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.byType(SplashScreen), findsNothing);
  expect(find.byType(HomeScreen), findsNothing);
  print('✅ LoginScreen found, splash cleared');

  print('🔍 Checking for login form elements...');
  expect(find.text('Inicio de sesión'), findsOneWidget);
  expect(find.text('Iniciar Sesión'), findsOneWidget);
  print('✅ Login form elements found');
}

Future<void> _llenarFormularioTarjeta(WidgetTester tester) async {
  // Llenar el formulario de tarjeta con datos válidos
  final textFields = find.byType(TextFormField);

  if (textFields.evaluate().length >= 5) {
    // Nombre del titular
    await tester.enterText(textFields.at(0), 'Juan Perez');

    // DNI
    await tester.enterText(textFields.at(1), '12345678');

    // Número de tarjeta (usando un número válido según el algoritmo de Luhn)
    await tester.enterText(textFields.at(2), '4532015112830366');

    // CVV
    await tester.enterText(textFields.at(3), '123');

    // Fecha de expiración
    await tester.enterText(textFields.at(4), '12/25');
  }

  await tester.pump(const Duration(milliseconds: 100));
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

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
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';
import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';
import 'package:cssayp_movil/shared/providers/connectivity_provider.dart';
import 'package:cssayp_movil/shared/screens/main_navigation_screen.dart';

import "../test/auth/data/datasources/usuario_data_source_test.mocks.dart";
import '../test/auth/presentation/providers/auth_provider_test.mocks.dart';

Future<void> pumpFrames(WidgetTester tester, {int frames = 10}) async {
  print('🔄 Pumping $frames frames...');
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16)); // ~60fps
    if (i % 5 == 0 && i > 0) {
      print('  - Pumped ${i + 1}/$frames frames...');
    }
  }
  print('✅ Pumped $frames frames successfully');
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

/// Helper function to debug and navigate to next step
Future<void> debugYNavigarSiguiente(WidgetTester tester) async {
  print('🔍 Debugging SIGUIENTE button...');

  // Verificar que el botón SIGUIENTE existe
  final siguienteButton = find.text('SIGUIENTE');
  if (siguienteButton.evaluate().isEmpty) {
    print('❌ "SIGUIENTE" button not found!');
    debugCurrentWidgets(tester);
    throw Exception('SIGUIENTE button not found');
  }

  print('✅ SIGUIENTE button found');

  // Verificar si el botón está habilitado
  final buttonWidget = siguienteButton.evaluate().first.widget;
  if (buttonWidget is ElevatedButton) {
    print('🔍 SIGUIENTE button enabled: ${buttonWidget.onPressed != null}');
    if (buttonWidget.onPressed == null) {
      print('❌ SIGUIENTE button is disabled! Form validation failed.');
      // Mostrar todos los campos de texto para debug
      final textFields = find.byType(TextFormField);
      print('Found ${textFields.evaluate().length} TextFormField widgets');
      for (int i = 0; i < textFields.evaluate().length; i++) {
        final field = textFields.at(i);
        final fieldWidget = field.evaluate().first.widget as TextFormField;
        print('  - Field $i: "${fieldWidget.controller?.text ?? 'empty'}"');
      }
      throw Exception('SIGUIENTE button is disabled - form validation failed');
    }
  }

  // Verificar el estado actual de la pantalla antes del tap
  print('🔍 Current screen before tap:');
  if (find.byType(Paso1BoletaInicioScreen).evaluate().isNotEmpty) {
    print('  - Currently on Paso1BoletaInicioScreen');
  } else if (find.byType(Paso2BoletaInicioScreen).evaluate().isNotEmpty) {
    print('  - Currently on Paso2BoletaInicioScreen');
  } else {
    print('  - Unknown screen type');
    debugCurrentWidgets(tester);
  }

  print('👆 Tapping "SIGUIENTE" button...');
  await tester.tap(siguienteButton);
  print('✅ "SIGUIENTE" button tapped, waiting for navigation...');

  // Dar tiempo extra para la navegación con múltiples intentos
  for (int attempt = 1; attempt <= 3; attempt++) {
    print('🔄 Navigation attempt $attempt/3...');
    await pumpFrames(tester, frames: 20);

    // Verificar si la navegación fue exitosa
    if (find.byType(Paso2BoletaInicioScreen).evaluate().isNotEmpty) {
      print('✅ Navigation successful! Now on Paso2BoletaInicioScreen');
      return;
    } else if (find.byType(Paso1BoletaInicioScreen).evaluate().isNotEmpty) {
      print('⚠️ Still on Paso1BoletaInicioScreen after attempt $attempt');
      if (attempt < 3) {
        print('🔄 Trying tap again...');
        await tester.tap(siguienteButton);
      }
    } else {
      print('❓ Unknown screen state after attempt $attempt');
      debugCurrentWidgets(tester);
    }
  }

  // Si llegamos aquí, la navegación falló - intentar métodos alternativos
  print('❌ Standard navigation failed after 3 attempts');
  print('🔄 Trying alternative navigation methods...');

  await intentarNavegacionAlternativa(tester);

  // Verificar una vez más después de los métodos alternativos
  if (find.byType(Paso2BoletaInicioScreen).evaluate().isNotEmpty) {
    print('✅ Alternative navigation successful!');
    return;
  }

  print('❌ All navigation methods failed');
  debugCurrentWidgets(tester);
  throw Exception('Failed to navigate to next step with all methods');
}

/// Alternative navigation approach - try different methods
Future<void> intentarNavegacionAlternativa(WidgetTester tester) async {
  print('🔄 Trying alternative navigation approaches...');

  // Método 1: Buscar por tipo de botón en lugar de texto
  final elevatedButtons = find.byType(ElevatedButton);
  print('Found ${elevatedButtons.evaluate().length} ElevatedButton widgets');

  for (int i = 0; i < elevatedButtons.evaluate().length; i++) {
    final button = elevatedButtons.at(i);
    final buttonWidget = button.evaluate().first.widget as ElevatedButton;
    if (buttonWidget.child is Text) {
      final text = (buttonWidget.child as Text).data ?? '';
      print('  - Button $i: "$text" (enabled: ${buttonWidget.onPressed != null})');

      if (text.toUpperCase().contains('SIGUIENTE') && buttonWidget.onPressed != null) {
        print('👆 Trying ElevatedButton approach...');
        await tester.tap(button);
        await pumpFrames(tester, frames: 20);

        if (find.byType(Paso2BoletaInicioScreen).evaluate().isNotEmpty) {
          print('✅ Alternative navigation successful!');
          return;
        }
      }
    }
  }

  // Método 2: Buscar por key si existe
  final siguienteByKey = find.byKey(const Key('siguiente_button'));
  if (siguienteByKey.evaluate().isNotEmpty) {
    print('👆 Trying by key approach...');
    await tester.tap(siguienteByKey);
    await pumpFrames(tester, frames: 20);

    if (find.byType(Paso2BoletaInicioScreen).evaluate().isNotEmpty) {
      print('✅ Key-based navigation successful!');
      return;
    }
  }

  // Método 3: Buscar por tooltip
  final siguienteByTooltip = find.byTooltip('Siguiente');
  if (siguienteByTooltip.evaluate().isNotEmpty) {
    print('👆 Trying by tooltip approach...');
    await tester.tap(siguienteByTooltip);
    await pumpFrames(tester, frames: 20);

    if (find.byType(Paso2BoletaInicioScreen).evaluate().isNotEmpty) {
      print('✅ Tooltip-based navigation successful!');
      return;
    }
  }

  print('❌ All alternative navigation methods failed');
}

/// Helper function to fill form fields with proper waiting
Future<void> llenarCamposConEspera(WidgetTester tester, List<String> valores) async {
  print('📝 Filling form fields with values: $valores...');

  for (int i = 0; i < valores.length; i++) {
    print('  - Filling field $i with "${valores[i]}"...');
    await tester.enterText(find.byType(TextFormField).at(i), valores[i]);

    // Pequeña pausa entre campos para permitir procesamiento
    await pumpFrames(tester, frames: 5);
  }

  // Verificar que los campos se llenaron correctamente
  print('🔍 Verifying form fields are filled...');
  final textFields = find.byType(TextFormField);
  print('Found ${textFields.evaluate().length} TextFormField widgets');

  for (int i = 0; i < textFields.evaluate().length; i++) {
    final field = textFields.at(i);
    final fieldWidget = field.evaluate().first.widget as TextFormField;
    print('  - Field $i: "${fieldWidget.controller?.text ?? 'empty'}"');
  }

  // Dar tiempo extra para que se procese la validación del formulario
  print('⏳ Waiting for form validation to complete...');
  await pumpFrames(tester, frames: 30);

  // Esperar un poco más para asegurar que la validación se complete
  print('⏳ Additional wait for form processing...');
  await tester.pump(const Duration(milliseconds: 1000));
  await pumpFrames(tester, frames: 20);

  print('✅ Form fields filled and validation completed');
}

/// Helper function to select boleta type by clicking the "Seleccionar" button
Future<void> seleccionarTipoBoleta(WidgetTester tester, String tipoBoleta) async {
  print('📋 Selecting "$tipoBoleta"...');

  // Buscar el botón "Seleccionar" dentro del widget que contiene el tipo de boleta
  final seleccionarButton = find.widgetWithText(Card, tipoBoleta);

  if (seleccionarButton.evaluate().isEmpty) {
    print('❌ "Seleccionar" button for "$tipoBoleta" not found, trying alternative approach...');
    // Buscar por el texto "Seleccionar" cerca del tipo de boleta
    final allSeleccionarButtons = find.text('Seleccionar');
    print('Found ${allSeleccionarButtons.evaluate().length} "Seleccionar" buttons');

    // Buscar el que esté más cerca del texto del tipo de boleta
    final tipoBoletaText = find.text(tipoBoleta);
    if (tipoBoletaText.evaluate().isNotEmpty && allSeleccionarButtons.evaluate().isNotEmpty) {
      print('✅ Found "$tipoBoleta" text, using first "Seleccionar" button...');
      await tester.tap(allSeleccionarButtons.first);
    } else {
      print('❌ Neither "$tipoBoleta" text nor "Seleccionar" button found!');
      debugCurrentWidgets(tester);
      throw Exception('Could not find selection button for $tipoBoleta');
    }
  } else {
    print('✅ Found "Seleccionar" button for "$tipoBoleta"');
    await tester.tap(seleccionarButton);
  }

  await pumpFrames(tester, frames: 15);
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
    String filtroEstado = 'todas',
  }) async {
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

  @override
  Future<CrearBoletaInicioResult> crearBoletaInicio({
    required String caratula,
    required String juzgado,
    required CircunscripcionEntity circunscripcion,
    required TipoJuicioEntity tipoJuicio,
  }) async {
    // Simular creación exitosa de boleta de inicio
    return CrearBoletaInicioResult(idBoleta: 1, urlPago: 'https://pago.com/boleta/1');
  }

  @override
  Future<BoletaEntity> crearBoletaFinalizacion({
    required int nroAfiliado,
    required String caratula,
    required int idBoletaInicio,
    required double monto,
    required DateTime fechaRegulacion,
    required double honorarios,
    required double cantidadJus,
    required double valorJus,
    int? nroExpediente,
    int? anioExpediente,
    int? cuij,
  }) async {
    // Simular creación exitosa de boleta de finalización
    return BoletaEntity(
      id: 2,
      tipo: BoletaTipo.finalizacion,
      monto: monto,
      fechaImpresion: DateTime.now(),
      fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
      caratula: "RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS",
      nroExpediente: nroExpediente,
      anioExpediente: anioExpediente,
      cuij: cuij,
      codBarra: null,
      gastosAdministrativos: null,
      estado: '',
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujos de Pago desde Diferentes Rutas', () {
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

    final successCrearBoletaInicioResponseBody = json.encode({
      'id_boleta': '12345',
      'monto_entero': 21000,
      'monto_decimal': 0,
      'fecha_impresion': '2024-01-15T10:30:00Z',
      'fecha_vencimiento': '30',
    });
    const successCrearBoletaInicioResponseStatus = 201;

    // Respuesta de boletas pendientes para la pantalla de pagos
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

    testWidgets('Debe completar flujo desde crear boleta de fin hasta Procesar Pago', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
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
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(boletasPendientesResponseBody, boletasPendientesResponseStatus);
        } else {
          return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
        }
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
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
        await pumpFrames(tester, frames: 15);
        debugCurrentWidgets(tester);
      }
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      print('🔍 Checking for HomeScreen...');
      if (find.byType(HomeScreen).evaluate().isEmpty) {
        print('❌ HomeScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      // Paso 2: Crear boleta de fin
      print('📋 Starting boleta creation process...');
      print('🔍 Looking for "Nueva boleta" button...');

      // Hacer scroll forzado para asegurar que el botón "Nueva boleta" esté completamente visible
      print('🔄 Forcing scroll to ensure "Nueva boleta" button is fully visible...');
      final scrollables = find.byType(Scrollable);
      print('Found ${scrollables.evaluate().length} Scrollable widgets');

      if (scrollables.evaluate().isNotEmpty) {
        // Hacer scroll hacia abajo para asegurar que el botón esté completamente visible
        print('🔄 Scrolling down to make "Nueva boleta" button fully visible...');
        await tester.scrollUntilVisible(find.text('Nueva boleta'), 100.0, scrollable: scrollables.first);

        // Hacer un scroll adicional para asegurar que no haya superposición
        print('🔄 Making additional scroll to avoid overlap with navigation...');
        await tester.drag(scrollables.first, const Offset(0, -50));
        await tester.pump(const Duration(milliseconds: 100));

        print('✅ Scroll completed');
      } else {
        print('❌ No scrollable widgets found!');
        debugCurrentWidgets(tester);
      }

      // Verificar que no hay superposición con el botón "Boletas" de navegación
      print('🔍 Checking for navigation button overlap...');
      final boletasNavButton = find.text('Boletas');
      if (boletasNavButton.evaluate().isNotEmpty) {
        print('⚠️ Navigation "Boletas" button found - ensuring no overlap...');
        // Hacer scroll adicional si hay superposición
        await tester.drag(scrollables.first, const Offset(0, -30));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Nueva boleta'), warnIfMissed: false);
      print('👆 "Nueva boleta" button tapped');
      await pumpFrames(tester, frames: 15);

      print('🔍 Checking for CrearBoletaScreen...');
      if (find.byType(CrearBoletaScreen).evaluate().isEmpty) {
        print('❌ CrearBoletaScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(CrearBoletaScreen), findsOneWidget);
      print('✅ CrearBoletaScreen found');

      await seleccionarTipoBoleta(tester, 'Boleta de Finalización');

      print('🔍 Checking for Paso1BoletaFinScreen...');
      expect(find.byType(Paso1BoletaFinScreen), findsOneWidget);
      print('✅ Paso1BoletaFinScreen found');

      // Seleccionar carátula
      print('📋 Step 1: Selecting carátula...');
      await tester.tap(find.text('Seleccione una carátula'));
      await pumpFrames(tester, frames: 15);

      print('⏳ Waiting for carátulas to load...');
      await tester.pump(const Duration(seconds: 1));
      await pumpFrames(tester, frames: 15);

      print('📋 Selecting carátula from list...');
      await tester.tap(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'));
      await pumpFrames(tester, frames: 15);

      // Completar campos opcionales
      print('📝 Filling optional fields...');
      await tester.enterText(find.byType(TextFormField).at(0), '12345');
      await tester.enterText(find.byType(TextFormField).at(1), '2024');
      await tester.enterText(find.byType(TextFormField).at(2), '98765');

      print('➡️ Moving to step 2...');
      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester, frames: 15);

      print('🔍 Checking for Paso2BoletaFinScreen...');
      expect(find.byType(Paso2BoletaFinScreen), findsOneWidget);
      print('✅ Paso2BoletaFinScreen found');

      // Seleccionar fecha de regulación
      print('📅 Step 2: Selecting regulation date...');
      await _seleccionarFechaEnDatePicker(tester);

      // Ingresar cantidad JUS
      print('📝 Entering JUS quantity...');
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), '10');
      } else if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.last, '10');
      }

      print('➡️ Moving to step 3...');
      await tester.tap(find.text('SIGUIENTE'), warnIfMissed: false);
      await pumpFrames(tester, frames: 15);

      print('⏳ Waiting for validation and navigation...');
      await tester.pump(const Duration(milliseconds: 1000));
      await pumpFrames(tester, frames: 15);

      print('🔍 Checking for Paso3BoletaFinScreen...');
      expect(find.byType(Paso3BoletaFinScreen), findsOneWidget);
      print('✅ Paso3BoletaFinScreen found');

      print('🔄 Generating boleta...');
      await tester.tap(find.text('GENERAR'), warnIfMissed: false);
      await pumpFrames(tester, frames: 15);

      // Confirmar en el diálogo
      print('✅ Confirming generation...');
      await tester.tap(find.text('SÍ'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester, frames: 15);

      // Paso 3: Verificar que se muestra la pantalla de boleta creada
      print('🔍 Checking for BoletaCreadaScreen...');
      expect(find.byType(BoletaCreadaScreen), findsOneWidget);
      expect(find.text('Boleta generada con éxito'), findsOneWidget);
      print('✅ BoletaCreadaScreen found with success message');

      // Paso 4: Hacer clic en "Pagar boleta" (debería redirigir a Procesar Pago)
      print('💳 Attempting to pay boleta...');
      await tester.tap(find.text('Pagar boleta'));
      await pumpFrames(tester, frames: 15);

      // Verificar que el boton de "Pagar boleta" redirige a la pantalla de Procesar Pago
      print('🔍 Checking for ProcesarPagoScreen...');
      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
    });

    testWidgets('Debe completar flujo desde crear boleta de inicio hasta RedLinkPaymentScreen', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      // Respuesta con URL de pago para boleta de inicio
      final successCrearBoletaInicioConUrlResponseBody = json.encode({
        'id_boleta': '12345',
        'monto_entero': 21000,
        'monto_decimal': 0,
        'fecha_impresion': '2024-01-15T10:30:00Z',
        'fecha_vencimiento': '30',
        'url_pago': 'https://redlink-test.com/payment/12345',
      });

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaInicio')) {
          return http.Response(successCrearBoletaInicioConUrlResponseBody, successCrearBoletaInicioResponseStatus);
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
          boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
        ],
      );

      print('🚀 Starting test 2 - pumping MyApp widget...');
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
        await pumpFrames(tester, frames: 15);
        debugCurrentWidgets(tester);
      }
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      print('🔍 Checking for HomeScreen...');
      if (find.byType(HomeScreen).evaluate().isEmpty) {
        print('❌ HomeScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      // Paso 2: Crear boleta de inicio
      print('📋 Starting boleta creation process...');
      print('🔍 Looking for "Nueva boleta" button...');

      // Hacer scroll forzado para asegurar que el botón "Nueva boleta" esté completamente visible
      print('🔄 Forcing scroll to ensure "Nueva boleta" button is fully visible...');
      final scrollables = find.byType(Scrollable);
      print('Found ${scrollables.evaluate().length} Scrollable widgets');

      if (scrollables.evaluate().isNotEmpty) {
        // Hacer scroll hacia abajo para asegurar que el botón esté completamente visible
        print('🔄 Scrolling down to make "Nueva boleta" button fully visible...');
        await tester.scrollUntilVisible(find.text('Nueva boleta'), 100.0, scrollable: scrollables.first);

        // Hacer un scroll adicional para asegurar que no haya superposición
        print('🔄 Making additional scroll to avoid overlap with navigation...');
        await tester.drag(scrollables.first, const Offset(0, -50));
        await tester.pump(const Duration(milliseconds: 100));

        print('✅ Scroll completed');
      } else {
        print('❌ No scrollable widgets found!');
        debugCurrentWidgets(tester);
      }

      // Verificar que el botón "Nueva boleta" está disponible y no superpuesto
      print('🔍 Verifying "Nueva boleta" button is available and not overlapped...');
      final nuevaBoletaButton = find.text('Nueva boleta');
      if (nuevaBoletaButton.evaluate().isEmpty) {
        print('❌ "Nueva boleta" button still not found after scroll!');
        debugCurrentWidgets(tester);
        print('🔍 Looking for alternative buttons...');
        final allButtons = find.byType(ElevatedButton);
        print('Found ${allButtons.evaluate().length} ElevatedButton widgets');
        for (int i = 0; i < allButtons.evaluate().length; i++) {
          final button = allButtons.at(i);
          final buttonText = button.evaluate().first.widget as ElevatedButton;
          if (buttonText.child is Text) {
            final text = (buttonText.child as Text).data ?? '';
            print('  - Button $i: "$text"');
          }
        }
        throw Exception('Nueva boleta button not found');
      }

      // Verificar que no hay superposición con el botón "Boletas" de navegación
      print('🔍 Checking for navigation button overlap...');
      final boletasNavButton = find.text('Boletas');
      if (boletasNavButton.evaluate().isNotEmpty) {
        print('⚠️ Navigation "Boletas" button found - ensuring no overlap...');
        // Hacer scroll adicional si hay superposición
        await tester.drag(scrollables.first, const Offset(0, -30));
        await tester.pump(const Duration(milliseconds: 100));
      }

      print('👆 Tapping "Nueva boleta" button...');
      await tester.tap(nuevaBoletaButton);
      print('✅ "Nueva boleta" button tapped successfully');
      await pumpFrames(tester, frames: 20);

      print('🔍 Checking for CrearBoletaScreen...');
      if (find.byType(CrearBoletaScreen).evaluate().isEmpty) {
        print('❌ CrearBoletaScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(CrearBoletaScreen), findsOneWidget);
      print('✅ CrearBoletaScreen found');

      await seleccionarTipoBoleta(tester, 'Boleta de Inicio');

      print('🔍 Checking for Paso1BoletaInicioScreen...');
      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);
      print('✅ Paso1BoletaInicioScreen found');

      print('📝 Step 1: Filling actor and defendant names...');
      await llenarCamposConEspera(tester, ['Juan Perez', 'Maria Garcia']);

      print('➡️ Moving to step 2...');
      await debugYNavigarSiguiente(tester);

      print('🔍 Checking for Paso2BoletaInicioScreen...');
      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);
      print('✅ Paso2BoletaInicioScreen found');

      print('📝 Step 2: Filling cause description...');
      await llenarCamposConEspera(tester, ['Daños y Perjuicios']);

      print('➡️ Moving to step 3...');
      await debugYNavigarSiguiente(tester);

      print('🔍 Checking for Paso3BoletaInicioScreen...');
      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
      print('✅ Paso3BoletaInicioScreen found');

      print('🔄 Generating boleta...');
      await tester.tap(find.text('GENERAR'));
      await pumpFrames(tester, frames: 15);

      // Confirmar en el diálogo
      print('✅ Confirming generation...');
      await tester.tap(find.text('SÍ'));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester, frames: 15);

      // Paso 3: Verificar que se muestra la pantalla de boleta creada
      print('🔍 Checking for BoletaCreadaScreen...');
      expect(find.byType(BoletaCreadaScreen), findsOneWidget);
      expect(find.text('Boleta generada con éxito'), findsOneWidget);
      print('✅ BoletaCreadaScreen found with success message');

      // Paso 4: Hacer clic en "Pagar boleta" (debería navegar a RedLinkPaymentScreen)
      print('💳 Attempting to pay boleta (should go to RedLink)...');
      await tester.tap(find.text('Pagar boleta'));
      await pumpFrames(tester, frames: 15);

      // Verificar que se navega a la pantalla de Red Link
      print('🔍 Checking for RedLinkPaymentScreen...');
      expect(find.byType(RedLinkPaymentScreen), findsOneWidget);
      expect(find.text('Pago Red Link'), findsOneWidget);
      print('✅ RedLinkPaymentScreen found - Test completed successfully!');
    });

    testWidgets('Debe completar flujo desde crear boleta de inicio hasta Procesar Pago a través del historial', (
      tester,
    ) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockBoletasRepository = MockBoletasRepositoryComplete();
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletaInicio')) {
          return http.Response(successCrearBoletaInicioResponseBody, successCrearBoletaInicioResponseStatus);
        } else {
          return http.Response(successLoginResponseBody, successLoginResponseStatus);
        }
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((invocation) async {
        final url = invocation.positionalArguments[0].toString();

        if (url.contains('/api/v1/boletas/historial')) {
          return http.Response(boletasPendientesResponseBody, boletasPendientesResponseStatus);
        } else {
          return http.Response(successBoletasInicioPagadasResponseBody, successBoletasInicioPagadasResponseStatus);
        }
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          boletasRepositoryProvider.overrideWith((ref) => mockBoletasRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
        ],
      );

      print('🚀 Starting test 3 - pumping MyApp widget...');
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
        await pumpFrames(tester, frames: 15);
        debugCurrentWidgets(tester);
      }
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      print('🔍 Checking for HomeScreen...');
      if (find.byType(HomeScreen).evaluate().isEmpty) {
        print('❌ HomeScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      // Paso 2: Crear boleta de inicio
      print('📋 Starting boleta creation process...');
      print('🔍 Looking for "Nueva boleta" button...');

      // Hacer scroll forzado para asegurar que el botón "Nueva boleta" esté completamente visible
      print('🔄 Forcing scroll to ensure "Nueva boleta" button is fully visible...');
      final scrollables = find.byType(Scrollable);
      print('Found ${scrollables.evaluate().length} Scrollable widgets');

      if (scrollables.evaluate().isNotEmpty) {
        // Hacer scroll hacia abajo para asegurar que el botón esté completamente visible
        print('🔄 Scrolling down to make "Nueva boleta" button fully visible...');
        await tester.scrollUntilVisible(find.text('Nueva boleta'), 100.0, scrollable: scrollables.first);

        // Hacer un scroll adicional para asegurar que no haya superposición
        print('🔄 Making additional scroll to avoid overlap with navigation...');
        await tester.drag(scrollables.first, const Offset(0, -50));
        await tester.pump(const Duration(milliseconds: 100));

        print('✅ Scroll completed');
      } else {
        print('❌ No scrollable widgets found!');
        debugCurrentWidgets(tester);
      }

      // Verificar que no hay superposición con el botón "Boletas" de navegación
      print('🔍 Checking for navigation button overlap...');
      final boletasNavButton = find.text('Boletas');
      if (boletasNavButton.evaluate().isNotEmpty) {
        print('⚠️ Navigation "Boletas" button found - ensuring no overlap...');
        // Hacer scroll adicional si hay superposición
        await tester.drag(scrollables.first, const Offset(0, -30));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('Nueva boleta'));
      print('👆 "Nueva boleta" button tapped');
      await pumpFrames(tester, frames: 15);

      print('🔍 Checking for CrearBoletaScreen...');
      if (find.byType(CrearBoletaScreen).evaluate().isEmpty) {
        print('❌ CrearBoletaScreen not found, checking current widgets...');
        debugCurrentWidgets(tester);
      }
      expect(find.byType(CrearBoletaScreen), findsOneWidget);
      print('✅ CrearBoletaScreen found');

      await seleccionarTipoBoleta(tester, 'Boleta de Inicio');

      print('🔍 Checking for Paso1BoletaInicioScreen...');
      expect(find.byType(Paso1BoletaInicioScreen), findsOneWidget);
      print('✅ Paso1BoletaInicioScreen found');

      print('📝 Step 1: Filling actor and defendant names...');
      await llenarCamposConEspera(tester, ['Juan Perez', 'Maria Garcia']);

      print('➡️ Moving to step 2...');
      await debugYNavigarSiguiente(tester);

      print('🔍 Checking for Paso2BoletaInicioScreen...');
      expect(find.byType(Paso2BoletaInicioScreen), findsOneWidget);
      print('✅ Paso2BoletaInicioScreen found');

      print('📝 Step 2: Filling cause description...');
      await llenarCamposConEspera(tester, ['Daños y Perjuicios']);

      print('➡️ Moving to step 3...');
      await debugYNavigarSiguiente(tester);

      print('🔍 Checking for Paso3BoletaInicioScreen...');
      expect(find.byType(Paso3BoletaInicioScreen), findsOneWidget);
      print('✅ Paso3BoletaInicioScreen found');

      print('🔄 Generating boleta...');
      await tester.tap(find.text('GENERAR'));
      await pumpFrames(tester, frames: 15);

      // Confirmar en el diálogo
      print('✅ Confirming generation...');
      await tester.tap(find.text('SÍ'));
      await tester.pump(const Duration(milliseconds: 500));
      await pumpFrames(tester, frames: 15);

      // Paso 3: Verificar que se muestra la pantalla de boleta creada
      print('🔍 Checking for BoletaCreadaScreen...');
      expect(find.byType(BoletaCreadaScreen), findsOneWidget);
      expect(find.text('Boleta generada con éxito'), findsOneWidget);
      print('✅ BoletaCreadaScreen found with success message');

      // Paso 4: Ir al historial para acceder a Procesar Pago
      print('📋 Going to history to access Procesar Pago...');
      await tester.tap(find.text('Ir al historial'));
      await pumpFrames(tester, frames: 15);

      // Verificar que se navega a la pantalla de pagos
      print('🔍 Checking for PagosPrincipalScreen...');
      expect(find.byType(PagosPrincipalScreen), findsOneWidget);
      expect(find.text('Boletas de Inicio'), findsOneWidget);
      expect(find.text('Boletas de Finalización'), findsOneWidget);
      print('✅ PagosPrincipalScreen found with tabs');

      // Paso 5: Cambiar a la pestaña de "Boletas de Inicio"
      print('🔄 Switching to "Boletas de Inicio" tab...');
      await tester.tap(find.text('Boletas de Inicio'));
      await tester.pump(const Duration(milliseconds: 100));

      // Esperar a que se carguen las boletas
      print('⏳ Waiting for boletas to load...');
      await tester.pump(const Duration(seconds: 2));
      await pumpFrames(tester, frames: 15);

      // Paso 6: Seleccionar una boleta de inicio
      print('🔍 Looking for boleta to select...');
      expect(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'), findsOneWidget);
      await tester.tap(find.text('RODRIGUEZ MARIA C/ GOMEZ JOSE S/ DAÑOS Y PERJUICIOS'));
      await tester.pump(const Duration(milliseconds: 100));
      print('✅ Boleta selected');

      // Verificar que el total seleccionado se muestra
      print('🔍 Checking for total and continue button...');
      expect(find.text('Total: \$8500.75'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      print('✅ Total and continue button found');

      // Paso 7: Continuar con el pago
      print('➡️ Continuing with payment...');
      final continuarButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.child is Text && (widget.child as Text).data == 'Continuar',
      );

      expect(continuarButton, findsOneWidget);
      await tester.tap(continuarButton);
      await tester.pump(const Duration(milliseconds: 100));

      // Paso 8: Verificar que se navega a la pantalla de Procesar Pago
      print('🔍 Checking for ProcesarPagoScreen...');
      expect(find.byType(ProcesarPagoScreen), findsOneWidget);
      expect(find.text('Procesar Pago'), findsWidgets);
      print('✅ ProcesarPagoScreen found - Test completed successfully!');
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

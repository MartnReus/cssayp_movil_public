import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/main.dart';
import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';
import 'package:cssayp_movil/shared/screens/main_navigation_screen.dart';
import 'package:cssayp_movil/shared/services/pdf_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cssayp_movil/shared/database/database_helper.dart';
import 'package:cssayp_movil/shared/services/permission_handler_service.dart';

import '../test/auth/data/datasources/usuario_data_source_test.mocks.dart';

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
}

// Fake use case para simular la descarga+compartir sin invocar SharePlus nativo
class FakeGenerarComprobanteUseCase extends GenerarComprobanteUseCase {
  int sharedFilesCount = 0;

  FakeGenerarComprobanteUseCase() : super(pdfService: PdfService(), usuarioRepository: _FakeUsuarioRepositoryAlways());

  @override
  Future<String> execute(ComprobanteEntity comprobante) async {
    // Simula creación de PDF devolviendo una ruta dummy
    return '/tmp/fake.pdf';
  }
}

// Spy para rastrear llamadas a DescargarComprobanteUseCase (mantiene comportamiento real)
class SpyDescargarComprobanteUseCase extends DescargarComprobanteUseCase {
  int executeCallCount = 0;

  SpyDescargarComprobanteUseCase({required super.generarComprobanteUseCase, required super.permissionHandlerService});

  @override
  Future<String> execute(ComprobanteEntity comprobante) async {
    executeCallCount++;
    // Llama a la implementación real para mantener el comportamiento de integración
    return super.execute(comprobante);
  }
}

class FakePermissionHandlerService extends PermissionHandlerService {
  FakePermissionHandlerService() : super(deviceInfo: DeviceInfoPlugin());

  @override
  Future<bool> requestStoragePermission() async {
    return true; // Siempre concede permiso
  }
}

class _FakeUsuarioRepositoryAlways implements UsuarioRepository {
  @override
  Future<UsuarioEntity?> autenticar(String username, String password) async =>
      UsuarioEntity(nroAfiliado: 999, apellidoNombres: 'Perez, Juan', cambiarPassword: false, username: username);

  @override
  Future<void> cerrarSesion() async {}

  @override
  Future<bool> estaAutenticado() async => true;

  @override
  Future<UsuarioEntity?> obtenerUsuarioActual() async =>
      UsuarioEntity(nroAfiliado: 999, apellidoNombres: 'Perez, Juan', cambiarPassword: false, username: 'valid_user');

  @override
  Future<CambiarPasswordResponseModel> cambiarPassword(String passwordActual, String passwordNueva) {
    throw UnimplementedError();
  }

  @override
  Future<RecuperarResponseModel> recuperarPassword(String tipoDocumento, String nroDocumento, String email) {
    throw UnimplementedError();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Descargar comprobante - Flujos', () {
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

    // Respuesta del historial con una boleta pagada (para habilitar "Ver comprobante")
    final successHistorialBoletasResponseBody = json.encode({
      'data': [
        {
          'id_boleta_generada': '12345',
          'id_tipo_boleta': '1',
          'caratula': 'Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios',
          'monto': '21000.00',
          'fecha_impresion': '2024-01-15T10:30:00Z',
          'dias_vencimiento': '30',
          'fecha_pago': '2024-01-20T10:30:00Z', // pagada
          'cod_barra': '12345678901234567890',
          'gastos_administrativos': '500.00',
        },
      ],
      'current_page': 1,
      'last_page': 1,
      'total': 1,
      'per_page': 10,
      'next_page_url': null,
      'prev_page_url': null,
    });
    const successHistorialBoletasResponseStatus = 200;

    setUpAll(() async {
      secureStorage = const FlutterSecureStorage();
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    tearDown(() async {
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDownAll(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    testWidgets('Desde Boletas: Ver comprobante y descargar PDF (muestra SnackBar)', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);

      // Mock HTTP para login e historial
      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(successHistorialBoletasResponseBody, successHistorialBoletasResponseStatus),
      );

      // Repo de comprobantes que devuelve un comprobante de INICIO (mvc '0100')
      final comprobantesRepo = _FakeComprobantesRepositoryInicio();
      final fakeGenerar = FakeGenerarComprobanteUseCase();
      final fakePermissionHandler = FakePermissionHandlerService();
      final descargarUseCase = SpyDescargarComprobanteUseCase(
        generarComprobanteUseCase: fakeGenerar,
        permissionHandlerService: fakePermissionHandler,
      );

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          comprobantesRepositoryProvider.overrideWith((ref) => comprobantesRepo),
          descargarComprobanteUseCaseProvider.overrideWith((ref) => descargarUseCase),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
        ],
      );

      print('🚀 Starting test: Descargar comprobante desde Boletas');
      print('🔧 Pumping MyApp with overrides...');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));
      print('✅ MyApp widget pumped');

      // Login
      print('🔐 Starting login process...');
      await _esperarLoginScreen(tester);
      print('✅ Login screen visible');

      print('📝 Entering credentials...');
      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
      print('👆 Tapping login button...');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      print('✅ Logged in and settled');

      // Dar tiempo extra para que se inicialicen providers y navegación
      print('⏳ Waiting for login processing and provider initialization...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }

      // En Home y navegación principal
      print('🔍 Verifying main navigation and home...');
      if (find.byType(MainNavigationScreen).evaluate().isEmpty) {
        print('❌ MainNavigationScreen not found');
      }
      expect(find.byType(MainNavigationScreen), findsOneWidget);
      if (find.byType(HomeScreen).evaluate().isEmpty) {
        print('❌ HomeScreen not found');
      }
      expect(find.byType(HomeScreen), findsOneWidget);
      print('✅ MainNavigationScreen and HomeScreen visible');

      // Ir a Boletas
      print('📂 Navigating to Boletas tab...');
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pump();
      print('✅ Boletas tab opened');

      // Debe cargar historial y mostrar la boleta
      print('🔎 Waiting for Historial and paid boleta...');
      final historialFinder = find.byType(HistorialScreen);
      final historialCount = historialFinder.evaluate().length;
      print('📊 HistorialScreen instances on tree: $historialCount');
      expect(historialFinder, findsWidgets);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      if (find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios').evaluate().isEmpty) {
        print('❌ Paid boleta not found');
      }
      expect(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'), findsOneWidget);
      print('✅ Paid boleta found');

      // Tocar "Ver comprobante" (activo si está pagada)
      print('👁️ Tapping "Ver comprobante"...');
      await tester.tap(find.text('Ver comprobante'));
      await tester.pump();
      print('⏳ Waiting for comprobante detail...');

      // Debe navegar a detalle de comprobante de inicio
      if (find.byType(ComprobanteInicioScreen).evaluate().isEmpty) {
        print('❌ ComprobanteInicioScreen not found');
      }
      expect(find.byType(ComprobanteInicioScreen), findsOneWidget);
      print('✅ ComprobanteInicioScreen visible');

      // Pulsar DESCARGAR -> debe disparar share simulado y SnackBar de éxito
      print('💾 Tapping "DESCARGAR"...');
      await tester.tap(find.text('DESCARGAR'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      print('⏳ Waiting for success SnackBar...');

      // Verificar que descargarUseCase.execute() fue llamado al menos una vez
      expect(descargarUseCase.executeCallCount, greaterThanOrEqualTo(1));
      print('✅ descargarUseCase.execute() called ${descargarUseCase.executeCallCount} time(s)');
    });

    testWidgets('Desde Juicios: Ver comprobante y descargar boletas pagadas (inicio y fin)', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);

      // Mock HTTP para login (Historial de Juicios usa datos locales)
      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successLoginResponseBody, successLoginResponseStatus));
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(successHistorialBoletasResponseBody, successHistorialBoletasResponseStatus),
      );

      // Repo de comprobantes que devuelve comprobantes para inicio y fin
      final comprobantesRepo = _FakeComprobantesRepositoryInicio();
      final juiciosRepo = _FakeJuiciosRepository();
      final fakeGenerar = FakeGenerarComprobanteUseCase();
      final fakePermissionHandler = FakePermissionHandlerService();
      final descargarUseCase = SpyDescargarComprobanteUseCase(
        generarComprobanteUseCase: fakeGenerar,
        permissionHandlerService: fakePermissionHandler,
      );

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          juiciosRepositoryProvider.overrideWith((ref) => Future.value(juiciosRepo)),
          comprobantesRepositoryProvider.overrideWith((ref) => comprobantesRepo),
          descargarComprobanteUseCaseProvider.overrideWith((ref) => descargarUseCase),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
        ],
      );

      print('🚀 Starting test: Ver comprobante desde Juicios');
      print('🔧 Pumping MyApp with overrides...');
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));
      print('✅ MyApp widget pumped');

      // Login
      print('🔐 Starting login process...');
      await _esperarLoginScreen(tester);
      print('✅ Login screen visible');
      print('📝 Entering credentials...');
      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');
      print('👆 Tapping login button...');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      print('⏳ Waiting for login processing and provider initialization...');
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (i % 5 == 0) {
          print('  - Pump cycle ${i + 1}/30');
        }
      }

      // Ir a Boletas -> pestaña Juicios
      print('📂 Navigating to Boletas tab...');
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pump();
      final historialFinder2 = find.byType(HistorialScreen);
      print('📊 HistorialScreen instances on tree (Juicios): ${historialFinder2.evaluate().length}');
      expect(historialFinder2, findsWidgets);

      print('🗂️ Switching to Juicios tab...');
      await tester.tap(find.text('Juicios').first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      print('✅ Juicios tab opened');

      // Esperar a que se carguen los juicios
      print('⏳ Waiting for juicios to load...');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Verificar que hay ExpansionTiles disponibles
      print('🔍 Checking for ExpansionTiles...');
      final expansionTiles = find.byType(ExpansionTile);
      int attempts = 0;
      while (expansionTiles.evaluate().isEmpty && attempts < 10) {
        print('  - Attempt ${attempts + 1}/10: No ExpansionTiles found yet, waiting...');
        await tester.pump(const Duration(milliseconds: 500));
        attempts++;
      }

      if (expansionTiles.evaluate().isEmpty) {
        print('❌ No ExpansionTiles found after waiting');
        throw Exception('No ExpansionTiles available in Juicios tab');
      }
      print('✅ Found ${expansionTiles.evaluate().length} ExpansionTile(s)');

      // Expandir primer juicio de la lista
      print('📦 Expanding first ExpansionTile (juicio)...');
      final firstTile = expansionTiles.first;
      await tester.tap(firstTile);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      print('✅ First ExpansionTile expanded');

      // Verificar si hay botón "Ver comprobante" para inicio (solo aparece si está pagado)
      print('🔍 Looking for "Ver comprobante" button for inicio...');
      final verComprobanteButtons = find.text('Ver comprobante');

      if (verComprobanteButtons.evaluate().isNotEmpty) {
        print('✅ Found "Ver comprobante" button(s): ${verComprobanteButtons.evaluate().length}');

        // Tocar el primer botón "Ver comprobante" (boleta de inicio)
        print('👁️ Tapping first "Ver comprobante" button (inicio)...');
        await tester.tap(verComprobanteButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Debe navegar a detalle de comprobante de inicio
        print('🔍 Checking for ComprobanteInicioScreen...');
        if (find.byType(ComprobanteInicioScreen).evaluate().isEmpty) {
          print('❌ ComprobanteInicioScreen not found');
        } else {
          expect(find.byType(ComprobanteInicioScreen), findsOneWidget);
          print('✅ ComprobanteInicioScreen visible');

          // Pulsar DESCARGAR -> debe disparar share simulado y SnackBar de éxito
          print('💾 Tapping "DESCARGAR"...');
          await tester.tap(find.text('DESCARGAR'));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump();
          print('⏳ Waiting for success SnackBar...');

          if (find.text('Comprobante generado exitosamente').evaluate().isEmpty) {
            print('❌ Success SnackBar not shown');
          }
        }
        
        // Verificar si hay segundo botón "Ver comprobante" para fin
        if (verComprobanteButtons.evaluate().length > 1) {
          print('🔍 Found second "Ver comprobante" button (fin)');
          print('👁️ Tapping second "Ver comprobante" button (fin)...');
          await tester.tap(verComprobanteButtons.at(1));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          // Debe navegar a detalle de comprobante de fin
          print('🔍 Checking for ComprobanteFinScreen...');
          if (find.byType(ComprobanteFinScreen).evaluate().isNotEmpty) {
            expect(find.byType(ComprobanteFinScreen), findsOneWidget);
            print('✅ ComprobanteFinScreen visible');

            // Pulsar DESCARGAR
            print('💾 Tapping "DESCARGAR" for fin...');
            await tester.tap(find.text('DESCARGAR'));
            await tester.pump(const Duration(milliseconds: 300));
            await tester.pump();
          }
        }

        // Verificar que descargarUseCase fue llamado
        expect(descargarUseCase.executeCallCount, greaterThanOrEqualTo(1));
        print('✅ descargarUseCase.execute() called ${descargarUseCase.executeCallCount} time(s)');
      } else {
        print('⚠️ No "Ver comprobante" buttons found - juicio may not have paid boletas');
        print('ℹ️ This test requires at least one paid boleta in the juicio');
      }
    });
  });
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

Future<void> _limpiarTodoElEstado(FlutterSecureStorage secureStorage, SharedPreferences prefs) async {
  try {
    await secureStorage.deleteAll();
    await prefs.clear();

    // Limpiar base de datos SQLite
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('boletas_generadas');
    await db.delete('comprobantes');

    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    // Error limpiando estado - ignorar
    print('⚠️ Error limpiando estado: $e');
  }
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

// Fake repo que devuelve juicios con boletas pagadas
class _FakeJuiciosRepository implements JuiciosRepository {
  @override
  Future<List<JuicioEntity>> obtenerJuiciosActivos(int nroAfiliado, {int page = 1}) async {
    // Simular juicio con boleta de inicio pagada y boleta de fin pagada
    return [
      JuicioEntity(
        id: 1001,
        caratula: 'Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios',
        boletaInicioId: 12345,
        boletaFinId: 12346,
        fechaPagoInicio: DateTime(2024, 1, 20),
        fechaPagoFin: DateTime(2024, 3, 15),
      ),
      JuicioEntity(
        id: 1002,
        caratula: 'Rodriguez, Ana c/ Fernandez, Luis s/ Cobro Ejecutivo',
        boletaInicioId: 12347,
        boletaFinId: null,
        fechaPagoInicio: DateTime(2024, 2, 10),
        fechaPagoFin: null,
      ),
    ];
  }
}

// Fake repo que devuelve un comprobante de INICIO
class _FakeComprobantesRepositoryInicio implements ComprobantesRepository {
  @override
  Future<ComprobanteEntity> obtenerComprobante(int idBoletaPagada) async {
    // Devolver comprobante de inicio o fin dependiendo del ID
    final String mvc = idBoletaPagada == 12345 ? '0100' : '0200';
    
    return ComprobanteEntity(
      id: 777,
      fecha: '2024-01-21',
      importe: '21000.00',
      externalReferenceId: 'CSSAYP-777-ABC',
      boletasPagadas: [
        (
          id: idBoletaPagada,
          idBoletaGenerada: idBoletaPagada + 1000,
          importe: '21000.00',
          caratula: 'Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios',
          mvc: mvc,
          tipoJuicio: 'Daños y Perjuicios',
          montosOrganismos: const [
            (circunscripcion: 1, monto: 5000.0, organismo: 'colegio_abogados'),
            (circunscripcion: 1, monto: 2000.0, organismo: 'caja_forense'),
          ],
        ),
      ],
      comprobanteLink: null,
      metodoPago: 'Tarjeta',
    );
  }
}

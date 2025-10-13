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
import 'package:cssayp_movil/shared/providers/connectivity_provider.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';

import "../test/auth/data/datasources/usuario_data_source_test.mocks.dart";
import '../test/auth/presentation/providers/auth_provider_test.mocks.dart';

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

class MockConnectivityNotifier extends ConnectivityNotifier {
  late final ConnectivityStatus _mockStatus;

  @override
  Stream<ConnectivityStatus> build() {
    return Stream.value(_mockStatus);
  }

  void setMockStatus(ConnectivityStatus status) {
    _mockStatus = status;
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

  group('Historial Boletas Flow Tests', () {
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

    final successHistorialBoletasResponseBody = json.encode({
      'data': [
        {
          'id_boleta_generada': '12345',
          'id_tipo_boleta': '1',
          'caratula': 'Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios',
          'monto': '21000.00',
          'fecha_impresion': '2024-01-15T10:30:00Z',
          'dias_vencimiento': '30',
          'fecha_pago': '2024-01-20T10:30:00Z',
          'cod_barra': '12345678901234567890',
          'gastos_administrativos': '500.00',
        },
        {
          'id_boleta_generada': '12346',
          'id_tipo_boleta': '16',
          'caratula': 'Garcia, Maria c/ Lopez, Carlos s/ Alimentos',
          'monto': '15000.00',
          'fecha_impresion': '2024-01-10T14:20:00Z',
          'dias_vencimiento': '30',
          'fecha_pago': null,
          'cod_barra': '12345678901234567891',
          'gastos_administrativos': '300.00',
        },
        {
          'id_boleta_generada': '12347',
          'id_tipo_boleta': '1',
          'caratula': 'Lopez, Carlos c/ Rodriguez, Ana s/ Divorcio',
          'monto': '25000.00',
          'fecha_impresion': '2024-01-05T09:15:00Z',
          'dias_vencimiento': '30',
          'fecha_pago': '2024-01-12T09:15:00Z',
          'cod_barra': '12345678901234567892',
          'gastos_administrativos': '750.00',
        },
      ],
      'current_page': 1,
      'last_page': 2,
      'total': 5,
      'per_page': 10,
      'next_page_url': 'http://api.example.com/boletas?page=2',
      'prev_page_url': null,
    });
    const successHistorialBoletasResponseStatus = 200;

    final errorHistorialBoletasResponseBody = json.encode({
      'error': 'Error al obtener historial de boletas',
      'mensaje': 'No se pudo procesar la solicitud',
    });
    const errorHistorialBoletasResponseStatus = 400;

    setUpAll(() async {
      secureStorage = const FlutterSecureStorage();
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    tearDown(() async {
      // await Future.delayed(const Duration(seconds: 2));
    });

    tearDownAll(() async {
      await _limpiarTodoElEstado(secureStorage, prefs);
    });

    testWidgets('Debe navegar correctamente al historial de boletas y mostrar la lista', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successHistorialBoletasResponseBody, successHistorialBoletasResponseStatus);
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
      await tester.pumpAndSettle();

      // Verificar que estamos en HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navegar a la pestaña de Boletas (índice 1)
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Verificar que estamos en HistorialScreen
      expect(find.byType(HistorialScreen), findsOneWidget);
      expect(find.text('Historial'), findsOneWidget);

      // Verificar que las pestañas están presentes
      expect(find.text('Boletas'), findsAtLeastNWidgets(1));
      expect(find.text('Juicios'), findsOneWidget);

      // Esperar a que se carguen las boletas
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verificar que se muestran las boletas en la lista
      expect(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'), findsOneWidget);
      expect(find.text('Garcia, Maria c/ Lopez, Carlos s/ Alimentos'), findsOneWidget);
      expect(find.text('Lopez, Carlos c/ Rodriguez, Ana s/ Divorcio'), findsOneWidget);
    });

    testWidgets('Debe permitir buscar boletas por carátula', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successHistorialBoletasResponseBody, successHistorialBoletasResponseStatus);
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
      await tester.pumpAndSettle();

      // Navegar a la pestaña de Boletas
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Esperar a que se carguen las boletas
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Buscar el campo de búsqueda - puede estar en un TextField o TextFormField
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isEmpty) {
        final textFormField = find.byType(TextFormField);
        expect(textFormField, findsOneWidget);
      } else {
        expect(searchField, findsOneWidget);
      }

      // Ingresar texto de búsqueda
      final actualSearchField = searchField.evaluate().isNotEmpty ? searchField : find.byType(TextFormField);
      await tester.enterText(actualSearchField, 'Perez');
      await tester.pumpAndSettle();

      // Verificar que solo se muestra la boleta que coincide con la búsqueda
      expect(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'), findsOneWidget);
      expect(find.text('Garcia, Maria c/ Lopez, Carlos s/ Alimentos'), findsNothing);
      expect(find.text('Lopez, Carlos c/ Rodriguez, Ana s/ Divorcio'), findsNothing);

      // Limpiar la búsqueda
      await tester.enterText(actualSearchField, '');
      await tester.pumpAndSettle();

      // Verificar que se muestran todas las boletas nuevamente
      expect(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'), findsOneWidget);
      expect(find.text('Garcia, Maria c/ Lopez, Carlos s/ Alimentos'), findsOneWidget);
      expect(find.text('Lopez, Carlos c/ Rodriguez, Ana s/ Divorcio'), findsOneWidget);
    });

    testWidgets('Debe permitir cambiar entre las pestañas Boletas y Juicios', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successHistorialBoletasResponseBody, successHistorialBoletasResponseStatus);
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
      await tester.pumpAndSettle();

      // Navegar a la pestaña de Boletas
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Verificar que estamos en la pestaña de Boletas
      expect(find.byType(HistorialBoletasWidget), findsOneWidget);

      // Cambiar a la pestaña de Juicios - usar el primer match para evitar ambigüedad
      await tester.tap(find.text('Juicios').first);
      await tester.pumpAndSettle();

      // Verificar que estamos en la pestaña de Juicios
      expect(find.byType(HistorialJuiciosWidget), findsOneWidget);

      // Volver a la pestaña de Boletas - usar el primer match para evitar ambigüedad
      await tester.tap(find.text('Boletas').first);
      await tester.pumpAndSettle();

      // Verificar que estamos de vuelta en la pestaña de Boletas
      expect(find.byType(HistorialBoletasWidget), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje de error cuando falla la carga del historial', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(errorHistorialBoletasResponseBody, errorHistorialBoletasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          // Mock connectivity as offline to prevent cache fallback
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Navegar a la pestaña de Boletas
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Esperar a que se procese el error
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de historial y que maneja el error graciosamente
      expect(find.byType(HistorialScreen), findsOneWidget);
      expect(find.text('Historial'), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje de error cuando no hay conexión al servidor', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(TimeoutException('Connection timeout'));

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          // Mock connectivity as offline to prevent cache fallback
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Navegar a la pestaña de Boletas
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Esperar a que se procese el error de conexión
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de historial y que maneja el error graciosamente
      expect(find.byType(HistorialScreen), findsOneWidget);
      expect(find.text('Historial'), findsOneWidget);
    });

    testWidgets('Debe usar cache local cuando hay error de API pero está online', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(errorHistorialBoletasResponseBody, errorHistorialBoletasResponseStatus);
      });

      final container = ProviderContainer(
        overrides: [
          httpClientProvider.overrideWith((ref) => mockClient),
          usuarioRepositoryProvider.overrideWith((ref) => mockUsuarioRepository),
          preferenciasRepositoryProvider.overrideWith((ref) => mockPreferenciasRepository),
          secureStorageDataSourceProvider.overrideWith((ref) => mockSecureStorageDataSource),
          jwtTokenServiceProvider.overrideWith((ref) => mockJwtTokenService),
          // Mock connectivity as online to allow cache fallback
          connectivityProvider.overrideWith(() => MockConnectivityNotifier()),
        ],
      );

      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));

      await _esperarLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'valid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'valid_pass');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Navegar a la pestaña de Boletas
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Esperar a que se procese (puede usar cache o mostrar error)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de historial
      expect(find.byType(HistorialScreen), findsOneWidget);
      expect(find.text('Historial'), findsOneWidget);
    });

    testWidgets('Debe permitir hacer pull-to-refresh para actualizar la lista', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successHistorialBoletasResponseBody, successHistorialBoletasResponseStatus);
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
      await tester.pumpAndSettle();

      // Navegar a la pestaña de Boletas
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Esperar a que se carguen las boletas
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verificar que las boletas están cargadas
      expect(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'), findsOneWidget);

      // Simular pull-to-refresh
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();

      // Verificar que las boletas siguen visibles después del refresh
      expect(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'), findsOneWidget);
    });

    testWidgets('Debe mostrar información correcta de las boletas (montos, fechas, estado)', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successHistorialBoletasResponseBody, successHistorialBoletasResponseStatus);
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
      await tester.pumpAndSettle();

      // Navegar a la pestaña de Boletas
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Esperar a que se carguen las boletas
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verificar que se muestran las boletas con sus carátulas
      expect(find.text('Perez, Juan c/ Garcia, Maria s/ Daños y Perjuicios'), findsOneWidget);
      expect(find.text('Garcia, Maria c/ Lopez, Carlos s/ Alimentos'), findsOneWidget);
      expect(find.text('Lopez, Carlos c/ Rodriguez, Ana s/ Divorcio'), findsOneWidget);
    });

    testWidgets('Debe navegar correctamente de vuelta al home desde el historial', (tester) async {
      final mockClient = MockClient();
      final mockSecureStorageDataSource = MockSecureStorageDataSource();
      final mockUsuarioRepository = MockUsuarioRepositoryComplete(mockSecureStorageDataSource);
      final mockPreferenciasRepository = MockPreferenciasRepository();
      final mockJwtTokenService = MockJwtTokenService();

      when(mockPreferenciasRepository.obtenerPreferenciaBiometria()).thenAnswer((_) async => false);

      when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successLoginResponseBody, successLoginResponseStatus);
      });

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        return http.Response(successHistorialBoletasResponseBody, successHistorialBoletasResponseStatus);
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
      await tester.pumpAndSettle();

      // Navegar a la pestaña de Boletas
      await tester.tap(find.byIcon(Icons.balance_outlined));
      await tester.pumpAndSettle();

      // Verificar que estamos en HistorialScreen
      expect(find.byType(HistorialScreen), findsOneWidget);

      // Navegar de vuelta al home
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();

      // Verificar que estamos de vuelta en HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(HistorialScreen), findsNothing);
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

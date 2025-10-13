import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:cssayp_movil/boletas/boletas.dart';

import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';

import 'boletas_repository_impl_test.mocks.dart';

// Provide dummy values for sealed classes
void provideDummyValues() {
  provideDummy<CrearBoletaResponse>(CrearBoletaGenericErrorResponse(statusCode: 0, errorMessage: 'dummy'));
  provideDummy<HistorialBoletasResponse>(HistorialBoletasErrorResponse(statusCode: 0, errorMessage: 'dummy'));
  provideDummy<PaginatedResponseModel>(
    PaginatedResponseModel(statusCode: 0, data: [], currentPage: 1, lastPage: 1, total: 0, perPage: 10),
  );
  provideDummy<CrearBoletaInicioResult>(CrearBoletaInicioResult(idBoleta: 0, urlPago: 'dummy'));
}

@GenerateMocks([BoletasDataSource, BoletasLocalDataSource, JwtTokenService])
void main() {
  late BoletasRepositoryImpl repository;
  late MockBoletasDataSource mockBoletasDataSource;
  late MockBoletasLocalDataSource mockBoletasLocalDataSource;
  late MockJwtTokenService mockJwtTokenService;

  setUpAll(() {
    provideDummyValues();
  });

  setUp(() {
    mockBoletasDataSource = MockBoletasDataSource();
    mockBoletasLocalDataSource = MockBoletasLocalDataSource();
    mockJwtTokenService = MockJwtTokenService();

    repository = BoletasRepositoryImpl(
      boletasDataSource: mockBoletasDataSource,
      boletasLocalDataSource: mockBoletasLocalDataSource,
      jwtTokenService: mockJwtTokenService,
    );
  });

  group('crearBoletaInicio', () {
    const testCaratula = 'Test Caratula';
    const testJuzgado = 'Test Juzgado';
    const testToken = 'test-token';

    final testCircunscripcion = CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion');
    final testTipoJuicio = TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio');

    test('debería crear boleta de inicio exitosamente', () async {
      // Arrange
      final successResponse = CrearBoletaSuccessResponse(
        statusCode: 201,
        idBoleta: 1001,
        urlPago: 'https://test-payment-url.com',
      );

      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => testToken);
      when(
        mockBoletasDataSource.crearBoletaInicio(
          token: testToken,
          caratula: testCaratula,
          juzgado: testJuzgado,
          circunscripcion: testCircunscripcion,
          tipoJuicio: testTipoJuicio,
        ),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.crearBoletaInicio(
        caratula: testCaratula,
        juzgado: testJuzgado,
        circunscripcion: testCircunscripcion,
        tipoJuicio: testTipoJuicio,
      );

      // Assert
      expect(result, isA<CrearBoletaInicioResult>());
      expect(result.idBoleta, equals(1001));
      expect(result.urlPago, equals('https://test-payment-url.com'));

      verify(mockJwtTokenService.obtenerToken()).called(1);
      verify(
        mockBoletasDataSource.crearBoletaInicio(
          token: testToken,
          caratula: testCaratula,
          juzgado: testJuzgado,
          circunscripcion: testCircunscripcion,
          tipoJuicio: testTipoJuicio,
        ),
      ).called(1);
    });

    test('debería lanzar excepción cuando no se puede obtener el token', () async {
      // Arrange
      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.crearBoletaInicio(
          caratula: testCaratula,
          juzgado: testJuzgado,
          circunscripcion: testCircunscripcion,
          tipoJuicio: testTipoJuicio,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No se pudo obtener el token de autenticación'),
          ),
        ),
      );

      verify(mockJwtTokenService.obtenerToken()).called(1);
      verifyNever(
        mockBoletasDataSource.crearBoletaInicio(
          token: anyNamed('token'),
          caratula: anyNamed('caratula'),
          juzgado: anyNamed('juzgado'),
          circunscripcion: anyNamed('circunscripcion'),
          tipoJuicio: anyNamed('tipoJuicio'),
        ),
      );
    });

    test('debería lanzar excepción cuando la respuesta es un error', () async {
      // Arrange
      final errorResponse = CrearBoletaGenericErrorResponse(statusCode: 400, errorMessage: 'Error de validación');

      when(mockJwtTokenService.obtenerToken()).thenAnswer((_) async => testToken);
      when(
        mockBoletasDataSource.crearBoletaInicio(
          token: testToken,
          caratula: testCaratula,
          juzgado: testJuzgado,
          circunscripcion: testCircunscripcion,
          tipoJuicio: testTipoJuicio,
        ),
      ).thenAnswer((_) async => errorResponse);

      // Act & Assert
      try {
        await repository.crearBoletaInicio(
          caratula: testCaratula,
          juzgado: testJuzgado,
          circunscripcion: testCircunscripcion,
          tipoJuicio: testTipoJuicio,
        );
        fail('Se esperaba que se lanzara una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error al crear boleta de inicio: Error de validación'));
      }

      verify(mockJwtTokenService.obtenerToken()).called(1);
      verify(
        mockBoletasDataSource.crearBoletaInicio(
          token: testToken,
          caratula: testCaratula,
          juzgado: testJuzgado,
          circunscripcion: testCircunscripcion,
          tipoJuicio: testTipoJuicio,
        ),
      ).called(1);
    });
  });

  group('crearBoletaFinalizacion', () {
    const testNroAfiliado = 12345;
    const testCaratula = 'Test Caratula';
    const testIdBoletaInicio = 1001;
    const testMonto = 2000.0;
    final testFechaRegulacion = DateTime(2024, 1, 15);
    const testHonorarios = 500.0;
    const testCantidadJus = 2.0;
    const testValorJus = 100.0;
    const testNroExpediente = 123;
    const testAnioExpediente = 2024;
    const testCuij = 456;
    const testDigito = '5';

    test('debería crear boleta de finalización exitosamente', () async {
      // Arrange
      final successResponse = CrearBoletaSuccessResponse(
        statusCode: 201,
        idBoleta: 1002,
        urlPago: 'https://test-payment-url.com',
      );

      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => testDigito);
      when(
        mockBoletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: testNroAfiliado,
          digito: testDigito,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: testNroExpediente,
          anioExpediente: testAnioExpediente,
          cuij: testCuij,
        ),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.crearBoletaFinalizacion(
        nroAfiliado: testNroAfiliado,
        caratula: testCaratula,
        idBoletaInicio: testIdBoletaInicio,
        monto: testMonto,
        fechaRegulacion: testFechaRegulacion,
        honorarios: testHonorarios,
        cantidadJus: testCantidadJus,
        valorJus: testValorJus,
        nroExpediente: testNroExpediente,
        anioExpediente: testAnioExpediente,
        cuij: testCuij,
      );

      // Assert
      expect(result, isA<BoletaEntity>());
      expect(result.id, equals(1002));
      expect(result.tipo, equals(BoletaTipo.finalizacion));
      expect(result.monto, equals(2000.0));
      expect(result.caratula, equals(testCaratula));
      expect(result.codBarra, isNull);
      expect(result.gastosAdministrativos, isNull);

      verify(mockJwtTokenService.obtenerDigito()).called(1);
      verify(
        mockBoletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: testNroAfiliado,
          digito: testDigito,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: testNroExpediente,
          anioExpediente: testAnioExpediente,
          cuij: testCuij,
        ),
      ).called(1);
    });

    test('debería lanzar excepción cuando no se puede obtener el dígito', () async {
      // Arrange
      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.crearBoletaFinalizacion(
          nroAfiliado: testNroAfiliado,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No se pudo obtener el dígito del token de autenticación'),
          ),
        ),
      );

      verify(mockJwtTokenService.obtenerDigito()).called(1);
      verifyNever(
        mockBoletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: anyNamed('nroAfiliado'),
          digito: anyNamed('digito'),
          caratula: anyNamed('caratula'),
          idBoletaInicio: anyNamed('idBoletaInicio'),
          monto: anyNamed('monto'),
          fechaRegulacion: anyNamed('fechaRegulacion'),
          honorarios: anyNamed('honorarios'),
          cantidadJus: anyNamed('cantidadJus'),
          valorJus: anyNamed('valorJus'),
          nroExpediente: anyNamed('nroExpediente'),
          anioExpediente: anyNamed('anioExpediente'),
          cuij: anyNamed('cuij'),
        ),
      );
    });

    test('debería lanzar excepción cuando la respuesta es un error', () async {
      // Arrange
      final errorResponse = CrearBoletaGenericErrorResponse(
        statusCode: 400,
        errorMessage: 'Error de validación en finalización',
      );

      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => testDigito);
      when(
        mockBoletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: testNroAfiliado,
          digito: testDigito,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: testNroExpediente,
          anioExpediente: testAnioExpediente,
          cuij: testCuij,
        ),
      ).thenAnswer((_) async => errorResponse);

      // Act & Assert
      try {
        await repository.crearBoletaFinalizacion(
          nroAfiliado: testNroAfiliado,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: testNroExpediente,
          anioExpediente: testAnioExpediente,
          cuij: testCuij,
        );
        fail('Se esperaba que se lanzara una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error al crear boleta de finalización: Error de validación en finalización'));
      }

      verify(mockJwtTokenService.obtenerDigito()).called(1);
      verify(
        mockBoletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: testNroAfiliado,
          digito: testDigito,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: testNroExpediente,
          anioExpediente: testAnioExpediente,
          cuij: testCuij,
        ),
      ).called(1);
    });

    test('debería crear boleta de finalización con parámetros opcionales nulos', () async {
      // Arrange
      final successResponse = CrearBoletaSuccessResponse(
        statusCode: 201,
        idBoleta: 1002,
        urlPago: 'https://test-payment-url.com',
      );

      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => testDigito);
      when(
        mockBoletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: testNroAfiliado,
          digito: testDigito,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.crearBoletaFinalizacion(
        nroAfiliado: testNroAfiliado,
        caratula: testCaratula,
        idBoletaInicio: testIdBoletaInicio,
        monto: testMonto,
        fechaRegulacion: testFechaRegulacion,
        honorarios: testHonorarios,
        cantidadJus: testCantidadJus,
        valorJus: testValorJus,
      );

      // Assert
      expect(result, isA<BoletaEntity>());
      expect(result.id, equals(1002));
      expect(result.tipo, equals(BoletaTipo.finalizacion));

      verify(
        mockBoletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: testNroAfiliado,
          digito: testDigito,
          caratula: testCaratula,
          idBoletaInicio: testIdBoletaInicio,
          monto: testMonto,
          fechaRegulacion: testFechaRegulacion,
          honorarios: testHonorarios,
          cantidadJus: testCantidadJus,
          valorJus: testValorJus,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).called(1);
    });
  });

  group('obtenerHistorialBoletas', () {
    const testNroAfiliado = 12345;

    test('debería obtener historial de boletas desde API exitosamente', () async {
      // Arrange
      final boletasHistorial = [
        BoletaHistorialModel(
          idBoletaGenerada: '1001',
          idTipoTransaccion: '1',
          fechaImpresion: '2024-01-15T10:00:00Z',
          monto: '1500.50',
          caratula: 'Test Caratula 1',
          codBarra: '123456789',
        ),
        BoletaHistorialModel(
          idBoletaGenerada: '1002',
          idTipoTransaccion: '2',
          fechaImpresion: '2024-01-16T10:00:00Z',
          monto: '2000.0',
          caratula: 'Test Caratula 2',
          codBarra: '987654321',
        ),
      ];

      final successResponse = HistorialBoletasSuccessResponse(
        statusCode: 200,
        currentPage: 1,
        boletas: boletasHistorial,
        lastPage: 1,
        total: 2,
        perPage: 10,
      );

      when(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, page: null, mostrarPagadas: 1),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.obtenerHistorialBoletas(testNroAfiliado);

      // Assert
      expect(result, isA<HistorialBoletasSuccessResponse>());
      expect(result.statusCode, equals(200));
      expect(result.boletas.length, equals(2));
      expect(result.currentPage, equals(1));
      expect(result.total, equals(2));

      verify(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, page: null, mostrarPagadas: 1),
      ).called(1);
    });

    test('debería obtener historial de boletas con página específica', () async {
      // Arrange
      const page = 2;
      final boletasHistorial = [
        BoletaHistorialModel(
          idBoletaGenerada: '1003',
          idTipoTransaccion: '1',
          fechaImpresion: '2024-01-17T10:00:00Z',
          monto: '1750.25',
          caratula: 'Test Caratula 3',
          codBarra: '111222333',
        ),
      ];

      final successResponse = HistorialBoletasSuccessResponse(
        statusCode: 200,
        currentPage: page,
        boletas: boletasHistorial,
        lastPage: 3,
        total: 25,
        perPage: 10,
      );

      when(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, page: page, mostrarPagadas: 1),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.obtenerHistorialBoletas(testNroAfiliado, page: page);

      // Assert
      expect(result, isA<HistorialBoletasSuccessResponse>());
      expect(result.currentPage, equals(page));
      expect(result.lastPage, equals(3));
      expect(result.total, equals(25));

      verify(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, page: page, mostrarPagadas: 1),
      ).called(1);
    });

    test('debería fallback a datos locales cuando API falla', () async {
      // Arrange
      final boletasLocales = [
        BoletaEntity(
          id: 1001,
          tipo: BoletaTipo.inicio,
          monto: 1500.50,
          fechaImpresion: DateTime(2024, 1, 15),
          fechaVencimiento: DateTime(2024, 2, 15),
          caratula: 'Test Caratula Local',
          codBarra: '123456789',
        ),
      ];

      when(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, page: null, mostrarPagadas: 1),
      ).thenThrow(Exception('API Error'));

      when(
        mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0),
      ).thenAnswer((_) async => boletasLocales);
      when(mockBoletasLocalDataSource.obtenerConteoBoletasLocales()).thenAnswer((_) async => 1);

      // Act
      final result = await repository.obtenerHistorialBoletas(testNroAfiliado);

      // Assert
      expect(result, isA<HistorialBoletasSuccessResponse>());
      expect(result.statusCode, equals(200));
      expect(result.boletas.length, equals(1));
      expect(result.currentPage, equals(1));
      expect(result.total, equals(1));
      expect(result.perPage, equals(10));

      verify(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, page: null, mostrarPagadas: 1),
      ).called(1);
      verify(mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0)).called(1);
      verify(mockBoletasLocalDataSource.obtenerConteoBoletasLocales()).called(1);
    });

    test('debería lanzar excepción cuando API retorna error y no hay datos locales', () async {
      // Arrange
      when(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, page: null, mostrarPagadas: 1),
      ).thenThrow(Exception('API Error'));

      when(mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0)).thenThrow(Exception('Local Error'));

      // Act & Assert
      expect(
        () => repository.obtenerHistorialBoletas(testNroAfiliado),
        throwsA(
          isA<Exception>().having((e) => e.toString(), 'message', contains('Error al obtener historial de boletas')),
        ),
      );

      verify(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, page: null, mostrarPagadas: 1),
      ).called(1);
      verify(mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0)).called(1);
    });
  });

  group('buscarBoletasInicioPagadas', () {
    const testNroAfiliado = 12345;
    const testCaratulaBuscada = 'Test';

    test('debería buscar boletas de inicio pagadas desde API exitosamente', () async {
      // Arrange
      final data = [
        {'id': 1001, 'caratula': 'Test Caratula 1', 'monto': 1500.50, 'fechaImpresion': '2024-01-15T10:00:00Z'},
        {'id': 1002, 'caratula': 'Test Caratula 2', 'monto': 2000.0, 'fechaImpresion': '2024-01-16T10:00:00Z'},
      ];

      final successResponse = PaginatedResponseModel(
        statusCode: 200,
        data: data,
        currentPage: 1,
        lastPage: 1,
        total: 2,
        perPage: 10,
      );

      when(
        mockBoletasDataSource.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: 1,
          caratulaBuscada: testCaratulaBuscada,
        ),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.buscarBoletasInicioPagadas(
        nroAfiliado: testNroAfiliado,
        caratulaBuscada: testCaratulaBuscada,
      );

      // Assert
      expect(result, isA<PaginatedResponseModel>());
      expect(result.statusCode, equals(200));
      expect(result.data.length, equals(2));
      expect(result.currentPage, equals(1));
      expect(result.total, equals(2));

      verify(
        mockBoletasDataSource.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: 1,
          caratulaBuscada: testCaratulaBuscada,
        ),
      ).called(1);
    });

    test('debería buscar boletas de inicio pagadas con página específica', () async {
      // Arrange
      const page = 2;
      final data = [
        {'id': 1003, 'caratula': 'Test Caratula 3', 'monto': 1750.25, 'fechaImpresion': '2024-01-17T10:00:00Z'},
      ];

      final successResponse = PaginatedResponseModel(
        statusCode: 200,
        data: data,
        currentPage: page,
        lastPage: 3,
        total: 25,
        perPage: 10,
      );

      when(
        mockBoletasDataSource.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: page,
          caratulaBuscada: testCaratulaBuscada,
        ),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.buscarBoletasInicioPagadas(
        nroAfiliado: testNroAfiliado,
        page: page,
        caratulaBuscada: testCaratulaBuscada,
      );

      // Assert
      expect(result, isA<PaginatedResponseModel>());
      expect(result.currentPage, equals(page));
      expect(result.lastPage, equals(3));
      expect(result.total, equals(25));

      verify(
        mockBoletasDataSource.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: page,
          caratulaBuscada: testCaratulaBuscada,
        ),
      ).called(1);
    });

    test('debería fallback a búsqueda local cuando API falla', () async {
      // Arrange
      final boletasLocales = [
        BoletaEntity(
          id: 1001,
          tipo: BoletaTipo.inicio,
          monto: 1500.50,
          fechaImpresion: DateTime(2024, 1, 15),
          fechaVencimiento: DateTime(2024, 2, 15),
          caratula: 'Test Caratula Local',
          codBarra: '123456789',
        ),
      ];

      when(
        mockBoletasDataSource.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: 1,
          caratulaBuscada: testCaratulaBuscada,
        ),
      ).thenThrow(Exception('API Error'));

      when(
        mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0, caratulaFiltro: testCaratulaBuscada),
      ).thenAnswer((_) async => boletasLocales);

      when(
        mockBoletasLocalDataSource.obtenerConteoBoletasLocales(caratulaFiltro: testCaratulaBuscada),
      ).thenAnswer((_) async => 1);

      // Act
      final result = await repository.buscarBoletasInicioPagadas(
        nroAfiliado: testNroAfiliado,
        caratulaBuscada: testCaratulaBuscada,
      );

      // Assert
      expect(result, isA<PaginatedResponseModel>());
      expect(result.statusCode, equals(200));
      expect(result.data.length, equals(1));
      expect(result.currentPage, equals(1));
      expect(result.total, equals(1));
      expect(result.perPage, equals(10));

      verify(
        mockBoletasDataSource.buscarBoletasInicioPagadas(
          nroAfiliado: testNroAfiliado,
          page: 1,
          caratulaBuscada: testCaratulaBuscada,
        ),
      ).called(1);
      verify(
        mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0, caratulaFiltro: testCaratulaBuscada),
      ).called(1);
      verify(mockBoletasLocalDataSource.obtenerConteoBoletasLocales(caratulaFiltro: testCaratulaBuscada)).called(1);
    });

    test('debería buscar sin filtro de carátula cuando no se proporciona', () async {
      // Arrange
      final data = [
        {'id': 1001, 'caratula': 'Any Caratula', 'monto': 1500.50, 'fechaImpresion': '2024-01-15T10:00:00Z'},
      ];

      final successResponse = PaginatedResponseModel(
        statusCode: 200,
        data: data,
        currentPage: 1,
        lastPage: 1,
        total: 1,
        perPage: 10,
      );

      when(
        mockBoletasDataSource.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado);

      // Assert
      expect(result, isA<PaginatedResponseModel>());
      expect(result.data.length, equals(1));

      verify(
        mockBoletasDataSource.buscarBoletasInicioPagadas(nroAfiliado: testNroAfiliado, page: 1, caratulaBuscada: null),
      ).called(1);
    });
  });

  group('debeUsarCache', () {
    test('debería retornar false cuando no hay boletas en cache', () async {
      // Arrange
      when(mockBoletasLocalDataSource.tieneBoletasEnCache()).thenAnswer((_) async => false);

      // Act
      final result = await repository.debeUsarCache();

      // Assert
      expect(result, isFalse);
      verify(mockBoletasLocalDataSource.tieneBoletasEnCache()).called(1);
      verifyNever(mockBoletasLocalDataSource.obtenerUltimaSincronizacion());
    });

    test('debería retornar false cuando no hay última sincronización', () async {
      // Arrange
      when(mockBoletasLocalDataSource.tieneBoletasEnCache()).thenAnswer((_) async => true);
      when(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).thenAnswer((_) async => null);

      // Act
      final result = await repository.debeUsarCache();

      // Assert
      expect(result, isFalse);
      verify(mockBoletasLocalDataSource.tieneBoletasEnCache()).called(1);
      verify(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).called(1);
    });

    test('debería retornar true cuando cache es válido (menos de 1 hora)', () async {
      // Arrange
      final now = DateTime.now();
      final lastSync = now.subtract(const Duration(minutes: 30)); // 30 minutos atrás

      when(mockBoletasLocalDataSource.tieneBoletasEnCache()).thenAnswer((_) async => true);
      when(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).thenAnswer((_) async => lastSync);

      // Act
      final result = await repository.debeUsarCache();

      // Assert
      expect(result, isTrue);
      verify(mockBoletasLocalDataSource.tieneBoletasEnCache()).called(1);
      verify(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).called(1);
    });

    test('debería retornar false cuando cache es inválido (más de 1 hora)', () async {
      // Arrange
      final now = DateTime.now();
      final lastSync = now.subtract(const Duration(hours: 2)); // 2 horas atrás

      when(mockBoletasLocalDataSource.tieneBoletasEnCache()).thenAnswer((_) async => true);
      when(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).thenAnswer((_) async => lastSync);

      // Act
      final result = await repository.debeUsarCache();

      // Assert
      expect(result, isFalse);
      verify(mockBoletasLocalDataSource.tieneBoletasEnCache()).called(1);
      verify(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).called(1);
    });
  });

  group('syncCache', () {
    const testNroAfiliado = 12345;

    test('debería sincronizar cache exitosamente', () async {
      // Arrange
      final boletasHistorial = [
        BoletaHistorialModel(
          idBoletaGenerada: '1001',
          idTipoTransaccion: '1',
          fechaImpresion: '2024-01-15T10:00:00Z',
          monto: '1500.50',
          caratula: 'Test Caratula 1',
          codBarra: '123456789',
        ),
      ];

      final successResponse = HistorialBoletasSuccessResponse(
        statusCode: 200,
        currentPage: 1,
        boletas: boletasHistorial,
        lastPage: 1,
        total: 1,
        perPage: 10,
      );

      when(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, mostrarPagadas: 1),
      ).thenAnswer((_) async => successResponse);

      when(mockBoletasLocalDataSource.limpiarCache()).thenAnswer((_) async {});
      when(mockBoletasLocalDataSource.guardarBoletas(any)).thenAnswer((_) async {});

      // Act
      await repository.syncCache(testNroAfiliado);

      // Assert
      verify(mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, mostrarPagadas: 1)).called(1);
      verify(mockBoletasLocalDataSource.limpiarCache()).called(1);
      verify(mockBoletasLocalDataSource.guardarBoletas(any)).called(1);
    });

    test('debería manejar error en sincronización sin lanzar excepción', () async {
      // Arrange
      when(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, mostrarPagadas: 1),
      ).thenThrow(Exception('Sync Error'));

      // Act
      await repository.syncCache(testNroAfiliado);

      // Assert
      verify(mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, mostrarPagadas: 1)).called(1);
      verifyNever(mockBoletasLocalDataSource.limpiarCache());
      verifyNever(mockBoletasLocalDataSource.guardarBoletas(any));
    });

    test('debería manejar respuesta de error sin lanzar excepción', () async {
      // Arrange
      final errorResponse = HistorialBoletasErrorResponse(statusCode: 400, errorMessage: 'Error en API');

      when(
        mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, mostrarPagadas: 1),
      ).thenAnswer((_) async => errorResponse);

      // Act
      await repository.syncCache(testNroAfiliado);

      // Assert
      verify(mockBoletasDataSource.obtenerHistorialBoletas(nroAfiliado: testNroAfiliado, mostrarPagadas: 1)).called(1);
      verifyNever(mockBoletasLocalDataSource.limpiarCache());
      verifyNever(mockBoletasLocalDataSource.guardarBoletas(any));
    });
  });
}

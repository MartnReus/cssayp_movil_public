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
    const testNroAfiliado = 12345;
    const testMonto = 1500.50;
    const testDigito = '5';

    test('debería crear boleta de inicio exitosamente', () async {
      // Arrange
      final successResponse = CrearBoletaSuccessResponse(
        statusCode: 201,
        idBoleta: 1001,
        idTipoBoleta: 1,
        idTipoTransaccion: '1',
        codBarra: '123456789',
        caratula: testCaratula,
        fechaImpresion: '2024-01-15T10:00:00Z',
        fechaVencimiento: '30',
        montoEntero: '1500',
        montoDecimal: '50',
        gastosAdministrativos: 25.0,
      );

      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => testDigito);
      when(
        mockBoletasDataSource.crearBoletaInicio(
          caratula: testCaratula,
          nroAfiliado: testNroAfiliado,
          monto: testMonto,
          digito: testDigito,
        ),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.crearBoletaInicio(
        caratula: testCaratula,
        nroAfiliado: testNroAfiliado,
        monto: testMonto,
      );

      // Assert
      expect(result, isA<BoletaEntity>());
      expect(result.id, equals(1001));
      expect(result.tipo, equals(BoletaTipo.inicio));
      expect(result.monto, equals(1500.50));
      expect(result.caratula, equals(testCaratula));
      expect(result.codBarra, equals('123456789'));
      expect(result.gastosAdministrativos, equals(25.0));

      verify(mockJwtTokenService.obtenerDigito()).called(1);
      verify(
        mockBoletasDataSource.crearBoletaInicio(
          caratula: testCaratula,
          nroAfiliado: testNroAfiliado,
          monto: testMonto,
          digito: testDigito,
        ),
      ).called(1);
    });

    test('debería lanzar excepción cuando no se puede obtener el dígito', () async {
      // Arrange
      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => repository.crearBoletaInicio(caratula: testCaratula, nroAfiliado: testNroAfiliado, monto: testMonto),
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
        mockBoletasDataSource.crearBoletaInicio(
          caratula: anyNamed('caratula'),
          nroAfiliado: anyNamed('nroAfiliado'),
          monto: anyNamed('monto'),
          digito: anyNamed('digito'),
        ),
      );
    });

    test('debería lanzar excepción cuando la respuesta es un error', () async {
      // Arrange
      final errorResponse = CrearBoletaGenericErrorResponse(statusCode: 400, errorMessage: 'Error de validación');

      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => testDigito);
      when(
        mockBoletasDataSource.crearBoletaInicio(
          caratula: testCaratula,
          nroAfiliado: testNroAfiliado,
          monto: testMonto,
          digito: testDigito,
        ),
      ).thenAnswer((_) async => errorResponse);

      // Act & Assert
      try {
        await repository.crearBoletaInicio(caratula: testCaratula, nroAfiliado: testNroAfiliado, monto: testMonto);
        fail('Se esperaba que se lanzara una excepción');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Error al crear boleta de inicio: Error de validación'));
      }

      verify(mockJwtTokenService.obtenerDigito()).called(1);
      verify(
        mockBoletasDataSource.crearBoletaInicio(
          caratula: testCaratula,
          nroAfiliado: testNroAfiliado,
          monto: testMonto,
          digito: testDigito,
        ),
      ).called(1);
    });

    test('debería manejar valores nulos en monto correctamente', () async {
      // Arrange
      final successResponse = CrearBoletaSuccessResponse(
        statusCode: 201,
        idBoleta: 1001,
        idTipoBoleta: 1,
        idTipoTransaccion: '1',
        codBarra: '123456789',
        caratula: testCaratula,
        fechaImpresion: '2024-01-15T10:00:00Z',
        fechaVencimiento: '30',
        montoEntero: null,
        montoDecimal: null,
      );

      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => testDigito);
      when(
        mockBoletasDataSource.crearBoletaInicio(
          caratula: testCaratula,
          nroAfiliado: testNroAfiliado,
          monto: testMonto,
          digito: testDigito,
        ),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.crearBoletaInicio(
        caratula: testCaratula,
        nroAfiliado: testNroAfiliado,
        monto: testMonto,
      );

      // Assert
      expect(result.monto, equals(0.0));
    });

    test('debería calcular fecha de vencimiento correctamente', () async {
      // Arrange
      final successResponse = CrearBoletaSuccessResponse(
        statusCode: 201,
        idBoleta: 1001,
        idTipoBoleta: 1,
        idTipoTransaccion: '1',
        codBarra: '123456789',
        caratula: testCaratula,
        fechaImpresion: '2024-01-15T10:00:00Z',
        fechaVencimiento: '45',
        montoEntero: '1500',
        montoDecimal: '50',
      );

      when(mockJwtTokenService.obtenerDigito()).thenAnswer((_) async => testDigito);
      when(
        mockBoletasDataSource.crearBoletaInicio(
          caratula: testCaratula,
          nroAfiliado: testNroAfiliado,
          monto: testMonto,
          digito: testDigito,
        ),
      ).thenAnswer((_) async => successResponse);

      // Act
      final result = await repository.crearBoletaInicio(
        caratula: testCaratula,
        nroAfiliado: testNroAfiliado,
        monto: testMonto,
      );

      // Assert
      final expectedVencimiento = DateTime.parse('2024-01-15T10:00:00Z').add(const Duration(days: 45));
      expect(result.fechaVencimiento, equals(expectedVencimiento));
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
        idTipoBoleta: 2,
        idTipoTransaccion: '2',
        codBarra: '987654321',
        caratula: testCaratula,
        fechaImpresion: '2024-01-15T10:00:00Z',
        fechaVencimiento: '30',
        diasVencimiento: '30',
        montoEntero: '2000',
        montoDecimal: '0',
        gastosAdministrativos: 50.0,
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
      expect(result.codBarra, equals('987654321'));
      expect(result.gastosAdministrativos, equals(50.0));

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
        idTipoBoleta: 2,
        idTipoTransaccion: '2',
        codBarra: '987654321',
        caratula: testCaratula,
        fechaImpresion: '2024-01-15T10:00:00Z',
        fechaVencimiento: '30',
        diasVencimiento: '30',
        montoEntero: '2000',
        montoDecimal: '0',
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

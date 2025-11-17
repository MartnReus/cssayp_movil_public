import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:cssayp_movil/comprobantes/comprobantes.dart';

import 'comprobantes_repository_impl_test.mocks.dart';

// Provide dummy values for sealed classes
void provideDummyValues() {
  provideDummy<DatosComprobanteResponse>(DatosComprobanteGenericErrorResponse(statusCode: 0, errorMessage: 'dummy'));
}

@GenerateNiceMocks([MockSpec<ComprobantesRemoteDataSource>(), MockSpec<ComprobantesLocalDataSource>()])
void main() {
  late ComprobantesRepositoryImpl repository;
  late MockComprobantesRemoteDataSource mockRemoteDataSource;
  late MockComprobantesLocalDataSource mockLocalDataSource;

  setUpAll(() {
    provideDummyValues();
  });

  setUp(() {
    mockRemoteDataSource = MockComprobantesRemoteDataSource();
    mockLocalDataSource = MockComprobantesLocalDataSource();

    repository = ComprobantesRepositoryImpl(
      comprobantesLocalDataSource: mockLocalDataSource,
      comprobantesRemoteDataSource: mockRemoteDataSource,
    );
  });

  group('obtenerComprobante', () {
    const testIdBoletaPagada = 123;

    test(
      'debería devolver ComprobanteEntity cuando la fuente remota de datos devuelve una respuesta exitosa',
      () async {
      // Arrange
      final mockSuccessResponse = DatosComprobanteSuccessResponse(
        statusCode: 200,
        id: 456,
        fecha: '2025-10-26',
        importe: '1500.00',
        boletasPagadas: [
          (
            id: 789,
            importe: '1500.00',
            caratula: 'Test Caratula',
            mvc: 'TEST-123',
            tipoJuicio: 'Civil',
            montosOrganismos: [(circunscripcion: 1, organismo: 'Organismo Test', monto: 1500.0)],
          ),
        ],
        comprobanteLink: 'https://example.com/comprobante.pdf',
        metodoPago: 'Tarjeta de crédito',
      );

      when(
        mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada),
      ).thenAnswer((_) async => mockSuccessResponse);

      // Act
      final result = await repository.obtenerComprobante(testIdBoletaPagada);

      // Assert
      expect(result, isA<ComprobanteEntity>());
      expect(result.id, 456);
      expect(result.fecha, '2025-10-26');
      expect(result.importe, '1500.00');
      expect(result.boletasPagadas.length, 1);
      expect(result.boletasPagadas[0].id, 789);
      expect(result.comprobanteLink, 'https://example.com/comprobante.pdf');
      expect(result.metodoPago, 'Tarjeta de crédito');
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
      verifyNever(mockLocalDataSource.databaseHelper);
    });

    test('debería devolver ComprobanteEntity con el mapeo de datos correcto', () async {
      // Arrange
      final mockSuccessResponse = DatosComprobanteSuccessResponse(
        statusCode: 200,
        id: 100,
        fecha: '2025-01-15',
        importe: '2500.50',
        boletasPagadas: [
          (
            id: 200,
            importe: '1000.00',
            caratula: 'Caratula 1',
            mvc: 'MVC-001',
            tipoJuicio: 'Penal',
            montosOrganismos: null,
          ),
          (
            id: 201,
            importe: '1500.50',
            caratula: 'Caratula 2',
            mvc: 'MVC-002',
            tipoJuicio: null,
            montosOrganismos: [(circunscripcion: 2, organismo: 'Organismo 2', monto: 1500.5)],
          ),
        ],
        comprobanteLink: null,
        metodoPago: null,
      );

      when(
        mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada),
      ).thenAnswer((_) async => mockSuccessResponse);

      // Act
      final result = await repository.obtenerComprobante(testIdBoletaPagada);

      // Assert
      expect(result.id, 100);
      expect(result.fecha, '2025-01-15');
      expect(result.importe, '2500.50');
      expect(result.boletasPagadas.length, 2);
      expect(result.boletasPagadas[0].id, 200);
      expect(result.boletasPagadas[0].caratula, 'Caratula 1');
      expect(result.boletasPagadas[1].id, 201);
      expect(result.boletasPagadas[1].mvc, 'MVC-002');
      expect(result.comprobanteLink, isNull);
      expect(result.metodoPago, isNull);
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
    });

    test('debería lanzar Exception cuando el data source remoto devuelve una respuesta de error genérica', () async {
      // Arrange
      const errorMessage = 'Comprobante no encontrado';
      final mockErrorResponse = DatosComprobanteGenericErrorResponse(statusCode: 404, errorMessage: errorMessage);

      when(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).thenAnswer((_) async => mockErrorResponse);

      // Act & Assert
      expect(
        () => repository.obtenerComprobante(testIdBoletaPagada),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains(errorMessage))),
      );
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
    });

    test('debería lanzar Exception con el mensaje de error correcto para diferentes errores', () async {
      // Arrange
      const errorMessage = 'Error en la conexión con el servidor';
      final mockErrorResponse = DatosComprobanteGenericErrorResponse(statusCode: 0, errorMessage: errorMessage);

      when(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).thenAnswer((_) async => mockErrorResponse);

      // Act & Assert
      expect(
        () => repository.obtenerComprobante(testIdBoletaPagada),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', 'Exception: $errorMessage')),
      );
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
    });

    test('debería lanzar Exception con el mensaje de error 500', () async {
      // Arrange
      const errorMessage = 'Error interno del servidor';
      final mockErrorResponse = DatosComprobanteGenericErrorResponse(statusCode: 500, errorMessage: errorMessage);

      when(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).thenAnswer((_) async => mockErrorResponse);

      // Act & Assert
      expect(
        () => repository.obtenerComprobante(testIdBoletaPagada),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains(errorMessage))),
      );
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
    });

    test('debería llamar al data source remoto con el parámetro idBoletaPagada correcto', () async {
      // Arrange
      const differentId = 999;
      final mockSuccessResponse = DatosComprobanteSuccessResponse(
        statusCode: 200,
        id: 1,
        fecha: '2025-10-26',
        importe: '100.00',
        boletasPagadas: [],
      );

      when(mockRemoteDataSource.obtenerDatosComprobante(differentId)).thenAnswer((_) async => mockSuccessResponse);

      // Act
      await repository.obtenerComprobante(differentId);

      // Assert
      verify(mockRemoteDataSource.obtenerDatosComprobante(differentId)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('no debería llamar al data source local al obtener comprobante', () async {
      // Arrange
      final mockSuccessResponse = DatosComprobanteSuccessResponse(
        statusCode: 200,
        id: 1,
        fecha: '2025-10-26',
        importe: '100.00',
        boletasPagadas: [],
      );

      when(
        mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada),
      ).thenAnswer((_) async => mockSuccessResponse);

      // Act
      await repository.obtenerComprobante(testIdBoletaPagada);

      // Assert
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
      verifyZeroInteractions(mockLocalDataSource);
    });

    test('debería propagar la excepción cuando el data source remoto lanza una excepción', () async {
      // Arrange
      final testException = Exception('Network error');
      when(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).thenThrow(testException);

      // Act & Assert
      expect(() => repository.obtenerComprobante(testIdBoletaPagada), throwsA(testException));
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
    });

    test('debería manejar una lista vacía de boletasPagadas', () async {
      // Arrange
      final mockSuccessResponse = DatosComprobanteSuccessResponse(
        statusCode: 200,
        id: 1,
        fecha: '2025-10-26',
        importe: '0.00',
        boletasPagadas: [],
        comprobanteLink: 'https://example.com/empty.pdf',
        metodoPago: 'Efectivo',
      );

      when(
        mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada),
      ).thenAnswer((_) async => mockSuccessResponse);

      // Act
      final result = await repository.obtenerComprobante(testIdBoletaPagada);

      // Assert
      expect(result.boletasPagadas, isEmpty);
      expect(result.id, 1);
      expect(result.importe, '0.00');
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
    });

    test('debería manejar múltiples boletas con montos organismos complejos', () async {
      // Arrange
      final mockSuccessResponse = DatosComprobanteSuccessResponse(
        statusCode: 200,
        id: 1,
        fecha: '2025-10-26',
        importe: '5000.00',
        boletasPagadas: [
          (
            id: 1,
            importe: '2000.00',
            caratula: 'Boleta 1',
            mvc: 'MVC-1',
            tipoJuicio: 'Civil',
            montosOrganismos: [
              (circunscripcion: 1, organismo: 'Org 1', monto: 1000.0),
              (circunscripcion: 2, organismo: 'Org 2', monto: 1000.0),
            ],
          ),
          (
            id: 2,
            importe: '3000.00',
            caratula: 'Boleta 2',
            mvc: 'MVC-2',
            tipoJuicio: 'Penal',
            montosOrganismos: [
              (circunscripcion: 1, organismo: 'Org 1', monto: 1500.0),
              (circunscripcion: 2, organismo: 'Org 2', monto: 1500.0),
            ],
          ),
        ],
      );

      when(
        mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada),
      ).thenAnswer((_) async => mockSuccessResponse);

      // Act
      final result = await repository.obtenerComprobante(testIdBoletaPagada);

      // Assert
      expect(result.boletasPagadas.length, 2);
      expect(result.boletasPagadas[0].montosOrganismos?.length, 2);
      expect(result.boletasPagadas[1].montosOrganismos?.length, 2);
      expect(result.boletasPagadas[0].montosOrganismos?[0].monto, 1000.0);
      expect(result.boletasPagadas[1].montosOrganismos?[1].organismo, 'Org 2');
      verify(mockRemoteDataSource.obtenerDatosComprobante(testIdBoletaPagada)).called(1);
    });
  });
}

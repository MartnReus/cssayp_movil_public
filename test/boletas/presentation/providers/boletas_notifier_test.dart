import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';

@GenerateNiceMocks([
  MockSpec<ObtenerHistorialBoletasUseCase>(),
  MockSpec<GenerarBoletaInicioUseCase>(),
  MockSpec<GenerarBoletaFinalizacionUseCase>(),
  MockSpec<BuscarBoletasInicioPagadasUseCase>(),
  MockSpec<BoletasLocalDataSource>(),
])
import 'boletas_notifier_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoletasNotifier - Use Cases', () {
    late MockObtenerHistorialBoletasUseCase mockObtenerHistorialBoletasUseCase;
    late MockGenerarBoletaInicioUseCase mockGenerarBoletaInicioUseCase;
    late MockGenerarBoletaFinalizacionUseCase mockGenerarBoletaFinalizacionUseCase;
    late MockBuscarBoletasInicioPagadasUseCase mockBuscarBoletasInicioPagadasUseCase;
    late MockBoletasLocalDataSource mockBoletasLocalDataSource;

    setUp(() {
      mockObtenerHistorialBoletasUseCase = MockObtenerHistorialBoletasUseCase();
      mockGenerarBoletaInicioUseCase = MockGenerarBoletaInicioUseCase();
      mockGenerarBoletaFinalizacionUseCase = MockGenerarBoletaFinalizacionUseCase();
      mockBuscarBoletasInicioPagadasUseCase = MockBuscarBoletasInicioPagadasUseCase();
      mockBoletasLocalDataSource = MockBoletasLocalDataSource();
    });

    tearDown(() {
      reset(mockObtenerHistorialBoletasUseCase);
      reset(mockGenerarBoletaInicioUseCase);
      reset(mockGenerarBoletaFinalizacionUseCase);
      reset(mockBuscarBoletasInicioPagadasUseCase);
      reset(mockBoletasLocalDataSource);
    });

    test('ObtenerHistorialBoletasUseCase debería ejecutarse correctamente', () async {
      // Arrange
      when(mockObtenerHistorialBoletasUseCase.execute(page: 1)).thenAnswer(
        (_) async => HistorialBoletasSuccessResponse(
          statusCode: 200,
          boletas: [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
          perPage: 10,
          nextPageUrl: null,
          prevPageUrl: null,
        ),
      );

      // Act
      final result = await mockObtenerHistorialBoletasUseCase.execute(page: 1);

      // Assert
      expect(result, isA<HistorialBoletasSuccessResponse>());
      expect(result.statusCode, 200);
      expect(result.currentPage, 1);
      verify(mockObtenerHistorialBoletasUseCase.execute(page: 1)).called(1);
    });

    test('ObtenerHistorialBoletasUseCase debería manejar errores correctamente', () async {
      // Arrange
      when(mockObtenerHistorialBoletasUseCase.execute(page: 1)).thenThrow(Exception('Error de red'));

      // Act & Assert
      expect(() => mockObtenerHistorialBoletasUseCase.execute(page: 1), throwsA(isA<Exception>()));

      verify(mockObtenerHistorialBoletasUseCase.execute(page: 1)).called(1);
    });

    test('GenerarBoletaInicioUseCase debería ejecutarse correctamente', () async {
      // Arrange
      final mockBoleta = BoletaEntity(
        id: 1,
        tipo: BoletaTipo.inicio,
        monto: 100.0,
        fechaImpresion: DateTime.now(),
        fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
        codBarra: '123456',
        caratula: 'Test Caratula',
      );

      when(
        mockGenerarBoletaInicioUseCase.execute(caratula: 'Test Caratula', monto: 100.0),
      ).thenAnswer((_) async => mockBoleta);

      // Act
      final result = await mockGenerarBoletaInicioUseCase.execute(caratula: 'Test Caratula', monto: 100.0);

      // Assert
      expect(result, mockBoleta);
      expect(result.id, 1);
      expect(result.tipo, BoletaTipo.inicio);
      verify(mockGenerarBoletaInicioUseCase.execute(caratula: 'Test Caratula', monto: 100.0)).called(1);
    });

    test('GenerarBoletaInicioUseCase debería manejar errores correctamente', () async {
      // Arrange
      when(
        mockGenerarBoletaInicioUseCase.execute(caratula: 'Test Caratula', monto: 100.0),
      ).thenThrow(Exception('Error al generar boleta'));

      // Act & Assert
      expect(
        () => mockGenerarBoletaInicioUseCase.execute(caratula: 'Test Caratula', monto: 100.0),
        throwsA(isA<Exception>()),
      );

      verify(mockGenerarBoletaInicioUseCase.execute(caratula: 'Test Caratula', monto: 100.0)).called(1);
    });

    test('GenerarBoletaFinalizacionUseCase debería ejecutarse correctamente', () async {
      // Arrange
      final mockBoleta = BoletaEntity(
        id: 2,
        tipo: BoletaTipo.finalizacion,
        monto: 200.0,
        fechaImpresion: DateTime.now(),
        fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
        codBarra: '789012',
        caratula: 'Test Caratula Fin',
      );

      when(
        mockGenerarBoletaFinalizacionUseCase.execute(
          idBoletaInicio: 1,
          monto: 200.0,
          fechaRegulacion: anyNamed('fechaRegulacion'),
          honorarios: 50.0,
          caratula: 'Test Caratula Fin',
          cantidadJus: 5.0,
          valorJus: 10.0,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).thenAnswer((_) async => mockBoleta);

      // Act
      final result = await mockGenerarBoletaFinalizacionUseCase.execute(
        idBoletaInicio: 1,
        monto: 200.0,
        fechaRegulacion: DateTime.now(),
        honorarios: 50.0,
        caratula: 'Test Caratula Fin',
        cantidadJus: 5.0,
        valorJus: 10.0,
        nroExpediente: null,
        anioExpediente: null,
        cuij: null,
      );

      // Assert
      expect(result, mockBoleta);
      expect(result.id, 2);
      expect(result.tipo, BoletaTipo.finalizacion);
      verify(
        mockGenerarBoletaFinalizacionUseCase.execute(
          idBoletaInicio: 1,
          monto: 200.0,
          fechaRegulacion: anyNamed('fechaRegulacion'),
          honorarios: 50.0,
          caratula: 'Test Caratula Fin',
          cantidadJus: 5.0,
          valorJus: 10.0,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).called(1);
    });

    test('GenerarBoletaFinalizacionUseCase debería manejar errores correctamente', () async {
      // Arrange
      when(
        mockGenerarBoletaFinalizacionUseCase.execute(
          idBoletaInicio: 1,
          monto: 200.0,
          fechaRegulacion: anyNamed('fechaRegulacion'),
          honorarios: 50.0,
          caratula: 'Test Caratula Fin',
          cantidadJus: 5.0,
          valorJus: 10.0,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).thenThrow(Exception('Error al generar boleta de finalización'));

      // Act & Assert
      expect(
        () => mockGenerarBoletaFinalizacionUseCase.execute(
          idBoletaInicio: 1,
          monto: 200.0,
          fechaRegulacion: DateTime.now(),
          honorarios: 50.0,
          caratula: 'Test Caratula Fin',
          cantidadJus: 5.0,
          valorJus: 10.0,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
        throwsA(isA<Exception>()),
      );

      verify(
        mockGenerarBoletaFinalizacionUseCase.execute(
          idBoletaInicio: 1,
          monto: 200.0,
          fechaRegulacion: anyNamed('fechaRegulacion'),
          honorarios: 50.0,
          caratula: 'Test Caratula Fin',
          cantidadJus: 5.0,
          valorJus: 10.0,
          nroExpediente: null,
          anioExpediente: null,
          cuij: null,
        ),
      ).called(1);
    });

    test('BuscarBoletasInicioPagadasUseCase debería ejecutarse correctamente', () async {
      // Arrange
      when(mockBuscarBoletasInicioPagadasUseCase.execute(page: 1, caratulaBuscada: 'Test')).thenAnswer(
        (_) async =>
            PaginatedResponseModel(statusCode: 200, data: [], currentPage: 1, lastPage: 1, total: 0, perPage: 10),
      );

      // Act
      final result = await mockBuscarBoletasInicioPagadasUseCase.execute(page: 1, caratulaBuscada: 'Test');

      // Assert
      expect(result, isA<PaginatedResponseModel>());
      expect(result.statusCode, 200);
      expect(result.currentPage, 1);
      verify(mockBuscarBoletasInicioPagadasUseCase.execute(page: 1, caratulaBuscada: 'Test')).called(1);
    });

    test('BuscarBoletasInicioPagadasUseCase debería manejar errores correctamente', () async {
      // Arrange
      when(
        mockBuscarBoletasInicioPagadasUseCase.execute(page: 1, caratulaBuscada: 'Test'),
      ).thenThrow(Exception('Error al buscar boletas'));

      // Act & Assert
      expect(
        () => mockBuscarBoletasInicioPagadasUseCase.execute(page: 1, caratulaBuscada: 'Test'),
        throwsA(isA<Exception>()),
      );

      verify(mockBuscarBoletasInicioPagadasUseCase.execute(page: 1, caratulaBuscada: 'Test')).called(1);
    });

    test('BoletasLocalDataSource debería manejar cache correctamente', () async {
      // Arrange
      final mockBoletas = [
        BoletaEntity(
          id: 1,
          tipo: BoletaTipo.inicio,
          monto: 100.0,
          fechaImpresion: DateTime.now(),
          fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
          codBarra: '123456',
          caratula: 'Test Caratula',
        ),
      ];

      when(mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0)).thenAnswer((_) async => mockBoletas);
      when(mockBoletasLocalDataSource.obtenerConteoBoletasLocales()).thenAnswer((_) async => 1);
      when(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).thenAnswer((_) async => DateTime.now());
      when(mockBoletasLocalDataSource.tieneBoletasEnCache()).thenAnswer((_) async => true);

      // Act
      final boletas = await mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0);
      final total = await mockBoletasLocalDataSource.obtenerConteoBoletasLocales();
      final lastSync = await mockBoletasLocalDataSource.obtenerUltimaSincronizacion();
      final hasCache = await mockBoletasLocalDataSource.tieneBoletasEnCache();

      // Assert
      expect(boletas, mockBoletas);
      expect(total, 1);
      expect(lastSync, isA<DateTime>());
      expect(hasCache, true);

      verify(mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0)).called(1);
      verify(mockBoletasLocalDataSource.obtenerConteoBoletasLocales()).called(1);
      verify(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).called(1);
      verify(mockBoletasLocalDataSource.tieneBoletasEnCache()).called(1);
    });

    test('BoletasLocalDataSource debería manejar cache vacío correctamente', () async {
      // Arrange
      when(mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0)).thenAnswer((_) async => []);
      when(mockBoletasLocalDataSource.obtenerConteoBoletasLocales()).thenAnswer((_) async => 0);
      when(mockBoletasLocalDataSource.obtenerUltimaSincronizacion()).thenAnswer((_) async => DateTime.now());
      when(mockBoletasLocalDataSource.tieneBoletasEnCache()).thenAnswer((_) async => false);

      // Act
      final boletas = await mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0);
      final total = await mockBoletasLocalDataSource.obtenerConteoBoletasLocales();
      final hasCache = await mockBoletasLocalDataSource.tieneBoletasEnCache();

      // Assert
      expect(boletas, isEmpty);
      expect(total, 0);
      expect(hasCache, false);

      verify(mockBoletasLocalDataSource.obtenerBoletasLocales(limit: 10, offset: 0)).called(1);
      verify(mockBoletasLocalDataSource.obtenerConteoBoletasLocales()).called(1);
      verify(mockBoletasLocalDataSource.tieneBoletasEnCache()).called(1);
    });
  });

  group('BoletasNotifier - Estados y validaciones', () {
    test('BoletasState debería tener valores por defecto correctos', () {
      // Act
      const state = BoletasState();

      // Assert
      expect(state.boletas, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.currentPage, 1);
      expect(state.lastPage, 1);
      expect(state.total, 0);
      expect(state.perPage, 10);
      expect(state.hasNextPage, false);
      expect(state.hasPreviousPage, false);
      expect(state.isOfflineData, false);
      expect(state.lastSyncTime, isNull);
    });

    test('BoletasState copyWith debería actualizar solo los campos especificados', () {
      // Arrange
      const initialState = BoletasState();

      // Act
      final newState = initialState.copyWith(isLoading: true, currentPage: 2, total: 50);

      // Assert
      expect(newState.boletas, initialState.boletas);
      expect(newState.isLoading, true);
      expect(newState.error, initialState.error);
      expect(newState.currentPage, 2);
      expect(newState.lastPage, initialState.lastPage);
      expect(newState.total, 50);
      expect(newState.perPage, initialState.perPage);
      expect(newState.hasNextPage, initialState.hasNextPage);
      expect(newState.hasPreviousPage, initialState.hasPreviousPage);
      expect(newState.isOfflineData, initialState.isOfflineData);
      expect(newState.lastSyncTime, initialState.lastSyncTime);
    });

    test('BoletasState debería manejar listas de boletas correctamente', () {
      // Arrange
      final mockBoletas = [
        BoletaEntity(
          id: 1,
          tipo: BoletaTipo.inicio,
          monto: 100.0,
          fechaImpresion: DateTime.now(),
          fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
          codBarra: '123456',
          caratula: 'Test Caratula 1',
        ),
        BoletaEntity(
          id: 2,
          tipo: BoletaTipo.finalizacion,
          monto: 200.0,
          fechaImpresion: DateTime.now(),
          fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
          codBarra: '789012',
          caratula: 'Test Caratula 2',
        ),
      ];

      // Act
      final state = BoletasState(boletas: mockBoletas, total: 2);

      // Assert
      expect(state.boletas, mockBoletas);
      expect(state.boletas.length, 2);
      expect(state.total, 2);
      expect(state.boletas[0].id, 1);
      expect(state.boletas[0].tipo, BoletaTipo.inicio);
      expect(state.boletas[1].id, 2);
      expect(state.boletas[1].tipo, BoletaTipo.finalizacion);
    });
  });
}

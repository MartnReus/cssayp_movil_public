import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cssayp_movil/boletas/data/datasources/boletas_local_data_source.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_entity.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_tipo.dart';
import 'package:cssayp_movil/shared/database/database_helper.dart';

import 'boletas_local_data_source_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late BoletasLocalDataSource dataSource;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    dataSource = BoletasLocalDataSource(databaseHelper: mockDatabaseHelper);
  });

  group('BoletasLocalDataSource', () {
    group('guardarBoletas', () {
      test('debería llamar al database helper y transaction', () async {
        // Arrange
        final boletas = [
          BoletaEntity(
            id: 1,
            tipo: BoletaTipo.inicio,
            monto: 100.0,
            fechaImpresion: DateTime(2024, 1, 1),
            fechaVencimiento: DateTime(2024, 2, 1),
            caratula: 'Test Caratula 1',
          ),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.transaction(any)).thenAnswer((_) async {
          // Simular la ejecución del callback
          return null;
        });

        // Act
        await dataSource.guardarBoletas(boletas);

        // Assert
        verify(mockDatabaseHelper.database).called(1);
        verify(mockDatabase.transaction(any)).called(1);
      });

      test('debería manejar lista vacía de boletas', () async {
        // Arrange
        final boletas = <BoletaEntity>[];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.transaction(any)).thenAnswer((_) async {
          return null;
        });

        // Act
        await dataSource.guardarBoletas(boletas);

        // Assert
        verify(mockDatabaseHelper.database).called(1);
        verify(mockDatabase.transaction(any)).called(1);
      });
    });

    group('obtenerBoletasLocales', () {
      test('debería obtener boletas sin filtros', () async {
        // Arrange
        final mockResult = [
          {
            'id': 1,
            'tipo': 'inicio',
            'monto': 100.0,
            'fecha_impresion': '2024-01-01T00:00:00.000Z',
            'fecha_vencimiento': '2024-02-01T00:00:00.000Z',
            'cod_barra': null,
            'id_boleta_asociada': null,
            'fecha_pago': null,
            'importe_pago': null,
            'caratula': 'Test Caratula',
            'nro_expediente': null,
            'anio_expediente': null,
            'cuij': null,
            'gastos_administrativos': null,
          },
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerBoletasLocales();

        // Assert
        expect(result, isA<List<BoletaEntity>>());
        expect(result.length, 1);
        expect(result.first.id, 1);
        expect(result.first.tipo, BoletaTipo.inicio);
        expect(result.first.monto, 100.0);
        expect(result.first.caratula, 'Test Caratula');

        verify(mockDatabase.rawQuery(any, any)).called(1);
      });

      test('debería obtener boletas con filtro de carátula', () async {
        // Arrange
        final mockResult = [
          {
            'id': 1,
            'tipo': 'inicio',
            'monto': 100.0,
            'fecha_impresion': '2024-01-01T00:00:00.000Z',
            'fecha_vencimiento': '2024-02-01T00:00:00.000Z',
            'cod_barra': null,
            'id_boleta_asociada': null,
            'fecha_pago': null,
            'importe_pago': null,
            'caratula': 'Test Caratula',
            'nro_expediente': null,
            'anio_expediente': null,
            'cuij': null,
            'gastos_administrativos': null,
          },
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerBoletasLocales(caratulaFiltro: 'Test');

        // Assert
        expect(result, isA<List<BoletaEntity>>());
        expect(result.length, 1);

        verify(mockDatabase.rawQuery(any, any)).called(1);
      });

      test('debería obtener boletas con límite', () async {
        // Arrange
        final mockResult = <Map<String, dynamic>>[];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        await dataSource.obtenerBoletasLocales(limit: 10);

        // Assert
        verify(mockDatabase.rawQuery(any, any)).called(1);
      });

      test('debería obtener boletas con límite y offset', () async {
        // Arrange
        final mockResult = <Map<String, dynamic>>[];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        await dataSource.obtenerBoletasLocales(limit: 10, offset: 20);

        // Assert
        verify(mockDatabase.rawQuery(any, any)).called(1);
      });

      test('debería obtener boletas con filtro de carátula, límite y offset', () async {
        // Arrange
        final mockResult = <Map<String, dynamic>>[];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        await dataSource.obtenerBoletasLocales(caratulaFiltro: 'Test', limit: 5, offset: 10);

        // Assert
        verify(mockDatabase.rawQuery(any, any)).called(1);
      });

      test('debería manejar filtro de carátula vacío', () async {
        // Arrange
        final mockResult = <Map<String, dynamic>>[];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        await dataSource.obtenerBoletasLocales(caratulaFiltro: '');

        // Assert
        verify(mockDatabase.rawQuery(any, any)).called(1);
      });
    });

    group('obtenerConteoBoletasLocales', () {
      test('debería obtener conteo sin filtros', () async {
        // Arrange
        final mockResult = [
          {'count': 5},
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerConteoBoletasLocales();

        // Assert
        expect(result, 5);

        verify(mockDatabase.rawQuery(any, any)).called(1);
      });

      test('debería obtener conteo con filtro de carátula', () async {
        // Arrange
        final mockResult = [
          {'count': 2},
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerConteoBoletasLocales(caratulaFiltro: 'Test');

        // Assert
        expect(result, 2);

        verify(mockDatabase.rawQuery(any, any)).called(1);
      });

      test('debería retornar 0 cuando no hay resultados', () async {
        // Arrange
        final mockResult = <Map<String, dynamic>>[];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerConteoBoletasLocales();

        // Assert
        expect(result, 0);
      });

      test('debería manejar filtro de carátula vacío', () async {
        // Arrange
        final mockResult = [
          {'count': 3},
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerConteoBoletasLocales(caratulaFiltro: '');

        // Assert
        expect(result, 3);

        verify(mockDatabase.rawQuery(any, any)).called(1);
      });
    });

    group('limpiarCache', () {
      test('debería limpiar todas las boletas del cache', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete(any)).thenAnswer((_) async => 5);

        // Act
        await dataSource.limpiarCache();

        // Assert
        verify(mockDatabaseHelper.database).called(1);
        verify(mockDatabase.delete('boletas_historial')).called(1);
      });
    });

    group('obtenerUltimaSincronizacion', () {
      test('debería obtener la última fecha de sincronización', () async {
        // Arrange
        final mockResult = [
          {'ultima_sync': '2024-01-15T10:30:00.000Z'},
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerUltimaSincronizacion();

        // Assert
        expect(result, isA<DateTime>());
        expect(result, DateTime.parse('2024-01-15T10:30:00.000Z'));

        verify(mockDatabase.rawQuery(any)).called(1);
      });

      test('debería retornar null cuando no hay fechas de sincronización', () async {
        // Arrange
        final mockResult = [
          {'ultima_sync': null},
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerUltimaSincronizacion();

        // Assert
        expect(result, isNull);
      });

      test('debería retornar null cuando no hay resultados', () async {
        // Arrange
        final mockResult = <Map<String, dynamic>>[];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any)).thenAnswer((_) async => mockResult);

        // Act
        final result = await dataSource.obtenerUltimaSincronizacion();

        // Assert
        expect(result, isNull);
      });
    });

    group('tieneBoletasEnCache', () {
      test('debería retornar true cuando hay boletas en cache', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer(
          (_) async => [
            {'count': 3},
          ],
        );

        // Act
        final result = await dataSource.tieneBoletasEnCache();

        // Assert
        expect(result, true);
      });

      test('debería retornar false cuando no hay boletas en cache', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer(
          (_) async => [
            {'count': 0},
          ],
        );

        // Act
        final result = await dataSource.tieneBoletasEnCache();

        // Assert
        expect(result, false);
      });
    });

    group('boletaToMap', () {
      test('debería convertir BoletaEntity a Map correctamente', () {
        // Arrange
        final boleta = BoletaEntity(
          id: 1,
          tipo: BoletaTipo.inicio,
          monto: 150.75,
          fechaImpresion: DateTime(2024, 1, 15, 10, 30),
          fechaVencimiento: DateTime(2024, 2, 15, 10, 30),
          caratula: 'Test Caratula',
          codBarra: '123456789',
          idBoletaAsociada: 2,
          fechaPago: DateTime(2024, 1, 20, 15, 45),
          importePago: 150.75,
          nroExpediente: 12345,
          anioExpediente: 2024,
          cuij: 98765,
          gastosAdministrativos: 25.50,
        );

        // Act
        final result = dataSource.boletaToMap(boleta);

        // Assert
        expect(result['id'], 1);
        expect(result['tipo'], 'inicio');
        expect(result['monto'], 150.75);
        expect(result['fecha_impresion'], '2024-01-15T10:30:00.000');
        expect(result['fecha_vencimiento'], '2024-02-15T10:30:00.000');
        expect(result['cod_barra'], '123456789');
        expect(result['id_boleta_asociada'], 2);
        expect(result['fecha_pago'], '2024-01-20T15:45:00.000');
        expect(result['importe_pago'], 150.75);
        expect(result['caratula'], 'Test Caratula');
        expect(result['nro_expediente'], 12345);
        expect(result['anio_expediente'], 2024);
        expect(result['cuij'], 98765);
        expect(result['gastos_administrativos'], 25.50);
        expect(result['fecha_sync'], isA<String>());
        expect(result['created_at'], isA<String>());
      });

      test('debería manejar valores null correctamente', () {
        // Arrange
        final boleta = BoletaEntity(
          id: 1,
          tipo: BoletaTipo.finalizacion,
          monto: 100.0,
          fechaImpresion: DateTime(2024, 1, 1),
          fechaVencimiento: DateTime(2024, 2, 1),
          caratula: 'Test Caratula',
        );

        // Act
        final result = dataSource.boletaToMap(boleta);

        // Assert
        expect(result['cod_barra'], isNull);
        expect(result['id_boleta_asociada'], isNull);
        expect(result['fecha_pago'], isNull);
        expect(result['importe_pago'], isNull);
        expect(result['nro_expediente'], isNull);
        expect(result['anio_expediente'], isNull);
        expect(result['cuij'], isNull);
        expect(result['gastos_administrativos'], isNull);
      });
    });

    group('mapToBoleta', () {
      test('debería convertir Map a BoletaEntity correctamente', () {
        // Arrange
        final map = {
          'id': 1,
          'tipo': 'inicio',
          'monto': 150.75,
          'fecha_impresion': '2024-01-15T10:30:00.000Z',
          'fecha_vencimiento': '2024-02-15T10:30:00.000Z',
          'cod_barra': '123456789',
          'id_boleta_asociada': 2,
          'fecha_pago': '2024-01-20T15:45:00.000Z',
          'importe_pago': 150.75,
          'caratula': 'Test Caratula',
          'nro_expediente': 12345,
          'anio_expediente': 2024,
          'cuij': 98765,
          'gastos_administrativos': 25.50,
        };

        // Act
        final result = dataSource.mapToBoleta(map);

        // Assert
        expect(result.id, 1);
        expect(result.tipo, BoletaTipo.inicio);
        expect(result.monto, 150.75);
        expect(result.fechaImpresion, DateTime.parse('2024-01-15T10:30:00.000Z'));
        expect(result.fechaVencimiento, DateTime.parse('2024-02-15T10:30:00.000Z'));
        expect(result.codBarra, '123456789');
        expect(result.idBoletaAsociada, 2);
        expect(result.fechaPago, DateTime.parse('2024-01-20T15:45:00.000Z'));
        expect(result.importePago, 150.75);
        expect(result.caratula, 'Test Caratula');
        expect(result.nroExpediente, 12345);
        expect(result.anioExpediente, 2024);
        expect(result.cuij, 98765);
        expect(result.gastosAdministrativos, 25.50);
      });

      test('debería manejar valores null correctamente', () {
        // Arrange
        final map = {
          'id': 1,
          'tipo': 'finalizacion',
          'monto': 100.0,
          'fecha_impresion': '2024-01-01T00:00:00.000Z',
          'fecha_vencimiento': '2024-02-01T00:00:00.000Z',
          'cod_barra': null,
          'id_boleta_asociada': null,
          'fecha_pago': null,
          'importe_pago': null,
          'caratula': 'Test Caratula',
          'nro_expediente': null,
          'anio_expediente': null,
          'cuij': null,
          'gastos_administrativos': null,
        };

        // Act
        final result = dataSource.mapToBoleta(map);

        // Assert
        expect(result.codBarra, isNull);
        expect(result.idBoletaAsociada, isNull);
        expect(result.fechaPago, isNull);
        expect(result.importePago, isNull);
        expect(result.nroExpediente, isNull);
        expect(result.anioExpediente, isNull);
        expect(result.cuij, isNull);
        expect(result.gastosAdministrativos, isNull);
      });
    });
  });
}

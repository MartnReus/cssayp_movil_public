import 'package:flutter_test/flutter_test.dart';

import 'package:cssayp_movil/boletas/boletas.dart';

void main() {
  group('BoletasState', () {
    test('copyWith debería crear una nueva instancia con los valores actualizados', () {
      // Arrange
      const initialState = BoletasState();
      final fecha = DateTime.now();

      // Act
      final newState = initialState.copyWith(
        boletas: [
          BoletaEntity(
            id: 1,
            tipo: BoletaTipo.inicio,
            monto: 100.0,
            fechaImpresion: fecha,
            fechaVencimiento: fecha.add(const Duration(days: 30)),
            codBarra: '123456',
            caratula: 'Test Caratula',
          ),
        ],
        isLoading: true,
        error: 'Test error',
        currentPage: 2,
        lastPage: 5,
        total: 50,
        perPage: 10,
        hasNextPage: true,
        hasPreviousPage: true,
        isOfflineData: true,
        lastSyncTime: fecha,
      );

      // Assert
      expect(newState.boletas.length, 1);
      expect(newState.boletas.first.id, 1);
      expect(newState.isLoading, true);
      expect(newState.error, 'Test error');
      expect(newState.currentPage, 2);
      expect(newState.lastPage, 5);
      expect(newState.total, 50);
      expect(newState.perPage, 10);
      expect(newState.hasNextPage, true);
      expect(newState.hasPreviousPage, true);
      expect(newState.isOfflineData, true);
      expect(newState.lastSyncTime, fecha);
    });

    test('copyWith debería mantener los valores originales cuando no se especifican', () {
      // Arrange
      const initialState = BoletasState(currentPage: 3, total: 100);

      // Act
      final newState = initialState.copyWith(isLoading: true);

      // Assert
      expect(newState.currentPage, 3); // Valor original mantenido
      expect(newState.total, 100); // Valor original mantenido
      expect(newState.isLoading, true); // Valor actualizado
      expect(newState.boletas, isEmpty); // Valor por defecto
    });

    test('copyWith debería permitir actualizar solo algunos campos', () {
      // Arrange
      const initialState = BoletasState(
        currentPage: 1,
        total: 10,
        perPage: 10,
        hasNextPage: false,
        hasPreviousPage: false,
      );

      // Act
      final newState = initialState.copyWith(currentPage: 2, hasNextPage: true, hasPreviousPage: true);

      // Assert
      expect(newState.currentPage, 2); // Actualizado
      expect(newState.total, 10); // Mantenido
      expect(newState.perPage, 10); // Mantenido
      expect(newState.hasNextPage, true); // Actualizado
      expect(newState.hasPreviousPage, true); // Actualizado
    });

    test('copyWith debería manejar valores null correctamente', () {
      // Arrange
      const initialState = BoletasState(error: 'Error inicial');

      // Act
      final newState = initialState.copyWith(lastSyncTime: DateTime.now());

      // Assert
      expect(newState.error, 'Error inicial'); // Mantenido
      expect(newState.lastSyncTime, isNotNull); // Actualizado a valor
    });
  });

  group('BoletaInicioDataState', () {
    test('copyWith debería crear una nueva instancia con los valores actualizados', () {
      // Arrange
      const initialState = BoletaInicioDataState();

      // Act
      final newState = initialState.copyWith(
        actor: 'Juan Pérez',
        demandado: 'María García',
        causa: 'Daños y perjuicios',
      );

      // Assert
      expect(newState.actor, 'Juan Pérez');
      expect(newState.demandado, 'María García');
      expect(newState.causa, 'Daños y perjuicios');
      expect(newState.isValid, true);
    });

    test('isValid debería ser false cuando faltan campos', () {
      // Arrange
      const state = BoletaInicioDataState(actor: 'Juan Pérez');

      // Assert
      expect(state.isValid, false);
    });

    test('isValid debería ser true cuando todos los campos están presentes', () {
      // Arrange
      const state = BoletaInicioDataState(actor: 'Juan Pérez', demandado: 'María García', causa: 'Daños y perjuicios');

      // Assert
      expect(state.isValid, true);
    });

    test('copyWith debería mantener valores originales cuando no se especifican', () {
      // Arrange
      const initialState = BoletaInicioDataState(actor: 'Actor Original', demandado: 'Demandado Original');

      // Act
      final newState = initialState.copyWith(causa: 'Nueva Causa');

      // Assert
      expect(newState.actor, 'Actor Original'); // Mantenido
      expect(newState.demandado, 'Demandado Original'); // Mantenido
      expect(newState.causa, 'Nueva Causa'); // Actualizado
      expect(newState.isValid, true); // Ahora es válido
    });
  });

  group('BoletaFinDataState', () {
    test('copyWith debería crear una nueva instancia con los valores actualizados', () {
      // Arrange
      const initialState = BoletaFinDataState();
      final fecha = DateTime.now();

      // Act
      final newState = initialState.copyWith(
        idBoletaInicio: 123,
        caratula: 'Test Caratula',
        expediente: 456,
        anio: 2024,
        cuij: 789,
        fechaRegulacion: fecha,
        cantidadJus: 5.0,
        valorJus: 10.0,
        honorarios: 50.0,
        montoValido: 200.0,
      );

      // Assert
      expect(newState.idBoletaInicio, 123);
      expect(newState.caratula, 'Test Caratula');
      expect(newState.expediente, 456);
      expect(newState.anio, 2024);
      expect(newState.cuij, 789);
      expect(newState.fechaRegulacion, fecha);
      expect(newState.cantidadJus, 5.0);
      expect(newState.valorJus, 10.0);
      expect(newState.honorarios, 50.0);
      expect(newState.montoValido, 200.0);
      expect(newState.isValid, true);
    });

    test('isValid debería ser false cuando faltan campos requeridos', () {
      // Arrange
      const state = BoletaFinDataState(caratula: 'Test Caratula');

      // Assert
      expect(state.isValid, false);
    });

    test('isValid debería ser true cuando los campos requeridos están presentes', () {
      // Arrange
      final state = BoletaFinDataState(caratula: 'Test Caratula', fechaRegulacion: DateTime.now(), cantidadJus: 5.0);

      // Assert
      expect(state.isValid, true);
    });

    test('copyWith debería mantener valores originales cuando no se especifican', () {
      // Arrange
      const initialState = BoletaFinDataState(idBoletaInicio: 123, caratula: 'Caratula Original', expediente: 456);

      // Act
      final newState = initialState.copyWith(fechaRegulacion: DateTime.now(), cantidadJus: 5.0);

      // Assert
      expect(newState.idBoletaInicio, 123); // Mantenido
      expect(newState.caratula, 'Caratula Original'); // Mantenido
      expect(newState.expediente, 456); // Mantenido
      expect(newState.fechaRegulacion, isNotNull); // Actualizado
      expect(newState.cantidadJus, 5.0); // Actualizado
      expect(newState.isValid, true); // Ahora es válido
    });

    test('isValid debería ser false cuando solo tiene caratula', () {
      // Arrange
      const state = BoletaFinDataState(caratula: 'Solo Caratula');

      // Assert
      expect(state.isValid, false);
    });

    test('isValid debería ser false cuando solo tiene fechaRegulacion', () {
      // Arrange
      final state = BoletaFinDataState(fechaRegulacion: DateTime.now());

      // Assert
      expect(state.isValid, false);
    });

    test('isValid debería ser false cuando solo tiene cantidadJus', () {
      // Arrange
      const state = BoletaFinDataState(cantidadJus: 5.0);

      // Assert
      expect(state.isValid, false);
    });
  });
}

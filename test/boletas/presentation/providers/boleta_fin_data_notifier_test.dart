import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/boletas/boletas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoletaFinDataNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('El estado inicial debería ser vacío', () {
      // Act
      final state = container.read(boletaFinDataProvider);

      // Assert
      expect(state.idBoletaInicio, isNull);
      expect(state.caratula, isNull);
      expect(state.expediente, isNull);
      expect(state.anio, isNull);
      expect(state.cuij, isNull);
      expect(state.fechaRegulacion, isNull);
      expect(state.cantidadJus, isNull);
      expect(state.valorJus, isNull);
      expect(state.honorarios, isNull);
      expect(state.montoValido, isNull);
      expect(state.isValid, false);
    });

    test('updateIdBoletaInicio debería actualizar el ID correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateIdBoletaInicio(123);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.idBoletaInicio, 123);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateCaratula debería actualizar la carátula correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateCaratula('Test Caratula');

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.caratula, 'Test Caratula');
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateExpediente debería actualizar el expediente correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateExpediente(456);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.expediente, 456);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateAnio debería actualizar el año correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateAnio(2024);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.anio, 2024);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateCuij debería actualizar el CUIJ correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateCuij(789);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.cuij, 789);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateFechaRegulacion debería actualizar la fecha correctamente', () {
      // Arrange
      final fecha = DateTime.now();

      // Act
      container.read(boletaFinDataProvider.notifier).updateFechaRegulacion(fecha);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.fechaRegulacion, fecha);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateCantidadJus debería actualizar la cantidad correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateCantidadJus(5.0);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.cantidadJus, 5.0);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateValorJus debería actualizar el valor correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateValorJus(10.0);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.valorJus, 10.0);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateHonorarios debería actualizar los honorarios correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateHonorarios(50.0);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.honorarios, 50.0);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('updateMontoValido debería actualizar el monto válido correctamente', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateMontoValido(200.0);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.montoValido, 200.0);
      expect(state.isValid, false); // Aún no tiene todos los campos requeridos
    });

    test('isValid debería ser true cuando los campos requeridos están completos', () {
      // Act
      container.read(boletaFinDataProvider.notifier).updateCaratula('Test Caratula');
      container.read(boletaFinDataProvider.notifier).updateFechaRegulacion(DateTime.now());
      container.read(boletaFinDataProvider.notifier).updateCantidadJus(5.0);

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.caratula, 'Test Caratula');
      expect(state.fechaRegulacion, isNotNull);
      expect(state.cantidadJus, 5.0);
      expect(state.isValid, true);
    });

    test('reset debería limpiar todos los campos', () {
      // Arrange
      container.read(boletaFinDataProvider.notifier).updateIdBoletaInicio(123);
      container.read(boletaFinDataProvider.notifier).updateCaratula('Test Caratula');
      container.read(boletaFinDataProvider.notifier).updateFechaRegulacion(DateTime.now());
      container.read(boletaFinDataProvider.notifier).updateCantidadJus(5.0);

      // Act
      container.read(boletaFinDataProvider.notifier).reset();

      // Assert
      final state = container.read(boletaFinDataProvider);
      expect(state.idBoletaInicio, isNull);
      expect(state.caratula, isNull);
      expect(state.fechaRegulacion, isNull);
      expect(state.cantidadJus, isNull);
      expect(state.isValid, false);
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
  });
}

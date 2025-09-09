import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/boletas/boletas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoletaInicioDataNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('El estado inicial debería ser vacío', () {
      // Act
      final state = container.read(boletaInicioDataProvider);

      // Assert
      expect(state.actor, isNull);
      expect(state.demandado, isNull);
      expect(state.causa, isNull);
      expect(state.isValid, false);
    });

    test('updateActor debería actualizar el actor correctamente', () {
      // Act
      container.read(boletaInicioDataProvider.notifier).updateActor('Juan Pérez');

      // Assert
      final state = container.read(boletaInicioDataProvider);
      expect(state.actor, 'Juan Pérez');
      expect(state.isValid, false); // Aún no tiene todos los campos
    });

    test('updateDemandado debería actualizar el demandado correctamente', () {
      // Act
      container.read(boletaInicioDataProvider.notifier).updateDemandado('María García');

      // Assert
      final state = container.read(boletaInicioDataProvider);
      expect(state.demandado, 'María García');
      expect(state.isValid, false); // Aún no tiene todos los campos
    });

    test('updateCausa debería actualizar la causa correctamente', () {
      // Act
      container.read(boletaInicioDataProvider.notifier).updateCausa('Daños y perjuicios');

      // Assert
      final state = container.read(boletaInicioDataProvider);
      expect(state.causa, 'Daños y perjuicios');
      expect(state.isValid, false); // Aún no tiene todos los campos
    });

    test('isValid debería ser true cuando todos los campos están completos', () {
      // Act
      container.read(boletaInicioDataProvider.notifier).updateActor('Juan Pérez');
      container.read(boletaInicioDataProvider.notifier).updateDemandado('María García');
      container.read(boletaInicioDataProvider.notifier).updateCausa('Daños y perjuicios');

      // Assert
      final state = container.read(boletaInicioDataProvider);
      expect(state.actor, 'Juan Pérez');
      expect(state.demandado, 'María García');
      expect(state.causa, 'Daños y perjuicios');
      expect(state.isValid, true);
    });

    test('reset debería limpiar todos los campos', () {
      // Arrange
      container.read(boletaInicioDataProvider.notifier).updateActor('Juan Pérez');
      container.read(boletaInicioDataProvider.notifier).updateDemandado('María García');
      container.read(boletaInicioDataProvider.notifier).updateCausa('Daños y perjuicios');

      // Act
      container.read(boletaInicioDataProvider.notifier).reset();

      // Assert
      final state = container.read(boletaInicioDataProvider);
      expect(state.actor, isNull);
      expect(state.demandado, isNull);
      expect(state.causa, isNull);
      expect(state.isValid, false);
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
  });
}

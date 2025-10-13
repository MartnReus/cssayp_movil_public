import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cssayp_movil/boletas/boletas.dart';

@GenerateNiceMocks([MockSpec<ObtenerParametrosBoletaInicioUseCase>()])
import 'boleta_inicio_data_notifier_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoletaInicioDataNotifier', () {
    late ProviderContainer container;
    late MockObtenerParametrosBoletaInicioUseCase mockObtenerParametrosBoletaInicioUseCase;
    late ParametrosBoletaInicioEntity mockParametros;

    setUp(() {
      mockObtenerParametrosBoletaInicioUseCase = MockObtenerParametrosBoletaInicioUseCase();

      // Create mock entities for testing
      final mockTipoJuicio = TipoJuicioEntity(id: '1', descripcion: 'Test Tipo');
      final mockCircunscripcion = CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion');
      mockParametros = ParametrosBoletaInicioEntity(
        tiposJuicio: [mockTipoJuicio],
        circunscripciones: [mockCircunscripcion],
      );

      // Mock the use case to return our test data
      when(mockObtenerParametrosBoletaInicioUseCase.execute()).thenAnswer((_) async => mockParametros);

      // Create the ProviderContainer with overrides
      container = ProviderContainer(
        overrides: [
          obtenerParametrosBoletaInicioUseCaseProvider.overrideWith(
            (ref) => Future.value(mockObtenerParametrosBoletaInicioUseCase),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      reset(mockObtenerParametrosBoletaInicioUseCase);
    });

    test('El estado inicial debería ser vacío', () async {
      // Act
      await container.read(boletaInicioDataProvider.future);
      final state = container.read(boletaInicioDataProvider).value;

      // Assert
      expect(state, isNotNull);
      expect(state?.actor, isNull);
      expect(state?.demandado, isNull);
      expect(state?.causa, isNull);
      expect(state?.isValid, false);
    });

    test('updateActor debería actualizar el actor correctamente', () async {
      // Arrange
      await container.read(boletaInicioDataProvider.future);

      // Act
      container.read(boletaInicioDataProvider.notifier).updateActor('Juan Pérez');

      // Assert
      final state = container.read(boletaInicioDataProvider).value;
      expect(state?.actor, 'Juan Pérez');
      expect(state?.isValid, false); // Aún no tiene todos los campos
    });

    test('updateDemandado debería actualizar el demandado correctamente', () async {
      // Arrange
      await container.read(boletaInicioDataProvider.future);

      // Act
      container.read(boletaInicioDataProvider.notifier).updateDemandado('María García');

      // Assert
      final state = container.read(boletaInicioDataProvider).value;
      expect(state?.demandado, 'María García');
      expect(state?.isValid, false); // Aún no tiene todos los campos
    });

    test('updateCausa debería actualizar la causa correctamente', () async {
      // Arrange
      await container.read(boletaInicioDataProvider.future);

      // Act
      container.read(boletaInicioDataProvider.notifier).updateCausa('Daños y perjuicios');

      // Assert
      final state = container.read(boletaInicioDataProvider).value;
      expect(state?.causa, 'Daños y perjuicios');
      expect(state?.isValid, false); // Aún no tiene todos los campos
    });

    test('isValid debería ser true cuando todos los campos están completos', () async {
      // Arrange
      await container.read(boletaInicioDataProvider.future);
      final mockTipoJuicio = mockParametros.tiposJuicio.first;
      final mockCircunscripcion = mockParametros.circunscripciones.first;

      // Act
      container.read(boletaInicioDataProvider.notifier).updateActor('Juan Pérez');
      container.read(boletaInicioDataProvider.notifier).updateDemandado('María García');
      container.read(boletaInicioDataProvider.notifier).updateCausa('Daños y perjuicios');
      container.read(boletaInicioDataProvider.notifier).updateJuzgado('Juzgado Test');
      container.read(boletaInicioDataProvider.notifier).updateTipoJuicio(mockTipoJuicio);
      container.read(boletaInicioDataProvider.notifier).updateCircunscripcion(mockCircunscripcion);

      // Assert
      final state = container.read(boletaInicioDataProvider).value;
      expect(state?.actor, 'Juan Pérez');
      expect(state?.demandado, 'María García');
      expect(state?.causa, 'Daños y perjuicios');
      expect(state?.juzgado, 'Juzgado Test');
      expect(state?.tipoJuicio, mockTipoJuicio);
      expect(state?.circunscripcion, mockCircunscripcion);
      expect(state?.isValid, true);
    });

    test('reset debería limpiar todos los campos', () async {
      // Arrange
      await container.read(boletaInicioDataProvider.future);
      container.read(boletaInicioDataProvider.notifier).updateActor('Juan Pérez');
      container.read(boletaInicioDataProvider.notifier).updateDemandado('María García');
      container.read(boletaInicioDataProvider.notifier).updateCausa('Daños y perjuicios');

      // Act
      container.read(boletaInicioDataProvider.notifier).reset();
      // Wait a bit for the async reset to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      final state = container.read(boletaInicioDataProvider).value;
      expect(state?.actor, isNull);
      expect(state?.demandado, isNull);
      expect(state?.causa, isNull);
      expect(state?.isValid, false);
    });
  });

  group('BoletaInicioDataState', () {
    late ParametrosBoletaInicioEntity mockParametros;

    setUp(() {
      // Create mock entities for testing
      final mockTipoJuicio = TipoJuicioEntity(id: '1', descripcion: 'Test Tipo');
      final mockCircunscripcion = CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion');
      mockParametros = ParametrosBoletaInicioEntity(
        tiposJuicio: [mockTipoJuicio],
        circunscripciones: [mockCircunscripcion],
      );
    });

    test('copyWith debería crear una nueva instancia con los valores actualizados', () {
      // Arrange
      final mockTipoJuicio = mockParametros.tiposJuicio.first;
      final mockCircunscripcion = mockParametros.circunscripciones.first;
      final initialState = BoletaInicioDataState(parametrosBoletaInicio: mockParametros);

      // Act
      final newState = initialState.copyWith(
        actor: 'Juan Pérez',
        demandado: 'María García',
        causa: 'Daños y perjuicios',
        juzgado: 'Juzgado Test',
        tipoJuicio: mockTipoJuicio,
        circunscripcion: mockCircunscripcion,
      );

      // Assert
      expect(newState.actor, 'Juan Pérez');
      expect(newState.demandado, 'María García');
      expect(newState.causa, 'Daños y perjuicios');
      expect(newState.juzgado, 'Juzgado Test');
      expect(newState.tipoJuicio, mockTipoJuicio);
      expect(newState.circunscripcion, mockCircunscripcion);
      expect(newState.isValid, true);
    });

    test('isValid debería ser false cuando faltan campos', () {
      // Arrange
      final state = BoletaInicioDataState(parametrosBoletaInicio: mockParametros, actor: 'Juan Pérez');

      // Assert
      expect(state.isValid, false);
    });

    test('isValid debería ser true cuando todos los campos están presentes', () {
      // Arrange
      final mockTipoJuicio = TipoJuicioEntity(id: '1', descripcion: 'Test Tipo');
      final mockCircunscripcion = CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion');
      final state = BoletaInicioDataState(
        parametrosBoletaInicio: mockParametros,
        actor: 'Juan Pérez',
        demandado: 'María García',
        causa: 'Daños y perjuicios',
        juzgado: 'Juzgado Test',
        tipoJuicio: mockTipoJuicio,
        circunscripcion: mockCircunscripcion,
      );

      // Assert
      expect(state.isValid, true);
    });
  });
}

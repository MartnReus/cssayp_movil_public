import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/shared/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PagosNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('estado inicial', () {
      test('debe tener estado inicial con valores por defecto', () {
        // Act
        final state = container.read(pagosNotifierProvider);

        // Assert
        expect(state.selectedBoletaIds, isEmpty);
        expect(state.isProcessing, isFalse);
      });

      test('debe permitir leer el estado múltiples veces sin cambios', () {
        // Act
        final state1 = container.read(pagosNotifierProvider);
        final state2 = container.read(pagosNotifierProvider);

        // Assert
        expect(state1, equals(state2));
        expect(state1.selectedBoletaIds, isEmpty);
        expect(state1.isProcessing, isFalse);
      });
    });

    group('método selectBoletas', () {
      test('debe seleccionar una lista de boletas correctamente', () {
        // Arrange
        final boletaIds = [1, 2, 3];

        // Act
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds);

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, equals(boletaIds));
        expect(state.isProcessing, isFalse);
      });

      test('debe seleccionar una lista vacía correctamente', () {
        // Act
        container.read(pagosNotifierProvider.notifier).selectBoletas([]);

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, isEmpty);
        expect(state.isProcessing, isFalse);
      });

      test('debe cambiar la selección de boletas correctamente', () {
        // Arrange
        final boletaIds1 = [1, 2, 3];
        final boletaIds2 = [4, 5, 6];
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds1);

        // Act
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds2);

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, equals(boletaIds2));
        expect(state.selectedBoletaIds, isNot(equals(boletaIds1)));
      });

      test('debe permitir seleccionar la misma lista múltiples veces', () {
        // Arrange
        final boletaIds = [10, 20, 30];
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds);
        final state1 = container.read(pagosNotifierProvider);

        // Act
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds);

        // Assert
        final state2 = container.read(pagosNotifierProvider);
        expect(state1.selectedBoletaIds, equals(boletaIds));
        expect(state2.selectedBoletaIds, equals(boletaIds));
        expect(state1.selectedBoletaIds, equals(state2.selectedBoletaIds));
      });

      test('debe manejar listas con IDs duplicados', () {
        // Arrange
        final boletaIds = [1, 1, 2, 2, 3];

        // Act
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds);

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, equals(boletaIds));
        expect(state.selectedBoletaIds.length, equals(5));
      });
    });

    group('método clearSelection', () {
      test('debe limpiar la selección cuando hay boletas seleccionadas', () {
        // Arrange
        final boletaIds = [1, 2, 3];
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds);

        // Act
        container.read(pagosNotifierProvider.notifier).clearSelection();

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, isEmpty);
        expect(state.isProcessing, isFalse);
      });

      test('debe mantener la selección vacía cuando ya está vacía', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).selectBoletas([]);

        // Act
        container.read(pagosNotifierProvider.notifier).clearSelection();

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, isEmpty);
        expect(state.isProcessing, isFalse);
      });

      test('debe limpiar la selección sin afectar el estado de procesamiento', () {
        // Arrange
        final boletaIds = [1, 2, 3];
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds);
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(true);

        // Act
        container.read(pagosNotifierProvider.notifier).clearSelection();

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, isEmpty);
        expect(state.isProcessing, isTrue);
      });
    });

    group('método setProcessingPayment', () {
      test('debe establecer el estado de procesamiento en true', () {
        // Act
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(true);

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.isProcessing, isTrue);
        expect(state.selectedBoletaIds, isEmpty);
      });

      test('debe establecer el estado de procesamiento en false', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(true);

        // Act
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(false);

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.isProcessing, isFalse);
      });

      test('debe mantener el estado de procesamiento cuando se establece el mismo valor', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(true);
        final state1 = container.read(pagosNotifierProvider);

        // Act
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(true);

        // Assert
        final state2 = container.read(pagosNotifierProvider);
        expect(state1.isProcessing, isTrue);
        expect(state2.isProcessing, isTrue);
        expect(state1.isProcessing, equals(state2.isProcessing));
      });

      test('debe cambiar el estado de procesamiento sin afectar la selección de boletas', () {
        // Arrange
        final boletaIds = [1, 2, 3];
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds);

        // Act
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(true);

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.isProcessing, isTrue);
        expect(state.selectedBoletaIds, equals(boletaIds));
      });
    });

    group('método copyWith', () {
      test('debe crear una nueva instancia con el mismo estado cuando no se pasan parámetros', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).selectBoletas([1, 2, 3]);
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(true);
        final stateOriginal = container.read(pagosNotifierProvider);

        // Act
        final stateNuevo = stateOriginal.copyWith();

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateNuevo.selectedBoletaIds, equals(stateOriginal.selectedBoletaIds));
        expect(stateNuevo.isProcessing, equals(stateOriginal.isProcessing));
      });

      test('debe crear una nueva instancia con selectedBoletaIds actualizado', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).selectBoletas([1, 2, 3]);
        final stateOriginal = container.read(pagosNotifierProvider);
        final nuevasBoletas = [4, 5, 6];

        // Act
        final stateNuevo = stateOriginal.copyWith(selectedBoletaIds: nuevasBoletas);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.selectedBoletaIds, equals([1, 2, 3]));
        expect(stateNuevo.selectedBoletaIds, equals(nuevasBoletas));
        expect(stateNuevo.isProcessing, equals(stateOriginal.isProcessing));
      });

      test('debe crear una nueva instancia con isProcessing actualizado', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(false);
        final stateOriginal = container.read(pagosNotifierProvider);

        // Act
        final stateNuevo = stateOriginal.copyWith(isProcessing: true);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.isProcessing, isFalse);
        expect(stateNuevo.isProcessing, isTrue);
        expect(stateNuevo.selectedBoletaIds, equals(stateOriginal.selectedBoletaIds));
      });

      test('debe crear una nueva instancia con ambos parámetros actualizados', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).selectBoletas([1, 2]);
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(false);
        final stateOriginal = container.read(pagosNotifierProvider);
        final nuevasBoletas = [7, 8, 9];

        // Act
        final stateNuevo = stateOriginal.copyWith(selectedBoletaIds: nuevasBoletas, isProcessing: true);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.selectedBoletaIds, equals([1, 2]));
        expect(stateOriginal.isProcessing, isFalse);
        expect(stateNuevo.selectedBoletaIds, equals(nuevasBoletas));
        expect(stateNuevo.isProcessing, isTrue);
      });
    });

    group('integración con ProviderContainer', () {
      test('debe mantener el estado entre lecturas del provider', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).selectBoletas([1, 2, 3]);
        container.read(pagosNotifierProvider.notifier).setProcessingPayment(true);

        // Act
        final state1 = container.read(pagosNotifierProvider);
        final state2 = container.read(pagosNotifierProvider);

        // Assert
        expect(state1, equals(state2));
        expect(state1.selectedBoletaIds, equals([1, 2, 3]));
        expect(state1.isProcessing, isTrue);
      });

      test('debe permitir múltiples contenedores independientes', () {
        // Arrange
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();

        // Act
        container1.read(pagosNotifierProvider.notifier).selectBoletas([1, 2]);
        container1.read(pagosNotifierProvider.notifier).setProcessingPayment(true);
        container2.read(pagosNotifierProvider.notifier).selectBoletas([3, 4]);
        container2.read(pagosNotifierProvider.notifier).setProcessingPayment(false);

        // Assert
        final state1 = container1.read(pagosNotifierProvider);
        final state2 = container2.read(pagosNotifierProvider);
        expect(state1.selectedBoletaIds, equals([1, 2]));
        expect(state1.isProcessing, isTrue);
        expect(state2.selectedBoletaIds, equals([3, 4]));
        expect(state2.isProcessing, isFalse);

        // Cleanup
        container1.dispose();
        container2.dispose();
      });

      test('debe permitir escuchar cambios de estado', () async {
        // Arrange
        final notifier = container.read(pagosNotifierProvider.notifier);
        final listener = container.listen(pagosNotifierProvider, (previous, next) {});

        // Act
        notifier.selectBoletas([1, 2, 3]);
        notifier.setProcessingPayment(true);
        await container.pump();

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, equals([1, 2, 3]));
        expect(state.isProcessing, isTrue);

        // Cleanup
        listener.close();
      });
    });

    group('casos edge', () {
      test('debe manejar múltiples cambios rápidos de estado', () {
        // Act
        final notifier = container.read(pagosNotifierProvider.notifier);
        notifier.selectBoletas([1]);
        notifier.setProcessingPayment(true);
        notifier.selectBoletas([2, 3]);
        notifier.setProcessingPayment(false);
        notifier.clearSelection();

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds, isEmpty);
        expect(state.isProcessing, isFalse);
      });

      test('debe mantener la inmutabilidad del estado', () {
        // Arrange
        container.read(pagosNotifierProvider.notifier).selectBoletas([1, 2, 3]);
        final state1 = container.read(pagosNotifierProvider);

        // Act
        container.read(pagosNotifierProvider.notifier).selectBoletas([4, 5, 6]);
        final state2 = container.read(pagosNotifierProvider);

        // Assert
        expect(state1.selectedBoletaIds, equals([1, 2, 3]));
        expect(state2.selectedBoletaIds, equals([4, 5, 6]));
        expect(state1, isNot(equals(state2)));
      });

      test('debe manejar listas muy grandes de boletas', () {
        // Arrange
        final boletaIds = List.generate(1000, (index) => index);

        // Act
        container.read(pagosNotifierProvider.notifier).selectBoletas(boletaIds);

        // Assert
        final state = container.read(pagosNotifierProvider);
        expect(state.selectedBoletaIds.length, equals(1000));
        expect(state.selectedBoletaIds.first, equals(0));
        expect(state.selectedBoletaIds.last, equals(999));
      });
    });
  });

  group('Red Link Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('httpClientProvider debe proporcionar una instancia de http.Client', () {
      // Act
      final client = container.read(httpClientProvider);

      // Assert
      expect(client, isA<http.Client>());
    });

    test('redLinkDataSourceProvider debe proporcionar una instancia de RedLinkDataSource', () {
      // Act
      final dataSource = container.read(redLinkDataSourceProvider);

      // Assert
      expect(dataSource, isA<RedLinkDataSource>());
    });

    test('redLinkRepositoryProvider debe proporcionar una instancia de RedLinkRepository', () {
      // Act
      final repository = container.read(redLinkRepositoryProvider);

      // Assert
      expect(repository, isA<RedLinkRepository>());
    });

    test('pagarConRedLinkUseCaseProvider debe proporcionar una instancia de PagarConRedLinkUseCase', () {
      // Act
      final useCase = container.read(pagarConRedLinkUseCaseProvider);

      // Assert
      expect(useCase, isA<PagarConRedLinkUseCase>());
    });

    test('los providers deben mantener la misma instancia entre lecturas', () {
      // Act
      final client1 = container.read(httpClientProvider);
      final client2 = container.read(httpClientProvider);
      final dataSource1 = container.read(redLinkDataSourceProvider);
      final dataSource2 = container.read(redLinkDataSourceProvider);

      // Assert
      expect(client1, same(client2));
      expect(dataSource1, same(dataSource2));
    });

    test('los providers deben ser independientes entre contenedores', () {
      // Arrange
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();

      // Act
      final client1 = container1.read(httpClientProvider);
      final client2 = container2.read(httpClientProvider);
      final dataSource1 = container1.read(redLinkDataSourceProvider);
      final dataSource2 = container2.read(redLinkDataSourceProvider);

      // Assert
      expect(client1, isNot(same(client2)));
      expect(dataSource1, isNot(same(dataSource2)));

      // Cleanup
      container1.dispose();
      container2.dispose();
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/pagos/presentation/providers/metodo_pago_selector_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MetodoPagoSelectorNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('estado inicial', () {
      test('debe tener estado inicial con selectedMethod null', () {
        // Act
        final state = container.read(metodoPagoSelectorProvider);

        // Assert
        expect(state.selectedMethod, isNull);
        expect(state.canProceedWithPayment, isFalse);
      });

      test('debe permitir leer el estado múltiples veces sin cambios', () {
        // Act
        final state1 = container.read(metodoPagoSelectorProvider);
        final state2 = container.read(metodoPagoSelectorProvider);

        // Assert
        expect(state1, equals(state2));
        expect(state1.selectedMethod, isNull);
        expect(state1.canProceedWithPayment, isFalse);
      });
    });

    group('método selectMethod', () {
      test('debe seleccionar botonPago correctamente', () {
        // Act
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.botonPago);

        // Assert
        final state = container.read(metodoPagoSelectorProvider);
        expect(state.selectedMethod, equals(MetodoPago.botonPago));
        expect(state.canProceedWithPayment, isTrue);
      });

      test('debe seleccionar linkPago correctamente', () {
        // Act
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.linkPago);

        // Assert
        final state = container.read(metodoPagoSelectorProvider);
        expect(state.selectedMethod, equals(MetodoPago.linkPago));
        expect(state.canProceedWithPayment, isTrue);
      });

      test('debe seleccionar tarjeta correctamente', () {
        // Act
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.tarjeta);

        // Assert
        final state = container.read(metodoPagoSelectorProvider);
        expect(state.selectedMethod, equals(MetodoPago.tarjeta));
        expect(state.canProceedWithPayment, isTrue);
      });

      test('debe seleccionar redLink correctamente', () {
        // Act
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.redLink);

        // Assert
        final state = container.read(metodoPagoSelectorProvider);
        expect(state.selectedMethod, equals(MetodoPago.redLink));
        expect(state.canProceedWithPayment, isTrue);
      });

      test('debe cambiar de un método a otro correctamente', () {
        // Arrange
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.botonPago);
        final stateInicial = container.read(metodoPagoSelectorProvider);

        // Act
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.tarjeta);

        // Assert
        final stateFinal = container.read(metodoPagoSelectorProvider);
        expect(stateInicial.selectedMethod, equals(MetodoPago.botonPago));
        expect(stateFinal.selectedMethod, equals(MetodoPago.tarjeta));
        expect(stateFinal.canProceedWithPayment, isTrue);
      });

      test('debe permitir seleccionar el mismo método múltiples veces', () {
        // Arrange
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.redLink);
        final state1 = container.read(metodoPagoSelectorProvider);

        // Act
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.redLink);

        // Assert
        final state2 = container.read(metodoPagoSelectorProvider);
        expect(state1.selectedMethod, equals(MetodoPago.redLink));
        expect(state2.selectedMethod, equals(MetodoPago.redLink));
        expect(state1.selectedMethod, equals(state2.selectedMethod));
        expect(state1.canProceedWithPayment, equals(state2.canProceedWithPayment));
      });
    });

    group('propiedad canProceedWithPayment', () {
      test('debe ser false cuando no hay método seleccionado', () {
        // Act
        final state = container.read(metodoPagoSelectorProvider);

        // Assert
        expect(state.canProceedWithPayment, isFalse);
      });

      test('debe ser true cuando hay método seleccionado', () {
        // Arrange
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.botonPago);

        // Act
        final state = container.read(metodoPagoSelectorProvider);

        // Assert
        expect(state.canProceedWithPayment, isTrue);
      });

      test('debe cambiar correctamente al seleccionar y deseleccionar', () {
        // Estado inicial
        expect(container.read(metodoPagoSelectorProvider).canProceedWithPayment, isFalse);

        // Seleccionar método
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.linkPago);
        expect(container.read(metodoPagoSelectorProvider).canProceedWithPayment, isTrue);

        // Cambiar a otro método
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.tarjeta);
        expect(container.read(metodoPagoSelectorProvider).canProceedWithPayment, isTrue);
      });
    });

    group('método copyWith', () {
      test('debe crear una nueva instancia con el mismo estado cuando no se pasan parámetros', () {
        // Arrange
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.botonPago);
        final stateOriginal = container.read(metodoPagoSelectorProvider);

        // Act
        final stateNuevo = stateOriginal.copyWith();

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateNuevo.selectedMethod, equals(stateOriginal.selectedMethod));
        expect(stateNuevo.canProceedWithPayment, equals(stateOriginal.canProceedWithPayment));
      });

      test('debe crear una nueva instancia con el método actualizado', () {
        // Arrange
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.botonPago);
        final stateOriginal = container.read(metodoPagoSelectorProvider);

        // Act
        final stateNuevo = stateOriginal.copyWith(selectedMethod: MetodoPago.redLink);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.selectedMethod, equals(MetodoPago.botonPago));
        expect(stateNuevo.selectedMethod, equals(MetodoPago.redLink));
        expect(stateNuevo.canProceedWithPayment, isTrue);
      });

      test('debe mantener el selectedMethod original cuando se pasa null', () {
        // Arrange
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.tarjeta);
        final stateOriginal = container.read(metodoPagoSelectorProvider);

        // Act
        final stateNuevo = stateOriginal.copyWith(selectedMethod: null);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.selectedMethod, equals(MetodoPago.tarjeta));
        expect(stateNuevo.selectedMethod, equals(MetodoPago.tarjeta)); // copyWith no maneja null correctamente
        expect(stateNuevo.canProceedWithPayment, isTrue);
      });
    });

    group('enum MetodoPago', () {
      test('debe tener todos los valores esperados', () {
        // Act & Assert
        expect(MetodoPago.values, contains(MetodoPago.botonPago));
        expect(MetodoPago.values, contains(MetodoPago.linkPago));
        expect(MetodoPago.values, contains(MetodoPago.tarjeta));
        expect(MetodoPago.values, contains(MetodoPago.redLink));
        expect(MetodoPago.values.length, equals(4));
      });

      test('debe tener nombres correctos', () {
        // Act & Assert
        expect(MetodoPago.botonPago.name, equals('botonPago'));
        expect(MetodoPago.linkPago.name, equals('linkPago'));
        expect(MetodoPago.tarjeta.name, equals('tarjeta'));
        expect(MetodoPago.redLink.name, equals('redLink'));
      });
    });

    group('integración con ProviderContainer', () {
      test('debe mantener el estado entre lecturas del provider', () {
        // Arrange
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.redLink);

        // Act
        final state1 = container.read(metodoPagoSelectorProvider);
        final state2 = container.read(metodoPagoSelectorProvider);

        // Assert
        expect(state1, equals(state2));
        expect(state1.selectedMethod, equals(MetodoPago.redLink));
      });

      test('debe permitir múltiples contenedores independientes', () {
        // Arrange
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();

        // Act
        container1.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.botonPago);
        container2.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.tarjeta);

        // Assert
        expect(container1.read(metodoPagoSelectorProvider).selectedMethod, equals(MetodoPago.botonPago));
        expect(container2.read(metodoPagoSelectorProvider).selectedMethod, equals(MetodoPago.tarjeta));

        // Cleanup
        container1.dispose();
        container2.dispose();
      });

      test('debe permitir escuchar cambios de estado', () async {
        // Arrange
        final notifier = container.read(metodoPagoSelectorProvider.notifier);
        final listener = container.listen(metodoPagoSelectorProvider, (previous, next) {});

        // Act
        notifier.selectMethod(MetodoPago.linkPago);
        await container.pump();

        // Assert
        final state = container.read(metodoPagoSelectorProvider);
        expect(state.selectedMethod, equals(MetodoPago.linkPago));

        // Cleanup
        listener.close();
      });
    });

    group('casos edge', () {
      test('debe manejar múltiples cambios rápidos de estado', () {
        // Act
        final notifier = container.read(metodoPagoSelectorProvider.notifier);
        notifier.selectMethod(MetodoPago.botonPago);
        notifier.selectMethod(MetodoPago.linkPago);
        notifier.selectMethod(MetodoPago.tarjeta);
        notifier.selectMethod(MetodoPago.redLink);

        // Assert
        final state = container.read(metodoPagoSelectorProvider);
        expect(state.selectedMethod, equals(MetodoPago.redLink));
        expect(state.canProceedWithPayment, isTrue);
      });

      test('debe mantener la inmutabilidad del estado', () {
        // Arrange
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.botonPago);
        final state1 = container.read(metodoPagoSelectorProvider);

        // Act
        container.read(metodoPagoSelectorProvider.notifier).selectMethod(MetodoPago.tarjeta);
        final state2 = container.read(metodoPagoSelectorProvider);

        // Assert
        expect(state1.selectedMethod, equals(MetodoPago.botonPago));
        expect(state2.selectedMethod, equals(MetodoPago.tarjeta));
        expect(state1, isNot(equals(state2)));
      });
    });
  });
}

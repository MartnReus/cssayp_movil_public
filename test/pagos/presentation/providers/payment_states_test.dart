import 'package:flutter_test/flutter_test.dart';

import 'package:cssayp_movil/pagos/data/models/datos_tarjeta_model.dart';
import 'package:cssayp_movil/pagos/data/models/resultado_pago_model.dart';
import 'package:cssayp_movil/pagos/presentation/providers/payment_states.dart';

void main() {
  group('PaymentState', () {
    group('PaymentInitial', () {
      test('debe crear una instancia con valores por defecto', () {
        // Act
        const state = PaymentInitial();

        // Assert
        expect(state, isA<PaymentState>());
        expect(state, isA<PaymentInitial>());
      });

      test('debe ser igual a otra instancia de PaymentInitial', () {
        // Act
        const state1 = PaymentInitial();
        const state2 = PaymentInitial();

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('debe ser inmutable', () {
        // Act
        const state1 = PaymentInitial();
        const state2 = PaymentInitial();

        // Assert
        expect(identical(state1, state2), isTrue);
      });
    });

    group('PaymentLoading', () {
      test('debe crear una instancia con mensaje por defecto', () {
        // Act
        const state = PaymentLoading();

        // Assert
        expect(state, isA<PaymentState>());
        expect(state, isA<PaymentLoading>());
        expect(state.message, equals('Procesando pago...'));
      });

      test('debe crear una instancia con mensaje personalizado', () {
        // Act
        const state = PaymentLoading(message: 'Validando tarjeta...');

        // Assert
        expect(state, isA<PaymentState>());
        expect(state, isA<PaymentLoading>());
        expect(state.message, equals('Validando tarjeta...'));
      });

      test('debe ser igual a otra instancia con el mismo mensaje', () {
        // Act
        const state1 = PaymentLoading(message: 'Procesando...');
        const state2 = PaymentLoading(message: 'Procesando...');

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('debe ser diferente a otra instancia con mensaje distinto', () {
        // Act
        const state1 = PaymentLoading(message: 'Procesando...');
        const state2 = PaymentLoading(message: 'Validando...');

        // Assert
        expect(state1, isNot(equals(state2)));
        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });
    });

    group('PaymentSuccess', () {
      test('debe crear una instancia con resultado', () {
        // Arrange
        const resultado = ResultadoPagoModel(statusCode: 201, message: {'success': true, 'transaction_id': 'TXN123'});

        // Act
        const state = PaymentSuccess(resultado: resultado);

        // Assert
        expect(state, isA<PaymentState>());
        expect(state, isA<PaymentSuccess>());
        expect(state.resultado, equals(resultado));
      });

      test('debe ser igual a otra instancia con el mismo resultado', () {
        // Arrange
        const resultado = ResultadoPagoModel(statusCode: 201, message: {'success': true});

        // Act
        const state1 = PaymentSuccess(resultado: resultado);
        const state2 = PaymentSuccess(resultado: resultado);

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('debe ser diferente a otra instancia con resultado distinto', () {
        // Arrange
        const resultado1 = ResultadoPagoModel(statusCode: 201, message: {'success': true});
        const resultado2 = ResultadoPagoModel(statusCode: 400, message: {'error': 'Failed'});

        // Act
        const state1 = PaymentSuccess(resultado: resultado1);
        const state2 = PaymentSuccess(resultado: resultado2);

        // Assert
        expect(state1, isNot(equals(state2)));
        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });
    });

    group('PaymentError', () {
      test('debe crear una instancia con error', () {
        // Act
        const state = PaymentError(error: 'Error de conexión');

        // Assert
        expect(state, isA<PaymentState>());
        expect(state, isA<PaymentError>());
        expect(state.error, equals('Error de conexión'));
      });

      test('debe ser igual a otra instancia con el mismo error', () {
        // Act
        const state1 = PaymentError(error: 'Error de conexión');
        const state2 = PaymentError(error: 'Error de conexión');

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('debe ser diferente a otra instancia con error distinto', () {
        // Act
        const state1 = PaymentError(error: 'Error de conexión');
        const state2 = PaymentError(error: 'Error de validación');

        // Assert
        expect(state1, isNot(equals(state2)));
        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });
    });

    group('jerarquía de clases', () {
      test('todos los estados deben ser instancias de PaymentState', () {
        // Act
        const initial = PaymentInitial();
        const loading = PaymentLoading();
        const success = PaymentSuccess(resultado: ResultadoPagoModel(statusCode: 201, message: {}));
        const error = PaymentError(error: 'Error');

        // Assert
        expect(initial, isA<PaymentState>());
        expect(loading, isA<PaymentState>());
        expect(success, isA<PaymentState>());
        expect(error, isA<PaymentState>());
      });

      test('los estados deben ser diferentes entre sí', () {
        // Act
        const initial = PaymentInitial();
        const loading = PaymentLoading();
        const success = PaymentSuccess(resultado: ResultadoPagoModel(statusCode: 201, message: {}));
        const error = PaymentError(error: 'Error');

        // Assert
        expect(initial, isNot(equals(loading)));
        expect(initial, isNot(equals(success)));
        expect(initial, isNot(equals(error)));
        expect(loading, isNot(equals(success)));
        expect(loading, isNot(equals(error)));
        expect(success, isNot(equals(error)));
      });
    });
  });

  group('PayWayState', () {
    group('constructor', () {
      test('debe crear una instancia con valores por defecto', () {
        // Act
        const state = PayWayState();

        // Assert
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.datosTarjeta, isNull);
        expect(state.validationErrors, isEmpty);
        expect(state.touchedFields, isEmpty);
        expect(state.isFormValid, isFalse);
        expect(state.tipoTarjeta, equals(TipoTarjeta.debito));
        expect(state.cuotas, equals(1));
      });

      test('debe crear una instancia con valores personalizados', () {
        // Arrange
        const paymentState = PaymentLoading(message: 'Procesando...');
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '1234567890123456',
          cvv: '123',
          fechaExpiracion: '12/25',
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 3,
        );
        const validationErrors = {'nombre': 'Campo requerido'};
        const touchedFields = {'nombre', 'dni'};

        // Act
        const state = PayWayState(
          paymentState: paymentState,
          datosTarjeta: datosTarjeta,
          validationErrors: validationErrors,
          touchedFields: touchedFields,
          isFormValid: true,
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 6,
        );

        // Assert
        expect(state.paymentState, equals(paymentState));
        expect(state.datosTarjeta, equals(datosTarjeta));
        expect(state.validationErrors, equals(validationErrors));
        expect(state.touchedFields, equals(touchedFields));
        expect(state.isFormValid, isTrue);
        expect(state.tipoTarjeta, equals(TipoTarjeta.credito));
        expect(state.cuotas, equals(6));
      });
    });

    group('método copyWith', () {
      test('debe crear una nueva instancia con el mismo estado cuando no se pasan parámetros', () {
        // Arrange
        const stateOriginal = PayWayState(paymentState: PaymentLoading(), isFormValid: true, cuotas: 3);

        // Act
        final stateNuevo = stateOriginal.copyWith();

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateNuevo.paymentState, equals(stateOriginal.paymentState));
        expect(stateNuevo.datosTarjeta, equals(stateOriginal.datosTarjeta));
        expect(stateNuevo.validationErrors, equals(stateOriginal.validationErrors));
        expect(stateNuevo.touchedFields, equals(stateOriginal.touchedFields));
        expect(stateNuevo.isFormValid, equals(stateOriginal.isFormValid));
        expect(stateNuevo.tipoTarjeta, equals(stateOriginal.tipoTarjeta));
        expect(stateNuevo.cuotas, equals(stateOriginal.cuotas));
      });

      test('debe crear una nueva instancia con paymentState actualizado', () {
        // Arrange
        const stateOriginal = PayWayState(paymentState: PaymentInitial());
        const nuevoPaymentState = PaymentLoading(message: 'Nuevo mensaje');

        // Act
        final stateNuevo = stateOriginal.copyWith(paymentState: nuevoPaymentState);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.paymentState, isA<PaymentInitial>());
        expect(stateNuevo.paymentState, equals(nuevoPaymentState));
        expect(stateNuevo.datosTarjeta, equals(stateOriginal.datosTarjeta));
      });

      test('debe crear una nueva instancia con datosTarjeta actualizado', () {
        // Arrange
        const stateOriginal = PayWayState();
        const nuevosDatosTarjeta = DatosTarjetaModel(
          nombre: 'María García',
          dni: '87654321',
          nroTarjeta: '9876543210987654',
          cvv: '456',
          fechaExpiracion: '06/26',
        );

        // Act
        final stateNuevo = stateOriginal.copyWith(datosTarjeta: nuevosDatosTarjeta);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.datosTarjeta, isNull);
        expect(stateNuevo.datosTarjeta, equals(nuevosDatosTarjeta));
      });

      test('debe crear una nueva instancia con validationErrors actualizado', () {
        // Arrange
        const stateOriginal = PayWayState();
        const nuevosValidationErrors = {'cvv': 'CVV inválido', 'fecha': 'Fecha expirada'};

        // Act
        final stateNuevo = stateOriginal.copyWith(validationErrors: nuevosValidationErrors);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.validationErrors, isEmpty);
        expect(stateNuevo.validationErrors, equals(nuevosValidationErrors));
      });

      test('debe crear una nueva instancia con touchedFields actualizado', () {
        // Arrange
        const stateOriginal = PayWayState();
        const nuevosTouchedFields = {'nombre', 'dni', 'nroTarjeta'};

        // Act
        final stateNuevo = stateOriginal.copyWith(touchedFields: nuevosTouchedFields);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.touchedFields, isEmpty);
        expect(stateNuevo.touchedFields, equals(nuevosTouchedFields));
      });

      test('debe crear una nueva instancia con isFormValid actualizado', () {
        // Arrange
        const stateOriginal = PayWayState(isFormValid: false);

        // Act
        final stateNuevo = stateOriginal.copyWith(isFormValid: true);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.isFormValid, isFalse);
        expect(stateNuevo.isFormValid, isTrue);
      });

      test('debe crear una nueva instancia con tipoTarjeta actualizado', () {
        // Arrange
        const stateOriginal = PayWayState(tipoTarjeta: TipoTarjeta.debito);

        // Act
        final stateNuevo = stateOriginal.copyWith(tipoTarjeta: TipoTarjeta.credito);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.tipoTarjeta, equals(TipoTarjeta.debito));
        expect(stateNuevo.tipoTarjeta, equals(TipoTarjeta.credito));
      });

      test('debe crear una nueva instancia con cuotas actualizado', () {
        // Arrange
        const stateOriginal = PayWayState(cuotas: 1);

        // Act
        final stateNuevo = stateOriginal.copyWith(cuotas: 12);

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.cuotas, equals(1));
        expect(stateNuevo.cuotas, equals(12));
      });

      test('debe crear una nueva instancia con múltiples parámetros actualizados', () {
        // Arrange
        const stateOriginal = PayWayState();
        const nuevoPaymentState = PaymentSuccess(
          resultado: ResultadoPagoModel(statusCode: 201, message: {'success': true}),
        );
        const nuevosDatosTarjeta = DatosTarjetaModel(
          nombre: 'Test User',
          dni: '12345678',
          nroTarjeta: '1234567890123456',
          cvv: '123',
          fechaExpiracion: '12/25',
        );

        // Act
        final stateNuevo = stateOriginal.copyWith(
          paymentState: nuevoPaymentState,
          datosTarjeta: nuevosDatosTarjeta,
          isFormValid: true,
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 6,
        );

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateNuevo.paymentState, equals(nuevoPaymentState));
        expect(stateNuevo.datosTarjeta, equals(nuevosDatosTarjeta));
        expect(stateNuevo.isFormValid, isTrue);
        expect(stateNuevo.tipoTarjeta, equals(TipoTarjeta.credito));
        expect(stateNuevo.cuotas, equals(6));
      });
    });

    group('casos edge', () {
      test('debe manejar validationErrors vacío', () {
        // Act
        const state = PayWayState(validationErrors: {});

        // Assert
        expect(state.validationErrors, isEmpty);
        expect(state.validationErrors.length, equals(0));
      });

      test('debe manejar touchedFields vacío', () {
        // Act
        const state = PayWayState(touchedFields: {});

        // Assert
        expect(state.touchedFields, isEmpty);
        expect(state.touchedFields.length, equals(0));
      });

      test('debe manejar validationErrors con múltiples errores', () {
        // Arrange
        const validationErrors = {
          'nombre': 'Campo requerido',
          'dni': 'DNI inválido',
          'nroTarjeta': 'Tarjeta inválida',
          'cvv': 'CVV inválido',
          'fechaExpiracion': 'Fecha expirada',
        };

        // Act
        const state = PayWayState(validationErrors: validationErrors);

        // Assert
        expect(state.validationErrors.length, equals(5));
        expect(state.validationErrors['nombre'], equals('Campo requerido'));
        expect(state.validationErrors['dni'], equals('DNI inválido'));
        expect(state.validationErrors['nroTarjeta'], equals('Tarjeta inválida'));
        expect(state.validationErrors['cvv'], equals('CVV inválido'));
        expect(state.validationErrors['fechaExpiracion'], equals('Fecha expirada'));
      });

      test('debe manejar touchedFields con múltiples campos', () {
        // Arrange
        const touchedFields = {'nombre', 'dni', 'nroTarjeta', 'cvv', 'fechaExpiracion'};

        // Act
        const state = PayWayState(touchedFields: touchedFields);

        // Assert
        expect(state.touchedFields.length, equals(5));
        expect(state.touchedFields.contains('nombre'), isTrue);
        expect(state.touchedFields.contains('dni'), isTrue);
        expect(state.touchedFields.contains('nroTarjeta'), isTrue);
        expect(state.touchedFields.contains('cvv'), isTrue);
        expect(state.touchedFields.contains('fechaExpiracion'), isTrue);
      });

      test('debe manejar cuotas con valores extremos', () {
        // Test con cuotas mínimas
        const stateMin = PayWayState(cuotas: 1);
        expect(stateMin.cuotas, equals(1));

        // Test con cuotas máximas
        const stateMax = PayWayState(cuotas: 24);
        expect(stateMax.cuotas, equals(24));

        // Test con cuotas cero
        const stateZero = PayWayState(cuotas: 0);
        expect(stateZero.cuotas, equals(0));
      });

      test('debe mantener la inmutabilidad en copyWith', () {
        // Arrange
        const stateOriginal = PayWayState(validationErrors: {'campo1': 'error1'}, touchedFields: {'campo1', 'campo2'});

        // Act
        final stateNuevo = stateOriginal.copyWith(
          validationErrors: {'campo3': 'error3'},
          touchedFields: {'campo3', 'campo4'},
        );

        // Assert
        expect(stateOriginal.validationErrors, equals({'campo1': 'error1'}));
        expect(stateOriginal.touchedFields, equals({'campo1', 'campo2'}));
        expect(stateNuevo.validationErrors, equals({'campo3': 'error3'}));
        expect(stateNuevo.touchedFields, equals({'campo3', 'campo4'}));
      });
    });

    group('igualdad y hashCode', () {
      test('debe ser igual a otra instancia con los mismos valores', () {
        // Arrange
        const paymentState = PaymentLoading(message: 'Test');
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Test',
          dni: '12345678',
          nroTarjeta: '1234567890123456',
          cvv: '123',
          fechaExpiracion: '12/25',
        );

        // Act
        const state1 = PayWayState(
          paymentState: paymentState,
          datosTarjeta: datosTarjeta,
          validationErrors: {'error': 'test'},
          touchedFields: {'field'},
          isFormValid: true,
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 3,
        );
        const state2 = PayWayState(
          paymentState: paymentState,
          datosTarjeta: datosTarjeta,
          validationErrors: {'error': 'test'},
          touchedFields: {'field'},
          isFormValid: true,
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 3,
        );

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('debe ser diferente a otra instancia con valores distintos', () {
        // Act
        const state1 = PayWayState(isFormValid: false);
        const state2 = PayWayState(isFormValid: true);

        // Assert
        expect(state1, isNot(equals(state2)));
        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });
    });
  });
}

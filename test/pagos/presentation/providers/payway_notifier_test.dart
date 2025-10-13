import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:cssayp_movil/pagos/data/models/datos_tarjeta_model.dart';
import 'package:cssayp_movil/pagos/data/models/resultado_pago_model.dart';
import 'package:cssayp_movil/pagos/domain/entities/boleta_a_pagar_entity.dart';
import 'package:cssayp_movil/pagos/domain/usecases/pagar_con_payway_use_case.dart';
import 'package:cssayp_movil/pagos/presentation/providers/payway_notifier.dart';
import 'package:cssayp_movil/pagos/presentation/providers/payment_states.dart';
import 'package:cssayp_movil/pagos/presentation/providers/pagos_use_cases_providers.dart';

import 'payway_notifier_test.mocks.dart';

@GenerateMocks([PagarConPaywayUseCase])
void main() {
  group('PayWayNotifier', () {
    late MockPagarConPaywayUseCase mockPagarConPaywayUseCase;
    late ProviderContainer container;
    late PayWayNotifier notifier;

    setUp(() {
      mockPagarConPaywayUseCase = MockPagarConPaywayUseCase();
      container = ProviderContainer(
        overrides: [pagarConPaywayUseCaseProvider.overrideWith((ref) => Future.value(mockPagarConPaywayUseCase))],
      );
      notifier = container.read(payWayNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('build() y estado inicial', () {
      test('debe inicializar con estado por defecto', () async {
        // Act
        final state = await container.read(payWayNotifierProvider.future);

        // Assert
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.datosTarjeta, isNull);
        expect(state.validationErrors, isEmpty);
        expect(state.touchedFields, isEmpty);
        expect(state.isFormValid, isFalse);
        expect(state.tipoTarjeta, equals(TipoTarjeta.debito));
        expect(state.cuotas, equals(1));
      });

      test('debe cargar el use case correctamente', () async {
        // Act
        await container.read(payWayNotifierProvider.future);

        // Assert
        // El use case se carga durante el build() del notifier
        // Verificamos que el notifier esté inicializado correctamente
        expect(notifier, isNotNull);
        final state = container.read(payWayNotifierProvider).value!;
        expect(state, isNotNull);
      });
    });

    group('markFieldAsTouched', () {
      test('debe marcar un campo como tocado', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);

        // Act
        notifier.markFieldAsTouched('nombre');

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.touchedFields.contains('nombre'), isTrue);
      });

      test('debe marcar múltiples campos como tocados', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);

        // Act
        notifier.markFieldAsTouched('nombre');
        notifier.markFieldAsTouched('dni');
        notifier.markFieldAsTouched('nroTarjeta');

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.touchedFields.contains('nombre'), isTrue);
        expect(state.touchedFields.contains('dni'), isTrue);
        expect(state.touchedFields.contains('nroTarjeta'), isTrue);
        expect(state.touchedFields.length, equals(3));
      });

      test('debe mantener campos ya tocados al marcar uno nuevo', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nombre');

        // Act
        notifier.markFieldAsTouched('dni');

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.touchedFields.contains('nombre'), isTrue);
        expect(state.touchedFields.contains('dni'), isTrue);
        expect(state.touchedFields.length, equals(2));
      });
    });

    group('updateCardData', () {
      test('debe actualizar datos de tarjeta válidos sin errores', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366', // Número válido con algoritmo de Luhn
          cvv: '123',
          fechaExpiracion: '12/30',
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 3,
        );

        // Act
        notifier.updateCardData(datosTarjeta);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.datosTarjeta, equals(datosTarjeta));
        expect(state.validationErrors, isEmpty);
        expect(state.isFormValid, isTrue);
        expect(state.tipoTarjeta, equals(TipoTarjeta.credito));
        expect(state.cuotas, equals(3));
      });

      test('debe mostrar errores solo para campos tocados', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nombre');
        notifier.markFieldAsTouched('dni');

        const datosTarjeta = DatosTarjetaModel(
          nombre: '', // Inválido
          dni: '123', // Inválido
          nroTarjeta: '4532015112830366', // Válido pero no tocado
          cvv: '12', // Inválido pero no tocado
          fechaExpiracion: '12/30',
        );

        // Act
        notifier.updateCardData(datosTarjeta);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('nombre'), isTrue);
        expect(state.validationErrors.containsKey('dni'), isTrue);
        expect(state.validationErrors.containsKey('nroTarjeta'), isFalse);
        expect(state.validationErrors.containsKey('cvv'), isFalse);
        expect(state.isFormValid, isFalse);
      });

      test('debe validar nombre correctamente', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nombre');

        // Test nombre vacío
        const datosTarjetaVacio = DatosTarjetaModel(
          nombre: '',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaVacio);
        var state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['nombre'], equals('El nombre es requerido'));

        // Test nombre muy corto
        const datosTarjetaCorto = DatosTarjetaModel(
          nombre: 'A',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaCorto);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['nombre'], equals('El nombre debe tener al menos 2 caracteres'));

        // Test nombre válido
        const datosTarjetaValido = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaValido);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('nombre'), isFalse);
      });

      test('debe validar DNI correctamente', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('dni');

        // Test DNI vacío
        const datosTarjetaVacio = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaVacio);
        var state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['dni'], equals('El DNI es requerido'));

        // Test DNI inválido
        const datosTarjetaInvalido = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '123456',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaInvalido);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['dni'], equals('El DNI debe tener 7 u 8 dígitos'));

        // Test DNI válido
        const datosTarjetaValido = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaValido);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('dni'), isFalse);
      });

      test('debe validar número de tarjeta correctamente', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nroTarjeta');

        // Test número vacío
        const datosTarjetaVacio = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaVacio);
        var state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['nroTarjeta'], equals('El número de tarjeta es requerido'));

        // Test número inválido (muy corto)
        const datosTarjetaCorto = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '123456789012',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaCorto);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['nroTarjeta'], equals('Número de tarjeta inválido'));

        // Test número inválido (algoritmo de Luhn)
        const datosTarjetaLuhnInvalido = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830367', // Número inválido con Luhn
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaLuhnInvalido);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['nroTarjeta'], equals('Número de tarjeta inválido'));

        // Test número válido
        const datosTarjetaValido = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366', // Número válido con Luhn
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaValido);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('nroTarjeta'), isFalse);
      });

      test('debe validar CVV correctamente', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('cvv');

        // Test CVV vacío
        const datosTarjetaVacio = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaVacio);
        var state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['cvv'], equals('El CVV es requerido'));

        // Test CVV inválido
        const datosTarjetaInvalido = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '12',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaInvalido);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['cvv'], equals('El CVV debe tener 3 o 4 dígitos'));

        // Test CVV válido (3 dígitos)
        const datosTarjetaValido3 = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaValido3);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('cvv'), isFalse);

        // Test CVV válido (4 dígitos)
        const datosTarjetaValido4 = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '1234',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaValido4);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('cvv'), isFalse);
      });

      test('debe validar fecha de expiración correctamente', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('fechaExpiracion');

        // Test fecha vacía
        const datosTarjetaVacio = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '',
        );

        notifier.updateCardData(datosTarjetaVacio);
        var state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['fechaExpiracion'], equals('La fecha de expiración es requerida'));

        // Test formato inválido
        const datosTarjetaFormatoInvalido = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '13/30',
        );

        notifier.updateCardData(datosTarjetaFormatoInvalido);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['fechaExpiracion'], equals('Formato inválido (MM/YY)'));

        // Test fecha válida futura
        const datosTarjetaValido = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        notifier.updateCardData(datosTarjetaValido);
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('fechaExpiracion'), isFalse);
      });
    });

    group('updateTipoTarjeta', () {
      test('debe actualizar tipo de tarjeta cuando hay datos existentes', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosIniciales = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
          tipoTarjeta: TipoTarjeta.debito,
          cuotas: 1,
        );
        notifier.updateCardData(datosIniciales);

        // Act
        notifier.updateTipoTarjeta(TipoTarjeta.credito);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.datosTarjeta!.tipoTarjeta, equals(TipoTarjeta.credito));
        expect(state.tipoTarjeta, equals(TipoTarjeta.credito));
        expect(state.cuotas, equals(1)); // Se mantiene el valor actual
      });

      test('debe actualizar tipo de tarjeta cuando no hay datos existentes', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);

        // Act
        notifier.updateTipoTarjeta(TipoTarjeta.credito);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.tipoTarjeta, equals(TipoTarjeta.credito));
        expect(state.datosTarjeta, isNull);
      });

      test('debe limpiar espacios del número de tarjeta', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosIniciales = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532 0151 1283 0366', // Con espacios
          cvv: '123',
          fechaExpiracion: '12/30',
          tipoTarjeta: TipoTarjeta.debito,
          cuotas: 1,
        );
        notifier.updateCardData(datosIniciales);

        // Act
        notifier.updateTipoTarjeta(TipoTarjeta.credito);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.datosTarjeta!.nroTarjeta, equals('4532015112830366')); // Sin espacios
      });
    });

    group('updateCuotas', () {
      test('debe actualizar cuotas cuando hay datos existentes', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosIniciales = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 3,
        );
        notifier.updateCardData(datosIniciales);

        // Act
        notifier.updateCuotas(6);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.datosTarjeta!.cuotas, equals(6));
        expect(state.cuotas, equals(6));
      });

      test('debe actualizar cuotas cuando no hay datos existentes', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);

        // Act
        notifier.updateCuotas(12);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.cuotas, equals(12));
        expect(state.datosTarjeta, isNull);
      });
    });

    group('clearFieldError', () {
      test('debe limpiar error de un campo específico', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nombre');
        const datosTarjeta = DatosTarjetaModel(
          nombre: '', // Inválido
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta);

        // Verificar que hay error
        var state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('nombre'), isTrue);

        // Act
        notifier.clearFieldError('nombre');

        // Assert
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('nombre'), isFalse);
      });

      test('debe mantener otros errores al limpiar uno específico', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nombre');
        notifier.markFieldAsTouched('dni');
        const datosTarjeta = DatosTarjetaModel(
          nombre: '', // Inválido
          dni: '123', // Inválido
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta);

        // Act
        notifier.clearFieldError('nombre');

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('nombre'), isFalse);
        expect(state.validationErrors.containsKey('dni'), isTrue);
      });

      test('no debe hacer nada si el campo no tiene error', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta);

        // Act
        notifier.clearFieldError('nombre');

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors, isEmpty);
      });
    });

    group('procesarPago', () {
      test('debe procesar pago exitosamente', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 3,
        );
        notifier.updateCardData(datosTarjeta);

        final boletas = [
          BoletaAPagarEntity(idBoleta: 1, monto: 100.0, caratula: 'Boleta 1', nroAfiliado: 12345),
          BoletaAPagarEntity(idBoleta: 2, monto: 200.0, caratula: 'Boleta 2', nroAfiliado: 12345),
        ];

        const resultadoEsperado = ResultadoPagoModel(
          statusCode: 200,
          message: {'success': true, 'transaction_id': 'TXN123'},
        );

        when(
          mockPagarConPaywayUseCase.execute(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        ).thenAnswer((_) async => resultadoEsperado);

        // Act
        await notifier.procesarPago(boletas);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentSuccess>());
        expect((state.paymentState as PaymentSuccess).resultado, equals(resultadoEsperado));

        verify(
          mockPagarConPaywayUseCase.execute(
            boletas: boletas,
            datosTarjeta: argThat(
              predicate<DatosTarjetaModel>((d) => d.nroTarjeta == '4532015112830366'), // Sin espacios
              named: 'datosTarjeta',
            ),
          ),
        ).called(1);
      });

      test('debe mostrar error si el formulario no es válido', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: '', // Inválido
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.markFieldAsTouched('nombre');
        notifier.updateCardData(datosTarjeta);

        final boletas = [BoletaAPagarEntity(idBoleta: 1, monto: 100.0, caratula: 'Boleta 1', nroAfiliado: 12345)];

        // Act
        await notifier.procesarPago(boletas);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentError>());
        expect((state.paymentState as PaymentError).error, equals('Por favor complete todos los campos correctamente'));

        verifyNever(
          mockPagarConPaywayUseCase.execute(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        );
      });

      test('debe mostrar error si no hay datos de tarjeta', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        final boletas = [BoletaAPagarEntity(idBoleta: 1, monto: 100.0, caratula: 'Boleta 1', nroAfiliado: 12345)];

        // Act
        await notifier.procesarPago(boletas);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentError>());
        expect((state.paymentState as PaymentError).error, equals('Por favor complete todos los campos correctamente'));

        verifyNever(
          mockPagarConPaywayUseCase.execute(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        );
      });

      test('debe mostrar estado de carga durante el procesamiento', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta);

        final boletas = [BoletaAPagarEntity(idBoleta: 1, monto: 100.0, caratula: 'Boleta 1', nroAfiliado: 12345)];

        // Simular delay en el use case
        when(
          mockPagarConPaywayUseCase.execute(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return const ResultadoPagoModel(statusCode: 200, message: {'success': true});
        });

        // Act
        final future = notifier.procesarPago(boletas);

        // Verificar estado de carga
        final stateLoading = container.read(payWayNotifierProvider).value!;
        expect(stateLoading.paymentState, isA<PaymentLoading>());
        expect((stateLoading.paymentState as PaymentLoading).message, equals('Procesando pago con tarjeta...'));

        // Esperar a que termine
        await future;

        // Verificar estado final
        final stateFinal = container.read(payWayNotifierProvider).value!;
        expect(stateFinal.paymentState, isA<PaymentSuccess>());
      });

      test('debe manejar errores del use case', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta);

        final boletas = [BoletaAPagarEntity(idBoleta: 1, monto: 100.0, caratula: 'Boleta 1', nroAfiliado: 12345)];

        when(
          mockPagarConPaywayUseCase.execute(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        ).thenThrow(Exception('Error de red'));

        // Act
        await notifier.procesarPago(boletas);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentError>());
        expect((state.paymentState as PaymentError).error, contains('Error al procesar el pago'));
        expect((state.paymentState as PaymentError).error, contains('Error de red'));
      });

      test('debe limpiar espacios del número de tarjeta antes de procesar', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532 0151 1283 0366', // Con espacios
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta);

        final boletas = [BoletaAPagarEntity(idBoleta: 1, monto: 100.0, caratula: 'Boleta 1', nroAfiliado: 12345)];

        when(
          mockPagarConPaywayUseCase.execute(boletas: anyNamed('boletas'), datosTarjeta: anyNamed('datosTarjeta')),
        ).thenAnswer((_) async => const ResultadoPagoModel(statusCode: 201, message: {'success': true}));

        // Act
        await notifier.procesarPago(boletas);

        // Assert
        verify(
          mockPagarConPaywayUseCase.execute(
            boletas: boletas,
            datosTarjeta: argThat(
              predicate<DatosTarjetaModel>((d) => d.nroTarjeta == '4532015112830366'), // Sin espacios
              named: 'datosTarjeta',
            ),
          ),
        ).called(1);
      });
    });

    group('resetState', () {
      test('debe reiniciar el estado a valores por defecto', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta);
        notifier.markFieldAsTouched('nombre');

        // Verificar que el estado no es el inicial
        var state = container.read(payWayNotifierProvider).value!;
        expect(state.datosTarjeta, isNotNull);
        expect(state.touchedFields.isNotEmpty, isTrue);

        // Act
        notifier.resetState();

        // Assert
        state = container.read(payWayNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.datosTarjeta, isNull);
        expect(state.validationErrors, isEmpty);
        expect(state.touchedFields, isEmpty);
        expect(state.isFormValid, isFalse);
        expect(state.tipoTarjeta, equals(TipoTarjeta.debito));
        expect(state.cuotas, equals(1));
      });
    });

    group('clearPaymentState', () {
      test('debe limpiar solo el estado de pago manteniendo datos del formulario', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta);
        notifier.markFieldAsTouched('nombre');

        // Simular un estado de pago exitoso
        const resultado = ResultadoPagoModel(statusCode: 201, message: {'success': true});
        notifier.state = AsyncValue.data(
          notifier.state.value!.copyWith(paymentState: PaymentSuccess(resultado: resultado)),
        );

        // Verificar que el estado de pago no es inicial
        var state = container.read(payWayNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentSuccess>());

        // Act
        notifier.clearPaymentState();

        // Assert
        state = container.read(payWayNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.datosTarjeta, equals(datosTarjeta)); // Se mantiene
        expect(state.touchedFields.contains('nombre'), isTrue); // Se mantiene
        expect(state.validationErrors, isEmpty); // Se mantiene
        expect(state.isFormValid, isTrue); // Se mantiene
      });
    });

    group('casos edge', () {
      test('debe manejar campos con solo espacios en blanco', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nombre');
        notifier.markFieldAsTouched('dni');

        const datosTarjeta = DatosTarjetaModel(
          nombre: '   ', // Solo espacios
          dni: '   ', // Solo espacios
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        // Act
        notifier.updateCardData(datosTarjeta);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors['nombre'], equals('El nombre es requerido'));
        expect(state.validationErrors['dni'], equals('El DNI es requerido'));
      });

      test('debe manejar número de tarjeta con múltiples espacios', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nroTarjeta');

        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532  0151  1283  0366', // Múltiples espacios
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        // Act
        notifier.updateCardData(datosTarjeta);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('nroTarjeta'), isFalse); // Válido después de limpiar espacios
      });

      test('debe manejar fecha de expiración con espacios', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('fechaExpiracion');

        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: ' 12/30 ', // Con espacios
        );

        // Act
        notifier.updateCardData(datosTarjeta);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('fechaExpiracion'), isFalse); // Válido después de trim
      });

      test('debe manejar CVV con espacios', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('cvv');

        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: ' 123 ', // Con espacios
          fechaExpiracion: '12/30',
        );

        // Act
        notifier.updateCardData(datosTarjeta);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('cvv'), isFalse); // Válido después de trim
      });

      test('debe manejar DNI con espacios', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('dni');

        const datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: ' 12345678 ', // Con espacios
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        // Act
        notifier.updateCardData(datosTarjeta);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('dni'), isFalse); // Válido después de trim
      });

      test('debe manejar nombre con espacios al inicio y final', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nombre');

        const datosTarjeta = DatosTarjetaModel(
          nombre: ' Juan Pérez ', // Con espacios
          dni: '12345678',
          nroTarjeta: '4532015112830366',
          cvv: '123',
          fechaExpiracion: '12/30',
        );

        // Act
        notifier.updateCardData(datosTarjeta);

        // Assert
        final state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.containsKey('nombre'), isFalse); // Válido después de trim
      });

      test('debe manejar múltiples actualizaciones de campos tocados', () async {
        // Arrange
        await container.read(payWayNotifierProvider.future);
        notifier.markFieldAsTouched('nombre');
        notifier.markFieldAsTouched('dni');
        notifier.markFieldAsTouched('nroTarjeta');

        // Primera actualización con errores
        const datosTarjeta1 = DatosTarjetaModel(
          nombre: '', // Inválido
          dni: '123', // Inválido
          nroTarjeta: '123', // Inválido
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta1);

        var state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.length, equals(3));

        // Segunda actualización corrigiendo algunos errores
        const datosTarjeta2 = DatosTarjetaModel(
          nombre: 'Juan Pérez', // Válido
          dni: '12345678', // Válido
          nroTarjeta: '123', // Sigue inválido
          cvv: '123',
          fechaExpiracion: '12/30',
        );
        notifier.updateCardData(datosTarjeta2);

        // Assert
        state = container.read(payWayNotifierProvider).value!;
        expect(state.validationErrors.length, equals(1));
        expect(state.validationErrors.containsKey('nroTarjeta'), isTrue);
        expect(state.validationErrors.containsKey('nombre'), isFalse);
        expect(state.validationErrors.containsKey('dni'), isFalse);
      });
    });
  });
}

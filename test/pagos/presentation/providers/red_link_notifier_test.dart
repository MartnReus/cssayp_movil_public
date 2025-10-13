import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:cssayp_movil/pagos/data/models/red_link_payment_response_model.dart';
import 'package:cssayp_movil/pagos/data/models/resultado_pago_model.dart';
import 'package:cssayp_movil/pagos/domain/usecases/pagar_con_red_link_use_case.dart';
import 'package:cssayp_movil/pagos/presentation/providers/red_link_notifier.dart';
import 'package:cssayp_movil/pagos/presentation/providers/payment_states.dart';
import 'package:cssayp_movil/pagos/presentation/providers/pagos_providers.dart';

import 'red_link_notifier_test.mocks.dart';

@GenerateMocks([PagarConRedLinkUseCase])
void main() {
  group('RedLinkNotifier', () {
    late MockPagarConRedLinkUseCase mockPagarConRedLinkUseCase;
    late ProviderContainer container;
    late RedLinkNotifier notifier;

    setUp(() {
      mockPagarConRedLinkUseCase = MockPagarConRedLinkUseCase();
      container = ProviderContainer(
        overrides: [pagarConRedLinkUseCaseProvider.overrideWithValue(mockPagarConRedLinkUseCase)],
      );
      notifier = container.read(redLinkNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('build() y estado inicial', () {
      test('debe inicializar con estado por defecto', () {
        // Act
        final state = container.read(redLinkNotifierProvider).value!;

        // Assert
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.paymentUrl, isNull);
        expect(state.tokenIdLink, isNull);
        expect(state.referencia, isNull);
        expect(state.boletaId, isNull);
        expect(state.isPaymentUrlAvailable, isFalse);
        expect(state.isMonitoringPayment, isFalse);
      });

      test('debe cargar el use case correctamente', () {
        // Act
        final state = container.read(redLinkNotifierProvider).value!;

        // Assert
        // El use case se carga durante el build() del notifier
        // Verificamos que el notifier esté inicializado correctamente
        expect(notifier, isNotNull);
        expect(state, isNotNull);
      });
    });

    group('iniciarPago', () {
      test('debe iniciar pago exitosamente', () async {
        // Arrange
        const idBoleta = 123;
        const response = RedLinkPaymentResponseModel(
          success: true,
          paymentUrl: 'https://redlink.com/pay/123',
          tokenIdLink: 'token123',
          referencia: 'ref123',
        );

        when(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta)).thenAnswer((_) async => response);

        // Act
        await notifier.iniciarPago(idBoleta: idBoleta);

        // Assert
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentLoading>());
        expect((state.paymentState as PaymentLoading).message, equals('URL de pago generada. Abriendo Red Link...'));
        expect(state.paymentUrl, equals('https://redlink.com/pay/123'));
        expect(state.tokenIdLink, equals('token123'));
        expect(state.referencia, equals('ref123'));
        expect(state.boletaId, equals(idBoleta));
        expect(state.isPaymentUrlAvailable, isTrue);

        verify(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta)).called(1);
      });

      test('debe manejar error en respuesta del use case', () async {
        // Arrange
        const idBoleta = 123;
        const response = RedLinkPaymentResponseModel(
          success: false,
          paymentUrl: '',
          tokenIdLink: '',
          referencia: '',
          error: 'Error al generar URL',
        );

        when(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta)).thenAnswer((_) async => response);

        // Act
        await notifier.iniciarPago(idBoleta: idBoleta);

        // Assert
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentError>());
        expect((state.paymentState as PaymentError).error, equals('Error al generar URL'));
        expect(state.boletaId, equals(idBoleta));

        verify(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta)).called(1);
      });

      test('debe manejar excepción del use case', () async {
        // Arrange
        const idBoleta = 123;

        when(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta)).thenThrow(Exception('Error de red'));

        // Act
        await notifier.iniciarPago(idBoleta: idBoleta);

        // Assert
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentError>());
        expect((state.paymentState as PaymentError).error, contains('Error inesperado'));
        expect((state.paymentState as PaymentError).error, contains('Error de red'));

        verify(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta)).called(1);
      });

      test('debe mostrar estado de carga durante el proceso', () async {
        // Arrange
        const idBoleta = 123;
        const response = RedLinkPaymentResponseModel(
          success: true,
          paymentUrl: 'https://redlink.com/pay/123',
          tokenIdLink: 'token123',
          referencia: 'ref123',
        );

        when(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return response;
        });

        // Act
        final future = notifier.iniciarPago(idBoleta: idBoleta);

        // Verificar estado de carga inicial
        var state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentLoading>());
        expect((state.paymentState as PaymentLoading).message, equals('Generando URL de pago...'));
        expect(state.boletaId, equals(idBoleta));

        // Esperar a que termine
        await future;

        // Verificar estado final
        state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentLoading>());
        expect((state.paymentState as PaymentLoading).message, equals('URL de pago generada. Abriendo Red Link...'));
        expect(state.paymentUrl, equals('https://redlink.com/pay/123'));
      });
    });

    group('iniciarMonitoreo', () {
      test('debe iniciar monitoreo cuando hay boletaId', () async {
        // Arrange
        const idBoleta = 123;
        const statusModel = RedLinkPaymentStatusModel(pagado: true, mensaje: 'Pago exitoso');

        // Configurar el stream del use case
        final streamController = StreamController<RedLinkPaymentStatusModel>();
        when(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).thenAnswer((_) => streamController.stream);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Act
        notifier.iniciarMonitoreo();

        // Verificar estado de monitoreo
        var state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentLoading>());
        expect((state.paymentState as PaymentLoading).message, equals('Esperando confirmación del pago...'));
        expect(state.isMonitoringPayment, isTrue);

        // Simular pago exitoso
        streamController.add(statusModel);
        await Future.delayed(const Duration(milliseconds: 10));

        // Verificar estado final
        state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentSuccess>());
        expect((state.paymentState as PaymentSuccess).resultado.statusCode, equals(200));

        // Cleanup
        await streamController.close();
      });

      test('debe manejar error en el stream de monitoreo', () async {
        // Arrange
        const idBoleta = 123;

        // Configurar el stream del use case
        final streamController = StreamController<RedLinkPaymentStatusModel>();
        when(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).thenAnswer((_) => streamController.stream);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Act
        notifier.iniciarMonitoreo();

        // Simular error en el stream
        streamController.addError('Error de conexión');
        await Future.delayed(const Duration(milliseconds: 10));

        // Verificar estado de error
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentError>());
        expect((state.paymentState as PaymentError).error, contains('Error al monitorear pago'));

        // Cleanup
        await streamController.close();
      });

      test('debe manejar mensaje de error en el status', () async {
        // Arrange
        const idBoleta = 123;
        const statusModel = RedLinkPaymentStatusModel(pagado: false, mensaje: 'Error: Pago rechazado');

        // Configurar el stream del use case
        final streamController = StreamController<RedLinkPaymentStatusModel>();
        when(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).thenAnswer((_) => streamController.stream);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Act
        notifier.iniciarMonitoreo();

        // Simular mensaje de error
        streamController.add(statusModel);
        await Future.delayed(const Duration(milliseconds: 10));

        // Verificar estado de error
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentError>());
        expect((state.paymentState as PaymentError).error, equals('Error: Pago rechazado'));

        // Cleanup
        await streamController.close();
      });

      test('debe cancelar suscripción anterior al iniciar nueva', () async {
        // Arrange
        const idBoleta = 123;

        // Configurar el stream del use case
        final streamController1 = StreamController<RedLinkPaymentStatusModel>();
        final streamController2 = StreamController<RedLinkPaymentStatusModel>();

        when(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).thenAnswer((_) => streamController1.stream);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Act - Primera suscripción
        notifier.iniciarMonitoreo();

        // Cambiar el mock para la segunda suscripción
        when(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).thenAnswer((_) => streamController2.stream);

        // Segunda suscripción
        notifier.iniciarMonitoreo();

        // Verificar que se llamó dos veces
        verify(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).called(2);

        // Cleanup
        await streamController1.close();
        await streamController2.close();
      });

      test('no debe hacer nada si no hay boletaId', () {
        // Arrange - Estado inicial sin boletaId
        final initialState = container.read(redLinkNotifierProvider).value!;
        expect(initialState.boletaId, isNull);

        // Act
        notifier.iniciarMonitoreo();

        // Assert - El estado no debe cambiar
        final finalState = container.read(redLinkNotifierProvider).value!;
        expect(finalState, equals(initialState));

        // Verificar que no se llamó al use case
        verifyNever(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: anyNamed('idBoleta'),
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        );
      });
    });

    group('detenerMonitoreo', () {
      test('debe detener el monitoreo correctamente', () async {
        // Arrange
        const idBoleta = 123;

        // Configurar el stream del use case
        final streamController = StreamController<RedLinkPaymentStatusModel>();
        when(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).thenAnswer((_) => streamController.stream);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Iniciar monitoreo
        notifier.iniciarMonitoreo();

        // Act
        notifier.detenerMonitoreo();

        // Assert - El monitoreo se detiene sin errores
        // No hay forma directa de verificar que la suscripción se canceló,
        // pero el método no debe lanzar excepciones

        // Cleanup
        await streamController.close();
      });

      test('debe manejar detener monitoreo cuando no hay suscripción activa', () {
        // Act & Assert - No debe lanzar excepciones
        expect(() => notifier.detenerMonitoreo(), returnsNormally);
      });
    });

    group('verificarEstadoPago', () {
      test('debe verificar estado exitosamente cuando el pago está completado', () async {
        // Arrange
        const idBoleta = 123;
        const statusModel = RedLinkPaymentStatusModel(pagado: true, mensaje: 'Pago exitoso');

        when(mockPagarConRedLinkUseCase.verificarEstado(idBoleta: idBoleta)).thenAnswer((_) async => statusModel);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Act
        await notifier.verificarEstadoPago();

        // Assert
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentSuccess>());
        expect((state.paymentState as PaymentSuccess).resultado.statusCode, equals(200));

        verify(mockPagarConRedLinkUseCase.verificarEstado(idBoleta: idBoleta)).called(1);
      });

      test('debe verificar estado cuando el pago no está completado', () async {
        // Arrange
        const idBoleta = 123;
        const statusModel = RedLinkPaymentStatusModel(pagado: false, mensaje: 'Esperando pago');

        when(mockPagarConRedLinkUseCase.verificarEstado(idBoleta: idBoleta)).thenAnswer((_) async => statusModel);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Act
        await notifier.verificarEstadoPago();

        // Assert
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentLoading>());
        expect((state.paymentState as PaymentLoading).message, equals('Esperando pago'));

        verify(mockPagarConRedLinkUseCase.verificarEstado(idBoleta: idBoleta)).called(1);
      });

      test('debe manejar error en verificación de estado', () async {
        // Arrange
        const idBoleta = 123;

        when(mockPagarConRedLinkUseCase.verificarEstado(idBoleta: idBoleta)).thenThrow(Exception('Error de red'));

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Act
        await notifier.verificarEstadoPago();

        // Assert
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentError>());
        expect((state.paymentState as PaymentError).error, contains('Error al verificar estado'));

        verify(mockPagarConRedLinkUseCase.verificarEstado(idBoleta: idBoleta)).called(1);
      });

      test('no debe hacer nada si no hay boletaId', () async {
        // Arrange - Estado inicial sin boletaId
        final initialState = container.read(redLinkNotifierProvider).value!;
        expect(initialState.boletaId, isNull);

        // Act
        await notifier.verificarEstadoPago();

        // Assert - El estado no debe cambiar
        final finalState = container.read(redLinkNotifierProvider).value!;
        expect(finalState, equals(initialState));

        // Verificar que no se llamó al use case
        verifyNever(mockPagarConRedLinkUseCase.verificarEstado(idBoleta: anyNamed('idBoleta')));
      });
    });

    group('resetState', () {
      test('debe reiniciar el estado a valores por defecto', () async {
        // Arrange
        const idBoleta = 123;
        const paymentUrl = 'https://redlink.com/pay/123';

        // Configurar estado con datos
        notifier.state = AsyncValue.data(
          notifier.state.value!.copyWith(
            boletaId: idBoleta,
            paymentUrl: paymentUrl,
            paymentState: const PaymentLoading(message: 'Procesando...'),
          ),
        );

        // Verificar que el estado no es el inicial
        var state = container.read(redLinkNotifierProvider).value!;
        expect(state.boletaId, equals(idBoleta));
        expect(state.paymentUrl, equals(paymentUrl));
        expect(state.paymentState, isA<PaymentLoading>());

        // Act
        notifier.resetState();

        // Assert
        state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.paymentUrl, isNull);
        expect(state.tokenIdLink, isNull);
        expect(state.referencia, isNull);
        expect(state.boletaId, isNull);
        expect(state.isPaymentUrlAvailable, isFalse);
        expect(state.isMonitoringPayment, isFalse);
      });

      test('debe cancelar suscripción activa al resetear', () async {
        // Arrange
        const idBoleta = 123;

        // Configurar el stream del use case
        final streamController = StreamController<RedLinkPaymentStatusModel>();
        when(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).thenAnswer((_) => streamController.stream);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Iniciar monitoreo
        notifier.iniciarMonitoreo();

        // Act
        notifier.resetState();

        // Assert - El reset se completa sin errores
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.boletaId, isNull);

        // Cleanup
        await streamController.close();
      });
    });

    group('clearPaymentState', () {
      test('debe limpiar solo el estado de pago manteniendo otros datos', () async {
        // Arrange
        const idBoleta = 123;
        const paymentUrl = 'https://redlink.com/pay/123';
        const tokenIdLink = 'token123';
        const referencia = 'ref123';

        // Configurar estado con datos
        notifier.state = AsyncValue.data(
          notifier.state.value!.copyWith(
            boletaId: idBoleta,
            paymentUrl: paymentUrl,
            tokenIdLink: tokenIdLink,
            referencia: referencia,
            paymentState: const PaymentLoading(message: 'Procesando...'),
          ),
        );

        // Verificar que el estado de pago no es inicial
        var state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentLoading>());

        // Act
        notifier.clearPaymentState();

        // Assert
        state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.boletaId, equals(idBoleta)); // Se mantiene
        expect(state.paymentUrl, equals(paymentUrl)); // Se mantiene
        expect(state.tokenIdLink, equals(tokenIdLink)); // Se mantiene
        expect(state.referencia, equals(referencia)); // Se mantiene
        expect(state.isPaymentUrlAvailable, isTrue); // Se mantiene
      });
    });

    group('RedLinkState', () {
      test('debe crear instancia con valores por defecto', () {
        // Act
        const state = RedLinkState();

        // Assert
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.paymentUrl, isNull);
        expect(state.tokenIdLink, isNull);
        expect(state.referencia, isNull);
        expect(state.boletaId, isNull);
        expect(state.isPaymentUrlAvailable, isFalse);
        expect(state.isMonitoringPayment, isFalse);
      });

      test('debe crear instancia con valores personalizados', () {
        // Arrange
        const paymentState = PaymentLoading(message: 'Procesando...');
        const paymentUrl = 'https://redlink.com/pay/123';
        const tokenIdLink = 'token123';
        const referencia = 'ref123';
        const boletaId = 123;

        // Act
        const state = RedLinkState(
          paymentState: paymentState,
          paymentUrl: paymentUrl,
          tokenIdLink: tokenIdLink,
          referencia: referencia,
          boletaId: boletaId,
        );

        // Assert
        expect(state.paymentState, equals(paymentState));
        expect(state.paymentUrl, equals(paymentUrl));
        expect(state.tokenIdLink, equals(tokenIdLink));
        expect(state.referencia, equals(referencia));
        expect(state.boletaId, equals(boletaId));
        expect(state.isPaymentUrlAvailable, isTrue);
        expect(state.isMonitoringPayment, isTrue);
      });

      test('debe actualizar estado con copyWith', () {
        // Arrange
        const stateOriginal = RedLinkState(paymentUrl: 'https://redlink.com/pay/123', boletaId: 123);

        // Act
        final stateNuevo = stateOriginal.copyWith(
          paymentState: const PaymentLoading(message: 'Nuevo estado'),
          tokenIdLink: 'nuevoToken',
        );

        // Assert
        expect(stateNuevo, isNot(same(stateOriginal)));
        expect(stateOriginal.paymentState, isA<PaymentInitial>());
        expect(stateNuevo.paymentState, isA<PaymentLoading>());
        expect(stateOriginal.tokenIdLink, isNull);
        expect(stateNuevo.tokenIdLink, equals('nuevoToken'));
        expect(stateNuevo.paymentUrl, equals('https://redlink.com/pay/123')); // Se mantiene
        expect(stateNuevo.boletaId, equals(123)); // Se mantiene
      });

      test('debe calcular isPaymentUrlAvailable correctamente', () {
        // Test con URL válida
        const stateConUrl = RedLinkState(paymentUrl: 'https://redlink.com/pay/123');
        expect(stateConUrl.isPaymentUrlAvailable, isTrue);

        // Test con URL vacía
        const stateConUrlVacia = RedLinkState(paymentUrl: '');
        expect(stateConUrlVacia.isPaymentUrlAvailable, isFalse);

        // Test sin URL
        const stateSinUrl = RedLinkState();
        expect(stateSinUrl.isPaymentUrlAvailable, isFalse);
      });

      test('debe calcular isMonitoringPayment correctamente', () {
        // Test con estado de carga
        const stateMonitoreando = RedLinkState(paymentState: PaymentLoading(message: 'Monitoreando...'));
        expect(stateMonitoreando.isMonitoringPayment, isTrue);

        // Test con estado inicial
        const stateInicial = RedLinkState();
        expect(stateInicial.isMonitoringPayment, isFalse);

        // Test con estado de éxito
        const stateExito = RedLinkState(
          paymentState: PaymentSuccess(resultado: ResultadoPagoModel(statusCode: 200, message: {})),
        );
        expect(stateExito.isMonitoringPayment, isFalse);
      });
    });

    group('casos edge', () {
      test('debe manejar múltiples llamadas a iniciarPago', () async {
        // Arrange
        const idBoleta1 = 123;
        const idBoleta2 = 456;
        const response1 = RedLinkPaymentResponseModel(
          success: true,
          paymentUrl: 'https://redlink.com/pay/123',
          tokenIdLink: 'token123',
          referencia: 'ref123',
        );
        const response2 = RedLinkPaymentResponseModel(
          success: true,
          paymentUrl: 'https://redlink.com/pay/456',
          tokenIdLink: 'token456',
          referencia: 'ref456',
        );

        when(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta1)).thenAnswer((_) async => response1);
        when(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta2)).thenAnswer((_) async => response2);

        // Act
        await notifier.iniciarPago(idBoleta: idBoleta1);
        var state = container.read(redLinkNotifierProvider).value!;
        expect(state.boletaId, equals(idBoleta1));
        expect(state.paymentUrl, equals('https://redlink.com/pay/123'));

        await notifier.iniciarPago(idBoleta: idBoleta2);
        state = container.read(redLinkNotifierProvider).value!;
        expect(state.boletaId, equals(idBoleta2));
        expect(state.paymentUrl, equals('https://redlink.com/pay/456'));

        // Assert
        verify(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta1)).called(1);
        verify(mockPagarConRedLinkUseCase.iniciarPago(idBoleta: idBoleta2)).called(1);
      });

      test('debe manejar stream que emite múltiples estados', () async {
        // Arrange
        const idBoleta = 123;

        // Configurar el stream del use case
        final streamController = StreamController<RedLinkPaymentStatusModel>();
        when(
          mockPagarConRedLinkUseCase.monitorearPago(
            idBoleta: idBoleta,
            intervalo: anyNamed('intervalo'),
            maxIntentos: anyNamed('maxIntentos'),
          ),
        ).thenAnswer((_) => streamController.stream);

        // Configurar estado inicial con boletaId
        notifier.state = AsyncValue.data(notifier.state.value!.copyWith(boletaId: idBoleta));

        // Act
        notifier.iniciarMonitoreo();

        // Emitir múltiples estados
        streamController.add(const RedLinkPaymentStatusModel(pagado: false, mensaje: 'Esperando pago'));
        await Future.delayed(const Duration(milliseconds: 10));

        streamController.add(const RedLinkPaymentStatusModel(pagado: false, mensaje: 'Procesando pago'));
        await Future.delayed(const Duration(milliseconds: 10));

        streamController.add(const RedLinkPaymentStatusModel(pagado: true, mensaje: 'Pago exitoso'));
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentSuccess>());

        // Cleanup
        await streamController.close();
      });

      test('debe manejar detener monitoreo múltiples veces', () {
        // Act & Assert - No debe lanzar excepciones
        expect(() {
          notifier.detenerMonitoreo();
          notifier.detenerMonitoreo();
          notifier.detenerMonitoreo();
        }, returnsNormally);
      });

      test('debe manejar resetState múltiples veces', () {
        // Arrange
        notifier.state = AsyncValue.data(
          notifier.state.value!.copyWith(
            boletaId: 123,
            paymentUrl: 'https://redlink.com/pay/123',
            paymentState: const PaymentLoading(message: 'Procesando...'),
          ),
        );

        // Act & Assert - No debe lanzar excepciones
        expect(() {
          notifier.resetState();
          notifier.resetState();
          notifier.resetState();
        }, returnsNormally);

        // Verificar que el estado final es el inicial
        final state = container.read(redLinkNotifierProvider).value!;
        expect(state.paymentState, isA<PaymentInitial>());
        expect(state.boletaId, isNull);
        expect(state.paymentUrl, isNull);
      });
    });
  });
}

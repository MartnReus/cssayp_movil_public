import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:cssayp_movil/pagos/data/models/red_link_payment_response_model.dart';
import 'package:cssayp_movil/pagos/domain/repositories/red_link_repository.dart';
import 'package:cssayp_movil/pagos/domain/usecases/pagar_con_red_link_use_case.dart';

import 'pagar_con_red_link_use_case_test.mocks.dart';

@GenerateMocks([RedLinkRepository])
void main() {
  group('PagarConRedLinkUseCase', () {
    late PagarConRedLinkUseCase useCase;
    late MockRedLinkRepository mockRedLinkRepository;

    setUp(() {
      mockRedLinkRepository = MockRedLinkRepository();
      useCase = PagarConRedLinkUseCase(repository: mockRedLinkRepository);
    });

    group('método iniciarPago', () {
      const int idBoleta = 12345;

      test('debe retornar RedLinkPaymentResponseModel exitoso cuando se genera URL correctamente', () async {
        // Arrange
        const expectedResponse = RedLinkPaymentResponseModel(
          paymentUrl: 'https://redlink.com/payment/12345',
          tokenIdLink: 'token123456',
          referencia: 'REF123456',
          success: true,
        );

        when(mockRedLinkRepository.generarUrlPago(idBoleta: idBoleta)).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await useCase.iniciarPago(idBoleta: idBoleta);

        // Assert
        expect(result, equals(expectedResponse));
        expect(result.success, equals(true));
        expect(result.paymentUrl, equals('https://redlink.com/payment/12345'));
        expect(result.tokenIdLink, equals('token123456'));
        expect(result.referencia, equals('REF123456'));

        verify(mockRedLinkRepository.generarUrlPago(idBoleta: idBoleta)).called(1);
      });

      test('debe retornar RedLinkPaymentResponseModel con error cuando falla la generación', () async {
        // Arrange
        const expectedResponse = RedLinkPaymentResponseModel(
          paymentUrl: '',
          tokenIdLink: '',
          referencia: '',
          success: false,
          error: 'Error al generar URL de pago',
        );

        when(mockRedLinkRepository.generarUrlPago(idBoleta: idBoleta)).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await useCase.iniciarPago(idBoleta: idBoleta);

        // Assert
        expect(result, equals(expectedResponse));
        expect(result.success, equals(false));
        expect(result.error, equals('Error al generar URL de pago'));

        verify(mockRedLinkRepository.generarUrlPago(idBoleta: idBoleta)).called(1);
      });

      test('debe manejar excepciones del repository', () async {
        // Arrange
        when(mockRedLinkRepository.generarUrlPago(idBoleta: idBoleta)).thenThrow(Exception('Error de conexión'));

        // Act & Assert
        expect(() => useCase.iniciarPago(idBoleta: idBoleta), throwsException);

        verify(mockRedLinkRepository.generarUrlPago(idBoleta: idBoleta)).called(1);
      });

      test('debe pasar el idBoleta correcto al repository', () async {
        // Arrange
        const expectedResponse = RedLinkPaymentResponseModel(
          paymentUrl: 'https://redlink.com/payment/12345',
          tokenIdLink: 'token123456',
          referencia: 'REF123456',
          success: true,
        );

        when(
          mockRedLinkRepository.generarUrlPago(idBoleta: anyNamed('idBoleta')),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        await useCase.iniciarPago(idBoleta: idBoleta);

        // Assert
        verify(mockRedLinkRepository.generarUrlPago(idBoleta: idBoleta)).called(1);
      });
    });

    group('método monitorearPago', () {
      const int idBoleta = 12345;

      test('debe emitir estados de pago correctamente', () async {
        // Arrange
        const estadoPendiente = RedLinkPaymentStatusModel(
          pagado: false,
          estado: 'PENDIENTE',
          mensaje: 'Pago pendiente',
        );
        const estadoExitoso = RedLinkPaymentStatusModel(pagado: true, estado: 'APROBADO', mensaje: 'Pago exitoso');

        int callCount = 0;
        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? estadoPendiente : estadoExitoso;
        });

        // Act
        final stream = useCase.monitorearPago(idBoleta: idBoleta, intervalo: Duration(milliseconds: 100));
        final results = await stream.take(2).toList();

        // Assert
        expect(results.length, equals(2));
        expect(results[0], equals(estadoPendiente));
        expect(results[1], equals(estadoExitoso));
        expect(results[1].pagado, equals(true));

        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(2);
      });

      test('debe terminar el monitoreo cuando el pago es exitoso', () async {
        // Arrange
        const estadoExitoso = RedLinkPaymentStatusModel(pagado: true, estado: 'APROBADO', mensaje: 'Pago exitoso');

        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenAnswer((_) async => estadoExitoso);

        // Act
        final stream = useCase.monitorearPago(idBoleta: idBoleta, intervalo: Duration(milliseconds: 100));
        final results = await stream.take(1).toList();

        // Assert
        expect(results.length, equals(1));
        expect(results[0], equals(estadoExitoso));
        expect(results[0].pagado, equals(true));

        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(1);
      });

      test('debe manejar errores durante el monitoreo', () async {
        // Arrange
        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenThrow(Exception('Error de conexión'));

        // Act
        final stream = useCase.monitorearPago(idBoleta: idBoleta, intervalo: Duration(milliseconds: 100));
        final results = await stream.take(1).toList();

        // Assert
        expect(results.length, equals(1));
        expect(results[0].pagado, equals(false));
        expect(results[0].mensaje, contains('Error al verificar estado'));

        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(1);
      });

      test('debe respetar el número máximo de intentos', () async {
        // Arrange
        const estadoPendiente = RedLinkPaymentStatusModel(
          pagado: false,
          estado: 'PENDIENTE',
          mensaje: 'Pago pendiente',
        );

        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenAnswer((_) async => estadoPendiente);

        // Act
        final stream = useCase.monitorearPago(
          idBoleta: idBoleta,
          intervalo: Duration(milliseconds: 50),
          maxIntentos: 3,
        );
        final results = await stream.take(3).toList();

        // Assert
        expect(results.length, equals(3));
        expect(results.every((estado) => estado.pagado == false), equals(true));

        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(3);
      });

      test('debe usar el intervalo de tiempo correcto', () async {
        // Arrange
        const estadoPendiente = RedLinkPaymentStatusModel(
          pagado: false,
          estado: 'PENDIENTE',
          mensaje: 'Pago pendiente',
        );

        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenAnswer((_) async => estadoPendiente);

        // Act
        final stopwatch = Stopwatch()..start();
        final stream = useCase.monitorearPago(
          idBoleta: idBoleta,
          intervalo: Duration(milliseconds: 200),
          maxIntentos: 2,
        );
        await stream.take(2).toList();
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(200));
        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(2);
      });
    });

    group('método verificarEstado', () {
      const int idBoleta = 12345;

      test('debe retornar RedLinkPaymentStatusModel cuando el pago está pendiente', () async {
        // Arrange
        const expectedStatus = RedLinkPaymentStatusModel(pagado: false, estado: 'PENDIENTE', mensaje: 'Pago pendiente');

        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenAnswer((_) async => expectedStatus);

        // Act
        final result = await useCase.verificarEstado(idBoleta: idBoleta);

        // Assert
        expect(result, equals(expectedStatus));
        expect(result.pagado, equals(false));
        expect(result.estado, equals('PENDIENTE'));

        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(1);
      });

      test('debe retornar RedLinkPaymentStatusModel cuando el pago está aprobado', () async {
        // Arrange
        const expectedStatus = RedLinkPaymentStatusModel(pagado: true, estado: 'APROBADO', mensaje: 'Pago exitoso');

        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenAnswer((_) async => expectedStatus);

        // Act
        final result = await useCase.verificarEstado(idBoleta: idBoleta);

        // Assert
        expect(result, equals(expectedStatus));
        expect(result.pagado, equals(true));
        expect(result.estado, equals('APROBADO'));

        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(1);
      });

      test('debe retornar RedLinkPaymentStatusModel cuando el pago fue rechazado', () async {
        // Arrange
        const expectedStatus = RedLinkPaymentStatusModel(
          pagado: false,
          estado: 'RECHAZADO',
          mensaje: 'Pago rechazado por el banco',
        );

        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenAnswer((_) async => expectedStatus);

        // Act
        final result = await useCase.verificarEstado(idBoleta: idBoleta);

        // Assert
        expect(result, equals(expectedStatus));
        expect(result.pagado, equals(false));
        expect(result.estado, equals('RECHAZADO'));

        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(1);
      });

      test('debe manejar excepciones del repository', () async {
        // Arrange
        when(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).thenThrow(Exception('Error de conexión'));

        // Act & Assert
        expect(() => useCase.verificarEstado(idBoleta: idBoleta), throwsException);

        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(1);
      });

      test('debe pasar el idBoleta correcto al repository', () async {
        // Arrange
        const expectedStatus = RedLinkPaymentStatusModel(pagado: true, estado: 'APROBADO', mensaje: 'Pago exitoso');

        when(
          mockRedLinkRepository.verificarEstadoPago(idBoleta: anyNamed('idBoleta')),
        ).thenAnswer((_) async => expectedStatus);

        // Act
        await useCase.verificarEstado(idBoleta: idBoleta);

        // Assert
        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(1);
      });
    });

    group('integración con RedLinkRepository', () {
      const int idBoleta = 12345;

      test('debe delegar correctamente las llamadas al repository', () async {
        // Arrange
        const expectedResponse = RedLinkPaymentResponseModel(
          paymentUrl: 'https://redlink.com/payment/12345',
          tokenIdLink: 'token123456',
          referencia: 'REF123456',
          success: true,
        );
        const expectedStatus = RedLinkPaymentStatusModel(pagado: true, estado: 'APROBADO', mensaje: 'Pago exitoso');

        when(
          mockRedLinkRepository.generarUrlPago(idBoleta: anyNamed('idBoleta')),
        ).thenAnswer((_) async => expectedResponse);
        when(
          mockRedLinkRepository.verificarEstadoPago(idBoleta: anyNamed('idBoleta')),
        ).thenAnswer((_) async => expectedStatus);

        // Act
        final response = await useCase.iniciarPago(idBoleta: idBoleta);
        final status = await useCase.verificarEstado(idBoleta: idBoleta);

        // Assert
        expect(response, equals(expectedResponse));
        expect(status, equals(expectedStatus));

        verify(mockRedLinkRepository.generarUrlPago(idBoleta: idBoleta)).called(1);
        verify(mockRedLinkRepository.verificarEstadoPago(idBoleta: idBoleta)).called(1);
        verifyNoMoreInteractions(mockRedLinkRepository);
      });

      test('debe manejar múltiples llamadas consecutivas', () async {
        // Arrange
        const expectedResponse1 = RedLinkPaymentResponseModel(
          paymentUrl: 'https://redlink.com/payment/12345',
          tokenIdLink: 'token123456',
          referencia: 'REF123456',
          success: true,
        );
        const expectedResponse2 = RedLinkPaymentResponseModel(
          paymentUrl: 'https://redlink.com/payment/67890',
          tokenIdLink: 'token789012',
          referencia: 'REF789012',
          success: true,
        );

        when(mockRedLinkRepository.generarUrlPago(idBoleta: 12345)).thenAnswer((_) async => expectedResponse1);
        when(mockRedLinkRepository.generarUrlPago(idBoleta: 67890)).thenAnswer((_) async => expectedResponse2);

        // Act
        final result1 = await useCase.iniciarPago(idBoleta: 12345);
        final result2 = await useCase.iniciarPago(idBoleta: 67890);

        // Assert
        expect(result1, equals(expectedResponse1));
        expect(result2, equals(expectedResponse2));

        verify(mockRedLinkRepository.generarUrlPago(idBoleta: 12345)).called(1);
        verify(mockRedLinkRepository.generarUrlPago(idBoleta: 67890)).called(1);
      });
    });
  });
}

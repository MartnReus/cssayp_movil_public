import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/pagos/data/datasources/red_link_data_source.dart';
import 'package:cssayp_movil/config.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'red_link_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group("RedLinkDataSource", () {
    late RedLinkDataSource redLinkDataSource;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      redLinkDataSource = RedLinkDataSource(client: mockClient);
    });

    group("método generarUrlPago", () {
      const int testIdBoleta = 123;

      test("debe retornar RedLinkPaymentResponseModel exitoso cuando el status code es 200", () async {
        // Arrange
        final successResponseBody = json.encode({
          'payment_url': 'https://redlink.com/payment/123',
          'token_id_link': 'token123',
          'referencia': 'ref123',
          'success': true,
        });
        const successResponseStatus = 200;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(true));
        expect(result.paymentUrl, equals('https://redlink.com/payment/123'));
        expect(result.tokenIdLink, equals('token123'));
        expect(result.referencia, equals('ref123'));
        expect(result.error, isNull);
      });

      test("debe retornar RedLinkPaymentResponseModel exitoso cuando el status code es 201", () async {
        // Arrange
        final successResponseBody = json.encode({
          'payment_url': 'https://redlink.com/payment/456',
          'token_id_link': 'token456',
          'referencia': 'ref456',
          'success': true,
        });
        const successResponseStatus = 201;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(true));
        expect(result.paymentUrl, equals('https://redlink.com/payment/456'));
        expect(result.tokenIdLink, equals('token456'));
        expect(result.referencia, equals('ref456'));
        expect(result.error, isNull);
      });

      test("debe retornar RedLinkPaymentResponseModel con error cuando el status code no es 200 o 201", () async {
        // Arrange
        final errorResponseBody = json.encode({'error': 'Error al generar URL de pago', 'success': false});
        const errorResponseStatus = 400;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(false));
        expect(result.paymentUrl, equals(''));
        expect(result.tokenIdLink, equals(''));
        expect(result.referencia, equals(''));
        expect(result.error, equals('Error al generar URL de pago'));
      });

      test("debe retornar error por defecto cuando no hay campo error en la respuesta", () async {
        // Arrange
        final errorResponseBody = json.encode({'success': false});
        const errorResponseStatus = 500;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(false));
        expect(result.error, equals('Error desconocido al generar URL de pago'));
      });

      test("debe manejar SocketException y retornar mensaje de error de conexión", () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(SocketException('No internet connection'));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(false));
        expect(result.paymentUrl, equals(''));
        expect(result.tokenIdLink, equals(''));
        expect(result.referencia, equals(''));
        expect(result.error, equals('Error en la conexión con el servidor'));
      });

      test("debe manejar TimeoutException y retornar mensaje de error de tiempo agotado", () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(TimeoutException('Request timeout'));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(false));
        expect(result.paymentUrl, equals(''));
        expect(result.tokenIdLink, equals(''));
        expect(result.referencia, equals(''));
        expect(result.error, equals('Tiempo de espera agotado'));
      });

      test("debe manejar FormatException y retornar mensaje de error del servidor", () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(FormatException('Invalid JSON format'));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(false));
        expect(result.paymentUrl, equals(''));
        expect(result.tokenIdLink, equals(''));
        expect(result.referencia, equals(''));
        expect(result.error, equals('Error del servidor, intente nuevamente más tarde'));
      });

      test("debe manejar excepciones genéricas y retornar mensaje de error inesperado", () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(false));
        expect(result.paymentUrl, equals(''));
        expect(result.tokenIdLink, equals(''));
        expect(result.referencia, equals(''));
        expect(result.error, equals('Error inesperado: Exception: Unexpected error'));
      });

      test("debe enviar la URL correcta y headers apropiados", () async {
        // Arrange
        final successResponseBody = json.encode({
          'payment_url': 'https://redlink.com/payment/123',
          'token_id_link': 'token123',
          'referencia': 'ref123',
          'success': true,
        });
        const successResponseStatus = 200;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        verify(
          mockClient.get(
            Uri.parse('${AppConfig.cgaUrl}/ws/bol/generar-url-pago/$testIdBoleta'),
            headers: {'Accept': 'application/json'},
          ),
        ).called(1);
      });

      test("debe manejar respuesta con JSON inválido", () async {
        // Arrange
        const invalidJsonResponse = 'invalid json response';
        const successResponseStatus = 200;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(invalidJsonResponse, successResponseStatus));

        // Act
        final result = await redLinkDataSource.generarUrlPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.success, equals(false));
        expect(result.error, equals('Error del servidor, intente nuevamente más tarde'));
      });
    });

    group("método verificarEstadoPago", () {
      const int testIdBoleta = 456;

      test("debe retornar RedLinkPaymentStatusModel exitoso cuando el status code es 200", () async {
        // Arrange
        final successResponseBody = json.encode({
          'pagado': true,
          'estado': 'APROBADO',
          'mensaje': 'Pago procesado exitosamente',
        });
        const successResponseStatus = 200;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(true));
        expect(result.estado, equals('APROBADO'));
        expect(result.mensaje, equals('Pago procesado exitosamente'));
      });

      test("debe retornar RedLinkPaymentStatusModel con pagado false cuando el status code no es 200", () async {
        // Arrange
        final errorResponseBody = json.encode({
          'pagado': false,
          'estado': 'RECHAZADO',
          'mensaje': 'Error al verificar estado del pago',
        });
        const errorResponseStatus = 400;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(false));
        expect(result.mensaje, equals('Error al verificar estado del pago'));
      });

      test("debe manejar excepciones y retornar mensaje de error de conexión", () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(SocketException('No internet connection'));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(false));
        expect(result.mensaje, equals('Error de conexión al verificar estado del pago'));
      });

      test("debe manejar TimeoutException y retornar mensaje de error de conexión", () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(TimeoutException('Request timeout'));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(false));
        expect(result.mensaje, equals('Error de conexión al verificar estado del pago'));
      });

      test("debe manejar FormatException y retornar mensaje de error de conexión", () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(FormatException('Invalid JSON format'));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(false));
        expect(result.mensaje, equals('Error de conexión al verificar estado del pago'));
      });

      test("debe manejar excepciones genéricas y retornar mensaje de error de conexión", () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(false));
        expect(result.mensaje, equals('Error de conexión al verificar estado del pago'));
      });

      test("debe enviar la URL correcta y headers apropiados", () async {
        // Arrange
        final successResponseBody = json.encode({
          'pagado': true,
          'estado': 'APROBADO',
          'mensaje': 'Pago procesado exitosamente',
        });
        const successResponseStatus = 200;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        verify(
          mockClient.get(
            Uri.parse('${AppConfig.pagoApiURL}/ws/bol/verificar-estado-pago/$testIdBoleta'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          ),
        ).called(1);
      });

      test("debe manejar respuesta con JSON inválido", () async {
        // Arrange
        const invalidJsonResponse = 'invalid json response';
        const successResponseStatus = 200;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(invalidJsonResponse, successResponseStatus));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(false));
        expect(result.mensaje, equals('Error de conexión al verificar estado del pago'));
      });

      test("debe manejar respuesta con pagado como entero 1", () async {
        // Arrange
        final successResponseBody = json.encode({
          'pagado': 1,
          'estado': 'APROBADO',
          'mensaje': 'Pago procesado exitosamente',
        });
        const successResponseStatus = 200;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(true));
        expect(result.estado, equals('APROBADO'));
        expect(result.mensaje, equals('Pago procesado exitosamente'));
      });

      test("debe manejar respuesta con pagado como entero 0", () async {
        // Arrange
        final successResponseBody = json.encode({'pagado': 0, 'estado': 'PENDIENTE', 'mensaje': 'Pago pendiente'});
        const successResponseStatus = 200;

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        final result = await redLinkDataSource.verificarEstadoPago(idBoleta: testIdBoleta);

        // Assert
        expect(result.pagado, equals(false));
        expect(result.estado, equals('PENDIENTE'));
        expect(result.mensaje, equals('Pago pendiente'));
      });
    });
  });
}

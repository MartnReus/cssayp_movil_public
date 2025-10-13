import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/config.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'payway_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group("PaywayDataSource", () {
    late PaywayDataSource paywayDataSource;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      paywayDataSource = PaywayDataSource(client: mockClient);
    });

    group("método pagar", () {
      late List<BoletaAPagarEntity> boletas;
      late DatosTarjetaModel datosTarjeta;

      setUp(() {
        boletas = [BoletaAPagarEntity(idBoleta: 1, caratula: 'Test Caratula 1', monto: 100.0, nroAfiliado: 12345)];

        datosTarjeta = DatosTarjetaModel(
          nombre: 'Juan Pérez',
          dni: '12345678',
          nroTarjeta: '1234567890123456',
          cvv: '123',
          fechaExpiracion: '12/25',
          tipoTarjeta: TipoTarjeta.credito,
          cuotas: 3,
        );
      });

      test("debe retornar ResultadoPagoModel exitoso cuando el status code es 201", () async {
        // Arrange
        final successResponseBody = json.encode({
          'success': true,
          'transaction_id': 'TXN123456',
          'message': 'Pago procesado exitosamente',
        });
        const successResponseStatus = 201;

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        final result = await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result.statusCode, equals(201));
        expect(result.message, isA<Map<String, dynamic>>());
        final messageMap = result.message as Map<String, dynamic>;
        expect(messageMap['success'], equals(true));
        expect(messageMap['transaction_id'], equals('TXN123456'));
      });

      test("debe retornar ResultadoPagoModel con error cuando el status code no es 201", () async {
        // Arrange
        final errorResponseBody = json.encode({
          'success': false,
          'error': 'Tarjeta rechazada',
          'code': 'CARD_DECLINED',
        });
        const errorResponseStatus = 400;

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

        // Act
        final result = await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result.statusCode, equals(400));
        expect(result.message, isA<Map<String, dynamic>>());
        final messageMap = result.message as Map<String, dynamic>;
        expect(messageMap['success'], equals(false));
        expect(messageMap['error'], equals('Tarjeta rechazada'));
      });

      test("debe manejar SocketException y retornar mensaje de error de conexión", () async {
        // Arrange
        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenThrow(SocketException('No internet connection'));

        // Act
        final result = await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result.statusCode, equals(0));
        expect(result.message, equals('Error en la conexión con el servidor'));
      });

      test("debe manejar TimeoutException y retornar mensaje de error de conexión", () async {
        // Arrange
        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenThrow(TimeoutException('Request timeout'));

        // Act
        final result = await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result.statusCode, equals(0));
        expect(result.message, equals('Error en la conexión con el servidor'));
      });

      test("debe manejar FormatException y retornar mensaje de error del servidor", () async {
        // Arrange
        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenThrow(FormatException('Invalid JSON format'));

        // Act
        final result = await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result.statusCode, equals(500));
        expect(result.message, equals('Error del servidor, intente nuevamente más tarde'));
      });

      test("debe manejar excepciones genéricas y retornar mensaje de error inesperado", () async {
        // Arrange
        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result.statusCode, equals(0));
        expect(result.message, equals('Error inesperado al procesar el pago'));
      });

      test("debe enviar los datos correctos en el body de la petición", () async {
        // Arrange
        final successResponseBody = json.encode({'success': true});
        const successResponseStatus = 201;

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        // Act
        await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        final expectedBody = json.encode({
          'datos_tarjeta': datosTarjeta.toJson(),
          'boletas': boletas.map((boleta) => boleta.toJson()).toList(),
        });

        verify(
          mockClient.post(
            Uri.parse('${AppConfig.pagoApiURL}/api/checkout/payment-prisma'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: expectedBody,
          ),
        ).called(1);
      });

      test("debe manejar respuesta con JSON inválido", () async {
        // Arrange
        const invalidJsonResponse = 'invalid json response';
        const successResponseStatus = 201;

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(invalidJsonResponse, successResponseStatus));

        // Act
        final result = await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);

        // Assert
        expect(result.statusCode, equals(500));
        expect(result.message, equals('Error del servidor, intente nuevamente más tarde'));
      });
    });
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:cssayp_movil/config.dart';

import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'comprobantes_remote_data_source_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  late ComprobantesRemoteDataSource dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = ComprobantesRemoteDataSource(client: mockHttpClient);
  });

  group('obtenerDatosComprobante', () {
    const testIdBoleta = 123;
    final testUrl = '${AppConfig.pagoApiURL}/api/checkout/datosComprobante/$testIdBoleta';

    test('debería devolver DatosComprobanteSuccessResponse cuando el código de estado sea 200', () async {
      // Arrange
      final mockResponseBody = {
        'id': 456,
        'fecha': '2025-10-26',
        'importe': '1500.00',
        'boletas_pagadas': [
          {
            'id': 789,
            'importe': '1500.00',
            'caratula': 'Test Caratula',
            'mvc': 'TEST-123',
            'tipo_juicio': 'Civil',
            'montos_organismos': [
              {'circunscripcion': 1, 'organismo': 'Organismo Test', 'monto': 1500.0},
            ],
          },
        ],
        'comprobante_link': 'https://example.com/comprobante.pdf',
        'metodo_pago': 'Tarjeta de crédito',
      };

      when(
        mockHttpClient.get(Uri.parse(testUrl)),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockResponseBody), 200));

      // Act
      final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

      // Assert
      expect(result, isA<DatosComprobanteSuccessResponse>());
      final successResponse = result as DatosComprobanteSuccessResponse;
      expect(successResponse.statusCode, 200);
      expect(successResponse.id, 456);
      expect(successResponse.fecha, '2025-10-26');
      expect(successResponse.importe, '1500.00');
      expect(successResponse.boletasPagadas.length, 1);
      expect(successResponse.comprobanteLink, 'https://example.com/comprobante.pdf');
      expect(successResponse.metodoPago, 'Tarjeta de crédito');
      verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
    });

    test('debería devolver DatosComprobanteGenericErrorResponse cuando el código de estado sea 400', () async {
      // Arrange
      final mockErrorBody = {'error_message': 'Solicitud inválida'};

      when(
        mockHttpClient.get(Uri.parse(testUrl)),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockErrorBody), 400));

      // Act
      final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

      // Assert
      expect(result, isA<DatosComprobanteGenericErrorResponse>());
      final errorResponse = result as DatosComprobanteGenericErrorResponse;
      expect(errorResponse.statusCode, 400);
      expect(errorResponse.errorMessage, 'Solicitud inválida');
      verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
    });

    test('debería devolver DatosComprobanteGenericErrorResponse cuando el código de estado sea 404', () async {
      // Arrange
      final mockErrorBody = {'error_message': 'Comprobante no encontrado'};

      when(
        mockHttpClient.get(Uri.parse(testUrl)),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockErrorBody), 404));

      // Act
      final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

      // Assert
      expect(result, isA<DatosComprobanteGenericErrorResponse>());
      final errorResponse = result as DatosComprobanteGenericErrorResponse;
      expect(errorResponse.statusCode, 404);
      expect(errorResponse.errorMessage, 'Comprobante no encontrado');
      verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
    });

    test('debería devolver DatosComprobanteGenericErrorResponse cuando el código de estado sea 500', () async {
      // Arrange
      final mockErrorBody = {'error_message': 'Error interno del servidor'};

      when(
        mockHttpClient.get(Uri.parse(testUrl)),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockErrorBody), 500));

      // Act
      final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

      // Assert
      expect(result, isA<DatosComprobanteGenericErrorResponse>());
      final errorResponse = result as DatosComprobanteGenericErrorResponse;
      expect(errorResponse.statusCode, 500);
      expect(errorResponse.errorMessage, 'Error interno del servidor');
      verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
    });

    test(
      'debería devolver DatosComprobanteGenericErrorResponse con mensaje de error predeterminado cuando falta error_message',
      () async {
        // Arrange
        final mockErrorBody = {};

        when(
          mockHttpClient.get(Uri.parse(testUrl)),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockErrorBody), 400));

        // Act
        final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

        // Assert
        expect(result, isA<DatosComprobanteGenericErrorResponse>());
        final errorResponse = result as DatosComprobanteGenericErrorResponse;
        expect(errorResponse.statusCode, 400);
        expect(errorResponse.errorMessage, 'Error desconocido');
        verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
      },
    );

    test(
      'debería devolver DatosComprobanteGenericErrorResponse con statusCode 0 cuando ocurra SocketException',
      () async {
      // Arrange
      when(mockHttpClient.get(Uri.parse(testUrl))).thenThrow(const SocketException('No Internet'));

      // Act
      final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

      // Assert
      expect(result, isA<DatosComprobanteGenericErrorResponse>());
      final errorResponse = result as DatosComprobanteGenericErrorResponse;
      expect(errorResponse.statusCode, 0);
      expect(errorResponse.errorMessage, 'Error en la conexión con el servidor');
      verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
    });

    test(
      'debería devolver DatosComprobanteGenericErrorResponse con statusCode 0 cuando ocurra TimeoutException',
      () async {
      // Arrange
      when(mockHttpClient.get(Uri.parse(testUrl))).thenThrow(TimeoutException('Request timeout'));

      // Act
      final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

      // Assert
      expect(result, isA<DatosComprobanteGenericErrorResponse>());
      final errorResponse = result as DatosComprobanteGenericErrorResponse;
      expect(errorResponse.statusCode, 0);
      expect(errorResponse.errorMessage, 'Error en la conexión con el servidor');
      verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
    });

    test(
      'debería devolver DatosComprobanteGenericErrorResponse con statusCode 0 cuando ocurra FormatException',
      () async {
      // Arrange
      when(mockHttpClient.get(Uri.parse(testUrl))).thenAnswer((_) async => http.Response('Invalid JSON', 200));

      // Act
      final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

      // Assert
      expect(result, isA<DatosComprobanteGenericErrorResponse>());
      final errorResponse = result as DatosComprobanteGenericErrorResponse;
      expect(errorResponse.statusCode, 0);
      expect(errorResponse.errorMessage, 'Error del servidor, intente nuevamente más tarde');
      verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
    });

    test(
      'debería devolver DatosComprobanteGenericErrorResponse con statusCode 0 cuando ocurra una excepción inesperada',
      () async {
        // Arrange
        when(mockHttpClient.get(Uri.parse(testUrl))).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

        // Assert
        expect(result, isA<DatosComprobanteGenericErrorResponse>());
        final errorResponse = result as DatosComprobanteGenericErrorResponse;
        expect(errorResponse.statusCode, 0);
        expect(errorResponse.errorMessage, 'Error inesperado al obtener datos del comprobante');
        verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
      },
    );

    test('debería construir la URL correcta con el parámetro idBoleta', () async {
      // Arrange
      const differentIdBoleta = 999;
      final expectedUrl = '${AppConfig.pagoApiURL}/api/checkout/datosComprobante/$differentIdBoleta';
      final mockResponseBody = {'id': 1, 'fecha': '2025-10-26', 'importe': '100.00', 'boletas_pagadas': []};

      when(
        mockHttpClient.get(Uri.parse(expectedUrl)),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockResponseBody), 200));

      // Act
      await dataSource.obtenerDatosComprobante(differentIdBoleta);

      // Assert
      verify(mockHttpClient.get(Uri.parse(expectedUrl))).called(1);
    });

    test('debería manejar la respuesta cuando los campos opcionales son nulos', () async {
      // Arrange
      final mockResponseBody = {
        'id': 456,
        'fecha': '2025-10-26',
        'importe': '1500.00',
        'boletas_pagadas': [],
        'comprobante_link': null,
        'metodo_pago': null,
      };

      when(
        mockHttpClient.get(Uri.parse(testUrl)),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockResponseBody), 200));

      // Act
      final result = await dataSource.obtenerDatosComprobante(testIdBoleta);

      // Assert
      expect(result, isA<DatosComprobanteSuccessResponse>());
      final successResponse = result as DatosComprobanteSuccessResponse;
      expect(successResponse.comprobanteLink, isNull);
      expect(successResponse.metodoPago, isNull);
      verify(mockHttpClient.get(Uri.parse(testUrl))).called(1);
    });
  });
}

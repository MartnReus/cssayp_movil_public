import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';
import 'package:cssayp_movil/config.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'boletas_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group("Función de crear boleta de inicio (crearBoletaInicio)", () {
    late BoletasDataSource boletasDataSource;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      boletasDataSource = BoletasDataSource(client: mockClient);
    });

    test("crearBoletaInicio debe retornar un CrearBoletaSuccessResponse si los datos son correctos", () async {
      final requestBody = json.encode({
        'aporteVoluntario': 'N',
        'caratula': 'Test Caratula',
        'circunscripcion': ['1', 'Test Circunscripcion'],
        'juzgado': 'Test Juzgado',
        'tipoJuicio': ['1', 'Test Tipo Juicio'],
        'tipoPago': 4,
      });

      // Respuesta que devuelve el endpoint
      final successResponseBody = json.encode({'id_boleta_generada': '123', 'url': 'https://example.com/payment'});
      const successResponseStatus = 200;

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

      final result = await boletasDataSource.crearBoletaInicio(
        token: 'test-token',
        caratula: 'Test Caratula',
        juzgado: 'Test Juzgado',
        circunscripcion: CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion'),
        tipoJuicio: TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio'),
      );

      expect(result, isA<CrearBoletaSuccessResponse>());
      expect((result as CrearBoletaSuccessResponse).statusCode, equals(200));
      expect((result).idBoleta, equals(123));
      expect((result).urlPago, equals('https://example.com/payment'));

      verify(
        mockClient.post(
          Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
          body: requestBody,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer test-token',
          },
        ),
      ).called(1);
    });

    test("crearBoletaInicio debe retornar un CrearBoletaGenericErrorResponse si hay error en el servidor", () async {
      final requestBody = json.encode({
        'aporteVoluntario': 'N',
        'caratula': 'Test Caratula',
        'circunscripcion': ['1', 'Test Circunscripcion'],
        'juzgado': 'Test Juzgado',
        'tipoJuicio': ['1', 'Test Tipo Juicio'],
        'tipoPago': 4,
      });

      // Respuesta de error del endpoint
      final errorResponseBody = json.encode({'errorMessage': 'Error al crear la boleta de inicio'});
      const errorResponseStatus = 400;

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

      final result = await boletasDataSource.crearBoletaInicio(
        token: 'test-token',
        caratula: 'Test Caratula',
        juzgado: 'Test Juzgado',
        circunscripcion: CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion'),
        tipoJuicio: TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio'),
      );

      expect(result, isA<CrearBoletaGenericErrorResponse>());
      expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(400));
      expect((result).errorMessage, equals('Error al crear la boleta de inicio'));

      verify(
        mockClient.post(
          Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
          body: requestBody,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer test-token',
          },
        ),
      ).called(1);
    });

    test("crearBoletaInicio debe retornar un CrearBoletaGenericErrorResponse cuando hay timeout de conexión", () async {
      final requestBodyTimeoutException = json.encode({
        'aporteVoluntario': 'N',
        'caratula': 'Test Timeout',
        'circunscripcion': ['1', 'Test Circunscripcion'],
        'juzgado': 'Test Juzgado',
        'tipoJuicio': ['1', 'Test Tipo Juicio'],
        'tipoPago': 4,
      });
      final requestBodySocketException = json.encode({
        'aporteVoluntario': 'N',
        'caratula': 'Test Socket',
        'circunscripcion': ['1', 'Test Circunscripcion'],
        'juzgado': 'Test Juzgado',
        'tipoJuicio': ['1', 'Test Tipo Juicio'],
        'tipoPago': 4,
      });

      when(
        mockClient.post(any, body: requestBodyTimeoutException, headers: anyNamed('headers')),
      ).thenThrow(TimeoutException('Connection timeout'));
      when(
        mockClient.post(any, body: requestBodySocketException, headers: anyNamed('headers')),
      ).thenThrow(SocketException('Connection timeout'));

      final resultTimeoutException = await boletasDataSource.crearBoletaInicio(
        token: 'test-token',
        caratula: 'Test Timeout',
        juzgado: 'Test Juzgado',
        circunscripcion: CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion'),
        tipoJuicio: TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio'),
      );
      final resultSocketException = await boletasDataSource.crearBoletaInicio(
        token: 'test-token',
        caratula: 'Test Socket',
        juzgado: 'Test Juzgado',
        circunscripcion: CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion'),
        tipoJuicio: TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio'),
      );

      expect(resultTimeoutException, isA<CrearBoletaGenericErrorResponse>());
      expect(resultSocketException, isA<CrearBoletaGenericErrorResponse>());
      expect((resultTimeoutException as CrearBoletaGenericErrorResponse).statusCode, equals(0));
      expect((resultSocketException as CrearBoletaGenericErrorResponse).statusCode, equals(0));
      expect((resultTimeoutException).errorMessage, equals('Error en la conexión con el servidor'));
      expect((resultSocketException).errorMessage, equals('Error en la conexión con el servidor'));

      verify(
        mockClient.post(
          Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
          body: requestBodyTimeoutException,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer test-token',
          },
        ),
      ).called(1);
      verify(
        mockClient.post(
          Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
          body: requestBodySocketException,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer test-token',
          },
        ),
      ).called(1);
    });

    test(
      "crearBoletaInicio debe retornar un CrearBoletaGenericErrorResponse cuando el servidor devuelve HTML",
      () async {
        final requestBody = json.encode({
          'aporteVoluntario': 'N',
          'caratula': 'Test Caratula',
          'circunscripcion': ['1', 'Test Circunscripcion'],
          'juzgado': 'Test Juzgado',
          'tipoJuicio': ['1', 'Test Tipo Juicio'],
          'tipoPago': 4,
        });
        const errorResponseStatus = 500;
        const errorResponseBody = '''
        <!DOCTYPE html>
        <html>
        <head><title>500 Internal Server Error</title></head>
        <body>
        <h1>Internal Server Error</h1>
        <p>The server encountered an internal error and was unable to complete your request.</p>
        </body>
        </html>
        ''';

        when(mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(errorResponseBody, errorResponseStatus, headers: {'Content-Type': 'text/html'}),
        );

        final result = await boletasDataSource.crearBoletaInicio(
          token: 'test-token',
          caratula: 'Test Caratula',
          juzgado: 'Test Juzgado',
          circunscripcion: CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion'),
          tipoJuicio: TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio'),
        );

        expect(result, isA<CrearBoletaGenericErrorResponse>());
        expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(500));
        expect((result).errorMessage, equals('Error del servidor, intente nuevamente más tarde'));

        verify(
          mockClient.post(
            Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
            body: requestBody,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer test-token',
            },
          ),
        ).called(1);
      },
    );

    test("crearBoletaInicio debe retornar un CrearBoletaGenericErrorResponse cuando hay FormatException", () async {
      final requestBody = json.encode({
        'aporteVoluntario': 'N',
        'caratula': 'Test Caratula',
        'circunscripcion': ['1', 'Test Circunscripcion'],
        'juzgado': 'Test Juzgado',
        'tipoJuicio': ['1', 'Test Tipo Juicio'],
        'tipoPago': 4,
      });

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenThrow(FormatException('Invalid JSON'));

      final result = await boletasDataSource.crearBoletaInicio(
        token: 'test-token',
        caratula: 'Test Caratula',
        juzgado: 'Test Juzgado',
        circunscripcion: CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion'),
        tipoJuicio: TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio'),
      );

      expect(result, isA<CrearBoletaGenericErrorResponse>());
      expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(500));
      expect((result).errorMessage, equals('Error del servidor, intente nuevamente más tarde'));

      verify(
        mockClient.post(
          Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
          body: requestBody,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer test-token',
          },
        ),
      ).called(1);
    });

    test(
      "crearBoletaInicio debe retornar un CrearBoletaGenericErrorResponse cuando hay una excepción genérica",
      () async {
        final requestBody = json.encode({
          'aporteVoluntario': 'N',
          'caratula': 'Test Caratula',
          'circunscripcion': ['1', 'Test Circunscripcion'],
          'juzgado': 'Test Juzgado',
          'tipoJuicio': ['1', 'Test Tipo Juicio'],
          'tipoPago': 4,
        });

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenThrow(Exception('Unexpected error'));

        final result = await boletasDataSource.crearBoletaInicio(
          token: 'test-token',
          caratula: 'Test Caratula',
          juzgado: 'Test Juzgado',
          circunscripcion: CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion'),
          tipoJuicio: TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio'),
        );

        expect(result, isA<CrearBoletaGenericErrorResponse>());
        expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(0));
        expect((result).errorMessage, equals('Error inesperado al crear boleta de inicio'));

        verify(
          mockClient.post(
            Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
            body: requestBody,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer test-token',
            },
          ),
        ).called(1);
      },
    );
  });

  group("Función de crear boleta de finalización (crearBoletaFinalizacion)", () {
    late BoletasDataSource boletasDataSource;
    late MockClient mockClient;

    final consultaApiURL = "${AppConfig.consultaApiURL}/api/v1/boletaFin";
    final requestHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'};

    setUp(() {
      mockClient = MockClient();
      boletasDataSource = BoletasDataSource(client: mockClient);
    });

    test("crearBoletaFinalizacion debe retornar un CrearBoletaSuccessResponse si los datos son correctos", () async {
      final fechaRegulacion = DateTime(2024, 1, 15);
      final requestBody = json.encode({
        'nro_afiliado': 12345,
        'digito': '1',
        'caratula': 'Test Caratula Finalizacion',
        'id_boleta_inicio': 123,
        'monto': 2000.75,
        'fecha_regulacion': fechaRegulacion.toIso8601String(),
        'honorarios': 500.25,
        'cantidad_jus': 2.0,
        'valor_jus': 100.50,
        'nro_expediente': 456,
        'anio_expediente': 2024,
        'cuij': 789,
      });

      // Respuesta que devuelve el endpoint
      final successResponseBody = json.encode({'id_boleta_generada': '124', 'url': 'https://example.com/payment'});
      const successResponseStatus = 201;

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

      final result = await boletasDataSource.crearBoletaFinalizacion(
        nroAfiliado: 12345,
        digito: '1',
        caratula: 'Test Caratula Finalizacion',
        idBoletaInicio: 123,
        monto: 2000.75,
        fechaRegulacion: fechaRegulacion,
        honorarios: 500.25,
        cantidadJus: 2.0,
        valorJus: 100.50,
        nroExpediente: 456,
        anioExpediente: 2024,
        cuij: 789,
      );

      expect(result, isA<CrearBoletaSuccessResponse>());
      expect((result as CrearBoletaSuccessResponse).statusCode, equals(201));
      expect((result).idBoleta, equals(124));
      expect((result).urlPago, equals('https://example.com/payment'));

      verify(mockClient.post(Uri.parse(consultaApiURL), body: requestBody, headers: requestHeaders)).called(1);
    });

    test(
      "crearBoletaFinalizacion debe retornar un CrearBoletaGenericErrorResponse si hay error en el servidor",
      () async {
        final fechaRegulacion = DateTime(2024, 1, 15);
        final requestBody = json.encode({
          'nro_afiliado': 12345,
          'digito': '1',
          'caratula': 'Test Caratula Finalizacion',
          'id_boleta_inicio': 123,
          'monto': 2000.75,
          'fecha_regulacion': fechaRegulacion.toIso8601String(),
          'honorarios': 500.25,
          'cantidad_jus': 2.0,
          'valor_jus': 100.50,
          'nro_expediente': null,
          'anio_expediente': null,
          'cuij': null,
        });

        // Respuesta de error del endpoint
        final errorResponseBody = json.encode({'errorMessage': 'Error al crear la boleta de finalización'});
        const errorResponseStatus = 400;

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

        final result = await boletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: 12345,
          digito: '1',
          caratula: 'Test Caratula Finalizacion',
          idBoletaInicio: 123,
          monto: 2000.75,
          fechaRegulacion: fechaRegulacion,
          honorarios: 500.25,
          cantidadJus: 2.0,
          valorJus: 100.50,
        );

        expect(result, isA<CrearBoletaGenericErrorResponse>());
        expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(400));
        expect((result).errorMessage, equals('Error al crear la boleta de finalización'));

        verify(mockClient.post(Uri.parse(consultaApiURL), body: requestBody, headers: requestHeaders)).called(1);
      },
    );

    test(
      "crearBoletaFinalizacion debe retornar un CrearBoletaGenericErrorResponse cuando hay timeout de conexión",
      () async {
        final fechaRegulacion = DateTime(2024, 1, 15);
        final requestBodyTimeoutException = json.encode({
          'nro_afiliado': 12345,
          'digito': '1',
          'caratula': 'Test Timeout',
          'id_boleta_inicio': 123,
          'monto': 2000.75,
          'fecha_regulacion': fechaRegulacion.toIso8601String(),
          'honorarios': 500.25,
          'cantidad_jus': 2.0,
          'valor_jus': 100.50,
          'nro_expediente': null,
          'anio_expediente': null,
          'cuij': null,
        });

        when(
          mockClient.post(any, body: requestBodyTimeoutException, headers: anyNamed('headers')),
        ).thenThrow(TimeoutException('Connection timeout'));

        final result = await boletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: 12345,
          digito: '1',
          caratula: 'Test Timeout',
          idBoletaInicio: 123,
          monto: 2000.75,
          fechaRegulacion: fechaRegulacion,
          honorarios: 500.25,
          cantidadJus: 2.0,
          valorJus: 100.50,
        );

        expect(result, isA<CrearBoletaGenericErrorResponse>());
        expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(0));
        expect((result).errorMessage, equals('Error en la conexión con el servidor'));

        verify(
          mockClient.post(Uri.parse(consultaApiURL), body: requestBodyTimeoutException, headers: requestHeaders),
        ).called(1);
      },
    );

    test(
      "crearBoletaFinalizacion debe retornar un CrearBoletaGenericErrorResponse cuando hay FormatException",
      () async {
        final fechaRegulacion = DateTime(2024, 1, 15);
        final requestBody = json.encode({
          'nro_afiliado': 12345,
          'digito': '1',
          'caratula': 'Test Caratula Finalizacion',
          'id_boleta_inicio': 123,
          'monto': 2000.75,
          'fecha_regulacion': fechaRegulacion.toIso8601String(),
          'honorarios': 500.25,
          'cantidad_jus': 2.0,
          'valor_jus': 100.50,
          'nro_expediente': null,
          'anio_expediente': null,
          'cuij': null,
        });

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenThrow(FormatException('Invalid JSON'));

        final result = await boletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: 12345,
          digito: '1',
          caratula: 'Test Caratula Finalizacion',
          idBoletaInicio: 123,
          monto: 2000.75,
          fechaRegulacion: fechaRegulacion,
          honorarios: 500.25,
          cantidadJus: 2.0,
          valorJus: 100.50,
        );

        expect(result, isA<CrearBoletaGenericErrorResponse>());
        expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(500));
        expect((result).errorMessage, equals('Error del servidor, intente nuevamente más tarde'));

        verify(mockClient.post(Uri.parse(consultaApiURL), body: requestBody, headers: requestHeaders)).called(1);
      },
    );

    test(
      "crearBoletaFinalizacion debe retornar un CrearBoletaGenericErrorResponse cuando hay una excepción genérica",
      () async {
        final fechaRegulacion = DateTime(2024, 1, 15);
        final requestBody = json.encode({
          'nro_afiliado': 12345,
          'digito': '1',
          'caratula': 'Test Caratula Finalizacion',
          'id_boleta_inicio': 123,
          'monto': 2000.75,
          'fecha_regulacion': fechaRegulacion.toIso8601String(),
          'honorarios': 500.25,
          'cantidad_jus': 2.0,
          'valor_jus': 100.50,
          'nro_expediente': null,
          'anio_expediente': null,
          'cuij': null,
        });

        when(
          mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
        ).thenThrow(Exception('Unexpected error'));

        final result = await boletasDataSource.crearBoletaFinalizacion(
          nroAfiliado: 12345,
          digito: '1',
          caratula: 'Test Caratula Finalizacion',
          idBoletaInicio: 123,
          monto: 2000.75,
          fechaRegulacion: fechaRegulacion,
          honorarios: 500.25,
          cantidadJus: 2.0,
          valorJus: 100.50,
        );

        expect(result, isA<CrearBoletaGenericErrorResponse>());
        expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(0));
        expect((result).errorMessage, equals('Error inesperado al crear boleta de finalización'));

        verify(mockClient.post(Uri.parse(consultaApiURL), body: requestBody, headers: requestHeaders)).called(1);
      },
    );
  });

  group("Función de obtener historial de boletas (obtenerHistorialBoletas)", () {
    late BoletasDataSource boletasDataSource;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      boletasDataSource = BoletasDataSource(client: mockClient);
    });

    test(
      "obtenerHistorialBoletas debe retornar un HistorialBoletasSuccessResponse si los datos son correctos",
      () async {
        final nroAfiliado = 12345;
        final uri = Uri.parse(
          '${AppConfig.consultaApiURL}/api/v1/boletasByNafPaginated/$nroAfiliado',
        ).replace(queryParameters: {'mostrar_pagadas': '1', 'page': '1'});

        // Respuesta que devuelve el endpoint
        final successResponseBody = json.encode({
          'current_page': 1,
          'data': [
            {
              'id_boleta_generada': '123',
              'id_tipo_transaccion': '1',
              'fecha_impresion': '2024-01-15',
              'monto': '1000.50',
              'gastos_administrativos': '50.25',
              'id_tipo_gasto': '1',
              'tipo_gasto': 'Honorarios',
              'caratula': 'Test Caratula',
              'cod_barra': '12345678901234567890',
              'anio_convenio': '2024',
              'id_tipo_boleta': '1',
              'fecha_pago': null,
              'dias_vencimiento': '30',
              'estado': 'Pendiente',
            },
          ],
          'last_page': 1,
          'total': 1,
          'per_page': '10',
          'next_page_url': null,
          'prev_page_url': null,
        });
        const successResponseStatus = 200;

        when(mockClient.get(any)).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

        final result = await boletasDataSource.obtenerHistorialBoletas(
          nroAfiliado: nroAfiliado,
          page: 1,
          mostrarPagadas: 1,
        );

        expect(result, isA<HistorialBoletasSuccessResponse>());
        expect((result as HistorialBoletasSuccessResponse).statusCode, equals(200));
        expect((result).currentPage, equals(1));
        expect((result).boletas.length, equals(1));
        expect((result).boletas.first.idBoletaGenerada, equals('123'));
        expect((result).boletas.first.caratula, equals('Test Caratula'));
        expect((result).boletas.first.monto, equals('1000.50'));
        expect((result).lastPage, equals(1));
        expect((result).total, equals(1));
        expect((result).perPage, equals(10));

        verify(mockClient.get(uri)).called(1);
      },
    );

    test(
      "obtenerHistorialBoletas debe retornar un HistorialBoletasErrorResponse si hay error en el servidor",
      () async {
        final nroAfiliado = 12345;
        final uri = Uri.parse(
          '${AppConfig.consultaApiURL}/api/v1/boletasByNafPaginated/$nroAfiliado',
        ).replace(queryParameters: {'mostrar_pagadas': '1'});

        // Respuesta de error del endpoint
        final errorResponseBody = json.encode({'errorMessage': 'Error al obtener historial de boletas'});
        const errorResponseStatus = 400;

        when(mockClient.get(any)).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

        final result = await boletasDataSource.obtenerHistorialBoletas(nroAfiliado: nroAfiliado, mostrarPagadas: 1);

        expect(result, isA<HistorialBoletasErrorResponse>());
        expect((result as HistorialBoletasErrorResponse).statusCode, equals(400));
        expect((result).errorMessage, equals('Error al obtener historial de boletas'));

        verify(mockClient.get(uri)).called(1);
      },
    );

    test(
      "obtenerHistorialBoletas debe retornar un HistorialBoletasErrorResponse cuando hay timeout de conexión",
      () async {
        final nroAfiliado = 12345;
        final uri = Uri.parse(
          '${AppConfig.consultaApiURL}/api/v1/boletasByNafPaginated/$nroAfiliado',
        ).replace(queryParameters: {'mostrar_pagadas': '1'});

        when(mockClient.get(any)).thenThrow(TimeoutException('Connection timeout'));

        final result = await boletasDataSource.obtenerHistorialBoletas(nroAfiliado: nroAfiliado, mostrarPagadas: 1);

        expect(result, isA<HistorialBoletasErrorResponse>());
        expect((result as HistorialBoletasErrorResponse).statusCode, equals(0));
        expect((result).errorMessage, equals('Error en la conexión con el servidor'));

        verify(mockClient.get(uri)).called(1);
      },
    );

    test("obtenerHistorialBoletas debe retornar un HistorialBoletasErrorResponse cuando hay FormatException", () async {
      final nroAfiliado = 12345;
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasByNafPaginated/$nroAfiliado',
      ).replace(queryParameters: {'mostrar_pagadas': '1'});

      when(mockClient.get(any)).thenThrow(FormatException('Invalid JSON'));

      final result = await boletasDataSource.obtenerHistorialBoletas(nroAfiliado: nroAfiliado, mostrarPagadas: 1);

      expect(result, isA<HistorialBoletasErrorResponse>());
      expect((result as HistorialBoletasErrorResponse).statusCode, equals(500));
      expect((result).errorMessage, equals('Error del servidor, intente nuevamente más tarde'));

      verify(mockClient.get(uri)).called(1);
    });

    test(
      "obtenerHistorialBoletas debe retornar un HistorialBoletasErrorResponse cuando hay una excepción genérica",
      () async {
        final nroAfiliado = 12345;
        final uri = Uri.parse(
          '${AppConfig.consultaApiURL}/api/v1/boletasByNafPaginated/$nroAfiliado',
        ).replace(queryParameters: {'mostrar_pagadas': '1'});

        when(mockClient.get(any)).thenThrow(Exception('Unexpected error'));

        final result = await boletasDataSource.obtenerHistorialBoletas(nroAfiliado: nroAfiliado, mostrarPagadas: 1);

        expect(result, isA<HistorialBoletasErrorResponse>());
        expect((result as HistorialBoletasErrorResponse).statusCode, equals(0));
        expect((result).errorMessage, equals('Error inesperado al obtener historial de boletas'));

        verify(mockClient.get(uri)).called(1);
      },
    );
  });

  group("Función de buscar boletas de inicio pagadas (buscarBoletasInicioPagadas)", () {
    late BoletasDataSource boletasDataSource;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      boletasDataSource = BoletasDataSource(client: mockClient);
    });

    test("buscarBoletasInicioPagadas debe retornar un PaginatedResponseModel si los datos son correctos", () async {
      final nroAfiliado = 12345;
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasInicioPagadasByNaf/$nroAfiliado',
      ).replace(queryParameters: {'search': 'Test Caratula', 'page': '1'});

      // Respuesta que devuelve el endpoint
      final successResponseBody = json.encode({
        'data': [
          {
            'id_boleta_generada': '123',
            'caratula': 'Test Caratula',
            'monto': '1000.50',
            'fecha_impresion': '2024-01-15',
          },
        ],
        'meta': {'current_page': 1, 'last_page': 1, 'total': 1, 'per_page': 10},
      });
      const successResponseStatus = 200;

      when(mockClient.get(any)).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

      final result = await boletasDataSource.buscarBoletasInicioPagadas(
        nroAfiliado: nroAfiliado,
        page: 1,
        caratulaBuscada: 'Test Caratula',
      );

      expect(result, isA<PaginatedResponseModel>());
      expect(result.statusCode, equals(200));
      expect(result.data.length, equals(1));
      expect(result.data.first['id_boleta_generada'], equals('123'));
      expect(result.data.first['caratula'], equals('Test Caratula'));
      expect(result.currentPage, equals(1));
      expect(result.lastPage, equals(1));
      expect(result.total, equals(1));
      expect(result.perPage, equals(10));

      verify(mockClient.get(uri)).called(1);
    });

    test("buscarBoletasInicioPagadas debe lanzar una excepción si hay error en el servidor", () async {
      final nroAfiliado = 12345;
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasInicioPagadasByNaf/$nroAfiliado',
      ).replace(queryParameters: {'search': null, 'page': '1'});

      const errorResponseStatus = 500;
      const errorResponseBody = '''
        <!DOCTYPE html>
        <html>
        <head><title>500 Internal Server Error</title></head>
        <body>
        <h1>Internal Server Error</h1>
        <p>The server encountered an internal error and was unable to complete your request.</p>
        </body>
        </html>
        ''';

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(errorResponseBody, errorResponseStatus, headers: {'Content-Type': 'text/html'}),
      );

      expect(
        () => boletasDataSource.buscarBoletasInicioPagadas(nroAfiliado: nroAfiliado, page: 1),
        throwsA(isA<Exception>()),
      );

      verify(mockClient.get(uri)).called(1);
    });

    test("buscarBoletasInicioPagadas debe lanzar una excepción cuando hay timeout de conexión", () async {
      final nroAfiliado = 12345;
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasInicioPagadasByNaf/$nroAfiliado',
      ).replace(queryParameters: {'search': null, 'page': '1'});

      when(mockClient.get(any)).thenThrow(TimeoutException('Connection timeout'));

      expect(
        () => boletasDataSource.buscarBoletasInicioPagadas(nroAfiliado: nroAfiliado, page: 1),
        throwsA(isA<Exception>()),
      );

      verify(mockClient.get(uri)).called(1);
    });

    test("buscarBoletasInicioPagadas debe lanzar una excepción cuando hay FormatException", () async {
      final nroAfiliado = 12345;
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasInicioPagadasByNaf/$nroAfiliado',
      ).replace(queryParameters: {'search': null, 'page': '1'});

      when(mockClient.get(any)).thenThrow(FormatException('Invalid JSON'));

      expect(
        () => boletasDataSource.buscarBoletasInicioPagadas(nroAfiliado: nroAfiliado, page: 1),
        throwsA(isA<Exception>()),
      );

      verify(mockClient.get(uri)).called(1);
    });

    test("buscarBoletasInicioPagadas debe lanzar una excepción cuando hay una excepción genérica", () async {
      final nroAfiliado = 12345;
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasInicioPagadasByNaf/$nroAfiliado',
      ).replace(queryParameters: {'search': null, 'page': '1'});

      when(mockClient.get(any)).thenThrow(Exception('Unexpected error'));

      expect(
        () => boletasDataSource.buscarBoletasInicioPagadas(nroAfiliado: nroAfiliado, page: 1),
        throwsA(isA<Exception>()),
      );

      verify(mockClient.get(uri)).called(1);
    });
  });

  group("Edge cases y casos especiales", () {
    late BoletasDataSource boletasDataSource;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      boletasDataSource = BoletasDataSource(client: mockClient);
    });

    test("crearBoletaInicio debe manejar diferentes códigos de estado de respuesta", () async {
      // Test with 500 status code
      final requestBody = json.encode({
        'aporteVoluntario': 'N',
        'caratula': 'Test Caratula',
        'circunscripcion': ['1', 'Test Circunscripcion'],
        'juzgado': 'Test Juzgado',
        'tipoJuicio': ['1', 'Test Tipo Juicio'],
        'tipoPago': 4,
      });
      final errorResponseBody = json.encode({'errorMessage': 'Internal server error'});
      const errorResponseStatus = 500;

      when(
        mockClient.post(any, body: anyNamed('body'), headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(errorResponseBody, errorResponseStatus));

      final result = await boletasDataSource.crearBoletaInicio(
        token: 'test-token',
        caratula: 'Test Caratula',
        juzgado: 'Test Juzgado',
        circunscripcion: CircunscripcionEntity(id: '1', descripcion: 'Test Circunscripcion'),
        tipoJuicio: TipoJuicioEntity(id: '1', descripcion: 'Test Tipo Juicio'),
      );

      expect(result, isA<CrearBoletaGenericErrorResponse>());
      expect((result as CrearBoletaGenericErrorResponse).statusCode, equals(500));
      expect((result).errorMessage, equals('Internal server error'));

      verify(
        mockClient.post(
          Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
          body: requestBody,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer test-token',
          },
        ),
      ).called(1);
    });

    test("obtenerHistorialBoletas debe manejar respuesta con página específica", () async {
      final nroAfiliado = 12345;
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasByNafPaginated/$nroAfiliado',
      ).replace(queryParameters: {'mostrar_pagadas': '0', 'page': '2'});

      final successResponseBody = json.encode({
        'current_page': 2,
        'data': [],
        'last_page': 2,
        'total': 0,
        'per_page': '10',
        'next_page_url': null,
        'prev_page_url': 'page=1',
      });
      const successResponseStatus = 200;

      when(mockClient.get(any)).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

      final result = await boletasDataSource.obtenerHistorialBoletas(
        nroAfiliado: nroAfiliado,
        page: 2,
        mostrarPagadas: 0,
      );

      expect(result, isA<HistorialBoletasSuccessResponse>());
      expect((result as HistorialBoletasSuccessResponse).currentPage, equals(2));
      expect((result).boletas.length, equals(0));

      verify(mockClient.get(uri)).called(1);
    });

    test("buscarBoletasInicioPagadas debe manejar búsqueda con caratula específica", () async {
      final nroAfiliado = 12345;
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasInicioPagadasByNaf/$nroAfiliado',
      ).replace(queryParameters: {'search': 'Test Search', 'page': '1'});

      final successResponseBody = json.encode({
        'data': [],
        'meta': {'current_page': 1, 'last_page': 1, 'total': 0, 'per_page': 10},
      });
      const successResponseStatus = 200;

      when(mockClient.get(any)).thenAnswer((_) async => http.Response(successResponseBody, successResponseStatus));

      final result = await boletasDataSource.buscarBoletasInicioPagadas(
        nroAfiliado: nroAfiliado,
        page: 1,
        caratulaBuscada: 'Test Search',
      );

      expect(result, isA<PaginatedResponseModel>());
      expect(result.statusCode, equals(200));
      expect(result.data.length, equals(0));
      expect(result.currentPage, equals(1));

      verify(mockClient.get(uri)).called(1);
    });
  });

  group("Constructor y configuración inicial", () {
    test("BoletasDataSource debe inicializarse correctamente con un cliente HTTP", () {
      final mockClient = MockClient();
      final boletasDataSource = BoletasDataSource(client: mockClient);

      expect(boletasDataSource, isA<BoletasDataSource>());
      expect(boletasDataSource.client, equals(mockClient));
    });
  });
}

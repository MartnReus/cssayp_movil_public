import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/boletas/data/models/juicios_abiertos_response.dart';
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';
import 'package:cssayp_movil/config.dart';
import 'package:http/http.dart' as http;

class BoletasDataSource {
  final http.Client client;

  BoletasDataSource({required this.client});

  Future<CrearBoletaResponse> crearBoletaInicio({
    required String token,
    required String caratula,
    required String juzgado,
    required CircunscripcionEntity circunscripcion,
    required TipoJuicioEntity tipoJuicio,
  }) async {
    try {
      final body = {
        'aporteVoluntario': 'N',
        'caratula': caratula,
        'circunscripcion': circunscripcion.toArray(),
        'juzgado': juzgado,
        'tipoJuicio': tipoJuicio.toArray(),
        'tipoPago': 4,
      };

      final response = await client.post(
        Uri.parse('${AppConfig.cgaUrl}/ws/bol/inicio-generar'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return CrearBoletaSuccessResponse.fromJson(response.statusCode, json.decode(response.body));
      } else {
        return CrearBoletaGenericErrorResponse.fromJson(response.statusCode, json.decode(response.body));
      }
    } on SocketException catch (_) {
      return CrearBoletaGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      return CrearBoletaGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on FormatException catch (_) {
      return CrearBoletaGenericErrorResponse(
        statusCode: 500,
        errorMessage: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return CrearBoletaGenericErrorResponse(statusCode: 0, errorMessage: 'Error inesperado al crear boleta de inicio');
    }
  }

  Future<CrearBoletaResponse> crearBoletaFinalizacion({
    required int nroAfiliado,
    required String digito,
    required String caratula,
    required int idBoletaInicio,
    required double monto,
    required DateTime fechaRegulacion,
    required double honorarios,
    required double cantidadJus,
    required double valorJus,
    int? nroExpediente,
    int? anioExpediente,
    int? cuij,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConfig.consultaApiURL}/api/v1/boletaFin'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'nro_afiliado': nroAfiliado,
          'digito': digito,
          'caratula': caratula,
          'id_boleta_inicio': idBoletaInicio,
          'monto': monto,
          'fecha_regulacion': fechaRegulacion.toIso8601String(),
          'honorarios': honorarios,
          'cantidad_jus': cantidadJus,
          'valor_jus': valorJus,
          'nro_expediente': nroExpediente,
          'anio_expediente': anioExpediente,
          'cuij': cuij,
        }),
      );

      if (response.statusCode == 201) {
        return CrearBoletaSuccessResponse.fromJson(response.statusCode, json.decode(response.body));
      } else {
        return CrearBoletaGenericErrorResponse.fromJson(response.statusCode, json.decode(response.body));
      }
    } on SocketException catch (_) {
      return CrearBoletaGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      return CrearBoletaGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on FormatException catch (_) {
      return CrearBoletaGenericErrorResponse(
        statusCode: 500,
        errorMessage: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return CrearBoletaGenericErrorResponse(
        statusCode: 0,
        errorMessage: 'Error inesperado al crear boleta de finalización',
      );
    }
  }

  Future<HistorialBoletasResponse> obtenerHistorialBoletas({
    required int nroAfiliado,
    int? page,
    String filtroEstado = 'todas',
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasByNafPaginated/$nroAfiliado',
      ).replace(queryParameters: {if (page != null) 'page': page.toString(), 'filtro_estado': filtroEstado});

      final response = await client.get(uri);

      if (response.statusCode == 200) {
        return HistorialBoletasSuccessResponse.fromJson(response.statusCode, json.decode(response.body));
      } else {
        return HistorialBoletasErrorResponse.fromJson(response.statusCode, json.decode(response.body));
      }
    } on SocketException catch (_) {
      return HistorialBoletasErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      return HistorialBoletasErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on FormatException catch (_) {
      return HistorialBoletasErrorResponse(
        statusCode: 500,
        errorMessage: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return HistorialBoletasErrorResponse(
        statusCode: 0,
        errorMessage: 'Error inesperado al obtener historial de boletas',
      );
    }
  }

  Future<Map<String, dynamic>> obtenerParametrosBoletaInicio(int nroAfiliado) async {
    final response = await client.get(
      Uri.parse('${AppConfig.consultaApiURL}/api/v1/parametros-boleta-inicio/$nroAfiliado'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener parámetros de boleta de inicio: ${response.statusCode}');
    }
  }

  Future<PaginatedResponseModel> buscarBoletasInicioPagadas({
    required int nroAfiliado,
    int page = 1,
    String? caratulaBuscada,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/boletasInicioPagadasByNaf/$nroAfiliado',
      ).replace(queryParameters: {'search': caratulaBuscada, 'page': page.toString()});
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        return PaginatedResponseModel.fromJson(response.statusCode, json.decode(response.body));
      } else {
        throw Exception('Error al buscar boletas de inicio pagadas: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      throw Exception('Error en la conexión con el servidor');
    } on FormatException catch (_) {
      throw Exception('Error del servidor, intente nuevamente más tarde');
    } catch (e) {
      throw Exception('Error inesperado al buscar boletas de inicio pagadas: $e');
    }
  }

  Future<JuiciosAbiertosPaginatedResponse> obtenerJuiciosAbiertos({required int nroAfiliado, int page = 1}) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.consultaApiURL}/api/v1/juiciosAbiertos/$nroAfiliado',
      ).replace(queryParameters: {'page': page.toString()});
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        return JuiciosAbiertosPaginatedResponse.fromJson(response.statusCode, json.decode(response.body));
      } else {
        throw Exception('Error al obtener juicios abiertos: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      throw Exception('Error en la conexión con el servidor');
    } on FormatException catch (_) {
      throw Exception('Error del servidor, intente nuevamente más tarde');
    } catch (e) {
      throw Exception('Error inesperado al obtener juicios abiertos: $e');
    }
  }
}

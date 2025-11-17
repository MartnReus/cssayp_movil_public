import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/config.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:http/http.dart' as http;

class ComprobantesRemoteDataSource {
  final http.Client client;

  ComprobantesRemoteDataSource({required this.client});
  Future<DatosComprobanteResponse> obtenerDatosComprobante(int idBoleta) async {
    try {
      final response = await client.get(Uri.parse('${AppConfig.pagoApiURL}/api/checkout/datosComprobante/$idBoleta'));

      if (response.statusCode == 200) {
        return DatosComprobanteSuccessResponse.fromJson(response.statusCode, json.decode(response.body));
      } else {
        return DatosComprobanteGenericErrorResponse.fromJson(response.statusCode, json.decode(response.body));
      }
    } on SocketException catch (_) {
      return DatosComprobanteGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      return DatosComprobanteGenericErrorResponse(statusCode: 0, errorMessage: 'Error en la conexión con el servidor');
    } on FormatException catch (_) {
      return DatosComprobanteGenericErrorResponse(
        statusCode: 0,
        errorMessage: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return DatosComprobanteGenericErrorResponse(
        statusCode: 0,
        errorMessage: 'Error inesperado al obtener datos del comprobante',
      );
    }
  }
}

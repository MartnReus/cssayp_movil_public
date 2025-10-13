import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/pagos/pagos.dart';
import 'package:cssayp_movil/config.dart';
import 'package:http/http.dart' as http;

class PaywayDataSource {
  final http.Client client;

  PaywayDataSource({required this.client});

  Future<ResultadoPagoModel> pagar({
    required List<BoletaAPagarEntity> boletas,
    required DatosTarjetaModel datosTarjeta,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConfig.pagoApiURL}/api/checkout/payment-prisma'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'datos_tarjeta': datosTarjeta.toJson(),
          'boletas': boletas.map((boleta) => boleta.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        return ResultadoPagoModel(statusCode: response.statusCode, message: json.decode(response.body));
      }

      return ResultadoPagoModel(statusCode: response.statusCode, message: json.decode(response.body));
    } on SocketException catch (_) {
      return ResultadoPagoModel(statusCode: 0, message: 'Error en la conexión con el servidor');
    } on TimeoutException catch (_) {
      return ResultadoPagoModel(statusCode: 0, message: 'Error en la conexión con el servidor');
    } on FormatException catch (_) {
      return ResultadoPagoModel(statusCode: 500, message: 'Error del servidor, intente nuevamente más tarde');
    } catch (e) {
      return ResultadoPagoModel(statusCode: 0, message: 'Error inesperado al procesar el pago');
    }
  }
}

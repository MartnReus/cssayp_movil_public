import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cssayp_movil/pagos/data/models/red_link_payment_response_model.dart';
import 'package:cssayp_movil/config.dart';
import 'package:http/http.dart' as http;

class RedLinkDataSource {
  final http.Client client;

  RedLinkDataSource({required this.client});

  /// Genera la URL de pago de Red Link para una boleta
  Future<RedLinkPaymentResponseModel> generarUrlPago({required int idBoleta}) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.cgaUrl}/ws/bol/generar-url-pago/$idBoleta'),
        headers: {'Accept': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RedLinkPaymentResponseModel.fromJson(responseData);
      } else {
        return RedLinkPaymentResponseModel(
          paymentUrl: '',
          tokenIdLink: '',
          referencia: '',
          success: false,
          error: responseData['error'] ?? 'Error desconocido al generar URL de pago',
        );
      }
    } on SocketException catch (_) {
      return const RedLinkPaymentResponseModel(
        paymentUrl: '',
        tokenIdLink: '',
        referencia: '',
        success: false,
        error: 'Error en la conexión con el servidor',
      );
    } on TimeoutException catch (_) {
      return const RedLinkPaymentResponseModel(
        paymentUrl: '',
        tokenIdLink: '',
        referencia: '',
        success: false,
        error: 'Tiempo de espera agotado',
      );
    } on FormatException catch (_) {
      return const RedLinkPaymentResponseModel(
        paymentUrl: '',
        tokenIdLink: '',
        referencia: '',
        success: false,
        error: 'Error del servidor, intente nuevamente más tarde',
      );
    } catch (e) {
      return RedLinkPaymentResponseModel(
        paymentUrl: '',
        tokenIdLink: '',
        referencia: '',
        success: false,
        error: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Verifica el estado del pago de una boleta
  Future<RedLinkPaymentStatusModel> verificarEstadoPago({required int idBoleta}) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.pagoApiURL}/ws/bol/verificar-estado-pago/$idBoleta'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return RedLinkPaymentStatusModel.fromJson(responseData);
      } else {
        return const RedLinkPaymentStatusModel(pagado: false, mensaje: 'Error al verificar estado del pago');
      }
    } catch (e) {
      return const RedLinkPaymentStatusModel(pagado: false, mensaje: 'Error de conexión al verificar estado del pago');
    }
  }
}

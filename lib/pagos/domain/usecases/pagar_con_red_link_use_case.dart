import 'dart:async';

import 'package:cssayp_movil/pagos/data/models/red_link_payment_response_model.dart';
import 'package:cssayp_movil/pagos/domain/repositories/red_link_repository.dart';

class PagarConRedLinkUseCase {
  final RedLinkRepository repository;

  PagarConRedLinkUseCase({required this.repository});

  /// Inicia el proceso de pago con Red Link
  Future<RedLinkPaymentResponseModel> iniciarPago({required int idBoleta}) async {
    return await repository.generarUrlPago(idBoleta: idBoleta);
  }

  /// Verifica el estado del pago de forma periódica
  Stream<RedLinkPaymentStatusModel> monitorearPago({
    required int idBoleta,
    Duration intervalo = const Duration(seconds: 5),
    int? maxIntentos,
  }) async* {
    int intentos = 0;

    while (maxIntentos == null || intentos < maxIntentos) {
      try {
        final estado = await repository.verificarEstadoPago(idBoleta: idBoleta);
        yield estado;

        // Si el pago fue exitoso, terminar el monitoreo
        if (estado.pagado) {
          break;
        }

        intentos++;
        await Future.delayed(intervalo);
      } catch (e) {
        yield RedLinkPaymentStatusModel(pagado: false, mensaje: 'Error al verificar estado: ${e.toString()}');

        intentos++;
        await Future.delayed(intervalo);
      }
    }
  }

  /// Verifica el estado del pago una sola vez
  Future<RedLinkPaymentStatusModel> verificarEstado({required int idBoleta}) async {
    return await repository.verificarEstadoPago(idBoleta: idBoleta);
  }
}

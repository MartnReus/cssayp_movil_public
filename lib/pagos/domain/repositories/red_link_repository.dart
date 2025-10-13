import 'package:cssayp_movil/pagos/data/models/red_link_payment_response_model.dart';

abstract class RedLinkRepository {
  Future<RedLinkPaymentResponseModel> generarUrlPago({required int idBoleta});
  Future<RedLinkPaymentStatusModel> verificarEstadoPago({required int idBoleta});
}

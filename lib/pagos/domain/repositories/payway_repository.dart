import 'package:cssayp_movil/pagos/pagos.dart';

abstract interface class PaywayRepository implements BasePagoRepository {
  Future<ResultadoPagoModel> pagar({
    required List<BoletaAPagarEntity> boletas,
    required DatosTarjetaModel datosTarjeta,
  });
}

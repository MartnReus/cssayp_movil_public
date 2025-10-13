import 'package:cssayp_movil/pagos/pagos.dart';

abstract interface class BasePagoRepository {
  Future<void> actualizarEstadoLocalBoleta(BoletaAPagarEntity boleta);
}

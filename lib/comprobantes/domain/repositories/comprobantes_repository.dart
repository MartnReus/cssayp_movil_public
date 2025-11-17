import 'package:cssayp_movil/comprobantes/comprobantes.dart';

abstract interface class ComprobantesRepository {
  Future<ComprobanteEntity> obtenerComprobante(int idBoletaPagada);
}

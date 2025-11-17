import 'package:cssayp_movil/comprobantes/comprobantes.dart';

class ObtenerComprobanteUseCase {
  final ComprobantesRepository comprobantesRepository;

  ObtenerComprobanteUseCase(this.comprobantesRepository);

  Future<ComprobanteEntity> execute(int idBoletaPagada) {
    return comprobantesRepository.obtenerComprobante(idBoletaPagada);
  }
}

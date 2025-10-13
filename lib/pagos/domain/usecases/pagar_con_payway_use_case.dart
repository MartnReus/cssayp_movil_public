import 'package:cssayp_movil/pagos/pagos.dart';

class PagarConPaywayUseCase {
  final PaywayRepository paywayRepository;

  PagarConPaywayUseCase({required this.paywayRepository});

  Future<ResultadoPagoModel> execute({
    required List<BoletaAPagarEntity> boletas,
    required DatosTarjetaModel datosTarjeta,
  }) async {
    return await paywayRepository.pagar(boletas: boletas, datosTarjeta: datosTarjeta);
  }
}

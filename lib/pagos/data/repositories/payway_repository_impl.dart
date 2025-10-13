import 'package:cssayp_movil/pagos/pagos.dart';

class PaywayRepositoryImpl implements PaywayRepository {
  final PaywayDataSource paywayDataSource;

  PaywayRepositoryImpl({required this.paywayDataSource});

  @override
  Future<ResultadoPagoModel> pagar({
    required List<BoletaAPagarEntity> boletas,
    required DatosTarjetaModel datosTarjeta,
  }) async {
    return await paywayDataSource.pagar(boletas: boletas, datosTarjeta: datosTarjeta);
  }

  @override
  Future<void> actualizarEstadoLocalBoleta(BoletaAPagarEntity boleta) async {
    // await paywayDataSource.actualizarEstadoLocalBoleta(boleta);
  }
}

import 'package:cssayp_movil/pagos/data/datasources/red_link_data_source.dart';
import 'package:cssayp_movil/pagos/data/models/red_link_payment_response_model.dart';
import 'package:cssayp_movil/pagos/domain/repositories/red_link_repository.dart';

class RedLinkRepositoryImpl implements RedLinkRepository {
  final RedLinkDataSource dataSource;

  RedLinkRepositoryImpl({required this.dataSource});

  @override
  Future<RedLinkPaymentResponseModel> generarUrlPago({required int idBoleta}) async {
    return await dataSource.generarUrlPago(idBoleta: idBoleta);
  }

  @override
  Future<RedLinkPaymentStatusModel> verificarEstadoPago({required int idBoleta}) async {
    return await dataSource.verificarEstadoPago(idBoleta: idBoleta);
  }
}

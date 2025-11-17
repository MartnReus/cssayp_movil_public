import 'package:cssayp_movil/comprobantes/comprobantes.dart';

class ComprobantesRepositoryImpl implements ComprobantesRepository {
  final ComprobantesLocalDataSource comprobantesLocalDataSource;
  final ComprobantesRemoteDataSource comprobantesRemoteDataSource;

  ComprobantesRepositoryImpl({required this.comprobantesLocalDataSource, required this.comprobantesRemoteDataSource});

  @override
  Future<ComprobanteEntity> obtenerComprobante(int idBoletaPagada) async {
    final datosComprobanteResponse = await comprobantesRemoteDataSource.obtenerDatosComprobante(idBoletaPagada);

    if (datosComprobanteResponse is DatosComprobanteGenericErrorResponse) {
      throw Exception(datosComprobanteResponse.errorMessage);
    }

    final comprobanteEntity = (datosComprobanteResponse as DatosComprobanteSuccessResponse).toEntity();

    return comprobanteEntity;
  }
}

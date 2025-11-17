import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';

abstract interface class BoletasRepository {
  Future<CrearBoletaInicioResult> crearBoletaInicio({
    required String caratula,
    required String juzgado,
    required CircunscripcionEntity circunscripcion,
    required TipoJuicioEntity tipoJuicio,
  });
  Future<BoletaEntity> crearBoletaFinalizacion({
    required int nroAfiliado,
    required String caratula,
    required int idBoletaInicio,
    required double monto,
    required DateTime fechaRegulacion,
    required double honorarios,
    required double cantidadJus,
    required double valorJus,
    int? nroExpediente,
    int? anioExpediente,
    int? cuij,
  });
  Future<HistorialBoletasSuccessResponse> obtenerHistorialBoletas(
    int nroAfiliado, {
    int? page,
    String filtroEstado = 'todas',
  });
  Future<ParametrosBoletaInicioEntity> obtenerParametrosBoletaInicio(int nroAfiliado);
  Future<PaginatedResponseModel> buscarBoletasInicioPagadas({
    required int nroAfiliado,
    int page = 1,
    String? caratulaBuscada,
  });
}

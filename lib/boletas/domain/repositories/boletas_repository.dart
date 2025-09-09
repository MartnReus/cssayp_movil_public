import 'package:cssayp_movil/boletas/domain/entities/boleta_entity.dart';
import 'package:cssayp_movil/boletas/data/models/historial_boletas_response_models.dart';
import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';
// import 'package:cssayp_movil/boletas/domain/entities/parametros_boleta_inicio_entity.dart';

abstract interface class BoletasRepository {
  Future<BoletaEntity> crearBoletaInicio({required String caratula, required int nroAfiliado, required double monto});
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
  Future<HistorialBoletasSuccessResponse> obtenerHistorialBoletas(int nroAfiliado, {int? page});
  // Future<ParametrosBoletaInicioEntity> obtenerParametrosBoletaInicio();
  Future<PaginatedResponseModel> buscarBoletasInicioPagadas({
    required int nroAfiliado,
    int page = 1,
    String? caratulaBuscada,
  });
}

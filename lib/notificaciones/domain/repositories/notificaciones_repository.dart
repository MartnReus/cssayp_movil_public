import 'package:cssayp_movil/notificaciones/domain/entities/notificacion_entity.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';

abstract interface class NotificacionesRepository {
  Future<PaginatedResponse<NotificacionEntity>> obtenerNotificaciones(int nroAfiliado);

  Future<void> registrarDispositivo(String token, int nroAfiliado, String nombreDispositivo, String plataforma);

  Future<void> marcarNotificacionesComoLeidas(List<String> uuidList, int nroAfiliado);
}

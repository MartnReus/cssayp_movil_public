import 'package:cssayp_movil/notificaciones/data/datasources/notificaciones_data_source.dart';
import 'package:cssayp_movil/notificaciones/domain/entities/notificacion_entity.dart';
import 'package:cssayp_movil/notificaciones/domain/repositories/notificaciones_repository.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';
import 'package:cssayp_movil/shared/services/jwt_token_service.dart';

class NotificacionesRepositoryImpl implements NotificacionesRepository {
  final NotificacionesDataSource dataSource;
  final JwtTokenService jwtTokenService;

  NotificacionesRepositoryImpl(this.dataSource, this.jwtTokenService);

  @override
  Future<PaginatedResponse<NotificacionEntity>> obtenerNotificaciones(int nroAfiliado) async {
    final authToken = await jwtTokenService.obtenerToken();
    if (authToken == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }
    final response = await dataSource.obtenerNotificaciones(nroAfiliado, authToken);

    final data = response.data.map((item) => item.toEntity()).toList();
    final links = response.links;
    final meta = response.meta;

    return PaginatedResponse<NotificacionEntity>(data: data, links: links, meta: meta);
  }

  @override
  Future<void> registrarDispositivo(
    String fcmToken,
    int nroAfiliado,
    String nombreDispositivo,
    String plataforma,
  ) async {
    final authToken = await jwtTokenService.obtenerToken();
    if (authToken == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }
    return dataSource.registrarDispositivo(fcmToken, nroAfiliado, nombreDispositivo, plataforma, authToken);
  }

  @override
  Future<void> marcarNotificacionesComoLeidas(List<String> uuidList, int nroAfiliado) async {
    final authToken = await jwtTokenService.obtenerToken();
    if (authToken == null) {
      throw Exception('No se pudo obtener el token de autenticación');
    }
    return dataSource.marcarNotificacionesComoLeidas(uuidList, nroAfiliado, authToken);
  }
}

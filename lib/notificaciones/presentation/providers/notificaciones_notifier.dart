import 'package:cssayp_movil/notificaciones/notificaciones.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';
import 'package:cssayp_movil/shared/models/pagination_links.dart';
import 'package:cssayp_movil/shared/models/pagination_meta.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificacionesState {
  final PaginatedResponse<NotificacionEntity> notificaciones;

  NotificacionesState({required this.notificaciones});

  NotificacionesState copyWith({PaginatedResponse<NotificacionEntity>? notificaciones}) {
    return NotificacionesState(notificaciones: notificaciones ?? this.notificaciones);
  }
}

class NotificacionesNotifier extends AsyncNotifier<NotificacionesState> {
  NotificacionesNotifier();

  @override
  NotificacionesState build() {
    return NotificacionesState(
      notificaciones: PaginatedResponse(
        data: [],
        links: PaginationLinks(),
        meta: PaginationMeta(currentPage: 1, path: '', perPage: 10),
      ),
    );
  }

  Future<void> obtenerListadoNotificaciones() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final ObtenerListadoNotificacionesUseCase obtenerListadoNotificacionesUseCase = await ref.read(
        obtenerListadoNotificacionesUseCaseProvider.future,
      );
      final notificaciones = await obtenerListadoNotificacionesUseCase.execute();

      return _marcarNotificacionesComoLeidas(notificaciones);
    });
  }

  Future<NotificacionesState> _marcarNotificacionesComoLeidas(
    PaginatedResponse<NotificacionEntity> notificaciones,
  ) async {
    final unreadNotifications = notificaciones.data.where((n) => !n.leido).toList();
    if (unreadNotifications.isNotEmpty) {
      final MarcarNotificacionesLeidasUseCase marcarNotificacionesLeidasUseCase = await ref.read(
        marcarNotificacionesLeidasUseCaseProvider.future,
      );
      final unreadUuids = unreadNotifications.map((n) => n.uuid).toList();
      await marcarNotificacionesLeidasUseCase.execute(unreadUuids);

      final updatedData = notificaciones.data.map((n) {
        if (unreadUuids.contains(n.uuid)) {
          return NotificacionEntity(
            uuid: n.uuid,
            titulo: n.titulo,
            mensaje: n.mensaje,
            codigoTipo: n.codigoTipo,
            fechaEnviado: n.fechaEnviado,
            fechaLeido: DateTime.now(),
            data: n.data,
          );
        }
        return n;
      }).toList();

      return NotificacionesState(
        notificaciones: PaginatedResponse(data: updatedData, links: notificaciones.links, meta: notificaciones.meta),
      );
    }

    return NotificacionesState(notificaciones: notificaciones);
  }
}

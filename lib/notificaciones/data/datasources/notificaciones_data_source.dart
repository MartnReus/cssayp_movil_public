import 'dart:convert';
import 'package:cssayp_movil/config.dart';
import 'package:cssayp_movil/notificaciones/data/models/notificacion_model.dart';
import 'package:cssayp_movil/shared/models/paginated_response.dart';
import 'package:http/http.dart' as http;

class NotificacionesDataSource {
  final http.Client client;

  NotificacionesDataSource(this.client);

  Future<void> registrarDispositivo(
    String fcmToken,
    int nroAfiliado,
    String nombreDispositivo,
    String plataforma,
    String authToken,
  ) async {
    final response = await client.post(
      Uri.parse('${AppConfig.personasApiURL}/api/notificaciones/afiliado/dispositivos/registrar'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $authToken'},
      body: jsonEncode({
        'fcmToken': fcmToken,
        'nroAfiliado': nroAfiliado,
        'nombreDispositivo': nombreDispositivo,
        'plataforma': plataforma,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Error al registrar dispositivo');
    }
  }

  Future<void> marcarNotificacionesComoLeidas(List<String> uuidList, int nroAfiliado, String authToken) async {
    final response = await client.post(
      Uri.parse('${AppConfig.personasApiURL}/api/notificaciones/marcar-leido'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $authToken'},
      body: jsonEncode({'uuidList': uuidList, 'nroAfiliado': nroAfiliado}),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Error al marcar notificaciones como leidas');
    }
  }

  Future<PaginatedResponse<NotificacionModel>> obtenerNotificaciones(int nroAfiliado, String authToken) async {
    final response = await client.get(
      Uri.parse('${AppConfig.personasApiURL}/api/notificaciones/afiliado/$nroAfiliado'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return PaginatedResponse<NotificacionModel>.fromJson(jsonData, (json) => NotificacionModel.fromJson(json));
    } else {
      throw Exception('Error al obtener notificaciones');
    }
  }
}

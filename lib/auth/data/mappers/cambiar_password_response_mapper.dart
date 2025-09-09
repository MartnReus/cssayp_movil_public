import 'package:cssayp_movil/auth/data/models/cambiar_password_response_models.dart';

class CambiarPasswordResponseMapper {
  static CambiarPasswordResponseModel fromApiResponse(int statusCode, Map<String, dynamic> json) {
    final estado = _parseEstado(json['estado']);
    final mensaje = json['mensaje'] ?? '';

    if (statusCode != 200) {
      return CambiarPasswordGenericErrorResponse(
        statusCode: statusCode,
        estado: false,
        mensaje: mensaje.isEmpty ? 'Error inesperado al cambiar la contraseña' : mensaje,
      );
    }

    if (estado) {
      return CambiarPasswordSuccessResponse(
        statusCode: statusCode,
        estado: estado,
        mensaje: mensaje.isEmpty ? 'Se asignó correctamente la nueva contraseña' : mensaje,
      );
    } else {
      return CambiarPasswordInvalidCredentialsResponse(
        statusCode: statusCode,
        estado: estado,
        mensaje: mensaje.isEmpty ? 'La contraseña actual es incorrecta' : mensaje,
      );
    }
  }

  static bool _parseEstado(dynamic estado) {
    if (estado is bool) return estado;
    if (estado is String) return estado == "1" || estado.toLowerCase() == "true";
    if (estado is int) return estado == 1;
    return false;
  }
}

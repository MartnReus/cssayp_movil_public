sealed class DatosUsuarioResponseModel {
  final int statusCode;

  const DatosUsuarioResponseModel({required this.statusCode});
}

class DatosUsuarioSuccessResponse extends DatosUsuarioResponseModel {
  final String apellido;
  final String nombres;
  final String apellidoNombres;
  final String titulo;
  final String nroAfiliadoDigito;
  final String circunscripcion;
  final String email;
  final bool cambiarPassword;
  final bool debeActualizarDatos;
  final bool debeValidar;

  const DatosUsuarioSuccessResponse({
    required super.statusCode,
    required this.apellido,
    required this.nombres,
    required this.apellidoNombres,
    required this.titulo,
    required this.nroAfiliadoDigito,
    required this.circunscripcion,
    required this.email,
    required this.cambiarPassword,
    required this.debeActualizarDatos,
    required this.debeValidar,
  });

  factory DatosUsuarioSuccessResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return DatosUsuarioSuccessResponse(
      statusCode: statusCode,
      apellido: json['APELLIDO'] ?? '',
      nombres: json['NOMBRES'] ?? '',
      apellidoNombres: json['APELLIDO_NOMBRES'] ?? '',
      titulo: json['TITULO'] ?? '',
      nroAfiliadoDigito: json['NRO_AFILIADO_DIGITO'] ?? '',
      circunscripcion: json['CIRCUNSCRIPCION'] ?? '',
      email: json['EMAIL'] ?? '',
      cambiarPassword: json['CAMBIAR_PASSWORD'] == '1',
      debeActualizarDatos: json['DEBE_ACTUALIZAR_DATOS'] == '1',
      debeValidar: json['DEBE_VALIDAR'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'apellido': apellido,
      'nombres': nombres,
      'apellidoNombres': apellidoNombres,
      'titulo': titulo,
      'nroAfiliadoDigito': nroAfiliadoDigito,
      'circunscripcion': circunscripcion,
      'email': email,
      'cambiarPassword': cambiarPassword,
      'debeActualizarDatos': debeActualizarDatos,
      'debeValidar': debeValidar,
    };
  }
}

class DatosUsuarioInvalidTokenResponse extends DatosUsuarioResponseModel {
  final String mensaje;
  const DatosUsuarioInvalidTokenResponse({required super.statusCode, required this.mensaje});

  factory DatosUsuarioInvalidTokenResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return DatosUsuarioInvalidTokenResponse(
      statusCode: statusCode,
      mensaje: json['mensaje'] ?? 'Error inesperado al obtener datos del usuario',
    );
  }
}

class DatosUsuarioGenericErrorResponse extends DatosUsuarioResponseModel {
  final String mensaje;
  const DatosUsuarioGenericErrorResponse({required super.statusCode, required this.mensaje});

  factory DatosUsuarioGenericErrorResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return DatosUsuarioGenericErrorResponse(
      statusCode: statusCode,
      mensaje: json['mensaje'] ?? 'Error inesperado al obtener datos del usuario',
    );
  }

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'mensaje': mensaje};
  }
}

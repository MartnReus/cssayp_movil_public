sealed class CambiarPasswordResponseModel {
  final int statusCode;
  final bool estado;
  final String mensaje;

  const CambiarPasswordResponseModel({required this.statusCode, required this.estado, required this.mensaje});

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'estado': estado, 'mensaje': mensaje};
  }
}

class CambiarPasswordSuccessResponse extends CambiarPasswordResponseModel {
  const CambiarPasswordSuccessResponse({required super.statusCode, required super.estado, required super.mensaje});
}

class CambiarPasswordInvalidCredentialsResponse extends CambiarPasswordResponseModel {
  const CambiarPasswordInvalidCredentialsResponse({
    required super.statusCode,
    required super.estado,
    required super.mensaje,
  });
}

class CambiarPasswordGenericErrorResponse extends CambiarPasswordResponseModel {
  const CambiarPasswordGenericErrorResponse({required super.statusCode, required super.estado, required super.mensaje});
}

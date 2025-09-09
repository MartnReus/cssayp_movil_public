sealed class AuthResponseModel {
  final int statusCode;

  const AuthResponseModel({required this.statusCode});
}

class AuthSuccessResponse extends AuthResponseModel {
  final int nroAfiliado;
  final String apellidoNombres;
  final String token;
  final bool cambiarPassword;

  const AuthSuccessResponse({
    required super.statusCode,
    required this.nroAfiliado,
    required this.apellidoNombres,
    required this.token,
    required this.cambiarPassword,
  });

  factory AuthSuccessResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return AuthSuccessResponse(
      statusCode: statusCode,
      nroAfiliado: json['nro_afiliado'],
      apellidoNombres: json['apellido_nombres'],
      token: json['token'],
      cambiarPassword: json['cambiar_password'] is bool
          ? json['cambiar_password']
          : json['cambiar_password'] == 1 || json['cambiar_password'] == "1",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'nroAfiliado': nroAfiliado,
      'apellidoNombres': apellidoNombres,
      'token': token,
      'cambiarPassword': cambiarPassword,
    };
  }
}

class AuthInvalidCredentialsResponse extends AuthResponseModel {
  final int nroAfiliado;
  final String errorMessage;

  const AuthInvalidCredentialsResponse({
    required super.statusCode,
    required this.nroAfiliado,
    required this.errorMessage,
  });

  factory AuthInvalidCredentialsResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return AuthInvalidCredentialsResponse(
      statusCode: statusCode,
      nroAfiliado: json['nro_afiliado'],
      errorMessage: json['mensaje'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'nroAfiliado': nroAfiliado, 'mensaje': errorMessage};
  }
}

class AuthGenericErrorResponse extends AuthResponseModel {
  final String errorMessage;

  const AuthGenericErrorResponse({required super.statusCode, required this.errorMessage});

  factory AuthGenericErrorResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return AuthGenericErrorResponse(statusCode: statusCode, errorMessage: json['mensaje']);
  }

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'mensaje': errorMessage};
  }
}

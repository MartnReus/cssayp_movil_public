sealed class RecuperarResponseModel {
  final int statusCode;
  final bool success;

  const RecuperarResponseModel({required this.statusCode, required this.success});

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'success': success};
  }
}

class RecuperarSuccessResponse extends RecuperarResponseModel {
  const RecuperarSuccessResponse({required super.statusCode, required super.success});

  factory RecuperarSuccessResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return RecuperarSuccessResponse(statusCode: statusCode, success: json['success']);
  }
}

class RecuperarInvalidCredentialsResponse extends RecuperarResponseModel {
  final String errorMessage;
  final String emailHint;

  const RecuperarInvalidCredentialsResponse({
    required super.statusCode,
    required super.success,
    required this.errorMessage,
    required this.emailHint,
  });

  factory RecuperarInvalidCredentialsResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return RecuperarInvalidCredentialsResponse(
      statusCode: statusCode,
      success: json['success'],
      errorMessage: json['error'],
      emailHint: json['email_hint'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({'error': errorMessage, 'email_hint': emailHint});
  }
}

class RecuperarGenericErrorResponse extends RecuperarResponseModel {
  final String errorMessage;
  const RecuperarGenericErrorResponse({
    super.statusCode = 500,
    super.success = false,
    this.errorMessage = 'Error inesperado al recuperar contraseña',
  });

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..addAll({'error': errorMessage});
  }
}

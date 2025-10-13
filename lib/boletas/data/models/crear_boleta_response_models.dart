sealed class CrearBoletaResponse {
  final int statusCode;

  const CrearBoletaResponse({required this.statusCode});
}

class CrearBoletaSuccessResponse extends CrearBoletaResponse {
  final int idBoleta;
  final String urlPago;

  const CrearBoletaSuccessResponse({required super.statusCode, required this.idBoleta, required this.urlPago});

  factory CrearBoletaSuccessResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return CrearBoletaSuccessResponse(
      statusCode: statusCode,
      idBoleta: int.tryParse(json['id_boleta_generada']?.toString() ?? '0') ?? 0,
      urlPago: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': idBoleta, 'url': urlPago};
  }
}

class CrearBoletaGenericErrorResponse extends CrearBoletaResponse {
  final String errorMessage;

  const CrearBoletaGenericErrorResponse({required super.statusCode, required this.errorMessage});

  factory CrearBoletaGenericErrorResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return CrearBoletaGenericErrorResponse(
      statusCode: statusCode,
      errorMessage: json['errorMessage'] ?? 'Error desconocido',
    );
  }

  Map<String, dynamic> toJson() {
    return {'statusCode': statusCode, 'errorMessage': errorMessage};
  }
}

sealed class CrearBoletaResponse {
  final int statusCode;

  const CrearBoletaResponse({required this.statusCode});
}

class CrearBoletaSuccessResponse extends CrearBoletaResponse {
  final int idBoleta;
  final int idTipoBoleta;
  final String idTipoTransaccion;
  final String codBarra;
  final String caratula;
  final String fechaImpresion;
  final String fechaVencimiento;
  final int? idBoletaAsociada;
  final String? diasVencimiento;
  final DateTime? fechaPago;
  final double? importePago;
  final double? gastosAdministrativos;
  final String? montoEntero;
  final String? montoDecimal;

  const CrearBoletaSuccessResponse({
    required super.statusCode,
    required this.idBoleta,
    required this.idTipoBoleta,
    required this.idTipoTransaccion,
    required this.codBarra,
    required this.caratula,
    required this.fechaImpresion,
    required this.fechaVencimiento,
    this.idBoletaAsociada,
    this.diasVencimiento,
    this.fechaPago,
    this.importePago,
    this.gastosAdministrativos,
    this.montoEntero,
    this.montoDecimal,
  });

  factory CrearBoletaSuccessResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return CrearBoletaSuccessResponse(
      statusCode: statusCode,
      idBoleta: int.tryParse(json['id_boleta_generada']?.toString() ?? '0') ?? 0,
      idTipoBoleta: int.tryParse(json['id_tipo_boleta']?.toString() ?? '0') ?? 0,
      idTipoTransaccion: json['id_tipo_transaccion']?.toString() ?? '',
      codBarra: json['cod_barra']?.toString() ?? '',
      caratula: json['caratula']?.toString() ?? '',
      fechaImpresion: json['fecha_impresion']?.toString() ?? '',
      fechaVencimiento: json['dias_vencimiento']?.toString() ?? '',
      diasVencimiento: json['dias_vencimiento']?.toString() ?? '',
      idBoletaAsociada: json['id_boleta_asociada'] != null ? int.tryParse(json['id_boleta_asociada'].toString()) : null,

      fechaPago: json['fecha_pago'] != null ? DateTime.tryParse(json['fecha_pago']) : null,
      importePago: json['importe_pago'] != null ? double.tryParse(json['importe_pago'].toString()) : null,
      gastosAdministrativos: json['gastos_administrativos'] != null
          ? double.tryParse(json['gastos_administrativos'].toString())
          : null,
      montoEntero: json['monto_entero']?.toString(),
      montoDecimal: json['monto_decimal']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idBoleta,
      'id_tipo_transaccion': idTipoBoleta.toString(),
      'fechaImpresion': fechaImpresion,
      'fechaVencimiento': fechaVencimiento,
      'diasVencimiento': diasVencimiento,
      'codBarra': codBarra,
      'idBoletaAsociada': idBoletaAsociada,
      'fechaPago': fechaPago,
      'importePago': importePago,
      'caratula': caratula,
      'gastosAdministrativos': gastosAdministrativos,
      'nroExpediente': null, // Not available in this response
      'anioExpediente': null, // Not available in this response
      'cuij': null, // Not available in this response
      'montoEntero': montoEntero,
      'montoDecimal': montoDecimal,
    };
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

class JuicioEntity {
  final int id; // ID único del juicio (id_juicio de la API)
  final String caratula; // CARATULA - Descripción del expediente
  
  // Relaciones con boletas
  final int boletaInicioId; // ID_BOLETA_GENERADA de la boleta de inicio
  final int? boletaFinId; // ID_BOLETA_GENERADA de la boleta de fin (puede ser null)

  // Estados de pago
  final DateTime? fechaPagoInicio; // fecha_pago_inicio de la API
  final DateTime? fechaPagoFin; // fecha_pago_fin de la API

  JuicioEntity({
    required this.id,
    required this.caratula,
    required this.boletaInicioId,
    this.boletaFinId,
    this.fechaPagoInicio,
    this.fechaPagoFin,
  });

  // Computed properties para facilitar el uso en la UI
  bool get inicioPagado => fechaPagoInicio != null;
  bool get finPagado => fechaPagoFin != null;
  bool get tieneBoletaFin => boletaFinId != null;

  factory JuicioEntity.fromJson(Map<String, dynamic> json) {
    return JuicioEntity(
      id: json['id'],
      caratula: json['caratula'],
      boletaInicioId: json['boletaInicioId'],
      boletaFinId: json['boletaFinId'],
      fechaPagoInicio: json['fechaPagoInicio'] != null ? DateTime.parse(json['fechaPagoInicio']) : null,
      fechaPagoFin: json['fechaPagoFin'] != null ? DateTime.parse(json['fechaPagoFin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caratula': caratula,
      'boletaInicioId': boletaInicioId,
      'boletaFinId': boletaFinId,
      'fechaPagoInicio': fechaPagoInicio?.toIso8601String(),
      'fechaPagoFin': fechaPagoFin?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'JuicioEntity(id: $id, caratula: $caratula, boletaInicioId: $boletaInicioId, boletaFinId: $boletaFinId, fechaPagoInicio: $fechaPagoInicio, fechaPagoFin: $fechaPagoFin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JuicioEntity &&
        other.id == id &&
        other.caratula == caratula &&
        other.boletaInicioId == boletaInicioId &&
        other.boletaFinId == boletaFinId &&
        other.fechaPagoInicio == fechaPagoInicio &&
        other.fechaPagoFin == fechaPagoFin;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      caratula,
      boletaInicioId,
      boletaFinId,
      fechaPagoInicio, fechaPagoFin,
    );
  }
}

class JuicioEntity {
  final int id; // ID único del juicio (puede ser el ID de la boleta de inicio)
  final String caratula; // CARATULA - Descripción del expediente
  final String juzgado; // JUZGADO - Juzgado del Juicio
  final String secretaria; // SECRETARIA - Secretaria del Juicio
  final int tipoJuicio; // TIPO_JUICIO - Tipo de juicio
  final int? nroExpediente; // NRO_EXPEDIENTE - Número de expediente
  final int? anioExpediente; // ANIO_EXPEDIENTE - Año del expediente
  final int? cuij; // CUIJ - Código Único de Identificación Judicial

  // Relaciones con boletas
  final int boletaInicioId; // ID_BOLETA_GENERADA de la boleta de inicio
  final int? boletaFinId; // ID_BOLETA_GENERADA de la boleta de fin

  // Estados de pago
  final bool inicioPagado; // Basado en FECHA_PAGO de boleta inicio
  final bool finPagado; // Basado en FECHA_PAGO de boleta fin

  JuicioEntity({
    required this.id,
    required this.caratula,
    required this.juzgado,
    required this.secretaria,
    required this.tipoJuicio,
    this.nroExpediente,
    this.anioExpediente,
    this.cuij,
    required this.boletaInicioId,
    this.boletaFinId,
    required this.inicioPagado,
    required this.finPagado,
  });

  factory JuicioEntity.fromJson(Map<String, dynamic> json) {
    return JuicioEntity(
      id: json['id'],
      caratula: json['caratula'],
      juzgado: json['juzgado'],
      secretaria: json['secretaria'],
      tipoJuicio: json['tipoJuicio'],
      nroExpediente: json['nroExpediente'],
      anioExpediente: json['anioExpediente'],
      cuij: json['cuij'],
      boletaInicioId: json['boletaInicioId'],
      boletaFinId: json['boletaFinId'],
      inicioPagado: json['inicioPagado'] ?? false,
      finPagado: json['finPagado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caratula': caratula,
      'juzgado': juzgado,
      'secretaria': secretaria,
      'tipoJuicio': tipoJuicio,
      'nroExpediente': nroExpediente,
      'anioExpediente': anioExpediente,
      'cuij': cuij,
      'boletaInicioId': boletaInicioId,
      'boletaFinId': boletaFinId,
      'inicioPagado': inicioPagado,
      'finPagado': finPagado,
    };
  }

  @override
  String toString() {
    return 'JuicioEntity(id: $id, caratula: $caratula, juzgado: $juzgado, secretaria: $secretaria, tipoJuicio: $tipoJuicio, nroExpediente: $nroExpediente, anioExpediente: $anioExpediente, cuij: $cuij, boletaInicioId: $boletaInicioId, boletaFinId: $boletaFinId, inicioPagado: $inicioPagado, finPagado: $finPagado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JuicioEntity &&
        other.id == id &&
        other.caratula == caratula &&
        other.juzgado == juzgado &&
        other.secretaria == secretaria &&
        other.tipoJuicio == tipoJuicio &&
        other.nroExpediente == nroExpediente &&
        other.anioExpediente == anioExpediente &&
        other.cuij == cuij &&
        other.boletaInicioId == boletaInicioId &&
        other.boletaFinId == boletaFinId &&
        other.inicioPagado == inicioPagado &&
        other.finPagado == finPagado;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      caratula,
      juzgado,
      secretaria,
      tipoJuicio,
      nroExpediente,
      anioExpediente,
      cuij,
      boletaInicioId,
      boletaFinId,
      inicioPagado,
      finPagado,
    );
  }
}

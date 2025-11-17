import 'package:cssayp_movil/boletas/domain/entities/boleta_tipo.dart';

class BoletaEntity {
  final int id; // ID_BOLETA_GENERADA
  final BoletaTipo tipo; // ID_TIPO_BOLETA (1=inicio, 2=fin)
  final double monto; // MONTO_ENTERO + MONTO_DECIMAL
  final DateTime fechaImpresion; // FECHA_IMPRESION
  final DateTime fechaVencimiento; // FECHA_VENCIMIENTO_CUOTA
  final String? codBarra; // COD_BARRA

  // Relación con boleta asociada
  final int? idBoletaAsociada; // ID_BOLETA_ASOCIADA

  // Estado de pago
  final DateTime? fechaPago; // FECHA_PAGO
  final double? importePago; // IMPORTE_PAGO
  final String? estado; // ESTADO_PAGO

  // Información del juicio
  final String caratula; // CARATULA

  // Campos adicionales
  final int? nroExpediente; // NRO_EXPEDIENTE
  final int? anioExpediente; // ANIO_EXPEDIENTE
  final int? cuij; // CUIJ
  final double? gastosAdministrativos; // GASTOS_ADMINISTRATIVOS

  BoletaEntity({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.fechaImpresion,
    required this.fechaVencimiento,
    required this.caratula,
    this.idBoletaAsociada,
    this.fechaPago,
    this.importePago,
    this.codBarra,
    this.nroExpediente,
    this.anioExpediente,
    this.cuij,
    this.gastosAdministrativos,
    this.estado,
  });

  factory BoletaEntity.fromJson(Map<String, dynamic> json) {
    return BoletaEntity(
      id: json['id'],
      tipo: BoletaTipo.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipo'],
        orElse: () => BoletaTipo.inicio,
      ),
      monto: (json['monto'] ?? 0).toDouble(),
      fechaImpresion: DateTime.parse(json['fechaImpresion']),
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
      idBoletaAsociada: json['idBoletaAsociada'],
      fechaPago: json['fechaPago'] != null ? DateTime.parse(json['fechaPago']) : null,
      importePago: json['importePago'] != null ? double.tryParse(json['importePago'].toString()) : null,
      codBarra: json['codBarra'],
      caratula: json['caratula'] ?? '',
      nroExpediente: json['nroExpediente'],
      anioExpediente: json['anioExpediente'],
      cuij: json['cuij'],
      gastosAdministrativos: json['gastosAdministrativos'] != null
          ? double.tryParse(json['gastosAdministrativos'].toString())
          : null,
      estado: json['estado'] ?? '',
    );
  }

  factory BoletaEntity.fromCrearBoletaResponse(Map<String, dynamic> json) {
    return BoletaEntity(
      id: json['id'],
      // id_tipo_transaccion is in (1,3) -> inicio, (2) -> finalizacion
      tipo: BoletaTipo.fromId(int.tryParse(json['id_tipo_transaccion']?.toString() ?? '') ?? 0),
      monto:
          (double.tryParse(json['montoEntero']?.toString() ?? '0') ?? 0) +
          (double.tryParse(json['montoDecimal']?.toString() ?? '0') ?? 0) / 100,
      fechaImpresion: DateTime.parse(json['fechaImpresion']),
      fechaVencimiento: DateTime.parse(
        json['fechaImpresion'],
      ).add(Duration(days: int.tryParse(json['diasVencimiento']?.toString() ?? '30') ?? 30)),
      idBoletaAsociada: json['idBoletaAsociada'],
      fechaPago: json['fechaPago'] != null ? DateTime.parse(json['fechaPago']) : null,
      importePago: json['importePago'] != null ? double.tryParse(json['importePago'].toString()) : null,
      codBarra: json['codBarra'],
      caratula: json['caratula'] ?? '',
      nroExpediente: json['nroExpediente'],
      anioExpediente: json['anioExpediente'],
      cuij: json['cuij'],
      gastosAdministrativos: json['gastosAdministrativos'] != null
          ? double.tryParse(json['gastosAdministrativos'].toString())
          : null,
      estado: json['estado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.toString().split('.').last,
      'monto': monto,
      'fechaImpresion': fechaImpresion.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'idBoletaAsociada': idBoletaAsociada,
      'fechaPago': fechaPago?.toIso8601String(),
      'importePago': importePago,
      'codBarra': codBarra,
      'caratula': caratula,
      'nroExpediente': nroExpediente,
      'anioExpediente': anioExpediente,
      'cuij': cuij,
      'gastosAdministrativos': gastosAdministrativos,
      'estado': estado,
    };
  }

  bool get estaPagada => fechaPago != null || estado == 'Para imputar';

  bool get estaVencida => DateTime.now().isAfter(fechaVencimiento);

  @override
  String toString() {
    return 'BoletaEntity(id: $id, tipo: $tipo, monto: $monto, fechaImpresion: $fechaImpresion, fechaVencimiento: $fechaVencimiento, caratula: $caratula, estaPagada: $estaPagada)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoletaEntity &&
        other.id == id &&
        other.tipo == tipo &&
        other.monto == monto &&
        other.fechaImpresion == fechaImpresion &&
        other.fechaVencimiento == fechaVencimiento &&
        other.caratula == caratula;
  }

  @override
  int get hashCode {
    return Object.hash(id, tipo, monto, fechaImpresion, fechaVencimiento, caratula);
  }
}

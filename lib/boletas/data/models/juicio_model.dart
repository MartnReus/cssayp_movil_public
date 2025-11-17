import 'package:cssayp_movil/boletas/domain/entities/juicio_entity.dart';

class JuicioModel {
  final String rn;
  final String idJuicio;
  final String caratula;
  final String boletaInicioId;
  final String? fechaPagoInicio;
  final String? boletaFinId;
  final String? fechaPagoFin;

  JuicioModel({
    required this.rn,
    required this.idJuicio,
    required this.caratula,
    required this.boletaInicioId,
    this.fechaPagoInicio,
    this.boletaFinId,
    this.fechaPagoFin,
  });

  factory JuicioModel.fromJson(Map<String, dynamic> json) {
    return JuicioModel(
      rn: json['rn'].toString(),
      idJuicio: json['id_juicio'].toString(),
      caratula: json['caratula'] as String,
      boletaInicioId: json['boleta_inicio_id'].toString(),
      fechaPagoInicio: json['fecha_pago_inicio'] as String?,
      boletaFinId: json['boleta_fin_id']?.toString(),
      fechaPagoFin: json['fecha_pago_fin'] as String?,
    );
  }

  JuicioEntity toEntity() {
    return JuicioEntity(
      id: int.parse(idJuicio),
      caratula: caratula,
      boletaInicioId: int.parse(boletaInicioId),
      boletaFinId: boletaFinId != null ? int.parse(boletaFinId!) : null,
      fechaPagoInicio: fechaPagoInicio != null ? _parseDate(fechaPagoInicio!) : null,
      fechaPagoFin: fechaPagoFin != null ? _parseDate(fechaPagoFin!) : null,
    );
  }

  DateTime? _parseDate(String dateString) {
    try {
      // La API devuelve fechas en formato "2025-09-07 00:00:00"
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'rn': rn,
      'id_juicio': idJuicio,
      'caratula': caratula,
      'boleta_inicio_id': boletaInicioId,
      'fecha_pago_inicio': fechaPagoInicio,
      'boleta_fin_id': boletaFinId,
      'fecha_pago_fin': fechaPagoFin,
    };
  }
}

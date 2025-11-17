import 'package:cssayp_movil/comprobantes/data/models/typedefs.dart';

class ComprobanteEntity {
  final int id;
  final String fecha;
  final String importe;
  final List<BoletaPagada> boletasPagadas;
  final String? externalReferenceId;
  final String? comprobanteLink;
  final String? metodoPago;

  ComprobanteEntity({
    required this.id,
    required this.fecha,
    required this.importe,
    required this.boletasPagadas,
    this.externalReferenceId,
    this.comprobanteLink,
    this.metodoPago,
  });

  factory ComprobanteEntity.fromJson(Map<String, dynamic> json) {
    List<dynamic> boletasJson = json['boletas_pagadas'] ?? [];
    List<BoletaPagada> boletasPagadas = boletasJson.map((boleta) => _boletaPagadaFromJson(boleta)).toList();
    return ComprobanteEntity(
      id: json['id'],
      fecha: json['fecha'],
      externalReferenceId: json['external_reference_id'],
      importe: json['importe'],
      boletasPagadas: boletasPagadas,
      comprobanteLink: json['comprobante_link'],
      metodoPago: json['metodo_pago'],
    );
  }
}

// Helpers
MontoOrganismo _montoOrganismoFromJson(Map<String, dynamic> json) {
  return (circunscripcion: json['circunscripcion'], monto: json['monto'].toDouble(), organismo: json['organismo']);
}

BoletaPagada _boletaPagadaFromJson(Map<String, dynamic> json) {
  List<MontoOrganismo>? montosOrganismos;
  if (json['mvc'] == '0100') {
    List<Map<String, dynamic>> montosJson = json['montos_organismos'] ?? [];
    if (montosJson.isNotEmpty) {
      montosOrganismos = montosJson.map((monto) => _montoOrganismoFromJson(monto)).toList();
    }
  }

  return (
    id: json['id'],
    importe: json['importe'],
    caratula: json['caratula'],
    mvc: json['mvc'],
    tipoJuicio: json['tipo_juicio'],
    montosOrganismos: montosOrganismos,
  );
}

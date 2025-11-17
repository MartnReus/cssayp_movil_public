import 'package:cssayp_movil/comprobantes/comprobantes.dart';

sealed class DatosComprobanteResponse {
  final int statusCode;

  DatosComprobanteResponse({required this.statusCode});
}

class DatosComprobanteSuccessResponse extends DatosComprobanteResponse {
  final int id;
  final String fecha;
  final String importe;
  final List<BoletaPagada> boletasPagadas;
  final String? externalReferenceId;
  final String? comprobanteLink;
  final String? metodoPago;

  DatosComprobanteSuccessResponse({
    required super.statusCode,
    required this.id,
    required this.fecha,
    required this.importe,
    required this.boletasPagadas,
    this.externalReferenceId,
    this.comprobanteLink,
    this.metodoPago,
  });

  factory DatosComprobanteSuccessResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    List<dynamic> boletasJson = json['boletas_pagadas'] ?? [];
    List<BoletaPagada> boletasPagadas = boletasJson
        .map(
          (boleta) => (
            id: boleta['id'] as int,
            importe: boleta['importe'] as String,
            caratula: boleta['caratula'] as String,
            mvc: boleta['mvc'] as String,
            tipoJuicio: boleta['tipo_juicio'] as String?,
            montosOrganismos: (boleta['montos_distribucion'] as List<dynamic>?)
                ?.map(
                  (monto) => (
                    circunscripcion: int.parse(monto['circunscripcion']),
                    organismo: monto['organismo'] as String,
                    monto: double.parse(monto['monto'] as String),
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    return DatosComprobanteSuccessResponse(
      statusCode: statusCode,
      id: json['id'],
      fecha: json['fecha'],
      importe: json['importe'],
      externalReferenceId: json['external_reference_id'],
      boletasPagadas: boletasPagadas,
      comprobanteLink: json['comprobante_link'],
      metodoPago: json['metodo_pago'],
    );
  }

  // Convert to domain entity
  ComprobanteEntity toEntity() {
    return ComprobanteEntity(
      id: id,
      fecha: fecha,
      externalReferenceId: externalReferenceId,
      importe: importe,
      boletasPagadas: boletasPagadas,
      comprobanteLink: comprobanteLink,
      metodoPago: metodoPago,
    );
  }
}

class DatosComprobanteGenericErrorResponse extends DatosComprobanteResponse {
  final String errorMessage;

  DatosComprobanteGenericErrorResponse({required super.statusCode, required this.errorMessage});

  factory DatosComprobanteGenericErrorResponse.fromJson(int statusCode, Map<String, dynamic> json) {
    return DatosComprobanteGenericErrorResponse(
      statusCode: statusCode,
      errorMessage: json['error_message'] ?? 'Error desconocido',
    );
  }
}

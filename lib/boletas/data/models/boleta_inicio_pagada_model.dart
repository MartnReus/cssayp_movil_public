class BoletaInicioPagadaModel {
  final String id;
  final String fechaImpresion;
  final String diasVencimiento;
  final String monto;
  final String fechaPago;
  final String caratula;

  const BoletaInicioPagadaModel({
    required this.id,
    required this.fechaImpresion,
    required this.diasVencimiento,
    required this.monto,
    required this.fechaPago,
    required this.caratula,
  });

  factory BoletaInicioPagadaModel.fromJson(Map<String, dynamic> json) {
    return BoletaInicioPagadaModel(
      id: json['id_boleta_generada'],
      fechaImpresion: json['fecha_impresion'],
      diasVencimiento: json['dias_vencimiento'],
      monto: json['monto'],
      fechaPago: json['fecha_pago'],
      caratula: json['caratula'],
    );
  }
}

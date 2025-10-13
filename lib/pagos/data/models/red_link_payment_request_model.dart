class RedLinkPaymentRequestModel {
  final int idBoleta;
  final String concepto;
  final String referencia;
  final double importe;
  final String cpe;

  const RedLinkPaymentRequestModel({
    required this.idBoleta,
    required this.concepto,
    required this.referencia,
    required this.importe,
    required this.cpe,
  });

  Map<String, dynamic> toJson() {
    return {'id_boleta': idBoleta, 'concepto': concepto, 'referencia': referencia, 'importe': importe, 'cpe': cpe};
  }

  factory RedLinkPaymentRequestModel.fromJson(Map<String, dynamic> json) {
    return RedLinkPaymentRequestModel(
      idBoleta: json['id_boleta'] as int,
      concepto: json['concepto'] as String,
      referencia: json['referencia'] as String,
      importe: (json['importe'] as num).toDouble(),
      cpe: json['cpe'] as String,
    );
  }
}

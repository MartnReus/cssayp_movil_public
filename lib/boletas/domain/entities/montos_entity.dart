class MontosEntity {
  final double montoCaja;
  final double montoForense;
  final double montoColegio;

  MontosEntity({required this.montoCaja, required this.montoForense, required this.montoColegio});

  factory MontosEntity.fromJson(Map<String, dynamic> json) {
    return MontosEntity(
      montoCaja: (json['monto_caja'] as num?)?.toDouble() ?? 0.0,
      montoForense: (json['monto_forense'] as num?)?.toDouble() ?? 0.0,
      montoColegio: (json['monto_colegio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'monto_caja': montoCaja, 'monto_forense': montoForense, 'monto_colegio': montoColegio};
  }
}

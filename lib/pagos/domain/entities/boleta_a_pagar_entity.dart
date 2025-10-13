class BoletaAPagarEntity {
  final int idBoleta;
  final double monto;
  final String caratula;
  final int nroAfiliado;

  BoletaAPagarEntity({required this.idBoleta, required this.caratula, required this.monto, required this.nroAfiliado});

  factory BoletaAPagarEntity.fromJson(Map<String, dynamic> json) {
    return BoletaAPagarEntity(
      idBoleta: json['idBoleta'],
      caratula: json['caratula'],
      nroAfiliado: json['nroAfiliado'],
      monto: json['monto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'idBoleta': idBoleta, 'caratula': caratula, 'nroAfiliado': nroAfiliado, 'monto': monto};
  }
}

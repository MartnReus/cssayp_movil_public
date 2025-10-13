class CrearBoletaInicioResult {
  final int idBoleta;
  final String urlPago;

  const CrearBoletaInicioResult({required this.idBoleta, required this.urlPago});

  @override
  String toString() {
    return 'CrearBoletaInicioResult(idBoleta: $idBoleta, urlPago: $urlPago)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrearBoletaInicioResult && other.idBoleta == idBoleta && other.urlPago == urlPago;
  }

  @override
  int get hashCode => Object.hash(idBoleta, urlPago);
}

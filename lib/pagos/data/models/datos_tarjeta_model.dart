enum TipoTarjeta { debito, credito }

class DatosTarjetaModel {
  final String nombre;
  final String dni;
  final String nroTarjeta;
  final String cvv;
  final String fechaExpiracion;
  final TipoTarjeta tipoTarjeta;
  final int cuotas;

  const DatosTarjetaModel({
    required this.nombre,
    required this.dni,
    required this.nroTarjeta,
    required this.cvv,
    required this.fechaExpiracion,
    this.tipoTarjeta = TipoTarjeta.debito,
    this.cuotas = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dni': dni,
      'nroTarjeta': nroTarjeta,
      'cvv': cvv,
      'fechaExpiracion': fechaExpiracion,
      'tipoTarjeta': tipoTarjeta.name,
      'cuotas': cuotas,
    };
  }
}

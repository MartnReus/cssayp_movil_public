class NotificacionEntity {
  final String uuid;
  final String titulo;
  final String mensaje;
  final String codigoTipo;
  final DateTime fechaEnviado;
  final DateTime? fechaLeido;
  final String? data;

  NotificacionEntity({
    required this.uuid,
    required this.titulo,
    required this.mensaje,
    required this.codigoTipo,
    required this.fechaEnviado,
    this.fechaLeido,
    this.data,
  });

  bool get leido => fechaLeido != null;
}
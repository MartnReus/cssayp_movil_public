import 'package:cssayp_movil/notificaciones/domain/entities/notificacion_entity.dart';

class NotificacionModel {
  final String uuid;
  final String type;
  final String title;
  final String body;
  final DateTime sentAt;
  final DateTime? readAt;

  const NotificacionModel({
    required this.uuid,
    required this.type,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.readAt,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      uuid: json['uuid'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      sentAt: DateTime.parse(json['sent_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  NotificacionEntity toEntity() {
    return NotificacionEntity(
      uuid: uuid,
      codigoTipo: type,
      titulo: title,
      mensaje: body,
      fechaEnviado: sentAt,
      fechaLeido: readAt,
    );
  }
}

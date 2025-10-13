import 'package:cssayp_movil/boletas/boletas.dart';

class TipoJuicioEntity {
  final String id;
  final String descripcion;
  final MontosEntity? montos;

  TipoJuicioEntity({required this.id, required this.descripcion, this.montos});

  factory TipoJuicioEntity.fromJson(Map<String, dynamic> json) {
    return TipoJuicioEntity(
      id: json['id']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      montos: json['montos'] != null ? MontosEntity.fromJson(json['montos']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descripcion': descripcion, 'montos': montos?.toJson()};
  }

  List<String> toArray() {
    return [id, descripcion];
  }
}

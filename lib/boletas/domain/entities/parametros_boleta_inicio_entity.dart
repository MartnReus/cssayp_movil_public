import 'package:cssayp_movil/boletas/boletas.dart';

class ParametrosBoletaInicioEntity {
  final List<TipoJuicioEntity> tiposJuicio;
  final List<CircunscripcionEntity> circunscripciones;

  const ParametrosBoletaInicioEntity({required this.tiposJuicio, required this.circunscripciones});

  factory ParametrosBoletaInicioEntity.fromJson(Map<String, dynamic> json) {
    return ParametrosBoletaInicioEntity(
      tiposJuicio: (json['tipos_juicios'] as List<dynamic>? ?? [])
          .map((item) => TipoJuicioEntity.fromJson(item as Map<String, dynamic>))
          .toList(),
      circunscripciones: (json['circunscripciones'] as List<dynamic>? ?? [])
          .map((item) => CircunscripcionEntity.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tipos_juicio': tiposJuicio, 'circunscripciones': circunscripciones};
  }
}

class ParametrosBoletaInicioEntity {
  final List<String> tiposJuicio;
  final List<String> circunscripciones;
  final List<String> competencias;
  final List<String> tiposCausa;

  const ParametrosBoletaInicioEntity({
    required this.tiposJuicio,
    required this.circunscripciones,
    required this.competencias,
    required this.tiposCausa,
  });

  factory ParametrosBoletaInicioEntity.fromJson(Map<String, dynamic> json) {
    return ParametrosBoletaInicioEntity(
      tiposJuicio: List<String>.from(json['tipos_juicio'] ?? []),
      circunscripciones: List<String>.from(json['circunscripciones'] ?? []),
      competencias: List<String>.from(json['competencias'] ?? []),
      tiposCausa: List<String>.from(json['tipos_causa'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipos_juicio': tiposJuicio,
      'circunscripciones': circunscripciones,
      'competencias': competencias,
      'tipos_causa': tiposCausa,
    };
  }
}

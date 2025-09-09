class DatosUsuarioEntity {
  final String titulo;
  final String nroAfiliadoDigito;
  final String circunscripcion;
  final String email;

  DatosUsuarioEntity({
    required this.titulo,
    required this.nroAfiliadoDigito,
    required this.circunscripcion,
    required this.email,
  });

  factory DatosUsuarioEntity.fromJson(Map<String, dynamic> json) {
    return DatosUsuarioEntity(
      titulo: json['titulo'],
      nroAfiliadoDigito: json['nroAfiliadoDigito'],
      circunscripcion: json['circunscripcion'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'nroAfiliadoDigito': nroAfiliadoDigito,
      'circunscripcion': circunscripcion,
      'email': email,
    };
  }
}

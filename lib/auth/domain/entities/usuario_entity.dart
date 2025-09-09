import 'package:cssayp_movil/auth/domain/entities/datos_usuario_entity.dart';

class UsuarioEntity {
  final int nroAfiliado;
  final String apellidoNombres;
  final bool cambiarPassword;
  final String username;
  DatosUsuarioEntity? datosUsuario;

  UsuarioEntity({
    required this.nroAfiliado,
    required this.apellidoNombres,
    required this.cambiarPassword,
    required this.username,
    this.datosUsuario,
  });

  factory UsuarioEntity.fromJson(Map<String, dynamic> json) {
    return UsuarioEntity(
      nroAfiliado: json['nroAfiliado'],
      apellidoNombres: json['apellidoNombres'],
      cambiarPassword: json['cambiarPassword'] is bool
          ? json['cambiarPassword']
          : json['cambiarPassword'] == 1 || json['cambiarPassword'] == "1",
      username: json['username'],
      datosUsuario: json['datosUsuario'] != null ? DatosUsuarioEntity.fromJson(json['datosUsuario']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nroAfiliado': nroAfiliado,
      'apellidoNombres': apellidoNombres,
      'cambiarPassword': cambiarPassword,
      'username': username,
      'datosUsuario': datosUsuario?.toJson(),
    };
  }
}

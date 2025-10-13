import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';

class ObtenerParametrosBoletaInicioUseCase {
  final BoletasRepository boletasRepository;
  final UsuarioRepository usuarioRepository;

  ObtenerParametrosBoletaInicioUseCase({required this.boletasRepository, required this.usuarioRepository});

  Future<ParametrosBoletaInicioEntity> execute() async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();
    if (usuario == null) {
      throw Exception('No hay usuario autenticado');
    }
    return await boletasRepository.obtenerParametrosBoletaInicio(usuario.nroAfiliado);
  }
}

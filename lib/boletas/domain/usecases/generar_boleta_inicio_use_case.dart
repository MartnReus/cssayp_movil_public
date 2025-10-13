import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';

class GenerarBoletaInicioUseCase {
  final BoletasRepository boletasRepository;
  final UsuarioRepository usuarioRepository;

  GenerarBoletaInicioUseCase({required this.boletasRepository, required this.usuarioRepository});

  Future<CrearBoletaInicioResult> execute({
    required String caratula,
    required CircunscripcionEntity circunscripcion,
    required TipoJuicioEntity tipoJuicio,
    required String juzgado,
  }) async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();

    if (usuario == null) {
      throw Exception('No hay usuario autenticado');
    }

    return await boletasRepository.crearBoletaInicio(
      caratula: caratula,
      circunscripcion: circunscripcion,
      juzgado: juzgado,
      tipoJuicio: tipoJuicio,
    );
  }
}

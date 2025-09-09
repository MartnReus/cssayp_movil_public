import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_entity.dart';
import 'package:cssayp_movil/boletas/domain/repositories/boletas_repository.dart';

class GenerarBoletaInicioUseCase {
  final BoletasRepository boletasRepository;
  final UsuarioRepository usuarioRepository;

  GenerarBoletaInicioUseCase({required this.boletasRepository, required this.usuarioRepository});

  Future<BoletaEntity> execute({required String caratula, required double monto}) async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();

    if (usuario == null) {
      throw Exception('No hay usuario autenticado');
    }

    return await boletasRepository.crearBoletaInicio(
      caratula: caratula,
      monto: monto,
      nroAfiliado: usuario.nroAfiliado,
    );
  }
}

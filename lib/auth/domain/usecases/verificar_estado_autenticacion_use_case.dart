import 'package:cssayp_movil/auth/domain/repositories/preferencias_repository.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';
import 'package:cssayp_movil/shared/enums/auth_status.dart';

class VerificarEstadoAutenticacionUseCase {
  final UsuarioRepository _usuarioRepository;
  final PreferenciasRepository _preferenciasRepository;

  VerificarEstadoAutenticacionUseCase({
    required UsuarioRepository usuarioRepository,
    required PreferenciasRepository preferenciasRepository,
  }) : _usuarioRepository = usuarioRepository,
       _preferenciasRepository = preferenciasRepository;

  Future<AuthStatus> execute() async {
    final estaAutenticado = await _usuarioRepository.estaAutenticado();
    if (!estaAutenticado) {
      return AuthStatus.noAutenticado;
    }

    final preferenciaBiometria = await _preferenciasRepository.obtenerPreferenciaBiometria();
    if (preferenciaBiometria) {
      return AuthStatus.autenticadoRequiereBiometria;
    }

    return AuthStatus.autenticadoNoRequiereBiometria;
  }
}

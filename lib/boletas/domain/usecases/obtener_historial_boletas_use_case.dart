import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/data/models/historial_boletas_response_models.dart';
import 'package:cssayp_movil/boletas/domain/repositories/boletas_repository.dart';
import 'package:cssayp_movil/shared/exceptions/auth_exceptions.dart';

class ObtenerHistorialBoletasUseCase {
  final BoletasRepository boletasRepository;
  final UsuarioRepository usuarioRepository;

  ObtenerHistorialBoletasUseCase({required this.boletasRepository, required this.usuarioRepository});

  Future<HistorialBoletasSuccessResponse> execute({int? page, String filtroEstado = 'todas'}) async {
    // Validar autenticación
    final usuario = await usuarioRepository.obtenerUsuarioActual();
    if (usuario == null) {
      throw AuthNotAuthenticatedException('No hay usuario autenticado');
    }

    // Obtener boletas del repositorio con paginación
    final response = await boletasRepository.obtenerHistorialBoletas(
      usuario.nroAfiliado,
      page: page,
      filtroEstado: filtroEstado,
    );

    return response;
  }
}

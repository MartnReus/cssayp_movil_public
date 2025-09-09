import 'package:cssayp_movil/boletas/data/models/paginated_response_model.dart';
import 'package:cssayp_movil/boletas/domain/repositories/boletas_repository.dart';
import 'package:cssayp_movil/auth/domain/repositories/usuario_repository.dart';

class BuscarBoletasInicioPagadasUseCase {
  final BoletasRepository boletasRepository;
  final UsuarioRepository usuarioRepository;

  BuscarBoletasInicioPagadasUseCase({required this.boletasRepository, required this.usuarioRepository});

  Future<PaginatedResponseModel> execute({int page = 1, String? caratulaBuscada}) async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();
    if (usuario == null) {
      throw Exception('No hay usuario autenticado');
    }
    return await boletasRepository.buscarBoletasInicioPagadas(
      nroAfiliado: usuario.nroAfiliado,
      page: page,
      caratulaBuscada: caratulaBuscada,
    );
  }
}

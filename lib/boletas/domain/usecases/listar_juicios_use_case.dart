import 'package:cssayp_movil/boletas/domain/entities/juicio_entity.dart';
import 'package:cssayp_movil/boletas/domain/repositories/juicios_repository.dart';

class ListarJuiciosUseCase {
  final JuiciosRepository juiciosRepository;

  ListarJuiciosUseCase({required this.juiciosRepository});

  Future<List<JuicioEntity>> execute(int nroAfiliado) async {
    return await juiciosRepository.obtenerJuiciosActivos(nroAfiliado);
  }
}

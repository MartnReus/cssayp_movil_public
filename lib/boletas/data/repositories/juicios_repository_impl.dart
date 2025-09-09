import 'package:cssayp_movil/boletas/domain/entities/juicio_entity.dart';
import 'package:cssayp_movil/boletas/domain/repositories/juicios_repository.dart';

class JuiciosRepositoryImpl implements JuiciosRepository {
  @override
  Future<List<JuicioEntity>> obtenerJuiciosActivos(int nroAfiliado) async {
    try {
      // Implementation would depend on the actual API
      // This is a placeholder implementation
      throw UnimplementedError('obtenerJuiciosActivos not implemented');
    } catch (e) {
      throw Exception('Error al obtener juicios activos: $e');
    }
  }
}


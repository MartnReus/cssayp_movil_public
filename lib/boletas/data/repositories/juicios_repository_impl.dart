import 'package:cssayp_movil/boletas/data/datasources/boletas_data_source.dart';
import 'package:cssayp_movil/boletas/domain/entities/juicio_entity.dart';
import 'package:cssayp_movil/boletas/domain/repositories/juicios_repository.dart';

class JuiciosRepositoryImpl implements JuiciosRepository {
  final BoletasDataSource dataSource;

  JuiciosRepositoryImpl({required this.dataSource});

  @override
  Future<List<JuicioEntity>> obtenerJuiciosActivos(int nroAfiliado, {int page = 1}) async {
    try {
      final response = await dataSource.obtenerJuiciosAbiertos(nroAfiliado: nroAfiliado, page: page);
      return response.data.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al obtener juicios activos: $e');
    }
  }
}

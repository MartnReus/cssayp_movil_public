import 'package:cssayp_movil/boletas/domain/entities/juicio_entity.dart';

abstract interface class JuiciosRepository {
  Future<List<JuicioEntity>> obtenerJuiciosActivos(int nroAfiliado, {int page = 1});
}

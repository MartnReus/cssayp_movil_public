import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_entity.dart';
import 'package:cssayp_movil/boletas/domain/repositories/boletas_repository.dart';

class GenerarBoletaFinalizacionUseCase {
  final BoletasRepository boletasRepository;
  final UsuarioRepository usuarioRepository;

  GenerarBoletaFinalizacionUseCase({required this.boletasRepository, required this.usuarioRepository});

  Future<BoletaEntity> execute({
    required int idBoletaInicio,
    required double monto,
    required DateTime fechaRegulacion,
    required double honorarios,
    required String caratula,
    required double cantidadJus,
    required double valorJus,
    int? nroExpediente,
    int? anioExpediente,
    int? cuij,
  }) async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();

    if (usuario == null) {
      throw Exception('No hay usuario autenticado');
    }

    return await boletasRepository.crearBoletaFinalizacion(
      nroAfiliado: usuario.nroAfiliado,
      caratula: caratula,
      idBoletaInicio: idBoletaInicio,
      monto: monto,
      fechaRegulacion: fechaRegulacion,
      honorarios: honorarios,
      cantidadJus: cantidadJus,
      valorJus: valorJus,
      nroExpediente: nroExpediente,
      anioExpediente: anioExpediente,
      cuij: cuij,
    );
  }
}

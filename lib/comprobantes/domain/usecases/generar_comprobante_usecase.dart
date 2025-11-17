import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:cssayp_movil/shared/services/pdf_service.dart';

class GenerarComprobanteUseCase {
  final PdfService pdfService;
  final UsuarioRepository usuarioRepository;

  GenerarComprobanteUseCase({required this.pdfService, required this.usuarioRepository});

  /// Método que se encarga de generar un comprobante en formato PDF y devolver la ruta del archivo generado.
  Future<String> execute(ComprobanteEntity comprobante) async {
    final usuario = await usuarioRepository.obtenerUsuarioActual();
    if (usuario == null) {
      throw Exception('No hay usuario autenticado');
    }

    final filePath = await pdfService.generarPdfComprobante(comprobante: comprobante, usuario: usuario);

    return filePath;
  }
}

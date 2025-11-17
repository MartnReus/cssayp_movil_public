import 'package:cssayp_movil/comprobantes/comprobantes.dart';

import 'package:share_plus/share_plus.dart';

class CompartirComprobanteUseCase {
  final GenerarComprobanteUseCase generarComprobanteUseCase;
  final SharePlus sharePlus;

  CompartirComprobanteUseCase({required this.generarComprobanteUseCase, required this.sharePlus});

  Future<void> execute(ComprobanteEntity comprobante) async {
    final filePath = await generarComprobanteUseCase.execute(comprobante);

    final result = await sharePlus.share(
      ShareParams(
        text: 'Comprobante de pago #${comprobante.id}',
        subject: 'Comprobante CSSAyP',
        files: [XFile(filePath)],
      ),
    );

    if (result.status == ShareResultStatus.dismissed) {
      return;
    }
  }
}

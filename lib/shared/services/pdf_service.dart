import 'dart:io';

import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  /// Genera un PDF del comprobante y lo guarda en el dispositivo
  /// Retorna la ruta del archivo generado
  Future<String> generarPdfComprobante({required ComprobanteEntity comprobante, required UsuarioEntity usuario}) async {
    final pdf = pw.Document();

    final esBoletaInicio = comprobante.boletasPagadas.isNotEmpty && comprobante.boletasPagadas.first.mvc == '0100';

    final header = await _buildHeader();

    final paginaPrincipal = _buildMainPage(pw.Header(child: header), comprobante, usuario, esBoletaInicio);

    pdf.addPage(paginaPrincipal);

    // Guardar el PDF
    return await _guardarPdf(pdf, comprobante.id);
  }

  Future<pw.Widget> _buildHeader() async {
    // Cargar el logo desde los assets usando rootBundle
    final logoBytes = await rootBundle.load('assets/images/logo_caja_texto.png');
    final logoImage = logoBytes.buffer.asUint8List();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1f2937'),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColor.fromHex('#1f2937')),
      ),
      child: pw.Column(
        children: [
          pw.Image(pw.MemoryImage(logoImage), width: 320),
          pw.SizedBox(height: 12),
          pw.Text(
            'COMPROBANTE DE PAGO',
            style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Page _buildMainPage(pw.Header header, ComprobanteEntity comprobante, UsuarioEntity usuario, bool esBoletaInicio) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Encabezado
            header,
            pw.SizedBox(height: 20),

            // Datos del afiliado
            _buildSection(
              borderLeftColor: '#1f2937',
              content: [
                _buildSubSection(
                  title: 'DATOS DEL AFILIADO',
                  content: [
                    _buildDataRow('Nombre:', '${usuario.apellidoNombres} - NAF: ${usuario.nroAfiliado}', fontSize: 10),
                    _buildDataRow('Correo electrónico:', usuario.datosUsuario?.email ?? '', fontSize: 10, isLast: true),
                  ],
                  titleBorderColor: '#1f2937',
                ),
                pw.SizedBox(height: 12),
                // Boletas pagadas
                if (esBoletaInicio)
                  _buildBoletasInicioSection(comprobante.boletasPagadas)
                else
                  _buildBoletasFinalizacionSection(comprobante.boletasPagadas),
                // Total
                pw.SizedBox(height: 10),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1f2937'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColor.fromHex('#1f2937')),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL:',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      ),
                      pw.Text(
                        '\$ ${comprobante.importe}',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // Detalle del pago
            _buildSection(
              borderLeftColor: '#059669',
              content: [
                // Para boletas de inicio: Layout con QR
                if (esBoletaInicio)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: _buildSubSection(
                          title: 'DETALLE DEL PAGO',
                          titleBorderColor: '#059669',
                          content: [
                            if (comprobante.externalReferenceId != null)
                              _buildDataRow('Identificador:', comprobante.externalReferenceId!, fontSize: 12),
                            _buildDataRow(
                              'Medio de pago:',
                              comprobante.metodoPago?.toUpperCase() ?? 'N/A',
                              fontSize: 12,
                            ),
                            _buildDataRow('Monto pagado:', '\$ ${comprobante.importe}', fontSize: 12, isLast: true),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Expanded(
                        flex: 1,
                        child: _buildSubSection(
                          title: 'VALIDACIÓN',
                          titleBorderColor: '#059669',
                          content: [
                            pw.Container(
                              height: 80,
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                'QR',
                                style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#9ca3af')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                // Para boletas de finalización: Layout simple sin QR
                if (!esBoletaInicio)
                  _buildSubSection(
                    title: 'DETALLE DEL PAGO',
                    titleBorderColor: '#059669',
                    content: [
                      if (comprobante.externalReferenceId != null)
                        _buildDataRow('Identificador:', comprobante.externalReferenceId!, fontSize: 12),
                      _buildDataRow('Medio de pago:', comprobante.metodoPago?.toUpperCase() ?? 'N/A', fontSize: 12),
                    ],
                  ),

                pw.SizedBox(height: 10),
                // Payment Status
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#059669'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColor.fromHex('#047857')),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'PAGO EXITOSO',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Transacción completada correctamente',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.normal,
                          color: PdfColor.fromHex('#d1fae5'),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),

                // Footer Info
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#f3f4f6'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColor.fromHex('#d1d5db')),
                  ),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#374151')),
                      children: [
                        pw.TextSpan(
                          text: 'Fecha de emisión: ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
                        ),
                        pw.TextSpan(text: comprobante.fecha),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.Spacer(),

            // Pie de página
            _buildFooter(),
          ],
        );
      },
    );
  }

  pw.Widget _buildSection({required List<pw.Widget> content, String? borderLeftColor}) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#e5e7eb'), borderRadius: pw.BorderRadius.circular(6)),
      padding: const pw.EdgeInsets.all(1),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex(borderLeftColor ?? '#1f2937'),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        padding: const pw.EdgeInsets.only(left: 4),
        child: pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.only(topRight: pw.Radius.circular(5), bottomRight: pw.Radius.circular(5)),
          ),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [...content]),
        ),
      ),
    );
  }

  pw.Widget _buildSubSection({required String title, required List<pw.Widget> content, String? titleBorderColor}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex(titleBorderColor ?? '#1f2937'), width: 2)),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
          ),
        ),
        pw.SizedBox(height: 8),
        ...content,
      ],
    );
  }

  pw.Widget _buildDataRow(String label, String value, {double fontSize = 10, bool isLast = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      decoration: pw.BoxDecoration(
        border: isLast ? null : pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#d1d5db'))),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: pw.FontWeight.normal,
              color: PdfColor.fromHex('#374151'),
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#111827'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBoletasInicioSection(List<BoletaPagada> boletas) {
    if (boletas.isEmpty) return pw.Container();

    final primeraBoleta = boletas.first;

    return _buildSubSection(
      title: 'BOLETA ÚNICA DE INICIACIÓN DE JUICIO',
      content: [
        // Carátula y tipo de juicio
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                primeraBoleta.caratula,
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
              ),
              if (primeraBoleta.tipoJuicio != null) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  primeraBoleta.tipoJuicio!,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.normal,
                    color: PdfColor.fromHex('#6b7280'),
                  ),
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 8),

        // Tabla de montos
        pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#d1d5db')),
            bottom: pw.BorderSide(color: PdfColor.fromHex('#d1d5db')),
          ),
          children: [
            _buildMontoRow('Caja de Seguridad Social de Abogados y Procuradores:', primeraBoleta.importe),
            _buildMontoRow(
              'Colegio de Abogados:',
              _getMontoOrganismo(primeraBoleta.montosOrganismos, 'Colegio de Abogados'),
            ),
            _buildMontoRow('Caja Forense:', _getMontoOrganismo(primeraBoleta.montosOrganismos, 'Caja Forense')),
          ],
        ),
      ],
      titleBorderColor: '#1f2937',
    );
  }

  pw.TableRow _buildMontoRow(String label, String amount) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal, color: PdfColor.fromHex('#374151')),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            '\$ $amount',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
          ),
        ),
      ],
    );
  }

  String _getMontoOrganismo(List<MontoOrganismo>? montosOrganismos, String organismo) {
    if (montosOrganismos == null) return '0.00';

    try {
      final monto = montosOrganismos.firstWhere(
        (m) => m.organismo == organismo,
        orElse: () => (circunscripcion: 0, monto: 0.0, organismo: ''),
      );
      return monto.monto.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  pw.Widget _buildBoletasFinalizacionSection(List<BoletaPagada> boletas) {
    return _buildSubSection(
      title: 'BOLETAS PAGADAS',
      content: [
        // Lista de boletas
        ...boletas.map((boleta) => _buildBoletaItem(boleta.caratula, boleta.importe)),
      ],
      titleBorderColor: '#1f2937',
    );
  }

  pw.Widget _buildBoletaItem(String caratula, String importe) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#f9fafb'),
        border: pw.Border(
          left: pw.BorderSide(color: PdfColor.fromHex('#1f2937'), width: 3),
          top: pw.BorderSide(color: PdfColor.fromHex('#e5e7eb')),
          right: pw.BorderSide(color: PdfColor.fromHex('#e5e7eb')),
          bottom: pw.BorderSide(color: PdfColor.fromHex('#e5e7eb')),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              caratula,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            '\$ $importe',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1f2937'),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColor.fromHex('#374151')),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Caja de Seguridad Social de Abogados y Procuradores de la Provincia de Santa Fe',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '3 de Febrero 2761, 4° Piso - Santa Fe, S3000',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#d1d5db')),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'capsantafe.org.ar',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#9ca3af')),
          ),
        ],
      ),
    );
  }

  Future<String> _guardarPdf(pw.Document pdf, int idComprobante) async {
    // Usar getApplicationDocumentsDirectory() que no requiere permisos especiales
    // En Android guarda en: /data/user/0/[package]/app_flutter/
    // En iOS guarda en: Documents directory
    late Directory output;

    if (Platform.isAndroid) {
      // Para Android, primero intentamos el directorio de documentos externos
      // Si falla, usamos el interno
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Crear carpeta "Comprobantes" si no existe
          final comprobantesDir = Directory('${externalDir.path}/Comprobantes');
          if (!await comprobantesDir.exists()) {
            await comprobantesDir.create(recursive: true);
          }
          output = comprobantesDir;
        } else {
          output = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        output = await getApplicationDocumentsDirectory();
      }
    } else {
      output = await getApplicationDocumentsDirectory();
    }

    final fileName = 'comprobante_$idComprobante.pdf';
    final file = File('${output.path}/$fileName');

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}

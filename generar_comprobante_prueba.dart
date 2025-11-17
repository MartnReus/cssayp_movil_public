import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main(List<String> args) async {
  print('=== Generador de Comprobantes de Prueba ===\n');

  // Mostrar opciones
  print('Selecciona el tipo de comprobante a generar:');
  print('1. Boleta de Inicio de Juicio');
  print('2. Boletas de Finalización');
  print('3. Ambos tipos\n');

  stdout.write('Ingresa tu opción (1-3): ');
  final opcion = stdin.readLineSync();

  try {
    switch (opcion) {
      case '1':
        await _generarBoletaInicio();
        break;
      case '2':
        await _generarBoletaFinalizacion();
        break;
      case '3':
        await _generarBoletaInicio();
        await _generarBoletaFinalizacion();
        break;
      default:
        print('❌ Opción inválida');
        exit(1);
    }

    print('\n✅ Comprobantes generados exitosamente');
    print('📁 Los archivos se guardaron en el directorio actual');
  } catch (e) {
    print('❌ Error al generar comprobantes: $e');
    exit(1);
  }
}

Future<void> _generarBoletaInicio() async {
  print('\n📄 Generando comprobante de Boleta de Inicio...');

  final pdf = pw.Document();
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Encabezado
            _buildHeader(),
            pw.SizedBox(height: 20),

            // Datos del afiliado
            _buildSection(
              borderLeftColor: '#1f2937',
              content: [
                _buildSubSection(
                  title: 'DATOS DEL AFILIADO',
                  content: [
                    _buildDataRow('Nombre:', 'RODRIGUEZ, MARIA FERNANDA - NAF: 12345', fontSize: 10),
                    _buildDataRow('Correo electrónico:', 'maria.rodriguez@example.com', fontSize: 10, isLast: true),
                  ],
                  titleBorderColor: '#1f2937',
                ),
                pw.SizedBox(height: 12),
                _buildSubSection(
                  title: 'BOLETA ÚNICA DE INICIACIÓN DE JUICIO',
                  content: [
                    // Carátula y tipo de juicio
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'GOMEZ, JUAN C/ PEREZ, MARIA S/ DAÑOS Y PERJUICIOS',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1f2937'),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Juicio Ordinario - Primera Instancia',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.normal,
                              color: PdfColor.fromHex('#6b7280'),
                            ),
                          ),
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
                        _buildMontoRow('Caja de Seguridad Social de Abogados y Procuradores:', '1200.00'),
                        _buildMontoRow('Colegio de Abogados:', '850.50'),
                        _buildMontoRow('Caja Forense:', '400.00'),
                      ],
                    ),
                  ],
                  titleBorderColor: '#1f2937',
                ),

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
                        '\$ 2450.50',
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
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: _buildSubSection(
                        title: 'DETALLE DEL PAGO',
                        titleBorderColor: '#059669',
                        content: [
                          _buildDataRow('Identificador:', 'REF-INICIO-$timestamp', fontSize: 12),
                          _buildDataRow('Medio de pago:', 'TARJETA DE CRÉDITO', fontSize: 12),
                          _buildDataRow('Monto pagado:', '\$ 2450.50', fontSize: 12, isLast: true),
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
                            child: pw.Text('QR', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#9ca3af'))),
                          ),
                        ],
                      ),
                    ),
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
                        pw.TextSpan(text: DateTime.now().toString().substring(0, 19)),
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
    ),
  );

  // Guardar el PDF
  final fileName = 'comprobante_inicio_$timestamp.pdf';
  final file = File(fileName);
  await file.writeAsBytes(await pdf.save());

  print('✓ Archivo generado: $fileName');
}

Future<void> _generarBoletaFinalizacion() async {
  print('\n📄 Generando comprobante de Boletas de Finalización...');

  final pdf = pw.Document();
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Encabezado
            _buildHeader(),
            pw.SizedBox(height: 20),

            // Datos del afiliado
            _buildSection(
              borderLeftColor: '#1f2937',
              content: [
                _buildSubSection(
                  title: 'DATOS DEL AFILIADO',
                  content: [
                    _buildDataRow('Nombre:', 'RODRIGUEZ, MARIA FERNANDA - NAF: 12345', fontSize: 10),
                    _buildDataRow('Correo electrónico:', 'maria.rodriguez@example.com', fontSize: 10, isLast: true),
                  ],
                  titleBorderColor: '#1f2937',
                ),
                pw.SizedBox(height: 12),
                _buildSubSection(
                  title: 'BOLETAS PAGADAS',
                  content: [
                    // Lista de boletas
                    _buildBoletaItem('MARTINEZ, CARLOS C/ GONZALEZ, ANA S/ DIVORCIO CONTENCIOSO', '1850.25'),
                    _buildBoletaItem('RODRIGUEZ, LUIS C/ FERNANDEZ, JORGE S/ COBRO DE PESOS', '2100.00'),
                    _buildBoletaItem('LOPEZ, MARIA C/ SANCHEZ, PEDRO S/ DESALOJO', '1720.50'),
                  ],
                  titleBorderColor: '#1f2937',
                ),

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
                        '\$ 5670.75',
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
                _buildSubSection(
                  title: 'DETALLE DEL PAGO',
                  titleBorderColor: '#059669',
                  content: [
                    _buildDataRow('Identificador:', 'REF-FIN-$timestamp', fontSize: 12),
                    _buildDataRow('Medio de pago:', 'TRANSFERENCIA BANCARIA', fontSize: 12),
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
                        pw.TextSpan(text: DateTime.now().toString().substring(0, 19)),
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
    ),
  );

  // Guardar el PDF
  final fileName = 'comprobante_finalizacion_$timestamp.pdf';
  final file = File(fileName);
  await file.writeAsBytes(await pdf.save());

  print('✓ Archivo generado: $fileName');
}

pw.Widget _buildHeader() {
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
        pw.Image(pw.MemoryImage(File('assets/images/logo_caja_texto.png').readAsBytesSync()), width: 320),
        pw.SizedBox(height: 12),
        pw.Text(
          'COMPROBANTE DE PAGO',
          style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
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
        // margin: const pw.EdgeInsets.only(top: ),
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
          style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.normal, color: PdfColor.fromHex('#374151')),
        ),
        pw.SizedBox(width: 4),
        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#111827')),
          ),
        ),
      ],
    ),
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

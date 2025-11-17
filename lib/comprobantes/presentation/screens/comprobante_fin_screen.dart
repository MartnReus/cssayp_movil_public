import 'dart:io';
import 'package:cssayp_movil/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';

class ComprobanteFinScreen extends ConsumerStatefulWidget {
  final ComprobanteEntity? comprobante;

  const ComprobanteFinScreen({super.key, this.comprobante});

  @override
  ConsumerState<ComprobanteFinScreen> createState() => _ComprobanteFinScreenState();
}

class _ComprobanteFinScreenState extends ConsumerState<ComprobanteFinScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final comprobante = widget.comprobante ?? ModalRoute.of(context)?.settings.arguments as ComprobanteEntity?;
    final currentUser = ref.read(authProvider).value?.usuario;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Detalle comprobante de pago",
          style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Contenido principal con scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: const ShapeDecoration(
                  color: Color(0xFFEEF9FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Texto descriptivo
                    const Text(
                      'Aquí se muestran los datos del pago de la boleta seleccionada. Puede descargar el comprobante en formato PDF para conservarlo o presentarlo ante la entidad correspondiente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF173664),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.29,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Datos del afiliado
                    _buildDataCard(
                      title: 'DATOS DEL AFILIADO',
                      children: [
                        _buildDataRow('Nombre: ', currentUser?.apellidoNombres ?? ''),
                        _buildDataRow('N° de afiliado: ', currentUser?.nroAfiliado.toString() ?? ''),
                        // _buildDataRow('Correo electrónico: ', currentUser?.correoElectronico ?? ''),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Boletas de finalización de juicio
                    _buildDataCard(
                      title: 'BOLETA DE FINALIZACIÓN DE JUICIO',
                      children: _buildBoletasFinList(comprobante?.boletasPagadas ?? []),
                    ),

                    const SizedBox(height: 10),

                    // Detalle del pago
                    _buildDataCard(
                      title: 'DETALLE DEL PAGO',
                      children: [
                        _buildDataRow('Identificador: ', ' ${comprobante?.externalReferenceId ?? ''}'),
                        _buildDataRow('Fecha de pago:', ' ${comprobante?.fecha ?? ''}'),
                        _buildDataRow('Medio de pago:', ' ${comprobante?.metodoPago ?? ''}'),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Total
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 15, left: 5, right: 15, bottom: 15),
                      decoration: const ShapeDecoration(
                        color: Color(0x192196F3),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0x4C2196F3)),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'TOTAL: ',
                              style: TextStyle(
                                color: Color(0xFF173664),
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                height: 1.25,
                              ),
                            ),
                            TextSpan(
                              text: '\$ ${comprobante?.importe ?? ''}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botones de acción
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              color: const Color(0xFFEEF9FF),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF194B8F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isDownloading ? null : _descargarComprobanteLocal,
                        child: _isDownloading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'DESCARGAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  height: 1.83,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF173664),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isDownloading ? null : _compartirComprobante,
                        child: _isDownloading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'COMPARTIR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  height: 1.83,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 15, left: 5, right: 15, bottom: 15),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4), spreadRadius: 0)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF173664),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(
                color: Color(0xFF111112),
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 1.29,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF111112),
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBoletasFinList(List<BoletaPagada> boletasFin) {
    if (boletasFin.isEmpty) {
      // Mostrar datos de ejemplo si no hay boletas
      return [
        _buildBoletaFinRow('CARATULA EJEMPLO 1', '0.0'),
        _buildBoletaFinSeparator(),
        _buildBoletaFinRow('CARATULA EJEMPLO 2', '0.0'),
      ];
    }

    List<Widget> widgets = [];
    for (int i = 0; i < boletasFin.length; i++) {
      widgets.add(_buildBoletaFinRow(boletasFin[i].caratula, boletasFin[i].importe));
      if (i < boletasFin.length - 1) {
        widgets.add(_buildBoletaFinSeparator());
      }
    }
    return widgets;
  }

  Widget _buildBoletaFinRow(String descripcion, String monto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            descripcion,
            style: const TextStyle(
              color: Color(0xFF111112),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: Text(
            '\$ $monto',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF111112),
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoletaFinSeparator() {
    return Container(margin: const EdgeInsets.symmetric(vertical: 8), height: 1, color: const Color(0xFFE0E0E0));
  }

  /// Descarga el comprobante localmente en el dispositivo
  /// Android: intenta guardar en Downloads (requiere permisos)
  /// iOS: guarda en el directorio de documentos de la app
  /// Windows/Linux/macOS: guarda en el directorio de Descargas del usuario
  Future<void> _descargarComprobanteLocal() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final comprobante = widget.comprobante ?? ModalRoute.of(context)?.settings.arguments as ComprobanteEntity?;

      if (comprobante == null) {
        throw Exception('No se encontró el comprobante');
      }

      final descargarUseCase = ref.read(descargarComprobanteUseCaseProvider);

      // Descargar el comprobante al dispositivo
      await descargarUseCase.execute(comprobante);

      if (!mounted) return;

      // Determinar el mensaje según la plataforma
      String message;
      if (Platform.isAndroid) {
        message = 'Comprobante descargado en: Downloads';
      } else if (Platform.isIOS) {
        message = 'Comprobante guardado en la carpeta de documentos de la aplicación';
      } else if (Platform.isWindows) {
        message = 'Comprobante descargado en: C:\\Users\\[usuario]\\Downloads';
      } else if (Platform.isLinux || Platform.isMacOS) {
        message = 'Comprobante descargado en: ~/Downloads';
      } else {
        message = 'Comprobante guardado exitosamente';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF173664),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Error al descargar: ${e.toString()}';
      if (e.toString().contains('permisos')) {
        errorMessage = 'Se requieren permisos de almacenamiento. Por favor, actívalos en la configuración de la app.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  /// Comparte el comprobante usando el sistema nativo de compartir
  Future<void> _compartirComprobante() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final comprobante = widget.comprobante ?? ModalRoute.of(context)?.settings.arguments as ComprobanteEntity?;

      if (comprobante == null) {
        throw Exception('No se encontró el comprobante');
      }

      final compartirUseCase = ref.read(compartirComprobanteUseCaseProvider);
      await compartirUseCase.execute(comprobante);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comprobante compartido exitosamente'),
          backgroundColor: Color(0xFF173664),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }
}

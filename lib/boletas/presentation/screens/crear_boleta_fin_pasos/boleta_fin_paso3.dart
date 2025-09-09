import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/presentation/widgets/boleta_stepper_widget.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/shared/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

class Paso3BoletaFinScreen extends ConsumerWidget {
  const Paso3BoletaFinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boletaFinData = ref.watch(boletaFinDataProvider);
    final boletasState = ref.watch(boletasProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal con scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    const BoletaStepperWidget(
                      currentStep: 3,
                      boletaType: 'Boleta de Finalización',
                      stepLabels: ['Datos del Expediente', 'Regulación', 'Resumen'],
                      icon: Icons.check_circle_outline,
                      iconColor: Color(0xFF2196F3),
                    ),

                    const SizedBox(height: 32),

                    // Subtítulo
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Revise y confirme la información",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF173664),
                            fontSize: 18,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Verifique que los datos y los montos sean correctos antes de generar la boleta",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF173664),
                            fontSize: 14,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Contenido de las tarjetas
                    _buildCard("Datos del juicio", [
                      _buildDato("Carátula", boletaFinData.caratula ?? "NO ESPECIFICADA"),
                      _buildDato("Número de expediente", boletaFinData.expediente?.toString() ?? "NO ESPECIFICADO"),
                      _buildDato("Año de expediente", boletaFinData.anio?.toString() ?? "NO ESPECIFICADO"),
                      _buildDato("Número de C.U.I.J.", boletaFinData.cuij?.toString() ?? "NO ESPECIFICADO"),
                    ]),
                    const SizedBox(height: 12),
                    _buildCard("Fechas", [
                      _buildDato(
                        "Fecha de regulación final",
                        boletaFinData.fechaRegulacion != null
                            ? DateFormat('dd/MM/yyyy').format(boletaFinData.fechaRegulacion!)
                            : "NO ESPECIFICADA",
                      ),
                      _buildDato("Fecha de impresión", _formatFechaImpresion()),
                      _buildDato("Fecha de vencimiento", _formatFechaVencimiento()),
                    ]),
                    const SizedBox(height: 12),
                    _buildCard("Montos y valores", [
                      _buildDato("Cantidad JUS", "${boletaFinData.cantidadJus?.toString() ?? "0"} "),
                      _buildDato("Valor JUS", "\$${boletaFinData.valorJus?.toStringAsFixed(2) ?? "0.00"} "),
                      _buildDato("Honorarios", "\$${boletaFinData.honorarios?.toStringAsFixed(2) ?? "0.00"} "),
                      _buildDato("Monto válido", "\$${boletaFinData.montoValido?.toStringAsFixed(2) ?? "0.00"} "),
                    ]),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationButtons(context, ref, boletaFinData, boletasState),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    WidgetRef ref,
    BoletaFinDataState boletaFinData,
    AsyncValue<BoletasState> boletasState,
  ) {
    final isLoading = boletasState.isLoading;
    if (isLoading) {
      return const LoadingIndicator();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Volver
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/boleta-fin-paso2');
              },
              child: isLoading
                  ? const LoadingIndicator()
                  : Container(
                      height: 48,
                      decoration: BoxDecoration(color: const Color(0xFF194B8F), borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text(
                          'Volver',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            height: 1.83,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Generar
          Expanded(
            child: InkWell(
              onTap: () async {
                // Verificar que todos los datos estén completos
                if (!boletaFinData.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor complete todos los datos antes de generar la boleta'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final confirmar = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        "Confirmar acción",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF173664),
                        ),
                      ),
                      content: const Text(
                        "¿Está seguro que desea generar la boleta?",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Color(0xFF111112)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            "NO",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF173664),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF173664),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            "SÍ",
                            style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirmar == true) {
                  if (!context.mounted) return;

                  try {
                    final boleta = await ref
                        .read(boletasProvider.notifier)
                        .crearBoletaFin(boletaFinData: boletaFinData);

                    if (boleta != null && context.mounted) {
                      ref.read(boletaFinDataProvider.notifier).reset();

                      Navigator.pushNamedAndRemoveUntil(context, '/boleta-generada', (route) => false);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al generar la boleta: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: isLoading
                  ? const LoadingIndicator()
                  : Container(
                      height: 48,
                      decoration: BoxDecoration(color: const Color(0xFF173664), borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text(
                          'GENERAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            height: 1.83,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String titulo, List<Widget> datos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFD9F1FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9F1FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w500,
              fontSize: 16,
              decoration: TextDecoration.underline,
              color: Color(0xFF111112),
            ),
          ),
          const SizedBox(height: 8),
          ...datos,
        ],
      ),
    );
  }

  Widget _buildDato(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontFamily: "Montserrat",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF111112),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontFamily: "Montserrat",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111112),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFechaImpresion() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString()}";
  }

  String _formatFechaVencimiento() {
    final vencimiento = DateTime.now().add(const Duration(days: 30));
    return "${vencimiento.day.toString().padLeft(2, '0')}/${vencimiento.month.toString().padLeft(2, '0')}/${vencimiento.year.toString()}";
  }
}

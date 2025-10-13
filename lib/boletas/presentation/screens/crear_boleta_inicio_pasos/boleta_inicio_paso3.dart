import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/boletas/presentation/widgets/boleta_stepper_widget.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/shared/widgets/loading_indicator.dart';

class Paso3BoletaInicioScreen extends ConsumerWidget {
  const Paso3BoletaInicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boletaData = ref.watch(boletaInicioDataProvider);
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
                      boletaType: 'Boleta de Inicio',
                      stepLabels: ['Partes', 'Datos del Juicio', 'Resumen'],
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
                          "Verifique que los datos y montos sean correctos antes de generar la boleta",
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
                    _buildCard("Carátula", [_buildCaratula(boletaData.value!)]),
                    const SizedBox(height: 12),
                    _buildCard("Montos y fechas", [
                      _buildMontosDatos(boletaData.value!),
                      _buildDato("Fecha de Impresión", _formatFechaImpresion()),
                      _buildDato("Fecha de Vencimiento", _formatFechaVencimiento()),
                    ]),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationButtons(context, ref, boletaData.value!, boletasState),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    WidgetRef ref,
    BoletaInicioDataState boletaData,
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
                Navigator.pushReplacementNamed(context, '/boleta-inicio-paso2');
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
                if (!boletaData.isValid) {
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
                  barrierDismissible: false, // evita cerrar tocando afuera
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
                  if (!context.mounted) return; // evita usar context si el widget ya no existe

                  try {
                    final caratula = _buildCaratulaString(boletaData);
                    final juzgado = boletaData.juzgado;
                    final circunscripcion = boletaData.circunscripcion;
                    final tipoJuicio = boletaData.tipoJuicio;

                    if (circunscripcion == null || tipoJuicio == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El tipo de juicio y la circunscripción deben ser seleccionados'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (juzgado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El juzgado no puede estar vacío'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final resultado = await ref
                        .read(boletasProvider.notifier)
                        .crearBoletaInicio(
                          caratula: caratula,
                          juzgado: juzgado,
                          circunscripcion: circunscripcion,
                          tipoJuicio: tipoJuicio,
                        );

                    if (resultado != null && context.mounted) {
                      // Limpiar los datos después de crear la boleta exitosamente
                      ref.read(boletaInicioDataProvider.notifier).reset();

                      // Obtener la boleta creada del provider
                      final boletasState = ref.read(boletasProvider);
                      final boletaCreada = boletasState.value?.boletas.firstWhere((b) => b.id == resultado.idBoleta);

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/boleta-generada',
                        (route) => false,
                        arguments: boletaCreada,
                      );
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontFamily: "Montserrat",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF111112),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: "Montserrat",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111112),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaratula(BoletaInicioDataState boletaData) {
    final actor = boletaData.actor ?? "NO ESPECIFICADO";
    final demandado = boletaData.demandado ?? "NO ESPECIFICADO";
    final causa = boletaData.causa ?? "NO ESPECIFICADA";

    final caratula = "${actor.toUpperCase()} C/ ${demandado.toUpperCase()} S/ ${causa.toUpperCase()}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        caratula,
        style: const TextStyle(
          fontFamily: "Montserrat",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111112),
        ),
      ),
    );
  }

  String _formatFechaImpresion() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)}";
  }

  String _formatFechaVencimiento() {
    final vencimiento = DateTime.now().add(const Duration(days: 30));
    return "${vencimiento.day.toString().padLeft(2, '0')}/${vencimiento.month.toString().padLeft(2, '0')}/${vencimiento.year.toString().substring(2)}";
  }

  String _buildCaratulaString(BoletaInicioDataState boletaData) {
    final actor = boletaData.actor ?? "NO ESPECIFICADO";
    final demandado = boletaData.demandado ?? "NO ESPECIFICADO";
    final causa = boletaData.causa ?? "NO ESPECIFICADA";

    return "${actor.toUpperCase()} C/ ${demandado.toUpperCase()} S/ ${causa.toUpperCase()}";
  }

  MontosEntity? _obtenerMontosDesdeTipoJuicio(BoletaInicioDataState boletaData) {
    if (boletaData.tipoJuicio == null) return null;

    return boletaData.tipoJuicio!.montos;
  }

  Widget _buildMontosDatos(BoletaInicioDataState boletaData) {
    final montos = _obtenerMontosDesdeTipoJuicio(boletaData);

    if (montos == null) {
      return Column(
        children: [
          _buildDato("Caja", "No disponible"),
          _buildDato("Caja Forense", "No disponible"),
          _buildDato("Colegio", "No disponible"),
        ],
      );
    }

    return Column(
      children: [
        _buildDato("Caja", "\$${montos.montoCaja.toStringAsFixed(0)}"),
        _buildDato("Caja Forense", "\$${montos.montoForense.toStringAsFixed(0)}"),
        _buildDato("Colegio", "\$${montos.montoColegio.toStringAsFixed(0)}"),
      ],
    );
  }
}

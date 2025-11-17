import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/pagos/pagos.dart';

class PagosPrincipalScreen extends ConsumerStatefulWidget {
  const PagosPrincipalScreen({super.key});

  @override
  ConsumerState<PagosPrincipalScreen> createState() => _PagosPrincipalScreenState();
}

class _PagosPrincipalScreenState extends ConsumerState<PagosPrincipalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Lista de boletas seleccionadas para pagar
  final Set<int> _boletasSeleccionadas = <int>{};

  // Getter para obtener boletas de inicio
  List<BoletaEntity> get _boletasInicio {
    final boletasState = ref.read(boletasProvider);
    final boletas = boletasState.value?.boletas;
    return boletas?.where((b) => b.tipo == BoletaTipo.inicio).toList() ?? [];
  }

  // Getter para obtener boletas de finalización
  List<BoletaEntity> get _boletasFinalizacion {
    final boletasState = ref.read(boletasProvider);
    final boletas = boletasState.value?.boletas;
    return boletas?.where((b) => b.tipo == BoletaTipo.finalizacion).toList() ?? [];
  }

  double get _totalSeleccionado {
    final boletasState = ref.read(boletasProvider);
    final boletas = boletasState.value?.boletas;
    return _boletasSeleccionadas
        .map((id) => boletas?.firstWhere((b) => b.id == id).monto ?? 0.0)
        .fold(0.0, (sum, monto) => sum + monto);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, animationDuration: Duration.zero);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boletasPendientes = ref.watch(boletasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      body: boletasPendientes.when(
        data: (boletasState) {
          return Column(
            children: [
              // Título principal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                color: const Color(0xFF173664),
                child: const Text(
                  "Pagos",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              // Descripción y título de selección
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selecciona las boletas a pagar",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF173664),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Marca las boletas que deseas pagar. Solo puedes seleccionar boletas del mismo tipo a la vez. Las boletas de inicio solo se pueden pagar una a la vez.",
                      style: TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // TabBar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF173664),
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: const Color(0xFF173664),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Boletas de Inicio'),
                    Tab(text: 'Boletas de Finalización'),
                  ],
                ),
              ),

              // Lista de boletas con tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab de Boletas de Inicio
                    _buildBoletasList(_boletasInicio),

                    // Tab de Boletas de Finalización
                    _buildBoletasList(_boletasFinalizacion),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Scaffold(
          backgroundColor: const Color(0xFFEEF9FF),
          body: Center(child: Text(error.toString())),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF173664))),
      ),
      // Resumen flotante en la parte inferior
      bottomNavigationBar: _boletasSeleccionadas.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Resumen de selección
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_boletasSeleccionadas.length} boleta${_boletasSeleccionadas.length > 1 ? 's' : ''} de ${_getTipoSeleccionado()} seleccionada${_boletasSeleccionadas.length > 1 ? 's' : ''}",
                              style: TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Colors.grey[600]),
                            ),
                            Text(
                              "Total: \$${_totalSeleccionado.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Color(0xFF173664),
                              ),
                            ),
                          ],
                        ),
                        // Botón de continuar
                        ElevatedButton(
                          onPressed: () => _continuarConPago(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF173664),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Continuar",
                            style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBoletasList(List<BoletaEntity> boletas) {
    if (boletas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No hay boletas disponibles",
              style: TextStyle(fontFamily: "Montserrat", fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: boletas.length,
      itemBuilder: (context, index) {
        final boleta = boletas[index];
        final isSelected = _boletasSeleccionadas.contains(boleta.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected ? const BorderSide(color: Color(0xFF173664), width: 2) : BorderSide.none,
            ),
            child: GestureDetector(
              onTap: () {
                print('🔵 Boleta card tapped, calling _toggleBoletaSeleccionada');
                _toggleBoletaSeleccionada(boleta.id);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Selection indicator
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF173664), width: 2),
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected ? const Color(0xFF173664) : Colors.transparent,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),

                    // Información de la boleta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boleta.caratula,
                            style: const TextStyle(
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF173664),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: boleta.tipo == BoletaTipo.inicio ? Colors.blue[100] : Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  boleta.tipo == BoletaTipo.inicio ? "Inicio" : "Finalización",
                                  style: TextStyle(
                                    fontFamily: "Montserrat",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: boleta.tipo == BoletaTipo.inicio ? Colors.blue[800] : Colors.green[800],
                                  ),
                                ),
                              ),
                              if (boleta.nroExpediente != null && boleta.anioExpediente != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  "Exp: ${boleta.nroExpediente}/${boleta.anioExpediente}",
                                  style: TextStyle(fontFamily: "Montserrat", fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Vence: ${_formatearFecha(boleta.fechaVencimiento)}",
                                style: TextStyle(
                                  fontFamily: "Montserrat",
                                  fontSize: 12,
                                  color: boleta.estaVencida ? Colors.red[600] : Colors.grey[600],
                                ),
                              ),
                              Text(
                                "\$${boleta.monto.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF173664),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleBoletaSeleccionada(int boletaId) {
    print('🟡 _toggleBoletaSeleccionada called with boletaId: $boletaId');
    print('🟡 Current selected boletas: $_boletasSeleccionadas');

    // Move provider read outside of setState to prevent infinite rebuild loops
    final boletasState = ref.read(boletasProvider);
    final boletas = boletasState.value?.boletas;

    if (boletas == null) {
      print('⚠️ boletas is null, returning early');
      return; // Safety check
    }

    setState(() {
      print('🟢 setState called in _toggleBoletaSeleccionada');
      if (_boletasSeleccionadas.contains(boletaId)) {
        // Si la boleta ya está seleccionada, la deseleccionamos
        _boletasSeleccionadas.remove(boletaId);
        return;
      }

      // Obtener el tipo de la boleta que se está seleccionando
      final boletaSeleccionada = boletas.firstWhere((b) => b.id == boletaId);
      final tipoSeleccionado = boletaSeleccionada.tipo;

      // Limpiar todas las boletas del tipo opuesto
      if (tipoSeleccionado == BoletaTipo.inicio) {
        // Si se selecciona una boleta de inicio, limpiar todas las de finalización
        _boletasSeleccionadas.removeWhere((id) {
          final boleta = boletas.firstWhere((b) => b.id == id);
          return boleta.tipo == BoletaTipo.finalizacion;
        });

        // Para boletas de inicio, también limpiar cualquier otra boleta de inicio seleccionada
        // (solo se puede seleccionar una boleta de inicio a la vez)
        _boletasSeleccionadas.removeWhere((id) {
          final boleta = boletas.firstWhere((b) => b.id == id);
          return boleta.tipo == BoletaTipo.inicio;
        });
      } else {
        // Si se selecciona una boleta de finalización, limpiar todas las de inicio
        _boletasSeleccionadas.removeWhere((id) {
          final boleta = boletas.firstWhere((b) => b.id == id);
          return boleta.tipo == BoletaTipo.inicio;
        });
      }

      // Agregar la nueva boleta seleccionada
      _boletasSeleccionadas.add(boletaId);
    });
  }

  void _continuarConPago() {
    final boletasState = ref.read(boletasProvider);
    final boletas = boletasState.value?.boletas;
    final boletasSeleccionadas = boletas!.where((b) => _boletasSeleccionadas.contains(b.id)).toList();

    Navigator.push(context, MaterialPageRoute(builder: (context) => ProcesarPagoScreen(boletas: boletasSeleccionadas)));
  }

  String _getTipoSeleccionado() {
    if (_boletasSeleccionadas.isEmpty) return '';

    final boletasState = ref.read(boletasProvider);
    final boletas = boletasState.value?.boletas;
    final primeraBoleta = boletas!.firstWhere((b) => _boletasSeleccionadas.contains(b.id));
    return primeraBoleta.tipo == BoletaTipo.inicio ? 'inicio' : 'finalización';
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

import 'package:cssayp_movil/boletas/boletas.dart';

class HistorialBoletasWidget extends ConsumerStatefulWidget {
  const HistorialBoletasWidget({super.key});

  @override
  ConsumerState<HistorialBoletasWidget> createState() => _HistorialBoletasWidgetState();
}

class _HistorialBoletasWidgetState extends ConsumerState<HistorialBoletasWidget> {
  final TextEditingController _buscarController = TextEditingController();

  String _ordenActual = 'Fecha';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  List<BoletaHistorial> _filtradasYOrdenadas(List<BoletaEntity> boletas) {
    List<BoletaHistorial> lista = boletas.map((entity) => _entityToHistorial(entity)).toList();

    // Filtro por carátula
    final q = _buscarController.text.trim().toLowerCase();
    lista = lista.where((b) => q.isEmpty || b.caratula.toLowerCase().contains(q)).toList();

    // Ordenar por fecha impresion
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));

    return lista;
  }

  BoletaHistorial _entityToHistorial(BoletaEntity entity) {
    EstadoBoleta estado;
    if (entity.estaPagada) {
      estado = EstadoBoleta.pagada;
    } else if (entity.estaVencida) {
      estado = EstadoBoleta.vencida;
    } else {
      estado = EstadoBoleta.pendiente;
    }

    String tipo;
    switch (entity.tipo) {
      case BoletaTipo.inicio:
        tipo = 'Inicio';
        break;
      case BoletaTipo.finalizacion:
        tipo = 'Fin';
        break;
      case BoletaTipo.desconocido:
        tipo = 'Desconocido';
        break;
    }

    return BoletaHistorial(
      caratula: entity.caratula,
      fecha: entity.fechaImpresion,
      tipo: tipo,
      estado: estado,
      monto: entity.monto,
      fechaVencimiento: entity.fechaVencimiento,
      fechaPago: entity.fechaPago,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'es_AR');
    final moneyFmt = NumberFormat.currency(locale: 'es_AR', symbol: '\$');
    final boletasAsyncValue = ref.watch(boletasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      body: boletasAsyncValue.when(
        data: (boletasState) {
          final listaFiltrada = _filtradasYOrdenadas(boletasState.boletas);

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(boletasProvider.notifier).refresh();
            },
            color: const Color(0xFF173664),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Filtros
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Buscar por carátula
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filtrar por carátula',
                            style: TextStyle(
                              color: Color(0xFF173664),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _buscarController,
                              onChanged: (_) {
                                setState(() {
                                  // El filtrado ahora es solo local, no necesitamos resetear paginación
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Ingrese carátula…',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF194B8F), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF194B8F), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF194B8F), width: 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Ordenar por
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ordenar por',
                            style: TextStyle(
                              color: Color(0xFF173664),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'Fecha', child: Text('Fecha de creación')),
                                DropdownMenuItem(value: 'Carátula', child: Text('Carátula')),
                                DropdownMenuItem(value: 'Tipo', child: Text('Tipo de boleta')),
                                DropdownMenuItem(value: 'Estado', child: Text('Estado de pago')),
                              ],
                              value: _ordenActual,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _ordenActual = value;
                                  // El ordenamiento ahora es solo local, no necesitamos resetear paginación
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF194B8F), width: 1),
                                ),
                              ),
                              iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down)),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 260,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF194B8F), width: 1),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(height: 40),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lista de boletas
                if (listaFiltrada.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No se encontraron boletas',
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Color(0xFF173664)),
                      ),
                    ),
                  )
                else
                  ...listaFiltrada.map(
                    (b) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD9F1FF), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título (solo carátula)
                          Text(
                            b.caratula,
                            style: const TextStyle(
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF111112),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Datos
                          _dato('Fecha de creación', dateFmt.format(b.fecha)),
                          _dato('Tipo de boleta', b.tipo),
                          _dato('Estado de pago', _getEstadoText(b.estado)),
                          _dato(
                            b.estado == EstadoBoleta.pagada ? 'Fecha de pago' : 'Fecha de vencimiento',
                            b.estado == EstadoBoleta.pagada
                                ? dateFmt.format(b.fechaPago!)
                                : dateFmt.format(b.fechaVencimiento),
                          ),
                          _dato('Monto', moneyFmt.format(b.monto)),

                          const SizedBox(height: 12),

                          // Botones de acción
                          Row(
                            children: [
                              _accion(
                                icon: Icons.download_outlined,
                                label: 'Descargar',
                                isActive: true, // Siempre activo
                                onTap: () {
                                  // TODO: implementar descarga de boleta
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text('Descargando boleta...')));
                                },
                              ),
                              const SizedBox(width: 6),
                              _accion(
                                icon: Icons.payments_outlined,
                                label: 'Pagar',
                                isActive: b.estado == EstadoBoleta.pendiente, // Solo activo si está pendiente
                                onTap: b.estado == EstadoBoleta.pendiente
                                    ? () {
                                        // TODO: redirigir a pantalla de pago
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Redirigiendo a pantalla de pago...')),
                                        );
                                      }
                                    : () {},
                              ),
                              const SizedBox(width: 6),
                              _accion(
                                icon: Icons.visibility_outlined,
                                label: 'Ver comprobante',
                                isActive: b.estado == EstadoBoleta.pagada, // Solo activo si está pagada
                                onTap: b.estado == EstadoBoleta.pagada
                                    ? () {
                                        // TODO: implementar ver comprobante
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(const SnackBar(content: Text('Mostrando comprobante...')));
                                      }
                                    : () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Paginación del servidor
                if (boletasState.total > boletasState.perPage) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Botón Anterior
                      Expanded(
                        child: ElevatedButton(
                          onPressed: boletasState.hasPreviousPage
                              ? () => ref.read(boletasProvider.notifier).irAPaginaAnterior()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF194B8F),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF194B8F).withValues(alpha: 0.4),
                            disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                            shadowColor: const Color(0x3F000000),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero, // evita padding extra
                            minimumSize: const Size.fromHeight(40), // altura fija
                          ),
                          child: const Text(
                            'Anterior',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.83,
                            ),
                          ),
                        ),
                      ),

                      // Texto de página
                      Container(
                        width: 140,
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          'Página ${boletasState.currentPage} de ${boletasState.lastPage}',
                          style: const TextStyle(
                            color: Color(0xFF173664),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Botón Siguiente
                      Expanded(
                        child: ElevatedButton(
                          onPressed: boletasState.hasNextPage
                              ? () => ref.read(boletasProvider.notifier).irAPaginaSiguiente()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF173664),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF173664).withValues(alpha: 0.4),
                            disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                            shadowColor: const Color(0x3F000000),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text(
                            'Siguiente',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.83,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
        loading: () => const Scaffold(
          backgroundColor: Color(0xFFEEF9FF),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF173664))),
                SizedBox(height: 16),
                Text(
                  'Cargando boletas...',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Color(0xFF173664)),
                ),
              ],
            ),
          ),
        ),
        error: (error, stack) => Scaffold(
          backgroundColor: const Color(0xFFEEF9FF),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFFF44336)),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar las boletas',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF173664),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF666666)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(boletasProvider.notifier).obtenerBoletasCreadas(page: 1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173664),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dato(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _getEstadoColor(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEstadoText(EstadoBoleta estado) {
    switch (estado) {
      case EstadoBoleta.pagada:
        return 'Pagada';
      case EstadoBoleta.pendiente:
        return 'Pendiente';
      case EstadoBoleta.vencida:
        return 'Vencida';
      case EstadoBoleta.noCreada:
        return 'Error';
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Pagada':
        return const Color(0xFF4CAF50); // Verde
      case 'Pendiente':
        return const Color(0xFFD46E07); // Naranja
      case 'Vencida':
        return const Color(0xFFF44336); // Rojo
      default:
        return const Color(0xFF111112); // Color por defecto
    }
  }

  Widget _accion({required IconData icon, required String label, required VoidCallback onTap, bool isActive = true}) {
    return Expanded(
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD9F1FF) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? const Color(0xFF173664) : const Color(0xFF999999)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? const Color(0xFF173664) : const Color(0xFF999999),
                    fontSize: 11,
                    fontFamily: 'Montserrat',
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoletaHistorial {
  final String caratula;
  final DateTime fecha;
  final String tipo; // 'Inicio' | 'Fin'
  final EstadoBoleta estado;
  final double monto;
  final DateTime fechaVencimiento;
  final DateTime? fechaPago; // null si no está pagada

  BoletaHistorial({
    required this.caratula,
    required this.fecha,
    required this.tipo,
    required this.estado,
    required this.monto,
    required this.fechaVencimiento,
    this.fechaPago,
  });
}

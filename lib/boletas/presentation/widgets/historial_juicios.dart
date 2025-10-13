import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/pagos/pagos.dart';

class HistorialJuiciosWidget extends ConsumerStatefulWidget {
  const HistorialJuiciosWidget({super.key});

  @override
  ConsumerState<HistorialJuiciosWidget> createState() => _HistorialJuiciosWidgetState();
}

class _HistorialJuiciosWidgetState extends ConsumerState<HistorialJuiciosWidget> {
  final TextEditingController _buscarController = TextEditingController();

  // Mock de datos
  final List<JuicioHistorial> _todos = [
    JuicioHistorial(
      caratula: 'García c/ López',
      fechaInicio: DateTime(2025, 9, 15),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pagada,
        monto: 150000.00,
        fechaVencimiento: DateTime(2025, 10, 15),
        fechaPago: DateTime(2025, 9, 20),
      ),
      boletasFin: [
        BoletaFin(
          estado: EstadoBoleta.pendiente,
          monto: 75000.00,
          fechaVencimiento: DateTime(2025, 11, 15),
          fechaPago: null,
        ),
      ],
    ),
    JuicioHistorial(
      caratula: 'Pérez c/ Sánchez',
      fechaInicio: DateTime(2025, 9, 20),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pendiente,
        monto: 120000.00,
        fechaVencimiento: DateTime(2025, 10, 20),
        fechaPago: null,
      ),
      boletasFin: [],
    ),
    JuicioHistorial(
      caratula: 'Rodríguez c/ Empresa X',
      fechaInicio: DateTime(2025, 9, 25),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pagada,
        monto: 200000.00,
        fechaVencimiento: DateTime(2025, 10, 25),
        fechaPago: DateTime(2025, 9, 30),
      ),
      boletasFin: [
        BoletaFin(
          estado: EstadoBoleta.pagada,
          monto: 100000.00,
          fechaVencimiento: DateTime(2025, 11, 25),
          fechaPago: DateTime(2025, 11, 20),
        ),
        BoletaFin(
          estado: EstadoBoleta.pagada,
          monto: 50000.00,
          fechaVencimiento: DateTime(2025, 12, 25),
          fechaPago: DateTime(2025, 12, 20),
        ),
      ],
    ),
    JuicioHistorial(
      caratula: 'Fernández c/ Gómez',
      fechaInicio: DateTime(2025, 10, 5),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pendiente,
        monto: 95000.00,
        fechaVencimiento: DateTime(2025, 11, 5),
        fechaPago: null,
      ),
      boletasFin: [],
    ),
    JuicioHistorial(
      caratula: 'Juárez c/ Estado',
      fechaInicio: DateTime(2025, 10, 12),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pagada,
        monto: 180000.00,
        fechaVencimiento: DateTime(2025, 11, 12),
        fechaPago: DateTime(2025, 10, 25),
      ),
      boletasFin: [
        BoletaFin(
          estado: EstadoBoleta.pendiente,
          monto: 90000.00,
          fechaVencimiento: DateTime(2025, 12, 12),
          fechaPago: null,
        ),
      ],
    ),
    JuicioHistorial(
      caratula: 'Martínez c/ Rodríguez',
      fechaInicio: DateTime(2025, 10, 18),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pendiente,
        monto: 110000.00,
        fechaVencimiento: DateTime(2025, 11, 18),
        fechaPago: null,
      ),
      boletasFin: [],
    ),
    JuicioHistorial(
      caratula: 'Luna c/ Transporte SRL',
      fechaInicio: DateTime(2025, 10, 25),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pagada,
        monto: 85000.00,
        fechaVencimiento: DateTime(2025, 11, 25),
        fechaPago: DateTime(2025, 11, 5),
      ),
      boletasFin: [],
    ),
    JuicioHistorial(
      caratula: 'Navarro c/ Tech SA',
      fechaInicio: DateTime(2025, 11, 2),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pendiente,
        monto: 135000.00,
        fechaVencimiento: DateTime(2025, 12, 2),
        fechaPago: null,
      ),
      boletasFin: [],
    ),
    JuicioHistorial(
      caratula: 'Ibarra c/ Fábrica Z',
      fechaInicio: DateTime(2025, 11, 8),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pagada,
        monto: 160000.00,
        fechaVencimiento: DateTime(2025, 12, 8),
        fechaPago: DateTime(2025, 11, 25),
      ),
      boletasFin: [
        BoletaFin(
          estado: EstadoBoleta.pendiente,
          monto: 80000.00,
          fechaVencimiento: DateTime(2026, 1, 8),
          fechaPago: null,
        ),
      ],
    ),
    JuicioHistorial(
      caratula: 'Campos c/ Torres',
      fechaInicio: DateTime(2025, 11, 15),
      boletaInicio: BoletaInicio(
        estado: EstadoBoleta.pendiente,
        monto: 125000.00,
        fechaVencimiento: DateTime(2025, 12, 15),
        fechaPago: null,
      ),
      boletasFin: [],
    ),
  ];

  String _ordenActual = 'Fecha'; // Fecha / No creada / Pagada / Pendiente de pago
  int _paginaActual = 1; // 1-based
  static const int _porPagina = 5;

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  List<JuicioHistorial> get _filtradasYOrdenadas {
    // Filtro por carátula
    final q = _buscarController.text.trim().toLowerCase();
    List<JuicioHistorial> lista = _todos.where((j) => q.isEmpty || j.caratula.toLowerCase().contains(q)).toList();

    // Orden
    switch (_ordenActual) {
      case 'Fecha':
        // Más recientes primero
        lista.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
        break;
      case 'No creada':
        lista.sort((a, b) {
          // Priorizar juicios con boletas de fin no creadas
          if (a.boletasFin.isEmpty && b.boletasFin.isNotEmpty) return -1;
          if (a.boletasFin.isNotEmpty && b.boletasFin.isEmpty) return 1;
          // Desempate por fecha descendente
          return b.fechaInicio.compareTo(a.fechaInicio);
        });
        break;
      case 'Pagada':
        lista.sort((a, b) {
          // Priorizar juicios con más boletas pagadas
          final aPagadas =
              (a.boletaInicio.estado == EstadoBoleta.pagada ? 1 : 0) +
              a.boletasFin.where((bf) => bf.estado == EstadoBoleta.pagada).length;
          final bPagadas =
              (b.boletaInicio.estado == EstadoBoleta.pagada ? 1 : 0) +
              b.boletasFin.where((bf) => bf.estado == EstadoBoleta.pagada).length;
          if (aPagadas != bPagadas) return bPagadas.compareTo(aPagadas);
          // Desempate por fecha descendente
          return b.fechaInicio.compareTo(a.fechaInicio);
        });
        break;
      case 'Pendiente de pago':
        lista.sort((a, b) {
          // Priorizar juicios con más boletas pendientes
          final aPendientes =
              (a.boletaInicio.estado == EstadoBoleta.pendiente ? 1 : 0) +
              a.boletasFin.where((bf) => bf.estado == EstadoBoleta.pendiente).length;
          final bPendientes =
              (b.boletaInicio.estado == EstadoBoleta.pendiente ? 1 : 0) +
              b.boletasFin.where((bf) => bf.estado == EstadoBoleta.pendiente).length;
          if (aPendientes != bPendientes) return bPendientes.compareTo(aPendientes);
          // Desempate por fecha descendente
          return b.fechaInicio.compareTo(a.fechaInicio);
        });
        break;
    }

    return lista;
  }

  int get _totalPaginas {
    final total = _filtradasYOrdenadas.length;
    if (total == 0) return 1;
    return ((total + _porPagina - 1) / _porPagina).floor();
  }

  List<JuicioHistorial> get _paginaActualItems {
    final lista = _filtradasYOrdenadas;
    if (lista.isEmpty) return const [];
    final start = (_paginaActual - 1) * _porPagina;
    final end = (start + _porPagina).clamp(0, lista.length);
    if (start >= lista.length) return const [];
    return lista.sublist(start, end);
  }

  void _irAnterior() {
    if (_paginaActual > 1) {
      setState(() => _paginaActual--);
    }
  }

  void _irSiguiente() {
    if (_paginaActual < _totalPaginas) {
      setState(() => _paginaActual++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'es_AR');
    final moneyFmt = NumberFormat.currency(locale: 'es_AR', symbol: '\$');

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      body: ListView(
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
                            _paginaActual = 1; // reset de paginación al filtrar
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
                          DropdownMenuItem(value: 'Fecha', child: Text('Fecha')),
                          DropdownMenuItem(value: 'No creada', child: Text('No creada')),
                          DropdownMenuItem(value: 'Pagada', child: Text('Pagada')),
                          DropdownMenuItem(value: 'Pendiente de pago', child: Text('Pendiente')),
                        ],
                        value: _ordenActual,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _ordenActual = value;
                            _paginaActual = 1; // reset paginación al reordenar
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

          // Lista de juicios
          if (_paginaActualItems.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No se encontraron juicios',
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Color(0xFF173664)),
                ),
              ),
            )
          else
            ..._paginaActualItems.map(
              (j) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD9F1FF), width: 1),
                ),
                child: ExpansionTile(
                  title: Text(
                    j.caratula,
                    style: const TextStyle(
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF111112),
                    ),
                  ),
                  subtitle: Text(
                    'Fecha de inicio: ${dateFmt.format(j.fechaInicio)}',
                    style: const TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Color(0xFF173664)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Detalles del juicio
                          _dato('Boleta de inicio', _getEstadoText(j.boletaInicio.estado)),
                          _dato('Monto', moneyFmt.format(j.boletaInicio.monto)),
                          _dato(
                            j.boletaInicio.estado == EstadoBoleta.pagada ? 'Fecha de pago' : 'Fecha de vencimiento',
                            j.boletaInicio.estado == EstadoBoleta.pagada
                                ? dateFmt.format(j.boletaInicio.fechaPago!)
                                : dateFmt.format(j.boletaInicio.fechaVencimiento),
                          ),

                          if (j.boletasFin.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Boletas de fin:',
                              style: TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF173664),
                              ),
                            ),
                            ...j.boletasFin.map(
                              (bf) => Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dato('Monto', moneyFmt.format(bf.monto)),
                                    _dato('Estado', _getEstadoText(bf.estado)),
                                    _dato(
                                      bf.estado == EstadoBoleta.pagada ? 'Fecha de pago' : 'Fecha de vencimiento',
                                      bf.estado == EstadoBoleta.pagada
                                          ? dateFmt.format(bf.fechaPago!)
                                          : dateFmt.format(bf.fechaVencimiento),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            _dato('Boletas de fin', 'No creadas'),
                          ],

                          const SizedBox(height: 16),

                          // Botones de acción
                          Row(
                            children: [
                              Builder(
                                builder: (context) => _accion(
                                  icon: Icons.download_outlined,
                                  label: 'Descargar',
                                  onTap: () {
                                    _mostrarMenuDescargar(context, j);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              _accion(
                                icon: Icons.description_outlined,
                                label: 'Crear\nboleta',
                                onTap: () {
                                  // TODO: redirigir a pantalla de creación de boleta
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text('Descargar boleta (próximamente)')));
                                },
                              ),
                              const SizedBox(width: 8),
                              _accion(
                                icon: Icons.payments_outlined,
                                label: 'Pagar',
                                onTap: () {
                                  _navegarAPago(j);
                                },
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

          // Paginación
          if (_paginaActualItems.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                // Botón Anterior
                Expanded(
                  child: ElevatedButton(
                    onPressed: _paginaActual > 1 ? _irAnterior : null,
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
                    'Página $_paginaActual de $_totalPaginas',
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
                    onPressed: _paginaActual < _totalPaginas ? _irSiguiente : null,
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
  }

  void _mostrarMenuDescargar(BuildContext context, JuicioHistorial juicio) {
    final moneyFmt = NumberFormat.currency(locale: 'es_AR', symbol: '\$');

    // Obtener la posición del botón que activó el menú
    final RenderBox button = context.findRenderObject() as RenderBox;
    final buttonSize = button.size;
    final buttonPosition = button.localToGlobal(Offset.zero);

    // Calcular la posición del menú (debajo del botón)
    final menuPosition = RelativeRect.fromRect(
      Rect.fromLTWH(buttonPosition.dx, buttonPosition.dy + buttonSize.height, buttonSize.width, 0),
      Offset.zero & MediaQuery.of(context).size,
    );

    showMenu<dynamic>(
      context: context,
      position: menuPosition,
      items: <PopupMenuEntry<dynamic>>[
        // Boleta de inicio
        PopupMenuItem<dynamic>(
          child: Row(
            children: [
              const Icon(Icons.description, color: Color(0xFF173664)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Boleta de inicio - ${moneyFmt.format(juicio.boletaInicio.monto)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Descargando boleta de inicio...')));
          },
        ),
        // Separador
        const PopupMenuDivider(),
        // Boletas de fin
        ...juicio.boletasFin.map<PopupMenuItem<dynamic>>(
          (bf) => PopupMenuItem<dynamic>(
            child: Row(
              children: [
                const Icon(Icons.description, color: Color(0xFF173664)),
                const SizedBox(width: 8),
                Expanded(child: Text('Boleta de fin - ${moneyFmt.format(bf.monto)}', overflow: TextOverflow.ellipsis)),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Descargando boleta de fin ${moneyFmt.format(bf.monto)}...')));
            },
          ),
        ),
        // Si no hay boletas de fin
        if (juicio.boletasFin.isEmpty)
          const PopupMenuItem<dynamic>(
            enabled: false,
            child: Text('No hay boletas de fin para descargar', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }

  String _getEstadoText(EstadoBoleta estado) {
    switch (estado) {
      case EstadoBoleta.pagada:
        return 'Pagada';
      case EstadoBoleta.pendiente:
        return 'Pendiente de pago';
      case EstadoBoleta.vencida:
        return 'Vencida';
      case EstadoBoleta.noCreada:
        return 'No creada';
    }
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

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Pagada':
        return const Color(0xFF4CAF50); // Verde
      case 'Pendiente de pago':
        return const Color(0xFFF44336); // Rojo
      case 'No creadas':
        return const Color(0xFFD46E07); // Naranja
      default:
        return const Color(0xFF111112); // Color por defecto
    }
  }

  /// Recolecta todas las boletas pendientes de pago de un juicio
  List<BoletaEntity> _obtenerBoletasPendientes(JuicioHistorial juicio) {
    List<BoletaEntity> boletasPendientes = [];

    // Agregar boleta de inicio si está pendiente
    if (juicio.boletaInicio.estado == EstadoBoleta.pendiente) {
      boletasPendientes.add(
        BoletaEntity(
          id: 0, // ID temporal para boletas no creadas aún
          monto: juicio.boletaInicio.monto,
          fechaImpresion: DateTime.now(), // Fecha actual como fecha de impresión
          fechaVencimiento: juicio.boletaInicio.fechaVencimiento,
          caratula: juicio.caratula,
          tipo: BoletaTipo.inicio,
          fechaPago: juicio.boletaInicio.fechaPago,
        ),
      );
    }

    // Agregar boletas de fin pendientes
    for (int i = 0; i < juicio.boletasFin.length; i++) {
      final boletaFin = juicio.boletasFin[i];
      if (boletaFin.estado == EstadoBoleta.pendiente) {
        boletasPendientes.add(
          BoletaEntity(
            id: i + 1000, // ID temporal para boletas de fin
            monto: boletaFin.monto,
            fechaImpresion: DateTime.now(), // Fecha actual como fecha de impresión
            fechaVencimiento: boletaFin.fechaVencimiento,
            caratula: juicio.caratula,
            tipo: BoletaTipo.finalizacion,
            fechaPago: boletaFin.fechaPago,
          ),
        );
      }
    }

    return boletasPendientes;
  }

  /// Navega a la pantalla de procesamiento de pago
  void _navegarAPago(JuicioHistorial juicio) {
    final boletasPendientes = _obtenerBoletasPendientes(juicio);

    if (boletasPendientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay boletas pendientes de pago para este juicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProcesarPagoScreen(boletas: boletasPendientes)));
  }

  Widget _accion({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFD9F1FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD9F1FF), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF173664)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF173664),
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoletaInicio {
  final EstadoBoleta estado;
  final double monto;
  final DateTime fechaVencimiento;
  final DateTime? fechaPago; // null si no está pagada

  BoletaInicio({required this.estado, required this.monto, required this.fechaVencimiento, this.fechaPago});
}

class BoletaFin {
  final EstadoBoleta estado;
  final double monto;
  final DateTime fechaVencimiento;
  final DateTime? fechaPago; // null si no está pagada

  BoletaFin({required this.estado, required this.monto, required this.fechaVencimiento, this.fechaPago});
}

class JuicioHistorial {
  final String caratula;
  final DateTime fechaInicio;
  final BoletaInicio boletaInicio;
  final List<BoletaFin> boletasFin;

  JuicioHistorial({
    required this.caratula,
    required this.fechaInicio,
    required this.boletaInicio,
    required this.boletasFin,
  });
}

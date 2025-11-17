import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:cssayp_movil/shared/providers/navigation_provider.dart';

class HistorialJuiciosWidget extends ConsumerStatefulWidget {
  const HistorialJuiciosWidget({super.key});

  @override
  ConsumerState<HistorialJuiciosWidget> createState() => _HistorialJuiciosWidgetState();
}

class _HistorialJuiciosWidgetState extends ConsumerState<HistorialJuiciosWidget> {
  final TextEditingController _buscarController = TextEditingController();
  String _ordenActual = 'Fecha';

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  List<JuicioEntity> _filtradasYOrdenadas(List<JuicioEntity> juicios) {
    final q = _buscarController.text.trim().toLowerCase();
    List<JuicioEntity> lista = juicios.where((j) => q.isEmpty || j.caratula.toLowerCase().contains(q)).toList();

    switch (_ordenActual) {
      case 'Fecha':
        lista.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'No creada':
        lista.sort((a, b) {
          if (!a.tieneBoletaFin && b.tieneBoletaFin) return -1;
          if (a.tieneBoletaFin && !b.tieneBoletaFin) return 1;
          return b.id.compareTo(a.id);
        });
        break;
      case 'Pagada':
        lista.sort((a, b) {
          final aPagadas = (a.inicioPagado ? 1 : 0) + (a.finPagado ? 1 : 0);
          final bPagadas = (b.inicioPagado ? 1 : 0) + (b.finPagado ? 1 : 0);
          if (aPagadas != bPagadas) return bPagadas.compareTo(aPagadas);
          return b.id.compareTo(a.id);
        });
        break;
      case 'Pendiente de pago':
        lista.sort((a, b) {
          final aPendientes = (!a.inicioPagado ? 1 : 0) + (a.tieneBoletaFin && !a.finPagado ? 1 : 0);
          final bPendientes = (!b.inicioPagado ? 1 : 0) + (b.tieneBoletaFin && !b.finPagado ? 1 : 0);
          if (aPendientes != bPendientes) return bPendientes.compareTo(aPendientes);
          return b.id.compareTo(a.id);
        });
        break;
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'es_AR');
    final juiciosAsyncValue = ref.watch(juiciosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      body: juiciosAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(juiciosProvider.notifier).refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (juiciosState) {
          if (juiciosState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (juiciosState.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${juiciosState.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(juiciosProvider.notifier).refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final listaFiltrada = _filtradasYOrdenadas(juiciosState.juicios);

          return RefreshIndicator(
            onRefresh: () async => await ref.read(juiciosProvider.notifier).refresh(),
            color: const Color(0xFF173664),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFiltros(),
                if (listaFiltrada.isEmpty)
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
                  ...listaFiltrada.map((juicio) => _buildJuicioCard(juicio, dateFmt)),
                _buildPaginacion(juiciosState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por carátula',
            style: TextStyle(color: Color(0xFF173664), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: TextField(
              controller: _buscarController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por carátula',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9F1FF)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ordenar por',
            style: TextStyle(color: Color(0xFF173664), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: _ordenActual,
            isExpanded: true,
            items: [
              'Fecha',
              'No creada',
              'Pagada',
              'Pendiente de pago',
            ].map((orden) => DropdownMenuItem<String>(value: orden, child: Text(orden))).toList(),
            onChanged: (valor) => setState(() => _ordenActual = valor!),
          ),
        ],
      ),
    );
  }

  Widget _buildJuicioCard(JuicioEntity juicio, DateFormat dateFmt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD9F1FF)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            juicio.caratula,
            style: const TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF111112),
            ),
          ),
          subtitle: Text(
            'Juicio ID: ${juicio.id}',
            style: const TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Color(0xFF173664)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBoletaInfo(
                              'Boleta de inicio',
                              juicio.boletaInicioId,
                              juicio.inicioPagado,
                              juicio.fechaPagoInicio,
                              dateFmt,
                            ),
                            if (juicio.inicioPagado) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _verComprobanteInicio(juicio),
                                icon: const Icon(Icons.receipt),
                                label: const Text('Ver comprobante'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  backgroundColor: const Color(0xFFC8E6C9),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBoletaInfo(
                              'Boleta de fin',
                              juicio.boletaFinId,
                              juicio.finPagado,
                              juicio.fechaPagoFin,
                              dateFmt,
                            ),
                            if (juicio.boletaFinId == null) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _crearBoletaFin(juicio),
                                icon: const Icon(Icons.add),
                                label: const Text('Crear boleta'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  backgroundColor: const Color(0xFFC8E6C9),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                            if (juicio.tieneBoletaFin && juicio.finPagado) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _verComprobanteFin(juicio),
                                icon: const Icon(Icons.receipt),
                                label: const Text('Ver comprobante'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  backgroundColor: const Color(0xFFC8E6C9),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildAccion(
                        icon: Icons.file_download,
                        label: 'Descargar',
                        onTap: () => _descargarBoletas(juicio),
                      ),
                      const SizedBox(width: 8),
                      if (!juicio.inicioPagado || (juicio.tieneBoletaFin && !juicio.finPagado))
                        _buildAccion(icon: Icons.payment, label: 'Pagar', onTap: () => _navegarAPago(juicio)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoletaInfo(String titulo, int? boletaId, bool pagado, DateTime? fechaPago, DateFormat dateFmt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9F1FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF173664),
            ),
          ),
          const SizedBox(height: 8),
          if (boletaId != null) ...[
            _buildBoletaField('ID', boletaId.toString()),
            _buildBoletaField(
              'Estado',
              pagado ? "Pagada" : "Pendiente de pago",
              color: pagado ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
            ),
            _buildBoletaField('Fecha de pago', fechaPago != null ? dateFmt.format(fechaPago) : ''),
          ] else
            _buildBoletaField('Estado', 'No creada', color: const Color(0xFFD46E07)),
        ],
      ),
    );
  }

  Widget _buildBoletaField(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "Montserrat",
              fontSize: 11,
              color: Color(0xFF888A8D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? const Color(0xFF111112),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginacion(JuiciosState state) {
    if (!state.hasNextPage && !state.hasPreviousPage) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: state.hasPreviousPage ? () => ref.read(juiciosProvider.notifier).previousPage() : null,
              child: const Text('Anterior'),
            ),
          ),
          Container(width: 140, alignment: Alignment.center, child: Text('Página ${state.currentPage}')),
          Expanded(
            child: ElevatedButton(
              onPressed: state.hasNextPage ? () => ref.read(juiciosProvider.notifier).nextPage() : null,
              child: const Text('Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccion({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFD9F1FF),
            borderRadius: BorderRadius.circular(8),
          ),
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

  void _descargarBoletas(JuicioEntity juicio) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Descargando boletas del juicio ${juicio.id}...')));
  }

  void _navegarAPago(JuicioEntity juicio) {
    // TODO: Implement navigation to payment screen with real boleta data
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navegando a pago para juicio ${juicio.id}...')));
  }

  void _crearBoletaFin(JuicioEntity juicio) {
    ref.read(navigationProvider.notifier).selectTab(2, routeName: '/crear-boleta');
  }

  void _verComprobanteInicio(JuicioEntity juicio) async {
    final navigator = ref.read(navigationProvider).navigatorState;

    if (navigator == null) return;

    await ref.read(comprobantesProvider.notifier).obtenerComprobante(juicio.boletaInicioId);
    final comprobante = ref.read(comprobantesProvider).value?.comprobante;

    if (comprobante != null) {
      navigator.pushNamed("/ver-comprobante-inicio", arguments: comprobante);
    }
  }

  void _verComprobanteFin(JuicioEntity juicio) async {
    final navigator = ref.read(navigationProvider).navigatorState;

    if (navigator == null || juicio.boletaFinId == null) return;

    await ref.read(comprobantesProvider.notifier).obtenerComprobante(juicio.boletaFinId!);
    final comprobante = ref.read(comprobantesProvider).value?.comprobante;

    if (comprobante != null) {
      navigator.pushNamed("/ver-comprobante-fin", arguments: comprobante);
    }
  }
}

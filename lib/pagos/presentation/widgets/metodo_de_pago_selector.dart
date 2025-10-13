import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/pagos/presentation/providers/metodo_pago_selector_provider.dart';

class MetodoDePagoSelector extends ConsumerWidget {
  final bool tieneBoletasInicio;
  final bool tieneBoletasFin;
  final VoidCallback? onSelectionChanged;

  const MetodoDePagoSelector({
    super.key,
    required this.tieneBoletasInicio,
    required this.tieneBoletasFin,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metodoPagoState = ref.watch(metodoPagoSelectorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Método de pago",
          style: TextStyle(
            fontFamily: "Montserrat",
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF173664),
          ),
        ),
        const SizedBox(height: 12),

        Column(
          children: [
            if (tieneBoletasInicio) ...[
              _buildMetodoPagoCard(
                ref: ref,
                metodo: MetodoPago.redLink,
                titulo: "Red Link",
                descripcion: "Pagar con Red Link (Home Banking)",
                icono: Icons.account_balance,
                color: const Color(0xFF173664),
                isSelected: metodoPagoState.selectedMethod == MetodoPago.redLink,
              ),
            ],

            if (tieneBoletasFin) ...[
              _buildMetodoPagoCard(
                ref: ref,
                metodo: MetodoPago.tarjeta,
                titulo: "Tarjeta de crédito/débito",
                descripcion: "Pagar con tarjeta de crédito o débito",
                icono: Icons.credit_card,
                color: Colors.green[700]!,
                isSelected: metodoPagoState.selectedMethod == MetodoPago.tarjeta,
              ),
              const SizedBox(height: 12),
              _buildMetodoPagoCard(
                ref: ref,
                metodo: MetodoPago.redLink,
                titulo: "Red Link",
                descripcion: "Pagar con Red Link (Home Banking)",
                icono: Icons.account_balance,
                color: const Color(0xFF173664),
                isSelected: metodoPagoState.selectedMethod == MetodoPago.redLink,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMetodoPagoCard({
    required WidgetRef ref,
    required MetodoPago metodo,
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(metodoPagoSelectorProvider.notifier).selectMethod(metodo);
        onSelectionChanged?.call();
      },
      child: Card(
        elevation: isSelected ? 4 : 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected ? BorderSide(color: color, width: 2) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Custom radio indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? color : Colors.grey[400]!, width: 2),
                  color: isSelected ? color : Colors.transparent,
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icono, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(fontFamily: "Montserrat", fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

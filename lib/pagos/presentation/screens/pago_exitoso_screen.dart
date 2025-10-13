import 'package:flutter/material.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/pagos/data/models/resultado_pago_model.dart';

class PagoExitosoScreen extends StatelessWidget {
  final List<BoletaEntity> boletas;
  final ResultadoPagoModel? resultadoPago;
  final String? metodoPago;

  const PagoExitosoScreen({super.key, required this.boletas, this.resultadoPago, this.metodoPago});

  @override
  Widget build(BuildContext context) {
    final totalPago = boletas.fold(0.0, (sum, boleta) => sum + boleta.monto);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF173664),
        foregroundColor: Colors.white,
        title: const Text(
          "Pago Exitoso",
          style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Icono de éxito
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 24),

            // Título de éxito
            const Text(
              "¡Pago Exitoso!",
              style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Mensaje de confirmación
            const Text(
              "Su pago ha sido procesado exitosamente. Recibirá una confirmación por correo electrónico.",
              style: TextStyle(fontFamily: "Montserrat", fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Resumen del pago
            _buildResumenPago(totalPago),
            const SizedBox(height: 24),

            // Información adicional del resultado
            if (resultadoPago != null) _buildInformacionResultado(resultadoPago!),
            if (metodoPago != null) _buildMetodoPago(metodoPago!),
            const SizedBox(height: 32),

            // Botones de acción
            _buildBotonesAccion(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPago(double totalPago) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen del Pago",
            style: TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF173664),
            ),
          ),
          const SizedBox(height: 16),
          ...boletas.map(
            (boleta) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      boleta.caratula,
                      style: const TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  Text(
                    "\$${boleta.monto.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF173664),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Pagado:",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF173664),
                ),
              ),
              Text(
                "\$${totalPago.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionResultado(ResultadoPagoModel resultado) {
    // Extraer el mensaje del resultado, manejando tanto String como Map
    String mensaje = '';
    if (resultado.message is String) {
      mensaje = resultado.message as String;
    } else if (resultado.message is Map) {
      final messageMap = resultado.message as Map<String, dynamic>;
      mensaje = messageMap['mensaje']?.toString() ?? messageMap['message']?.toString() ?? 'Pago procesado exitosamente';
    } else {
      mensaje = 'Pago procesado exitosamente';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                "Información del Pago",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mensaje,
            style: const TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildMetodoPago(String metodo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.payment, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          const Text(
            "Método de Pago:",
            style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            metodo,
            style: const TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context) {
    return Column(
      children: [
        // Botón principal - Ver Historial
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navegarAHistorial(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF173664),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Ver Historial de Boletas",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón secundario - Inicio
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _navegarAInicio(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF173664),
              side: const BorderSide(color: Color(0xFF173664), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Volver al Inicio",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _navegarAHistorial(BuildContext context) {
    // Navegar al historial de boletas
    Navigator.pushNamedAndRemoveUntil(context, '/boletas', (route) => false);
  }

  void _navegarAInicio(BuildContext context) {
    // Navegar al inicio y limpiar el stack
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}

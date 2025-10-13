import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cssayp_movil/auth/auth.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/pagos/pagos.dart';

class ProcesarPagoScreen extends ConsumerStatefulWidget {
  final List<BoletaEntity> boletas;

  const ProcesarPagoScreen({super.key, required this.boletas});

  @override
  ConsumerState<ProcesarPagoScreen> createState() => _ProcesarPagoScreenState();
}

class _ProcesarPagoScreenState extends ConsumerState<ProcesarPagoScreen> {
  double get _totalPago {
    return widget.boletas.fold(0.0, (sum, boleta) => sum + boleta.monto);
  }

  bool get _tieneBoletasInicio {
    return widget.boletas.any((boleta) => boleta.tipo == BoletaTipo.inicio);
  }

  bool get _tieneBoletasFin {
    return widget.boletas.any((boleta) => boleta.tipo == BoletaTipo.finalizacion);
  }

  @override
  Widget build(BuildContext context) {
    final metodoPagoState = ref.watch(metodoPagoSelectorProvider);
    final payWayState = ref.watch(payWayNotifierProvider);

    // Escuchar cambios en el estado de pago
    ref.listen<AsyncValue<PayWayState>>(payWayNotifierProvider, (previous, next) {
      if (next.value?.paymentState is PaymentSuccess) {
        _mostrarResultadoPagoExitoso();
      } else if (next.value?.paymentState is PaymentError) {
        _mostrarErrorPago((next.value?.paymentState as PaymentError).error);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF173664),
        foregroundColor: Colors.white,
        title: const Text(
          "Procesar Pago",
          style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Resumen de boletas
          _buildResumenPago(),

          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Selector de método de pago
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MetodoDePagoSelector(
                      tieneBoletasInicio: _tieneBoletasInicio,
                      tieneBoletasFin: _tieneBoletasFin,
                      onSelectionChanged: () {
                        setState(() {}); // Actualizar UI cuando cambie la selección
                      },
                    ),
                  ),

                  // Mostrar formulario de tarjeta si está seleccionado el método de tarjeta
                  if (metodoPagoState.selectedMethod == MetodoPago.tarjeta) ...[const PayWayForm()],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Botón de procesar pago
          _buildBotonProcesarPago(metodoPagoState, payWayState.value ?? PayWayState()),
        ],
      ),
    );
  }

  Widget _buildResumenPago() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen del pago",
            style: TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF173664),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.boletas.map(
            (boleta) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      boleta.caratula,
                      style: const TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total a pagar:",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF173664),
                ),
              ),
              Text(
                "\$${_totalPago.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF173664),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotonProcesarPago(MetodoPagoState metodoPagoState, PayWayState payWayState) {
    bool canProceed = metodoPagoState.canProceedWithPayment;

    // Si el método seleccionado es tarjeta, también verificar que el formulario sea válido
    if (metodoPagoState.selectedMethod == MetodoPago.tarjeta) {
      canProceed = canProceed && payWayState.isFormValid;
    }

    final isLoading = payWayState.paymentState is PaymentLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: canProceed && !isLoading ? _procesarPago : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF173664),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Procesando...",
                    style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              )
            : const Text(
                "Procesar Pago",
                style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 16),
              ),
      ),
    );
  }

  void _procesarPago() {
    final metodoPagoState = ref.read(metodoPagoSelectorProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirmar Pago",
          style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600),
        ),
        content: Text(
          "¿Está seguro de que desea procesar el pago de \$${_totalPago.toStringAsFixed(2)}?",
          style: const TextStyle(fontFamily: "Montserrat"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(fontFamily: "Montserrat", color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _ejecutarPago(metodoPagoState.selectedMethod!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF173664), foregroundColor: Colors.white),
            child: const Text(
              "Confirmar",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _ejecutarPago(MetodoPago metodoPago) {
    switch (metodoPago) {
      case MetodoPago.redLink:
        _procesarPagoConRedLink();
        break;
      case MetodoPago.tarjeta:
        _procesarPagoConTarjeta();
        break;
      case MetodoPago.botonPago:
        _procesarPagoDirecto();
        break;
      case MetodoPago.linkPago:
        _procesarPagoConLink();
        break;
    }
  }

  void _procesarPagoConTarjeta() {
    final authState = ref.read(authProvider);
    final usuario = authState.value!.usuario;
    final boletas = widget.boletas
        .map(
          (b) => BoletaAPagarEntity(
            idBoleta: b.id,
            caratula: b.caratula,
            monto: b.monto,
            nroAfiliado: usuario!.nroAfiliado,
          ),
        )
        .toList();

    // Procesar pago con PayWay
    ref.read(payWayNotifierProvider.notifier).procesarPago(boletas);
  }

  void _procesarPagoDirecto() {
    // Simulación de pago directo
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _mostrarResultadoPagoExitoso();
      }
    });
  }

  void _procesarPagoConRedLink() {
    // Solo debe haber boletas de inicio para Red Link
    if (!_tieneBoletasInicio || widget.boletas.length != 1) {
      _mostrarErrorPago("Red Link solo está disponible para una boleta de inicio");
      return;
    }

    final boleta = widget.boletas.first;

    // Generar URL de pago con Red Link
    ref
        .read(redLinkNotifierProvider.notifier)
        .iniciarPago(idBoleta: boleta.id)
        .then((_) {
          if (mounted) {
            final redLinkState = ref.read(redLinkNotifierProvider).value;

            if (redLinkState != null && redLinkState.isPaymentUrlAvailable) {
              // Navegar a la pantalla de Red Link
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RedLinkPaymentScreen(paymentUrl: redLinkState.paymentUrl!, boletaId: boleta.id, boleta: boleta),
                ),
              );
            } else {
              _mostrarErrorPago((redLinkState?.paymentState as PaymentError).error);
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            _mostrarErrorPago("Error al iniciar pago con Red Link: ${error.toString()}");
          }
        });
  }

  void _procesarPagoConLink() {
    // Simulación de redirección a link de pago
    _mostrarMensajeRedirecion();
  }

  void _mostrarResultadoPagoExitoso() {
    final payWayState = ref.read(payWayNotifierProvider).value;
    final resultadoPago = payWayState?.paymentState is PaymentSuccess
        ? (payWayState!.paymentState as PaymentSuccess).resultado
        : null;

    final metodoPagoState = ref.read(metodoPagoSelectorProvider);
    final metodoPago = _getMetodoPagoNombre(metodoPagoState.selectedMethod);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PagoExitosoScreen(boletas: widget.boletas, resultadoPago: resultadoPago, metodoPago: metodoPago),
      ),
    );
  }

  String? _getMetodoPagoNombre(MetodoPago? metodo) {
    switch (metodo) {
      case MetodoPago.redLink:
        return "Red Link";
      case MetodoPago.tarjeta:
        return "Tarjeta de Crédito/Débito";
      case MetodoPago.botonPago:
        return "Botón de Pago";
      case MetodoPago.linkPago:
        return "Link de Pago";
      case null:
        return null;
    }
  }

  void _mostrarErrorPago(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              "Error en el Pago",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, color: Colors.red),
            ),
          ],
        ),
        content: Text(error, style: const TextStyle(fontFamily: "Montserrat")),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Limpiar el estado de error para permitir reintentar
              ref.read(payWayNotifierProvider.notifier).clearPaymentState();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF173664), foregroundColor: Colors.white),
            child: const Text(
              "Reintentar",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensajeRedirecion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Text(
              "Redirección",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, color: Colors.blue),
            ),
          ],
        ),
        content: const Text(
          "Será redirigido a la plataforma de pago externa para completar la transacción.",
          style: TextStyle(fontFamily: "Montserrat"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(fontFamily: "Montserrat", color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la lógica para abrir el link de pago
              _mostrarResultadoPagoExitoso(); // Simulación
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF173664), foregroundColor: Colors.white),
            child: const Text(
              "Continuar",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

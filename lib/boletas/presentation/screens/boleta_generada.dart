import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cssayp_movil/shared/providers/navigation_provider.dart';
import 'package:cssayp_movil/boletas/boletas.dart';
import 'package:cssayp_movil/pagos/pagos.dart';

class BoletaCreadaScreen extends ConsumerStatefulWidget {
  final BoletaEntity? boleta;

  const BoletaCreadaScreen({super.key, this.boleta});

  @override
  ConsumerState<BoletaCreadaScreen> createState() => _BoletaCreadaScreen();
}

class _BoletaCreadaScreen extends ConsumerState<BoletaCreadaScreen> {
  @override
  Widget build(BuildContext context) {
    final boleta = widget.boleta ?? ModalRoute.of(context)?.settings.arguments as BoletaEntity?;
    return Scaffold(
      backgroundColor: const Color(0xFFEEF9FF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Boleta generada con éxito',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF173664),
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 344,
                    child: Text(
                      'La boleta fue creada correctamente. Puede proceder al pago ahora o consultarla desde su historial.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF173664),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.29,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón primario
                      SizedBox(
                        width: 160,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF173664),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: boleta != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProcesarPagoScreen(boletas: [boleta])),
                                  );
                                }
                              : null,
                          child: const Text(
                            'Pagar boleta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Botón secundario
                      SizedBox(
                        width: 160,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF194B8F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            // Cambiar al tab de Historial Boletas (tab 1)
                            Navigator.of(context).pop(); // Cerrar la pantalla actual
                            // Cambiar al tab de Historial Boletas
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ref.read(navigationProvider.notifier).selectTab(1);
                              Navigator.of(context).pushNamed('/historial-boletas');
                            });
                          },
                          child: const Text(
                            'Ir al historial',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }
}

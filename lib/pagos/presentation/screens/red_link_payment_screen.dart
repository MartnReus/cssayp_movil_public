import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cssayp_movil/pagos/presentation/providers/red_link_notifier.dart';
import 'package:cssayp_movil/pagos/presentation/providers/payment_states.dart';
import 'package:cssayp_movil/pagos/presentation/screens/pago_exitoso_screen.dart';
import 'package:cssayp_movil/boletas/boletas.dart';

class RedLinkPaymentScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final int boletaId;
  final BoletaEntity? boleta;

  const RedLinkPaymentScreen({super.key, required this.paymentUrl, required this.boletaId, this.boleta});

  @override
  ConsumerState<RedLinkPaymentScreen> createState() => _RedLinkPaymentScreenState();
}

class _RedLinkPaymentScreenState extends ConsumerState<RedLinkPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();

    // Iniciar monitoreo del pago cuando se abra la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(redLinkNotifierProvider.notifier).iniciarMonitoreo();
    });
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Configurar User-Agent para mejor compatibilidad
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Página iniciada: $url');
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            print('Página terminada: $url');
            setState(() {
              _isLoading = false;
            });
            // Ejecutar el JavaScript para manejar popups después de que la página cargue
            _setupPopupHandling();
          },
          onWebResourceError: (WebResourceError error) {
            print('Error de recurso web: ${error.description} - ${error.errorCode}');
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = '${error.description} (${error.errorCode})';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Solicitud de navegación: ${request.url}');

            // Permitir todas las navegaciones de RedLink y bancosantafe
            if (request.url.contains('redlink') ||
                request.url.contains('bancosantafe') ||
                request.url.contains('buttonPaymentLogin')) {
              return NavigationDecision.navigate;
            }

            // Para otras URLs, también permitir navegación
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            print('URL cambiada: ${change.url}');
          },
        ),
      )
      // Habilitar manejo de popups y nuevas ventanas
      ..enableZoom(false)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'RedLinkHandler',
        onMessageReceived: (JavaScriptMessage message) {
          print('🔗 RedLink JS: ${message.message}');
          _handleJavaScriptMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _setupPopupHandling() {
    // Inyectar JavaScript para manejar popups con manejo de errores
    _controller
        .runJavaScript('''
      try {
        // Interceptar window.open para manejar popups
        var originalOpen = window.open;
        window.open = function(url, name, features) {
          console.log('Intercepted window.open:', url);
          RedLinkHandler.postMessage('popup_intercepted: ' + url);
          
          if (url && (url.includes('buttonPaymentLogin') || url.includes('bancosantafe'))) {
            // Navegar en la misma ventana en lugar de abrir popup
            window.location.href = url;
            return null;
          }
          return originalOpen.call(this, url, name, features);
        };
        
        // Interceptar clicks en enlaces que abren en nueva ventana
        document.addEventListener('click', function(e) {
          var target = e.target.closest('a');
          if (target && (target.target === '_blank' || target.target === '_new')) {
            e.preventDefault();
            console.log('Intercepted _blank/_new link:', target.href);
            RedLinkHandler.postMessage('link_intercepted: ' + target.href);
            
            if (target.href && (target.href.includes('buttonPaymentLogin') || target.href.includes('bancosantafe'))) {
              window.location.href = target.href;
            }
          }
        }, true);
        
        // Interceptar submits de formularios que abren en nueva ventana
        document.addEventListener('submit', function(e) {
          var form = e.target;
          if (form && (form.target === '_blank' || form.target === '_new')) {
            console.log('Intercepted form submit to new window:', form.action);
            RedLinkHandler.postMessage('form_intercepted: ' + form.action);
            
            if (form.action && (form.action.includes('buttonPaymentLogin') || form.action.includes('bancosantafe'))) {
              form.target = '_self';
            }
          }
        }, true);
        
        // Manejar errores de CORS y recursos
        window.addEventListener('error', function(e) {
          console.log('Resource error:', e.message, e.filename);
          RedLinkHandler.postMessage('resource_error: ' + e.message);
        });
        
        // Notificar cuando la página está lista
        if (document.readyState === 'complete') {
          RedLinkHandler.postMessage('page_ready');
        } else {
          window.addEventListener('load', function() {
            RedLinkHandler.postMessage('page_ready');
          });
        }
        
        RedLinkHandler.postMessage('javascript_injected');
      } catch (error) {
        console.error('Error setting up popup handling:', error);
        RedLinkHandler.postMessage('javascript_error: ' + error.message);
      }
    ''')
        .catchError((error) {
          print('Error ejecutando JavaScript: $error');
        });
  }

  void _handleJavaScriptMessage(String message) {
    if (message.startsWith('popup_intercepted:')) {
      final url = message.substring('popup_intercepted:'.length).trim();
      print('🚀 Popup interceptado: $url');
    } else if (message.startsWith('link_intercepted:')) {
      final url = message.substring('link_intercepted:'.length).trim();
      print('🔗 Link interceptado: $url');
    } else if (message.startsWith('form_intercepted:')) {
      final url = message.substring('form_intercepted:'.length).trim();
      print('📝 Formulario interceptado: $url');
    } else if (message.startsWith('resource_error:')) {
      final error = message.substring('resource_error:'.length).trim();
      print('❌ Error de recurso: $error');
    } else if (message.startsWith('javascript_error:')) {
      final error = message.substring('javascript_error:'.length).trim();
      print('💥 Error de JavaScript: $error');
    } else if (message == 'page_ready') {
      print('✅ Página lista');
    } else if (message == 'javascript_injected') {
      print('💉 JavaScript inyectado correctamente');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final redLinkState = ref.watch(redLinkNotifierProvider);

    // Escuchar cambios en el estado del pago
    ref.listen<AsyncValue<RedLinkState>>(redLinkNotifierProvider, (previous, next) {
      if (next.value?.paymentState is PaymentSuccess) {
        _mostrarResultadoPagoExitoso();
      } else if (next.value?.paymentState is PaymentError) {
        final paymentState = next.value!.paymentState;
        if (paymentState is PaymentError) {
          _mostrarErrorPago(paymentState.error);
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          "Pago Red Link",
          style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Estado del monitoreo
          _buildEstadoMonitoreo(redLinkState),

          // WebView
          Expanded(child: _buildWebViewContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(redLinkNotifierProvider.notifier).verificarEstadoPago();
        },
        backgroundColor: const Color(0xFF173664),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh),
        label: const Text(
          "Verificar Estado",
          style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEstadoMonitoreo(AsyncValue<RedLinkState> redLinkState) {
    final state = redLinkState.value;
    if (state == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: _getEstadoColor(state.paymentState),
      child: Row(
        children: [
          _getEstadoIcon(state.paymentState),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEstadoTitulo(state.paymentState),
                  style: const TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getEstadoDescripcion(state.paymentState),
                  style: const TextStyle(fontFamily: "Montserrat", fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewContent() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Error al cargar la página",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Error desconocido",
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: "Montserrat", fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                });
                _controller.reload();
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

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF173664))),
                SizedBox(height: 16),
                Text(
                  "Cargando Red Link...",
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 16, color: Color(0xFF173664)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getEstadoColor(PaymentState paymentState) {
    if (paymentState is PaymentSuccess) {
      return Colors.green;
    } else if (paymentState is PaymentError) {
      return Colors.red;
    } else if (paymentState is PaymentLoading) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  Widget _getEstadoIcon(PaymentState paymentState) {
    if (paymentState is PaymentSuccess) {
      return const Icon(Icons.check_circle, color: Colors.white);
    } else if (paymentState is PaymentError) {
      return const Icon(Icons.error, color: Colors.white);
    } else if (paymentState is PaymentLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
      );
    }
    return const Icon(Icons.info, color: Colors.white);
  }

  String _getEstadoTitulo(PaymentState paymentState) {
    if (paymentState is PaymentSuccess) {
      return "Pago Exitoso";
    } else if (paymentState is PaymentError) {
      return "Error en el Pago";
    } else if (paymentState is PaymentLoading) {
      return "Monitoreando Pago";
    }
    return "Estado del Pago";
  }

  String _getEstadoDescripcion(PaymentState paymentState) {
    if (paymentState is PaymentSuccess) {
      return "El pago se procesó correctamente";
    } else if (paymentState is PaymentError) {
      return paymentState.error;
    } else if (paymentState is PaymentLoading) {
      return paymentState.message;
    }
    return "Complete el pago en Red Link";
  }

  void _mostrarResultadoPagoExitoso() {
    final redLinkState = ref.read(redLinkNotifierProvider).value;
    final resultadoPago = redLinkState?.paymentState is PaymentSuccess
        ? (redLinkState!.paymentState as PaymentSuccess).resultado
        : null;

    // Crear la boleta para mostrar en la pantalla de éxito
    final boletas = widget.boleta != null ? [widget.boleta!] : <BoletaEntity>[];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PagoExitosoScreen(boletas: boletas, resultadoPago: resultadoPago, metodoPago: "Red Link"),
      ),
    );
  }

  void _mostrarErrorPago(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text(
          "Error en el Pago",
          style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600, color: Colors.red),
        ),
        content: Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: "Montserrat"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Entendido",
              style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

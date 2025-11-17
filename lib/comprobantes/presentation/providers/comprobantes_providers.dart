import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:cssayp_movil/comprobantes/comprobantes.dart";
import "package:cssayp_movil/shared/providers/app_providers.dart";

final comprobantesProvider = AsyncNotifierProvider<ComprobantesNotifier, ComprobantesState>(
  () => ComprobantesNotifier(),
);

final compartirComprobanteUseCaseProvider = Provider<CompartirComprobanteUseCase>((ref) {
  return CompartirComprobanteUseCase(
    generarComprobanteUseCase: ref.watch(generarComprobanteUseCaseProvider),
    sharePlus: ref.watch(sharePlusProvider),
  );
});

final descargarComprobanteUseCaseProvider = Provider<DescargarComprobanteUseCase>((ref) {
  return DescargarComprobanteUseCase(
    generarComprobanteUseCase: ref.watch(generarComprobanteUseCaseProvider),
    permissionHandlerService: ref.watch(permissionHandlerServiceProvider),
  );
});

final generarComprobanteUseCaseProvider = Provider<GenerarComprobanteUseCase>((ref) {
  final pdfService = ref.watch(pdfServiceProvider);
  final usuarioRepository = ref.watch(usuarioRepositoryProvider);
  return GenerarComprobanteUseCase(pdfService: pdfService, usuarioRepository: usuarioRepository.value!);
});

final obtenerComprobanteUseCaseProvider = FutureProvider<ObtenerComprobanteUseCase>((ref) async {
  final repository = await ref.watch(comprobantesRepositoryProvider.future);
  return ObtenerComprobanteUseCase(repository);
});

import 'dart:io';
import 'package:cssayp_movil/comprobantes/comprobantes.dart';
import 'package:cssayp_movil/shared/services/permission_handler_service.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DescargarComprobanteUseCase {
  final GenerarComprobanteUseCase generarComprobanteUseCase;
  final PermissionHandlerService permissionHandlerService;

  DescargarComprobanteUseCase({required this.generarComprobanteUseCase, required this.permissionHandlerService});

  /// Descarga el comprobante directamente al dispositivo y lo abre
  /// - Android: intenta guardar en Downloads (requiere permisos)
  /// - iOS: guarda en el directorio de documentos de la app
  /// - Windows/Linux/macOS: guarda en el directorio de Descargas del usuario
  Future<String> execute(ComprobanteEntity comprobante) async {
    final filePath = await generarComprobanteUseCase.execute(comprobante);
    final file = File(filePath);

    String finalPath;

    final hasStoragePermission = await permissionHandlerService.requestStoragePermission();

    finalPath = filePath;

    try {
      if (hasStoragePermission && Platform.isAndroid) {
        finalPath = await _saveToDownloads(file, comprobante) ?? filePath;
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        finalPath = await _saveToDownloadsDesktop(file, comprobante) ?? filePath;
      }
      await OpenFile.open(finalPath);
    } catch (_) {}

    return finalPath;
  }

  Future<String?> _saveToDownloads(File sourceFile, ComprobanteEntity comprobante) async {
    Directory? downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        downloadsDir = await getExternalStorageDirectory();
      }
    }

    if (downloadsDir == null) {
      return null;
    }

    final fileName = 'comprobante_${comprobante.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final newPath = '${downloadsDir.path}/$fileName';
    final newFile = await sourceFile.copy(newPath);

    return newFile.path;
  }

  Future<String?> _saveToDownloadsDesktop(File sourceFile, ComprobanteEntity comprobante) async {
    // Obtener el directorio de descargas del usuario en sistemas desktop
    Directory? downloadsDir;

    if (Platform.isWindows) {
      // Windows: C:\Users\[username]\Downloads
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        downloadsDir = Directory('$userProfile\\Downloads');
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      // Linux/macOS: /home/[username]/Downloads o ~/Downloads
      final home = Platform.environment['HOME'];
      if (home != null) {
        downloadsDir = Directory('$home/Downloads');
      }
    }

    // Fallback: usar el directorio de documentos si Downloads no existe
    if (downloadsDir == null || !await downloadsDir.exists()) {
      return null;
    }

    final fileName = 'comprobante_${comprobante.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final newPath = '${downloadsDir.path}${Platform.pathSeparator}$fileName';
    final newFile = await sourceFile.copy(newPath);

    return newFile.path;
  }
}

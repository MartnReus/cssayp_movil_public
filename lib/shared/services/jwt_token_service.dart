import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:cssayp_movil/auth/data/datasources/secure_storage_data_source.dart';

class JwtTokenService {
  final SecureStorageDataSource secureStorageDataSource;

  JwtTokenService({required this.secureStorageDataSource});

  Future<String?> obtenerToken() async {
    return await secureStorageDataSource.obtenerToken();
  }

  Future<String?> obtenerCampo(String campo) async {
    final payload = await _obtenerPayload();
    return payload?[campo]?.toString();
  }

  Future<String?> obtenerDigito() => obtenerCampo('dig');

  Future<String?> obtenerNumeroAfiliado() => obtenerCampo('naf');

  Future<Map<String, dynamic>?> obtenerPayloadCompleto() => _obtenerPayload();

  Future<Map<String, dynamic>?> _obtenerPayload() async {
    try {
      final token = await secureStorageDataSource.obtenerToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }
}

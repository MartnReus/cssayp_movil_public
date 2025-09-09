import 'package:sqflite/sqflite.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_entity.dart';
import 'package:cssayp_movil/boletas/domain/entities/boleta_tipo.dart';
import 'package:cssayp_movil/shared/database/database_helper.dart';

class BoletasLocalDataSource {
  final DatabaseHelper _databaseHelper;

  BoletasLocalDataSource({required DatabaseHelper databaseHelper}) : _databaseHelper = databaseHelper;

  Future<void> guardarBoletas(List<BoletaEntity> boletas) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      for (final boleta in boletas) {
        await txn.insert('boletas_historial', boletaToMap(boleta), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<BoletaEntity>> obtenerBoletasLocales({int? limit, int? offset, String? caratulaFiltro}) async {
    final db = await _databaseHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (caratulaFiltro != null && caratulaFiltro.isNotEmpty) {
      whereClause = 'WHERE caratula LIKE ?';
      whereArgs.add('%$caratulaFiltro%');
    }

    String limitClause = '';
    if (limit != null) {
      limitClause = 'LIMIT $limit';
      if (offset != null) {
        limitClause += ' OFFSET $offset';
      }
    }

    final result = await db.rawQuery('''
      SELECT * FROM boletas_historial 
      $whereClause 
      ORDER BY fecha_impresion DESC 
      $limitClause
    ''', whereArgs);

    return result.map((map) => mapToBoleta(map)).toList();
  }

  Future<int> obtenerConteoBoletasLocales({String? caratulaFiltro}) async {
    final db = await _databaseHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (caratulaFiltro != null && caratulaFiltro.isNotEmpty) {
      whereClause = 'WHERE caratula LIKE ?';
      whereArgs.add('%$caratulaFiltro%');
    }

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM boletas_historial $whereClause
    ''', whereArgs);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> limpiarCache() async {
    final db = await _databaseHelper.database;
    await db.delete('boletas_historial');
  }

  Future<DateTime?> obtenerUltimaSincronizacion() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT MAX(fecha_sync) as ultima_sync FROM boletas_historial
    ''');

    final ultimaSync = result.isNotEmpty ? result.first['ultima_sync'] as String? : null;
    if (ultimaSync != null) {
      return DateTime.parse(ultimaSync);
    }
    return null;
  }

  Future<bool> tieneBoletasEnCache() async {
    final conteo = await obtenerConteoBoletasLocales();
    return conteo > 0;
  }

  Map<String, dynamic> boletaToMap(BoletaEntity boleta) {
    return {
      'id': boleta.id,
      'tipo': boleta.tipo.toString().split('.').last,
      'monto': boleta.monto,
      'fecha_impresion': boleta.fechaImpresion.toIso8601String(),
      'fecha_vencimiento': boleta.fechaVencimiento.toIso8601String(),
      'cod_barra': boleta.codBarra,
      'id_boleta_asociada': boleta.idBoletaAsociada,
      'fecha_pago': boleta.fechaPago?.toIso8601String(),
      'importe_pago': boleta.importePago,
      'caratula': boleta.caratula,
      'nro_expediente': boleta.nroExpediente,
      'anio_expediente': boleta.anioExpediente,
      'cuij': boleta.cuij,
      'gastos_administrativos': boleta.gastosAdministrativos,
      'fecha_sync': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  BoletaEntity mapToBoleta(Map<String, dynamic> map) {
    return BoletaEntity(
      id: map['id'] as int,
      tipo: stringToBoletaTipo(map['tipo'] as String),
      monto: map['monto'] as double,
      fechaImpresion: DateTime.parse(map['fecha_impresion'] as String),
      fechaVencimiento: DateTime.parse(map['fecha_vencimiento'] as String),
      caratula: map['caratula'] as String,
      codBarra: map['cod_barra'] as String?,
      idBoletaAsociada: map['id_boleta_asociada'] as int?,
      fechaPago: map['fecha_pago'] != null ? DateTime.parse(map['fecha_pago'] as String) : null,
      importePago: map['importe_pago'] as double?,
      nroExpediente: map['nro_expediente'] as int?,
      anioExpediente: map['anio_expediente'] as int?,
      cuij: map['cuij'] as int?,
      gastosAdministrativos: map['gastos_administrativos'] as double?,
    );
  }

  BoletaTipo stringToBoletaTipo(String tipo) {
    switch (tipo) {
      case 'inicio':
        return BoletaTipo.inicio;
      case 'finalizacion':
        return BoletaTipo.finalizacion;
      default:
        return BoletaTipo.desconocido;
    }
  }
}

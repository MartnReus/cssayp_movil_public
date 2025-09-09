import 'dart:async';
import 'dart:io' show Platform;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath;

    if (Platform.isIOS) {
      final dir = await getLibraryDirectory();
      databasesPath = dir.path;
    } else {
      databasesPath = await getDatabasesPath();
    }

    final path = join(databasesPath, 'cssayp_movil.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE boletas_historial (
        id INTEGER PRIMARY KEY,
        tipo TEXT NOT NULL,
        monto REAL NOT NULL,
        fecha_impresion TEXT NOT NULL,
        fecha_vencimiento TEXT NOT NULL,
        cod_barra TEXT,
        id_boleta_asociada INTEGER,
        fecha_pago TEXT,
        importe_pago REAL,
        caratula TEXT NOT NULL,
        nro_expediente INTEGER,
        anio_expediente INTEGER,
        cuij INTEGER,
        gastos_administrativos REAL,
        fecha_sync TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_boletas_caratula ON boletas_historial(caratula)
    ''');

    await db.execute('''
      CREATE INDEX idx_boletas_fecha_impresion ON boletas_historial(fecha_impresion)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades in future versions
    if (oldVersion < newVersion) {
      // Add migration logic here when needed
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'duplicate_consolidation_service.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create almacenes table
    await db.execute('''
      CREATE TABLE ${AppConstants.almacenesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        direccion TEXT,
        descripcion TEXT,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      )
    ''');

    // Create categorias table
    await db.execute('''
      CREATE TABLE ${AppConstants.categoriasTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        descripcion TEXT,
        fecha_creacion TEXT NOT NULL
      )
    ''');

    // Create productos table
    await db.execute('''
      CREATE TABLE ${AppConstants.productosTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        peso REAL,
        volumen REAL,
        tamano TEXT,
        codigo_qr TEXT,
        categoria_id INTEGER NOT NULL,
        almacen_id INTEGER NOT NULL,
        fecha_creacion TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES ${AppConstants.categoriasTable} (id),
        FOREIGN KEY (almacen_id) REFERENCES ${AppConstants.almacenesTable} (id),
        UNIQUE(codigo_qr, almacen_id)
      )
    ''');

    // Create listas_compra table
    await db.execute('''
      CREATE TABLE ${AppConstants.listasCompraTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        total REAL NOT NULL,
        fecha_creacion TEXT NOT NULL
      )
    ''');

    // Create items_calculadora table
    await db.execute('''
      CREATE TABLE ${AppConstants.itemsCalculadoraTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lista_compra_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (lista_compra_id) REFERENCES ${AppConstants.listasCompraTable} (id),
        FOREIGN KEY (producto_id) REFERENCES ${AppConstants.productosTable} (id)
      )
    ''');

    // Create configuracion table
    await db.execute('''
      CREATE TABLE ${AppConstants.configuracionTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clave TEXT NOT NULL UNIQUE,
        valor TEXT NOT NULL,
        fecha_actualizacion TEXT NOT NULL
      )
    ''');

    // Create indices for better query performance
    await db.execute(
        'CREATE INDEX idx_productos_nombre ON ${AppConstants.productosTable} (nombre)');
    await db.execute(
        'CREATE INDEX idx_productos_codigo_qr ON ${AppConstants.productosTable} (codigo_qr)');
    await db.execute(
        'CREATE INDEX idx_productos_almacen_id ON ${AppConstants.productosTable} (almacen_id)');
    await db.execute(
        'CREATE INDEX idx_productos_categoria_id ON ${AppConstants.productosTable} (categoria_id)');
    await db.execute(
        'CREATE INDEX idx_productos_precio ON ${AppConstants.productosTable} (precio)');
    await db.execute(
        'CREATE INDEX idx_productos_volumen ON ${AppConstants.productosTable} (volumen)');
    await db.execute(
        'CREATE INDEX idx_items_calculadora_lista_id ON ${AppConstants.itemsCalculadoraTable} (lista_compra_id)');
    await db.execute(
        'CREATE INDEX idx_items_calculadora_producto_id ON ${AppConstants.itemsCalculadoraTable} (producto_id)');

    // Insert default category
    await db.insert(AppConstants.categoriasTable, {
      'nombre': AppConstants.defaultCategory,
      'descripcion': 'Categoría por defecto',
      'fecha_creacion': DateTime.now().toIso8601String(),
    });

    // Insert default currency configuration
    await db.insert(AppConstants.configuracionTable, {
      'clave': AppConstants.currencyConfigKey,
      'valor': AppConstants.defaultCurrency,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    });

    await db.insert(AppConstants.configuracionTable, {
      'clave': AppConstants.currencySymbolConfigKey,
      'valor': AppConstants.defaultCurrencySymbol,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _migrateToVersion(db, version);
    }
  }

  Future<void> _migrateToVersion(Database db, int version) async {
    switch (version) {
      case 2:
        // Add configuracion table for currency settings
        await db.execute('''
          CREATE TABLE ${AppConstants.configuracionTable} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            clave TEXT NOT NULL UNIQUE,
            valor TEXT NOT NULL,
            fecha_actualizacion TEXT NOT NULL
          )
        ''');

        // Insert default currency configuration
        await db.insert(AppConstants.configuracionTable, {
          'clave': AppConstants.currencyConfigKey,
          'valor': AppConstants.defaultCurrency,
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });

        await db.insert(AppConstants.configuracionTable, {
          'clave': AppConstants.currencySymbolConfigKey,
          'valor': AppConstants.defaultCurrencySymbol,
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });
        break;
      case 3:
        await _migrateToVersion3(db);
        break;
      default:
        break;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Reset database by deleting and recreating it
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    await deleteDatabase(path);
    _database = null;
    _database = await _initDatabase();
  }

  /// Check if database exists
  Future<bool> databaseExists() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    return await databaseFactory.databaseExists(path);
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, AppConstants.databaseName);
  }

  /// Force database recreation (useful for fixing schema issues)
  Future<void> recreateDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    // Close current database connection
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Delete existing database
    await deleteDatabase(path);

    // Recreate database
    _database = await _initDatabase();
  }

  /// Migrate to version 3: Add volumen field and unique constraint
  Future<void> _migrateToVersion3(Database db) async {
    try {
      // 1. Verificar si la columna volumen ya existe
      final tableInfo = await db
          .rawQuery("PRAGMA table_info(${AppConstants.productosTable})");
      final hasVolumeColumn =
          tableInfo.any((column) => column['name'] == 'volumen');

      if (!hasVolumeColumn) {
        // Agregar columna volumen a la tabla productos
        await db.execute(
            'ALTER TABLE ${AppConstants.productosTable} ADD COLUMN volumen REAL');
      }

      // 2. Consolidar productos duplicados antes de crear el índice único
      await DuplicateConsolidationService.consolidateDuplicateProductos(db);

      // 3. Verificar si el índice único ya existe antes de crearlo
      final indices = await db
          .rawQuery("PRAGMA index_list(${AppConstants.productosTable})");
      final hasUniqueIndex = indices
          .any((index) => index['name'] == 'idx_producto_almacen_unique');

      if (!hasUniqueIndex) {
        // Crear índice único para evitar duplicados futuros
        await db.execute('''
          CREATE UNIQUE INDEX idx_producto_almacen_unique 
          ON ${AppConstants.productosTable}(LOWER(TRIM(nombre)), almacen_id)
        ''');
      }

      // 4. Verificar si el índice de volumen ya existe antes de crearlo
      final hasVolumeIndex =
          indices.any((index) => index['name'] == 'idx_productos_volumen');

      if (!hasVolumeIndex) {
        // Crear índice para búsquedas por volumen
        await db.execute(
            'CREATE INDEX idx_productos_volumen ON ${AppConstants.productosTable} (volumen)');
      }
    } catch (e) {
      throw DatabaseException('Error durante la migración a versión 3: $e');
    }
  }
}

import 'dart:io';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'database_helper.dart';

class DatabaseRecoveryService {
  static final DatabaseRecoveryService _instance = DatabaseRecoveryService._internal();
  factory DatabaseRecoveryService() => _instance;
  DatabaseRecoveryService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Check database integrity
  Future<bool> checkDatabaseIntegrity() async {
    try {
      final db = await _databaseHelper.database;
      
      // Run integrity check
      final result = await db.rawQuery('PRAGMA integrity_check');
      final integrityResult = result.first['integrity_check'] as String;
      
      if (integrityResult != 'ok') {
        print('Database integrity check failed: $integrityResult');
        return false;
      }
      
      // Check if all required tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      final tableNames = tables.map((table) => table['name'] as String).toSet();
      
      final requiredTables = {
        AppConstants.almacenesTable,
        AppConstants.categoriasTable,
        AppConstants.productosTable,
        AppConstants.listasCompraTable,
        AppConstants.itemsCalculadoraTable,
      };
      
      for (final requiredTable in requiredTables) {
        if (!tableNames.contains(requiredTable)) {
          print('Required table missing: $requiredTable');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error checking database integrity: $e');
      return false;
    }
  }

  /// Attempt to repair database
  Future<bool> repairDatabase() async {
    try {
      print('Attempting database repair...');
      
      // First, try to backup existing data
      final backupData = await _backupCriticalData();
      
      // Reset the database
      await _databaseHelper.resetDatabase();
      
      // Restore backed up data
      if (backupData.isNotEmpty) {
        await _restoreBackupData(backupData);
      }
      
      // Verify repair was successful
      final isHealthy = await checkDatabaseIntegrity();
      
      if (isHealthy) {
        print('Database repair successful');
        return true;
      } else {
        print('Database repair failed');
        return false;
      }
    } catch (e) {
      print('Error during database repair: $e');
      return false;
    }
  }

  /// Backup critical data before repair
  Future<Map<String, List<Map<String, dynamic>>>> _backupCriticalData() async {
    final backupData = <String, List<Map<String, dynamic>>>{};
    
    try {
      final db = await _databaseHelper.database;
      
      // Backup almacenes
      try {
        final almacenes = await db.query(AppConstants.almacenesTable);
        backupData[AppConstants.almacenesTable] = almacenes;
      } catch (e) {
        print('Could not backup almacenes: $e');
      }
      
      // Backup categorias
      try {
        final categorias = await db.query(AppConstants.categoriasTable);
        backupData[AppConstants.categoriasTable] = categorias;
      } catch (e) {
        print('Could not backup categorias: $e');
      }
      
      // Backup productos
      try {
        final productos = await db.query(AppConstants.productosTable);
        backupData[AppConstants.productosTable] = productos;
      } catch (e) {
        print('Could not backup productos: $e');
      }
      
      // Backup listas_compra
      try {
        final listas = await db.query(AppConstants.listasCompraTable);
        backupData[AppConstants.listasCompraTable] = listas;
      } catch (e) {
        print('Could not backup listas_compra: $e');
      }
      
      // Backup items_calculadora
      try {
        final items = await db.query(AppConstants.itemsCalculadoraTable);
        backupData[AppConstants.itemsCalculadoraTable] = items;
      } catch (e) {
        print('Could not backup items_calculadora: $e');
      }
      
    } catch (e) {
      print('Error during backup: $e');
    }
    
    return backupData;
  }

  /// Restore backed up data
  Future<void> _restoreBackupData(Map<String, List<Map<String, dynamic>>> backupData) async {
    try {
      final db = await _databaseHelper.database;
      
      // Restore in dependency order
      
      // 1. Restore almacenes first
      if (backupData.containsKey(AppConstants.almacenesTable)) {
        for (final almacen in backupData[AppConstants.almacenesTable]!) {
          try {
            await db.insert(AppConstants.almacenesTable, almacen);
          } catch (e) {
            print('Error restoring almacen: $e');
          }
        }
      }
      
      // 2. Restore categorias
      if (backupData.containsKey(AppConstants.categoriasTable)) {
        for (final categoria in backupData[AppConstants.categoriasTable]!) {
          try {
            await db.insert(AppConstants.categoriasTable, categoria);
          } catch (e) {
            print('Error restoring categoria: $e');
          }
        }
      }
      
      // 3. Restore productos
      if (backupData.containsKey(AppConstants.productosTable)) {
        for (final producto in backupData[AppConstants.productosTable]!) {
          try {
            await db.insert(AppConstants.productosTable, producto);
          } catch (e) {
            print('Error restoring producto: $e');
          }
        }
      }
      
      // 4. Restore listas_compra
      if (backupData.containsKey(AppConstants.listasCompraTable)) {
        for (final lista in backupData[AppConstants.listasCompraTable]!) {
          try {
            await db.insert(AppConstants.listasCompraTable, lista);
          } catch (e) {
            print('Error restoring lista_compra: $e');
          }
        }
      }
      
      // 5. Restore items_calculadora
      if (backupData.containsKey(AppConstants.itemsCalculadoraTable)) {
        for (final item in backupData[AppConstants.itemsCalculadoraTable]!) {
          try {
            await db.insert(AppConstants.itemsCalculadoraTable, item);
          } catch (e) {
            print('Error restoring item_calculadora: $e');
          }
        }
      }
      
    } catch (e) {
      print('Error during restore: $e');
    }
  }

  /// Create database backup file
  Future<String?> createDatabaseBackup() async {
    try {
      final dbPath = await _databaseHelper.getDatabasePath();
      final dbFile = File(dbPath);
      
      if (!await dbFile.exists()) {
        throw const DatabaseException('Database file does not exist');
      }
      
      final backupDir = Directory(join(dirname(dbPath), 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = join(backupDir.path, 'backup_$timestamp.db');
      
      await dbFile.copy(backupPath);
      
      print('Database backup created: $backupPath');
      return backupPath;
    } catch (e) {
      print('Error creating database backup: $e');
      return null;
    }
  }

  /// Restore database from backup file
  Future<bool> restoreFromBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw const DatabaseException('Backup file does not exist');
      }
      
      // Close current database connection
      await _databaseHelper.close();
      
      // Replace current database with backup
      final dbPath = await _databaseHelper.getDatabasePath();
      await backupFile.copy(dbPath);
      
      // Verify restored database
      final isHealthy = await checkDatabaseIntegrity();
      
      if (isHealthy) {
        print('Database restored successfully from backup');
        return true;
      } else {
        print('Restored database failed integrity check');
        return false;
      }
    } catch (e) {
      print('Error restoring from backup: $e');
      return false;
    }
  }

  /// Clean up old backup files
  Future<void> cleanupOldBackups({int maxBackups = 5}) async {
    try {
      final dbPath = await _databaseHelper.getDatabasePath();
      final backupDir = Directory(join(dirname(dbPath), 'backups'));
      
      if (!await backupDir.exists()) {
        return;
      }
      
      final backupFiles = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .cast<File>()
          .toList();
      
      if (backupFiles.length <= maxBackups) {
        return;
      }
      
      // Sort by modification time (newest first)
      backupFiles.sort((a, b) => 
          b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      // Delete old backups
      for (int i = maxBackups; i < backupFiles.length; i++) {
        try {
          await backupFiles[i].delete();
          print('Deleted old backup: ${backupFiles[i].path}');
        } catch (e) {
          print('Error deleting backup file: $e');
        }
      }
    } catch (e) {
      print('Error cleaning up old backups: $e');
    }
  }

  /// Get database health status
  Future<DatabaseHealthStatus> getDatabaseHealthStatus() async {
    try {
      final isHealthy = await checkDatabaseIntegrity();
      
      if (!isHealthy) {
        return DatabaseHealthStatus.corrupted;
      }
      
      // Check if database has essential data
      final db = await _databaseHelper.database;
      
      final categoriaCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.categoriasTable}')
      ) ?? 0;
      
      if (categoriaCount == 0) {
        return DatabaseHealthStatus.missingEssentialData;
      }
      
      return DatabaseHealthStatus.healthy;
    } catch (e) {
      print('Error checking database health: $e');
      return DatabaseHealthStatus.error;
    }
  }

  /// Perform automatic recovery if needed
  Future<bool> performAutoRecovery() async {
    try {
      final healthStatus = await getDatabaseHealthStatus();
      
      switch (healthStatus) {
        case DatabaseHealthStatus.healthy:
          return true;
          
        case DatabaseHealthStatus.missingEssentialData:
          print('Database missing essential data, attempting repair...');
          return await _repairEssentialData();
          
        case DatabaseHealthStatus.corrupted:
          print('Database corrupted, attempting repair...');
          return await repairDatabase();
          
        case DatabaseHealthStatus.error:
          print('Database error, attempting full recovery...');
          return await repairDatabase();
      }
    } catch (e) {
      print('Error during auto recovery: $e');
      return false;
    }
  }

  /// Repair essential data (like default category)
  Future<bool> _repairEssentialData() async {
    try {
      final db = await _databaseHelper.database;
      
      // Ensure default category exists
      final categoriaCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.categoriasTable}')
      ) ?? 0;
      
      if (categoriaCount == 0) {
        await db.insert(AppConstants.categoriasTable, {
          'nombre': AppConstants.defaultCategory,
          'descripcion': 'Categoría por defecto',
          'fecha_creacion': DateTime.now().toIso8601String(),
        });
        print('Default category restored');
      }
      
      return true;
    } catch (e) {
      print('Error repairing essential data: $e');
      return false;
    }
  }
}

enum DatabaseHealthStatus {
  healthy,
  missingEssentialData,
  corrupted,
  error,
}
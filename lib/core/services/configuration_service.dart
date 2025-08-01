import '../database/database_helper.dart';
import '../constants/app_constants.dart';

class ConfigurationService {
  final DatabaseHelper _databaseHelper;

  ConfigurationService({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Get current currency
  Future<String> getCurrentCurrency() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      AppConstants.configuracionTable,
      where: 'clave = ?',
      whereArgs: [AppConstants.currencyConfigKey],
    );

    if (result.isNotEmpty) {
      return result.first['valor'] as String;
    }
    return AppConstants.defaultCurrency;
  }

  /// Get current currency symbol
  Future<String> getCurrentCurrencySymbol() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      AppConstants.configuracionTable,
      where: 'clave = ?',
      whereArgs: [AppConstants.currencySymbolConfigKey],
    );

    if (result.isNotEmpty) {
      return result.first['valor'] as String;
    }
    return AppConstants.defaultCurrencySymbol;
  }

  /// Update currency configuration
  Future<void> updateCurrency(String currency) async {
    final db = await _databaseHelper.database;
    final symbol = AppConstants.supportedCurrencies[currency] ?? AppConstants.defaultCurrencySymbol;

    // Update currency
    await db.update(
      AppConstants.configuracionTable,
      {
        'valor': currency,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      where: 'clave = ?',
      whereArgs: [AppConstants.currencyConfigKey],
    );

    // Update currency symbol
    await db.update(
      AppConstants.configuracionTable,
      {
        'valor': symbol,
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      },
      where: 'clave = ?',
      whereArgs: [AppConstants.currencySymbolConfigKey],
    );
  }

  /// Get all configuration
  Future<Map<String, String>> getAllConfiguration() async {
    final db = await _databaseHelper.database;
    final result = await db.query(AppConstants.configuracionTable);

    final config = <String, String>{};
    for (final row in result) {
      config[row['clave'] as String] = row['valor'] as String;
    }
    return config;
  }
}
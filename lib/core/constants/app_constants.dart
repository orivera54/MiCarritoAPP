class AppConstants {
  // Database constants
  static const String databaseName = 'supermercado_comparador.db';
  static const int databaseVersion = 3;
  
  // Table names
  static const String almacenesTable = 'almacenes';
  static const String categoriasTable = 'categorias';
  static const String productosTable = 'productos';
  static const String listasCompraTable = 'listas_compra';
  static const String itemsCalculadoraTable = 'items_calculadora';
  static const String configuracionTable = 'configuracion';
  
  // Default values
  static const String defaultCategory = 'General';
  static const String defaultCurrency = 'COP';
  static const String defaultCurrencySymbol = '\$';
  
  // Configuration keys
  static const String currencyConfigKey = 'currency';
  static const String currencySymbolConfigKey = 'currency_symbol';
  
  // Supported currencies
  static const Map<String, String> supportedCurrencies = {
    'COP': '\$',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'MXN': '\$',
    'ARS': '\$',
    'PEN': 'S/',
    'CLP': '\$',
    'UYU': '\$',
    'BOB': 'Bs',
  };
}
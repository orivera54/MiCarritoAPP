import 'package:intl/intl.dart';
import '../services/configuration_service.dart';
import '../constants/app_constants.dart';

class Formatters {
  static final ConfigurationService _configService = ConfigurationService();
  
  static Future<String> formatPrice(double price) async {
    try {
      final symbol = await _configService.getCurrentCurrencySymbol();
      final formatter = NumberFormat.currency(
        locale: 'es_CO',
        symbol: symbol,
        decimalDigits: 2,
      );
      return formatter.format(price);
    } catch (e) {
      // Fallback to default currency
      final formatter = NumberFormat.currency(
        locale: 'es_CO',
        symbol: AppConstants.defaultCurrencySymbol,
        decimalDigits: 2,
      );
      return formatter.format(price);
    }
  }
  
  static String formatPriceSync(double price, {String? currencySymbol}) {
    final symbol = currencySymbol ?? AppConstants.defaultCurrencySymbol;
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(price);
  }
  
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }
  
  static String formatDateOnly(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
  
  static String formatWeight(double weight) {
    if (weight < 1) {
      return '${(weight * 1000).toInt()}g';
    }
    return '${weight.toStringAsFixed(2)}kg';
  }
}
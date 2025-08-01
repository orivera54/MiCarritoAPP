import 'package:flutter/material.dart';
import '../../../../core/services/configuration_service.dart';
import '../../../../core/constants/app_constants.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final ConfigurationService _configService = ConfigurationService();
  String _currentCurrency = AppConstants.defaultCurrency;
  String _currentCurrencySymbol = AppConstants.defaultCurrencySymbol;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      final currency = await _configService.getCurrentCurrency();
      final symbol = await _configService.getCurrentCurrencySymbol();
      
      setState(() {
        _currentCurrency = currency;
        _currentCurrencySymbol = symbol;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar configuración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateCurrency(String newCurrency) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _configService.updateCurrency(newCurrency);
      
      setState(() {
        _currentCurrency = newCurrency;
        _currentCurrencySymbol = AppConstants.supportedCurrencies[newCurrency] ?? AppConstants.defaultCurrencySymbol;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Moneda actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar moneda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCurrencySection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildCurrencySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Configuración de Moneda',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Moneda actual: $_currentCurrency ($_currentCurrencySymbol)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCurrencySelector(),
              icon: const Icon(Icons.edit),
              label: const Text('Cambiar Moneda'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acerca de la aplicación',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Supermercado Comparador v1.0.0'),
            const SizedBox(height: 8),
            const Text('Aplicación para comparar precios y gestionar compras'),
            const SizedBox(height: 8),
            const Text('Funciona completamente offline'),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Moneda'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppConstants.supportedCurrencies.length,
              itemBuilder: (context, index) {
                final currency = AppConstants.supportedCurrencies.keys.elementAt(index);
                final symbol = AppConstants.supportedCurrencies[currency]!;
                final isSelected = currency == _currentCurrency;

                return ListTile(
                  leading: Text(
                    symbol,
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Text(currency),
                  subtitle: Text(_getCurrencyName(currency)),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (!isSelected) {
                      _updateCurrency(currency);
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  String _getCurrencyName(String currency) {
    switch (currency) {
      case 'COP':
        return 'Peso Colombiano';
      case 'USD':
        return 'Dólar Estadounidense';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'Libra Esterlina';
      case 'MXN':
        return 'Peso Mexicano';
      case 'ARS':
        return 'Peso Argentino';
      case 'PEN':
        return 'Sol Peruano';
      case 'CLP':
        return 'Peso Chileno';
      case 'UYU':
        return 'Peso Uruguayo';
      case 'BOB':
        return 'Boliviano';
      default:
        return currency;
    }
  }
}
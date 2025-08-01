import 'package:flutter/material.dart';
import '../navigation/navigation_state.dart';
import '../di/service_locator.dart';

class FeatureIntegrationService {
  static final NavigationState _navigationState = sl<NavigationState>();

  // Integration: Productos -> Calculadora
  static Future<void> addProductToCalculadora(dynamic producto) async {
    // Set pending arguments for calculadora
    _navigationState.setPendingArguments({
      'action': 'addProduct',
      'product': producto,
    });
    
    // Navigate to calculadora tab
    _navigationState.navigateToCalculadora();
  }

  // Integration: Productos -> Comparador
  static Future<void> compareProductPrices(dynamic producto) async {
    // Set pending arguments for comparador
    _navigationState.setPendingArguments({
      'action': 'searchProduct',
      'searchTerm': producto.nombre,
      'productId': producto.id,
    });
    
    // Navigate to comparador tab
    _navigationState.navigateToComparador();
  }

  // Integration: QR Scanner -> Productos Search
  static Future<void> searchProductByQR(String qrCode) async {
    // Set pending arguments for productos
    _navigationState.setPendingArguments({
      'action': 'searchByQR',
      'qrCode': qrCode,
    });
    
    // Navigate to productos tab
    _navigationState.navigateToProductos();
  }

  // Integration: QR Scanner -> Calculadora (if product found)
  static Future<void> addProductByQRToCalculadora(String qrCode) async {
    // Set pending arguments for calculadora to search and add product by QR
    _navigationState.setPendingArguments({
      'action': 'addProductByQR',
      'qrCode': qrCode,
    });
    
    // Navigate to calculadora tab
    _navigationState.navigateToCalculadora();
  }

  // Integration: Comparador -> Calculadora (add best price product)
  static Future<void> addBestPriceProductToCalculadora(dynamic producto) async {
    // Set pending arguments for calculadora
    _navigationState.setPendingArguments({
      'action': 'addProduct',
      'product': producto,
      'source': 'comparador',
    });
    
    // Navigate to calculadora tab
    _navigationState.navigateToCalculadora();
  }

  // Integration: Search flow from any feature
  static Future<void> initiateProductSearch({
    String? searchTerm,
    String? qrCode,
    int? almacenId,
    int? categoriaId,
  }) async {
    final args = <String, dynamic>{
      'action': 'search',
    };
    
    if (searchTerm != null) args['searchTerm'] = searchTerm;
    if (qrCode != null) args['qrCode'] = qrCode;
    if (almacenId != null) args['almacenId'] = almacenId;
    if (categoriaId != null) args['categoriaId'] = categoriaId;
    
    _navigationState.setPendingArguments(args);
    _navigationState.navigateToProductos();
  }

  // Integration: Navigate to specific almacen products
  static Future<void> viewAlmacenProducts(int almacenId, String almacenNombre) async {
    _navigationState.setPendingArguments({
      'action': 'filterByAlmacen',
      'almacenId': almacenId,
      'almacenNombre': almacenNombre,
    });
    
    _navigationState.navigateToProductos();
  }

  // Integration: Navigate to specific categoria products
  static Future<void> viewCategoriaProducts(int categoriaId, String categoriaNombre) async {
    _navigationState.setPendingArguments({
      'action': 'filterByCategoria',
      'categoriaId': categoriaId,
      'categoriaNombre': categoriaNombre,
    });
    
    _navigationState.navigateToProductos();
  }

  // Utility method to show contextual actions
  static void showProductContextMenu(
    BuildContext context,
    dynamic producto, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              producto.nombre,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Agregar a calculadora'),
              onTap: () {
                Navigator.pop(context);
                addProductToCalculadora(producto);
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Comparar precios'),
              onTap: () {
                Navigator.pop(context);
                compareProductPrices(producto);
              },
            ),
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Clear pending arguments after they've been processed
  static void clearPendingArguments() {
    _navigationState.clearPendingArguments();
  }

  // Get current pending arguments
  static Map<String, dynamic>? getPendingArguments() {
    return _navigationState.pendingArguments;
  }
}
import 'package:flutter/material.dart';
import '../../domain/entities/producto_comparacion.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/integration/feature_integration_service.dart';

class ComparacionTable extends StatelessWidget {
  final List<ProductoComparacion> productos;
  final Function(String)? onProductSelected;

  const ComparacionTable({
    super.key,
    required this.productos,
    this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return const Center(
        child: Text('No hay productos para comparar'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(context),
            const SizedBox(height: 8),
            ...productos.map((producto) => _buildProductRow(context, producto)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Producto',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Almacén',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Precio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 40), // Space for best price indicator
        ],
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, ProductoComparacion producto) {
    final isBestPrice = producto.esMejorPrecio;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: isBestPrice 
            ? Colors.green.shade50 
            : Theme.of(context).colorScheme.surface,
        border: isBestPrice 
            ? Border.all(color: Colors.green.shade300, width: 2)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () => _showProductDetails(context, producto),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.producto.nombre,
                      style: TextStyle(
                        fontWeight: isBestPrice ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (producto.producto.tamano != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        producto.producto.tamano!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => onProductSelected?.call(producto.producto.nombre),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.store,
                              size: 12,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ver todos los almacenes',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  producto.almacen.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBestPrice ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: PriceText(
                  price: producto.producto.precio,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isBestPrice ? Colors.green[700] : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 40,
                child: isBestPrice
                    ? Icon(
                        Icons.star,
                        color: Colors.amber[700],
                        size: 24,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, ProductoComparacion producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(producto.producto.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Almacén', producto.almacen.nombre),
            _buildDetailRowWithPrice('Precio', producto.producto.precio),
            if (producto.producto.tamano != null)
              _buildDetailRow('Tamaño', producto.producto.tamano!),
            if (producto.producto.peso != null)
              _buildDetailRow('Peso', Formatters.formatWeight(producto.producto.peso!)),
            if (producto.producto.codigoQR != null)
              _buildDetailRow('Código QR', producto.producto.codigoQR!),
            if (producto.almacen.direccion != null)
              _buildDetailRow('Dirección', producto.almacen.direccion!),
            if (producto.esMejorPrecio) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mejor precio disponible',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              FeatureIntegrationService.addBestPriceProductToCalculadora(producto.producto);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_shopping_cart, size: 18),
                SizedBox(width: 4),
                Text('Agregar a calculadora'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithPrice(String label, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: PriceText(price: price),
          ),
        ],
      ),
    );
  }
}
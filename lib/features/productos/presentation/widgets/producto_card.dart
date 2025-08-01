import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/integration/feature_integration_service.dart';
import '../../domain/entities/producto.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final String almacenNombre;
  final String categoriaNombre;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.almacenNombre,
    required this.categoriaNombre,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        PriceText(
                          price: producto.precio,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      color: Colors.red[400],
                      tooltip: 'Eliminar producto',
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Product details
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildDetailChip(
                    icon: Icons.store,
                    label: almacenNombre,
                    color: Colors.blue,
                  ),
                  _buildDetailChip(
                    icon: Icons.category,
                    label: categoriaNombre,
                    color: Colors.green,
                  ),
                  if (producto.peso != null)
                    _buildDetailChip(
                      icon: Icons.scale,
                      label: Formatters.formatWeight(producto.peso!),
                      color: Colors.orange,
                    ),
                  if (producto.tamano?.isNotEmpty == true)
                    _buildDetailChip(
                      icon: Icons.straighten,
                      label: producto.tamano!,
                      color: Colors.purple,
                    ),
                  if (producto.codigoQR?.isNotEmpty == true)
                    _buildDetailChip(
                      icon: Icons.qr_code,
                      label: 'QR',
                      color: Colors.teal,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Footer with dates
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Creado: ${Formatters.formatDateOnly(producto.fechaCreacion)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (producto.fechaActualizacion != producto.fechaCreacion) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Editado: ${Formatters.formatDateOnly(producto.fechaActualizacion)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    FeatureIntegrationService.showProductContextMenu(
      context,
      producto,
      onEdit: onTap,
      onDelete: onDelete,
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
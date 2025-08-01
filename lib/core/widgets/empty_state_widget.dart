import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SearchEmptyStateWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const SearchEmptyStateWidget({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No se encontraron resultados',
      subtitle: 'No hay productos que coincidan con "$searchQuery".\nIntenta con otros términos de búsqueda.',
      actionText: 'Limpiar búsqueda',
      onAction: onClearSearch,
      iconColor: Colors.orange[300],
    );
  }
}

class NoProductsEmptyStateWidget extends StatelessWidget {
  final VoidCallback? onAddProduct;

  const NoProductsEmptyStateWidget({
    super.key,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'No hay productos',
      subtitle: 'Aún no has agregado productos a este almacén.\n¡Comienza agregando tu primer producto!',
      actionText: 'Agregar producto',
      onAction: onAddProduct,
      iconColor: Colors.blue[300],
    );
  }
}

class NoAlmacenesEmptyStateWidget extends StatelessWidget {
  final VoidCallback? onAddAlmacen;

  const NoAlmacenesEmptyStateWidget({
    super.key,
    this.onAddAlmacen,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.store_outlined,
      title: 'No hay almacenes',
      subtitle: 'Necesitas crear al menos un almacén para comenzar a agregar productos.',
      actionText: 'Crear almacén',
      onAction: onAddAlmacen,
      iconColor: Colors.green[300],
    );
  }
}

class EmptyCalculadoraStateWidget extends StatelessWidget {
  final VoidCallback? onAddProduct;

  const EmptyCalculadoraStateWidget({
    super.key,
    this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'Tu lista está vacía',
      subtitle: 'Agrega productos a tu lista para calcular el total de tu compra.',
      actionText: 'Agregar producto',
      onAction: onAddProduct,
      iconColor: Colors.purple[300],
    );
  }
}

class NoComparacionEmptyStateWidget extends StatelessWidget {
  final String? searchQuery;

  const NoComparacionEmptyStateWidget({
    super.key,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.compare_arrows_outlined,
      title: 'No se encontraron productos para comparar',
      subtitle: searchQuery != null
          ? 'No hay productos que coincidan con "$searchQuery" en múltiples almacenes.'
          : 'Busca un producto para comparar precios entre diferentes almacenes.',
      iconColor: Colors.teal[300],
    );
  }
}
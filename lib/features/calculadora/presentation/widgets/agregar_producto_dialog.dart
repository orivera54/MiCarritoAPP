import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../productos/presentation/bloc/producto_bloc.dart';
import '../../../productos/presentation/bloc/producto_event.dart';
import '../../../productos/presentation/bloc/producto_state.dart';
import '../../../productos/domain/entities/producto.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/price_text.dart';

class AgregarProductoDialog extends StatefulWidget {
  final Function(Producto, int) onProductoSeleccionado;
  final int? almacenId;
  final String? almacenNombre;

  const AgregarProductoDialog({
    super.key,
    required this.onProductoSeleccionado,
    this.almacenId,
    this.almacenNombre,
  });

  @override
  State<AgregarProductoDialog> createState() => _AgregarProductoDialogState();
}

class _AgregarProductoDialogState extends State<AgregarProductoDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController(text: '1');
  Producto? _selectedProducto;
  int _cantidad = 1;

  @override
  void initState() {
    super.initState();
    // Load products filtered by almacen if specified
    _loadProducts();
  }

  void _loadProducts({String? searchTerm}) {
    if (widget.almacenId != null) {
      // Load products filtered by almacen
      if (searchTerm != null && searchTerm.isNotEmpty) {
        context.read<ProductoBloc>().add(SearchProductosWithFilters(
          searchTerm: searchTerm,
          almacenId: widget.almacenId,
        ));
      } else {
        context.read<ProductoBloc>().add(LoadProductosByAlmacen(widget.almacenId!));
      }
    } else {
      // Load all products if no almacen is specified
      if (searchTerm != null && searchTerm.isNotEmpty) {
        context.read<ProductoBloc>().add(SearchProductosByName(searchTerm));
      } else {
        context.read<ProductoBloc>().add(LoadAllProductos());
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agregar producto',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (widget.almacenNombre != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Productos de: ${widget.almacenNombre}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _loadProducts();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
                _loadProducts(searchTerm: value.trim().isEmpty ? null : value.trim());
              },
            ),
            
            const SizedBox(height: 16),
            
            // Products list
            Expanded(
              child: BlocBuilder<ProductoBloc, ProductoState>(
                builder: (context, state) {
                  if (state is ProductoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is ProductoError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar productos',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _loadProducts();
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  List<Producto> productos = [];
                  if (state is ProductoLoaded) {
                    productos = state.productos;
                  } else if (state is ProductoSearchResults) {
                    productos = state.productos;
                  } else if (state is ProductoFilteredResults) {
                    productos = state.productos;
                  }
                  
                  if (productos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron productos',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Intenta con otro término de búsqueda',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final producto = productos[index];
                      final isSelected = _selectedProducto?.id == producto.id;
                      
                      return Card(
                        color: isSelected 
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                        child: ListTile(
                          title: Text(
                            producto.nombre,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PriceText(price: producto.precio),
                              if (producto.peso != null)
                                Text('Peso: ${Formatters.formatWeight(producto.peso!)}'),
                              if (producto.tamano != null)
                                Text('Tamaño: ${producto.tamano}'),
                            ],
                          ),
                          trailing: isSelected 
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedProducto = producto;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cantidad selector
            if (_selectedProducto != null) ...[
              Row(
                children: [
                  Text(
                    'Cantidad:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _cantidad > 1
                        ? () {
                            setState(() {
                              _cantidad--;
                              _cantidadController.text = _cantidad.toString();
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _cantidadController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final cantidad = int.tryParse(value);
                        if (cantidad != null && cantidad > 0) {
                          setState(() {
                            _cantidad = cantidad;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _cantidad++;
                        _cantidadController.text = _cantidad.toString();
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                  const Spacer(),
                  PriceBuilder(
                    price: _selectedProducto!.precio * _cantidad,
                    builder: (formattedPrice) => Text(
                      'Subtotal: $formattedPrice',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedProducto != null
                        ? () {
                            widget.onProductoSeleccionado(_selectedProducto!, _cantidad);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: const Text('Agregar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/qr_scanner_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/integration/feature_integration_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/navigation_state.dart';
import '../../../almacenes/domain/entities/almacen.dart';
import '../../../almacenes/presentation/bloc/almacen_bloc.dart';
import '../../../almacenes/presentation/bloc/almacen_event.dart';
import '../../../almacenes/presentation/bloc/almacen_state.dart';
import '../../../categorias/domain/entities/categoria.dart';
import '../../../categorias/presentation/bloc/categoria_bloc.dart';
import '../../../categorias/presentation/bloc/categoria_event.dart';
import '../../../categorias/presentation/bloc/categoria_state.dart';
import '../../domain/entities/producto.dart';
import '../bloc/producto_bloc.dart';
import '../bloc/producto_event.dart';
import '../bloc/producto_state.dart';
import '../widgets/producto_card.dart';
import 'producto_form_screen.dart';
import 'qr_scanner_screen.dart';

class ProductosListScreen extends StatefulWidget {
  const ProductosListScreen({super.key});

  @override
  State<ProductosListScreen> createState() => _ProductosListScreenState();
}

class _ProductosListScreenState extends State<ProductosListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final QRScannerService _qrScannerService = QRScannerService();

  List<Almacen> _almacenes = [];
  List<Categoria> _categorias = [];
  int? _selectedAlmacenId;
  int? _selectedCategoriaId;
  double? _minPrice;
  double? _maxPrice;
  bool _showFilters = false;
  
  late NavigationState _navigationState;

  @override
  void initState() {
    super.initState();
    _navigationState = sl<NavigationState>();
    _navigationState.addListener(_onNavigationStateChanged);
    _loadInitialData();
    _handlePendingArguments();
  }

  @override
  void dispose() {
    _navigationState.removeListener(_onNavigationStateChanged);
    _searchController.dispose();
    _qrScannerService.dispose();
    super.dispose();
  }

  void _onNavigationStateChanged() {
    // Handle navigation state changes if needed
    _handlePendingArguments();
  }

  void _handlePendingArguments() {
    final args = FeatureIntegrationService.getPendingArguments();
    if (args != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processPendingArguments(args);
        FeatureIntegrationService.clearPendingArguments();
      });
    }
  }

  void _processPendingArguments(Map<String, dynamic> args) {
    final action = args['action'] as String?;
    
    switch (action) {
      case 'searchByQR':
        final qrCode = args['qrCode'] as String?;
        if (qrCode != null) {
          context.read<ProductoBloc>().add(SearchProductoByQR(qrCode));
        }
        break;
        
      case 'search':
        final searchTerm = args['searchTerm'] as String?;
        final qrCode = args['qrCode'] as String?;
        final almacenId = args['almacenId'] as int?;
        final categoriaId = args['categoriaId'] as int?;
        
        if (searchTerm != null) {
          _searchController.text = searchTerm;
        }
        
        setState(() {
          if (almacenId != null) _selectedAlmacenId = almacenId;
          if (categoriaId != null) _selectedCategoriaId = categoriaId;
        });
        
        if (qrCode != null) {
          context.read<ProductoBloc>().add(SearchProductoByQR(qrCode));
        } else {
          _performSearch();
        }
        break;
        
      case 'filterByAlmacen':
        final almacenId = args['almacenId'] as int?;
        final almacenNombre = args['almacenNombre'] as String?;
        
        if (almacenId != null) {
          setState(() {
            _selectedAlmacenId = almacenId;
            _showFilters = true;
          });
          _performSearch();
          
          if (almacenNombre != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mostrando productos de: $almacenNombre'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
        break;
        
      case 'filterByCategoria':
        final categoriaId = args['categoriaId'] as int?;
        final categoriaNombre = args['categoriaNombre'] as String?;
        
        if (categoriaId != null) {
          setState(() {
            _selectedCategoriaId = categoriaId;
            _showFilters = true;
          });
          _performSearch();
          
          if (categoriaNombre != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mostrando productos de categoría: $categoriaNombre'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
        break;
    }
  }

  void _loadInitialData() {
    context.read<ProductoBloc>().add(LoadAllProductos());
    context.read<AlmacenBloc>().add(LoadAlmacenes());
    context.read<CategoriaBloc>().add(LoadCategorias());
  }

  void _performSearch() {
    final searchTerm = _searchController.text.trim();

    if (searchTerm.isEmpty &&
        _selectedAlmacenId == null &&
        _selectedCategoriaId == null &&
        _minPrice == null &&
        _maxPrice == null) {
      context.read<ProductoBloc>().add(LoadAllProductos());
    } else if (searchTerm.isNotEmpty &&
        _selectedAlmacenId == null &&
        _selectedCategoriaId == null &&
        _minPrice == null &&
        _maxPrice == null) {
      context.read<ProductoBloc>().add(SearchProductosByName(searchTerm));
    } else {
      context.read<ProductoBloc>().add(SearchProductosWithFilters(
            searchTerm: searchTerm.isEmpty ? null : searchTerm,
            almacenId: _selectedAlmacenId,
            categoriaId: _selectedCategoriaId,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
          ));
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedAlmacenId = null;
      _selectedCategoriaId = null;
      _minPrice = null;
      _maxPrice = null;
    });
    context.read<ProductoBloc>().add(LoadAllProductos());
  }

  Future<void> _scanQR() async {
    try {
      final hasPermission = await _qrScannerService.hasCameraPermission();
      if (!hasPermission) {
        final granted = await _qrScannerService.requestCameraPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Se requiere permiso de cámara para escanear códigos QR'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        final result = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (context) => const QRScannerScreen(),
          ),
        );

        if (result != null && result.isNotEmpty) {
          context.read<ProductoBloc>().add(SearchProductoByQR(result));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al acceder a la cámara: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToProductForm([Producto? producto]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(producto: producto),
      ),
    );

    if (result == true) {
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQR,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch();
                  }
                });
              },
            ),
          ),

          // Filters section
          if (_showFilters) _buildFiltersSection(),

          // Products list
          Expanded(
            child: MultiBlocListener(
              listeners: [
                BlocListener<AlmacenBloc, AlmacenState>(
                  listener: (context, state) {
                    if (state is AlmacenesLoaded) {
                      setState(() {
                        _almacenes = state.almacenes;
                      });
                    }
                  },
                ),
                BlocListener<CategoriaBloc, CategoriaState>(
                  listener: (context, state) {
                    if (state is CategoriasLoaded) {
                      setState(() {
                        _categorias = state.categorias;
                      });
                    }
                  },
                ),
              ],
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
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadInitialData,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  List<Producto> productos = [];
                  String? searchInfo;

                  if (state is ProductoLoaded) {
                    productos = state.productos;
                  } else if (state is ProductoSearchResults) {
                    productos = state.productos;
                    searchInfo = 'Resultados para: "${state.searchTerm}"';
                  } else if (state is ProductoFilteredResults) {
                    productos = state.productos;
                    searchInfo = _buildFilterInfo(state);
                  } else if (state is ProductoQRResult) {
                    if (state.producto != null) {
                      productos = [state.producto!];
                      searchInfo =
                          'Producto encontrado por QR: ${state.codigoQR}';
                    } else {
                      searchInfo =
                          'No se encontró producto con QR: ${state.codigoQR}';
                    }
                  }

                  if (productos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchInfo ?? 'No hay productos registrados',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega tu primer producto usando el botón +',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (searchInfo != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Text(
                            searchInfo,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final producto = productos[index];
                            return ProductoCard(
                              producto: producto,
                              almacenNombre:
                                  _getAlmacenNombre(producto.almacenId),
                              categoriaNombre:
                                  _getCategoriaNombre(producto.categoriaId),
                              onTap: () => _navigateToProductForm(producto),
                              onDelete: () => _showDeleteDialog(producto),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToProductForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Filters in a responsive layout
          Column(
            children: [
              // First row: Almacén and Categoría
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _almacenes.any((a) => a.id == _selectedAlmacenId) ? _selectedAlmacenId : null,
                      decoration: const InputDecoration(
                        labelText: 'Almacén',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ..._almacenes.map((almacen) => DropdownMenuItem<int>(
                              value: almacen.id,
                              child: Text(
                                almacen.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAlmacenId = value;
                        });
                        _performSearch();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _categorias.any((c) => c.id == _selectedCategoriaId) ? _selectedCategoriaId : null,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ..._categorias.map((categoria) => DropdownMenuItem<int>(
                              value: categoria.id,
                              child: Text(
                                categoria.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoriaId = value;
                        });
                        _performSearch();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Second row: Price filters
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Precio mín.',
                        isDense: true,
                        prefixText: '\$ ',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _minPrice = double.tryParse(value);
                        });
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _performSearch();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Precio máx.',
                        isDense: true,
                        prefixText: '\$ ',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = double.tryParse(value);
                        });
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _performSearch();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildFilterInfo(ProductoFilteredResults state) {
    final filters = <String>[];

    if (state.searchTerm?.isNotEmpty == true) {
      filters.add('texto: "${state.searchTerm}"');
    }

    if (state.almacenId != null) {
      final almacen = _almacenes.firstWhere(
        (a) => a.id == state.almacenId,
        orElse: () => Almacen(
          nombre: 'Desconocido',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
      );
      filters.add('almacén: ${almacen.nombre}');
    }

    if (state.categoriaId != null) {
      final categoria = _categorias.firstWhere(
        (c) => c.id == state.categoriaId,
        orElse: () => Categoria(
          nombre: 'Desconocida',
          fechaCreacion: DateTime.now(),
        ),
      );
      filters.add('categoría: ${categoria.nombre}');
    }

    if (state.minPrice != null) {
      filters.add('precio mín: ${Formatters.formatPriceSync(state.minPrice!)}');
    }

    if (state.maxPrice != null) {
      filters.add('precio máx: ${Formatters.formatPriceSync(state.maxPrice!)}');
    }

    return 'Filtros aplicados: ${filters.join(', ')}';
  }

  String _getAlmacenNombre(int almacenId) {
    final almacen = _almacenes.firstWhere(
      (a) => a.id == almacenId,
      orElse: () => Almacen(
        nombre: 'Desconocido',
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      ),
    );
    return almacen.nombre;
  }

  String _getCategoriaNombre(int categoriaId) {
    final categoria = _categorias.firstWhere(
      (c) => c.id == categoriaId,
      orElse: () => Categoria(
        nombre: 'Desconocida',
        fechaCreacion: DateTime.now(),
      ),
    );
    return categoria.nombre;
  }

  void _showDeleteDialog(Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${producto.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProductoBloc>().add(DeleteProducto(producto.id!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto eliminado'),
                ),
              );
              _performSearch();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

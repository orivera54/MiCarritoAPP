import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/qr_scanner_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/volume_utils.dart';
import '../../../../core/integration/feature_integration_service.dart';
import '../../../almacenes/domain/entities/almacen.dart';
import '../../../almacenes/presentation/bloc/almacen_bloc.dart';
import '../../../almacenes/presentation/bloc/almacen_event.dart';
import '../../../almacenes/presentation/bloc/almacen_state.dart';
import '../../../categorias/domain/entities/categoria.dart';
import '../../../categorias/presentation/bloc/categoria_bloc.dart';
import '../../../categorias/presentation/bloc/categoria_event.dart';
import '../../../categorias/presentation/bloc/categoria_state.dart';
import '../../domain/entities/producto.dart';
import '../../domain/entities/almacen_precio.dart';
import '../bloc/producto_bloc.dart';
import '../bloc/producto_event.dart';
import '../bloc/producto_state.dart';
import '../widgets/almacen_precio_selector.dart';
import 'qr_scanner_screen.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({
    super.key,
    this.producto,
  });

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _pesoController = TextEditingController();
  final _volumenController = TextEditingController();
  final _tamanoController = TextEditingController();
  final _codigoQRController = TextEditingController();
  final QRScannerService _qrScannerService = QRScannerService();

  List<Almacen> _almacenes = [];
  List<Categoria> _categorias = [];
  List<AlmacenPrecio> _almacenPrecios = [];
  int? _selectedCategoriaId;
  bool _isLoading = false;

  bool get _isEditing => widget.producto != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initializeForm();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _pesoController.dispose();
    _volumenController.dispose();
    _tamanoController.dispose();
    _codigoQRController.dispose();
    _qrScannerService.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    context.read<AlmacenBloc>().add(LoadAlmacenes());
    context.read<CategoriaBloc>().add(LoadCategorias());
    
    // Si estamos editando, cargar productos relacionados
    if (_isEditing) {
      _loadRelatedProducts();
    }
  }

  void _loadRelatedProducts() {
    final producto = widget.producto!;
    context.read<ProductoBloc>().add(SearchProductosByName(producto.nombre));
  }

  void _loadRelatedProductsFromSearch(List<Producto> productos) {
    if (_almacenes.isEmpty) {
      // Si los almacenes aún no se han cargado, esperar
      return;
    }

    // Crear mapa de almacenes para lookup rápido
    final almacenesMap = {for (var almacen in _almacenes) almacen.id!: almacen};
    
    // Crear lista de AlmacenPrecio basada en los productos encontrados
    final Map<int, AlmacenPrecio> almacenPreciosMap = {};
    
    // Inicializar todos los almacenes como no seleccionados
    for (var almacen in _almacenes) {
      almacenPreciosMap[almacen.id!] = AlmacenPrecio(
        almacenId: almacen.id!,
        almacenNombre: almacen.nombre,
        almacenDireccion: almacen.direccion,
        precio: null,
        isSelected: false,
      );
    }
    
    // Actualizar con los productos existentes
    for (var producto in productos) {
      if (almacenesMap.containsKey(producto.almacenId)) {
        almacenPreciosMap[producto.almacenId] = AlmacenPrecio(
          almacenId: producto.almacenId,
          almacenNombre: almacenesMap[producto.almacenId]!.nombre,
          almacenDireccion: almacenesMap[producto.almacenId]!.direccion,
          precio: producto.precio,
          isSelected: true,
        );
      }
    }
    
    setState(() {
      _almacenPrecios = almacenPreciosMap.values.toList();
    });
  }

  void _initializeForm() {
    if (_isEditing) {
      final producto = widget.producto!;
      _nombreController.text = producto.nombre;
      _precioController.text = producto.precio.toString();
      _pesoController.text = producto.peso?.toString() ?? '';
      _volumenController.text = producto.volumen?.toString() ?? '';
      _tamanoController.text = producto.tamano ?? '';
      _codigoQRController.text = producto.codigoQR ?? '';
      _selectedCategoriaId = producto.categoriaId;
      
      // Para edición, inicializar con el almacén y precio actual
      _almacenPrecios = [
        AlmacenPrecio(
          almacenId: producto.almacenId,
          almacenNombre: '', // Se actualizará cuando se carguen los almacenes
          precio: producto.precio,
          isSelected: true,
        ),
      ];
    }
  }

  Future<void> _navigateToCreateAlmacen() async {
    final result = await Navigator.of(context).pushNamed('/almacen-form');
    if (result == true) {
      // Reload almacenes after creating a new one
      context.read<AlmacenBloc>().add(LoadAlmacenes());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Almacén creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _navigateToComparador() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el nombre del producto para comparar precios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create a temporary product object for comparison
    final tempProducto = Producto(
      id: null,
      nombre: _nombreController.text.trim(),
      precio: 0.0, // Temporary price
      categoriaId: 1, // Temporary category
      almacenId: 1, // Temporary almacen
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );

    // Use the feature integration service to compare prices
    await FeatureIntegrationService.compareProductPrices(tempProducto);
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
          setState(() {
            _codigoQRController.text = result;
          });
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

  void _saveProducto() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedAlmacenes = _almacenPrecios.where((ap) => ap.isSelected).toList();
    
    if (selectedAlmacenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un almacén'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!selectedAlmacenes.every((ap) => ap.hasValidPrice)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los almacenes seleccionados deben tener un precio válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    
    if (_isEditing) {
      // Para edición, actualizar/crear productos según la selección
      _updateProductosMultiAlmacen(now, selectedAlmacenes);
    } else {
      // Para creación, creamos un producto por cada almacén seleccionado
      _createProductosMultiAlmacen(now, selectedAlmacenes);
    }
  }

  void _updateProductosMultiAlmacen(DateTime now, List<AlmacenPrecio> selectedAlmacenes) async {
    if (!mounted) return;
    
    final originalProducto = widget.producto!;
    
    try {
      // Actualizar el producto original si su almacén está seleccionado
      final originalAlmacenPrecio = selectedAlmacenes.firstWhere(
        (ap) => ap.almacenId == originalProducto.almacenId,
        orElse: () => const AlmacenPrecio(
          almacenId: -1,
          almacenNombre: '',
          isSelected: false,
        ),
      );
      
      if (originalAlmacenPrecio.isSelected) {
        // Actualizar el producto original
        final updatedProducto = Producto(
          id: originalProducto.id,
          nombre: _nombreController.text.trim(),
          precio: originalAlmacenPrecio.precio!,
          peso: _pesoController.text.isNotEmpty
              ? double.tryParse(_pesoController.text)
              : null,
          volumen: _volumenController.text.isNotEmpty
              ? VolumeUtils.parseVolume(_volumenController.text)
              : null,
          tamano: _tamanoController.text.trim().isNotEmpty
              ? _tamanoController.text.trim()
              : null,
          codigoQR: _codigoQRController.text.trim().isNotEmpty
              ? _codigoQRController.text.trim()
              : null,
          categoriaId: _selectedCategoriaId!,
          almacenId: originalProducto.almacenId,
          fechaCreacion: originalProducto.fechaCreacion,
          fechaActualizacion: now,
        );
        
        if (mounted) {
          context.read<ProductoBloc>().add(UpdateProducto(updatedProducto));
        }
      }
      
      // Crear productos para almacenes nuevos
      final newAlmacenes = selectedAlmacenes.where(
        (ap) => ap.almacenId != originalProducto.almacenId,
      ).toList();
      
      for (AlmacenPrecio almacenPrecio in newAlmacenes) {
        if (!mounted) break;
        
        final producto = Producto(
          id: null,
          nombre: _nombreController.text.trim(),
          precio: almacenPrecio.precio!,
          peso: _pesoController.text.isNotEmpty
              ? double.tryParse(_pesoController.text)
              : null,
          volumen: _volumenController.text.isNotEmpty
              ? VolumeUtils.parseVolume(_volumenController.text)
              : null,
          tamano: _tamanoController.text.trim().isNotEmpty
              ? _tamanoController.text.trim()
              : null,
          codigoQR: _codigoQRController.text.trim().isNotEmpty
              ? _codigoQRController.text.trim()
              : null,
          categoriaId: _selectedCategoriaId!,
          almacenId: almacenPrecio.almacenId,
          fechaCreacion: now,
          fechaActualizacion: now,
        );
        
        context.read<ProductoBloc>().add(CreateProducto(producto));
      }
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto actualizado en ${selectedAlmacenes.length} almacén(es)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar productos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _createProductosMultiAlmacen(DateTime now, List<AlmacenPrecio> selectedAlmacenes) async {
    if (!mounted) return;
    
    final totalCount = selectedAlmacenes.length;
    
    try {
      for (AlmacenPrecio almacenPrecio in selectedAlmacenes) {
        if (!mounted) break;
        
        final producto = Producto(
          id: null,
          nombre: _nombreController.text.trim(),
          precio: almacenPrecio.precio!,
          peso: _pesoController.text.isNotEmpty
              ? double.tryParse(_pesoController.text)
              : null,
          volumen: _volumenController.text.isNotEmpty
              ? VolumeUtils.parseVolume(_volumenController.text)
              : null,
          tamano: _tamanoController.text.trim().isNotEmpty
              ? _tamanoController.text.trim()
              : null,
          codigoQR: _codigoQRController.text.trim().isNotEmpty
              ? _codigoQRController.text.trim()
              : null,
          categoriaId: _selectedCategoriaId!,
          almacenId: almacenPrecio.almacenId,
          fechaCreacion: now,
          fechaActualizacion: now,
        );
        
        // Crear el producto
        context.read<ProductoBloc>().add(CreateProducto(producto));
      }
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto creado en $totalCount almacén(es) con precios específicos'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear productos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveProducto,
              child: Text(
                _isEditing ? 'Guardar' : 'Crear',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AlmacenBloc, AlmacenState>(
            listener: (context, state) {
              if (state is AlmacenesLoaded) {
                setState(() {
                  _almacenes = state.almacenes;
                });
                
                // Si estamos editando y ya tenemos productos relacionados, actualizar
                if (_isEditing && _almacenPrecios.isNotEmpty) {
                  // Recargar productos relacionados ahora que tenemos los almacenes
                  _loadRelatedProducts();
                }
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
          BlocListener<ProductoBloc, ProductoState>(
            listener: (context, state) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });

                if (state is ProductoCreated) {
                  // No mostrar mensaje individual para creación múltiple
                  // El mensaje se muestra en los métodos _createProductosMultiAlmacen/_updateProductosMultiAlmacen
                } else if (state is ProductoUpdated) {
                  // No mostrar mensaje individual para actualización múltiple
                  // El mensaje se muestra en los métodos _createProductosMultiAlmacen/_updateProductosMultiAlmacen
                } else if (state is ProductoSearchResults && _isEditing) {
                  // Cargar productos relacionados para edición
                  try {
                    _loadRelatedProductsFromSearch(state.productos);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cargar productos relacionados: ${e.toString()}'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } else if (state is ProductoError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nombre
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del producto *',
                          hintText: 'Ej: Leche entera 1L',
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validateProductName,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _navigateToComparador,
                      icon: const Icon(Icons.compare_arrows),
                      tooltip: 'Comparar precios',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Almacenes y precios
                AlmacenPrecioSelector(
                  almacenes: _almacenes,
                  almacenPrecios: _almacenPrecios,
                  onAlmacenPreciosChanged: (almacenPrecios) {
                    setState(() {
                      _almacenPrecios = almacenPrecios;
                    });
                  },
                  onCreateAlmacen: _navigateToCreateAlmacen,
                ),

                const SizedBox(height: 16),

                // Categoría
                DropdownButtonFormField<int>(
                  value: _selectedCategoriaId,
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categorias
                      .map((categoria) => DropdownMenuItem<int>(
                            value: categoria.id,
                            child: Text(categoria.nombre),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoriaId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una categoría';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Peso (opcional)
                TextFormField(
                  controller: _pesoController,
                  decoration: const InputDecoration(
                    labelText: 'Peso (opcional)',
                    hintText: '1.5',
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,3}')),
                  ],
                  validator: (value) {
                    if (value?.isNotEmpty == true) {
                      final peso = double.tryParse(value!);
                      if (peso == null || peso <= 0) {
                        return 'Ingresa un peso válido';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Volumen (opcional)
                TextFormField(
                  controller: _volumenController,
                  decoration: InputDecoration(
                    labelText: 'Volumen (opcional)',
                    hintText: '500ml, 1.5L, etc.',
                    border: const OutlineInputBorder(),
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (String value) {
                        _volumenController.text = value;
                      },
                      itemBuilder: (BuildContext context) {
                        return VolumeUtils.getVolumeSuggestions()
                            .map((String value) {
                          return PopupMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  validator: VolumeUtils.validateVolumeInput,
                  onChanged: (value) {
                    // Formatear automáticamente mientras el usuario escribe
                    if (value.isNotEmpty) {
                      final parsed = VolumeUtils.parseVolume(value);
                      if (parsed != null) {
                        // Opcional: mostrar el valor parseado en algún lugar
                      }
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Tamaño (opcional)
                TextFormField(
                  controller: _tamanoController,
                  decoration: const InputDecoration(
                    labelText: 'Tamaño (opcional)',
                    hintText: 'Ej: 1L, 500ml, Grande',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Código QR (opcional)
                TextFormField(
                  controller: _codigoQRController,
                  decoration: InputDecoration(
                    labelText: 'Código QR (opcional)',
                    hintText: 'Escanea o ingresa manualmente',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanQR,
                      tooltip: 'Escanear QR',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Info text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Los campos marcados con * son obligatorios',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.store_mall_directory,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isEditing 
                                ? 'Puedes ver y editar los precios del producto en diferentes almacenes'
                                : 'Puedes seleccionar múltiples almacenes y especificar un precio diferente para cada uno',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.local_drink,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'El volumen es útil para productos líquidos. Puedes usar ml, L, etc. (ej: 500ml, 1.5L)',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save button (for mobile)
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProducto,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditing ? 'Guardar Cambios' : 'Crear Producto',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

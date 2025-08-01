import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/integration/feature_integration_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/navigation_state.dart';
import '../../../productos/presentation/bloc/producto_bloc.dart';
import '../../../productos/presentation/bloc/producto_event.dart';
import '../../../almacenes/domain/entities/almacen.dart';
import '../../../almacenes/presentation/bloc/almacen_bloc.dart';
import '../../../almacenes/presentation/bloc/almacen_event.dart';
import '../../../almacenes/presentation/bloc/almacen_state.dart';
import '../bloc/calculadora_bloc.dart';
import '../bloc/calculadora_event.dart';
import '../bloc/calculadora_state.dart';
import '../widgets/calculadora_item_card.dart';
import '../widgets/calculadora_total_card.dart';
import '../widgets/agregar_producto_dialog.dart';
import '../widgets/guardar_lista_dialog.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  late NavigationState _navigationState;
  List<Almacen> _almacenes = [];
  int? _selectedAlmacenId;
  String? _selectedAlmacenNombre;

  @override
  void initState() {
    super.initState();
    _navigationState = sl<NavigationState>();
    _navigationState.addListener(_onNavigationStateChanged);
    context.read<CalculadoraBloc>().add(CargarListaActual());
    context.read<AlmacenBloc>().add(LoadAlmacenes());
    _handlePendingArguments();
  }

  @override
  void dispose() {
    _navigationState.removeListener(_onNavigationStateChanged);
    super.dispose();
  }

  void _onNavigationStateChanged() {
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
      case 'addProduct':
        final product = args['product'];
        final source = args['source'] as String?;
        
        if (product != null) {
          // Add product to calculadora with default quantity of 1
          context.read<CalculadoraBloc>().add(
            AgregarProducto(
              producto: product,
              cantidad: 1,
              almacenId: _selectedAlmacenId,
            ),
          );
          
          // Show feedback message
          final sourceName = source == 'comparador' ? 'comparador' : 'productos';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto agregado desde $sourceName: ${product.nombre}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
        
      case 'addProductByQR':
        final qrCode = args['qrCode'] as String?;
        
        if (qrCode != null) {
          // Search for product by QR and add it if found
          context.read<ProductoBloc>().add(SearchProductoByQR(qrCode));
          
          // Listen for the result and add to calculadora
          _listenForQRProductResult(qrCode);
        }
        break;
    }
  }

  void _listenForQRProductResult(String qrCode) {
    // This would ideally be handled through a proper stream subscription
    // For now, we'll show a message that the QR search was initiated
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buscando producto con QR: $qrCode'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Compras'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'limpiar':
                  _showLimpiarDialog();
                  break;
                case 'guardar':
                  _showGuardarDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'limpiar',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Limpiar lista'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'guardar',
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Guardar lista'),
                  ],
                ),
              ),
            ],
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
                  // Si no hay almacén seleccionado y hay almacenes disponibles, seleccionar el primero
                  if (_selectedAlmacenId == null && _almacenes.isNotEmpty) {
                    _selectedAlmacenId = _almacenes.first.id;
                    _selectedAlmacenNombre = _almacenes.first.nombre;
                  }
                });
              }
            },
          ),
          BlocListener<CalculadoraBloc, CalculadoraState>(
            listener: (context, state) {
              if (state is CalculadoraError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is CalculadoraListaGuardada) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lista guardada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
        child: Column(
          children: [
            // Selector de almacén
            if (_almacenes.isNotEmpty) _buildAlmacenSelector(),
            
            // Contenido principal
            Expanded(
              child: BlocBuilder<CalculadoraBloc, CalculadoraState>(
                builder: (context, state) {
                  if (state is CalculadoraLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is CalculadoraLoaded) {
                    final listaCompra = state.listaCompra;

                    if (listaCompra.items.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: listaCompra.items.length,
                            itemBuilder: (context, index) {
                              final item = listaCompra.items[index];
                              return CalculadoraItemCard(
                                item: item,
                                onCantidadChanged: (nuevaCantidad) {
                                  context.read<CalculadoraBloc>().add(
                                        ModificarCantidad(
                                          productoId: item.productoId,
                                          nuevaCantidad: nuevaCantidad,
                                        ),
                                      );
                                },
                                onEliminar: () {
                                  context.read<CalculadoraBloc>().add(
                                        EliminarProducto(productoId: item.productoId),
                                      );
                                },
                              );
                            },
                          ),
                        ),
                        CalculadoraTotalCard(
                          total: listaCompra.total,
                          itemCount: listaCompra.items.length,
                          almacenNombre: _selectedAlmacenNombre,
                          onGuardar: _showGuardarDialog,
                        ),
                      ],
                    );
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarProductoDialog,
        tooltip: 'Agregar producto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tu lista está vacía',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar a calcular',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAgregarProductoDialog,
            icon: const Icon(Icons.add),
            label: const Text('Agregar producto'),
          ),
        ],
      ),
    );
  }

  void _showAgregarProductoDialog() {
    showDialog(
      context: context,
      builder: (context) => AgregarProductoDialog(
        almacenId: _selectedAlmacenId,
        almacenNombre: _selectedAlmacenNombre,
        onProductoSeleccionado: (producto, cantidad) {
          context.read<CalculadoraBloc>().add(
                AgregarProducto(
                  producto: producto,
                  cantidad: cantidad,
                  almacenId: _selectedAlmacenId,
                ),
              );
        },
      ),
    );
  }

  void _showGuardarDialog() {
    final state = context.read<CalculadoraBloc>().state;
    if (state is CalculadoraLoaded && state.listaCompra.items.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => GuardarListaDialog(
          onGuardar: (nombre) {
            context.read<CalculadoraBloc>().add(
                  GuardarLista(nombre: nombre),
                );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay productos en la lista para guardar'),
        ),
      );
    }
  }

  void _showLimpiarDialog() {
    final state = context.read<CalculadoraBloc>().state;
    if (state is CalculadoraLoaded && state.listaCompra.items.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limpiar lista'),
          content:
              const Text('¿Estás seguro de que quieres limpiar toda la lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CalculadoraBloc>().add(LimpiarLista());
              },
              child: const Text('Limpiar'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAlmacenSelector() {
    return Container(
      width: double.infinity,
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
          Text(
            'Calculadora por almacén',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedAlmacenId,
            decoration: const InputDecoration(
              labelText: 'Seleccionar almacén',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _almacenes.map((almacen) => DropdownMenuItem<int>(
              value: almacen.id,
              child: Text(
                almacen.nombre,
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                final almacen = _almacenes.firstWhere((a) => a.id == value);
                setState(() {
                  _selectedAlmacenId = value;
                  _selectedAlmacenNombre = almacen.nombre;
                });
                
                // Mostrar mensaje de cambio de almacén
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Calculadora cambiada a: ${almacen.nombre}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Los productos se calcularán para este almacén específico',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

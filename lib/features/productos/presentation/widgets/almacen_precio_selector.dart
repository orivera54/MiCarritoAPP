import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../almacenes/domain/entities/almacen.dart';
import '../../domain/entities/almacen_precio.dart';

class AlmacenPrecioSelector extends StatefulWidget {
  final List<Almacen> almacenes;
  final List<AlmacenPrecio> almacenPrecios;
  final ValueChanged<List<AlmacenPrecio>> onAlmacenPreciosChanged;
  final VoidCallback? onCreateAlmacen;

  const AlmacenPrecioSelector({
    super.key,
    required this.almacenes,
    required this.almacenPrecios,
    required this.onAlmacenPreciosChanged,
    this.onCreateAlmacen,
  });

  @override
  State<AlmacenPrecioSelector> createState() => _AlmacenPrecioSelectorState();
}

class _AlmacenPrecioSelectorState extends State<AlmacenPrecioSelector> {
  late List<AlmacenPrecio> _almacenPrecios;
  final Map<int, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeAlmacenPrecios();
  }

  @override
  void didUpdateWidget(AlmacenPrecioSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.almacenes != widget.almacenes) {
      _initializeAlmacenPrecios();
    }
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAlmacenPrecios() {
    try {
      // Crear mapa de almacenes existentes para lookup rápido
      final existingMap = {
        for (var ap in widget.almacenPrecios) ap.almacenId: ap
      };

      _almacenPrecios = widget.almacenes.where((almacen) => almacen.id != null).map((almacen) {
        final existing = existingMap[almacen.id];
        final almacenPrecio = AlmacenPrecio(
          almacenId: almacen.id!,
          almacenNombre: almacen.nombre,
          almacenDireccion: almacen.direccion,
          precio: existing?.precio,
          isSelected: existing?.isSelected ?? false,
        );

        // Inicializar controller si no existe
        if (!_priceControllers.containsKey(almacen.id)) {
          _priceControllers[almacen.id!] = TextEditingController();
        }

        // Actualizar el texto del controller de forma segura
        final controller = _priceControllers[almacen.id!];
        if (controller != null) {
          if (almacenPrecio.precio != null) {
            controller.text = almacenPrecio.precio.toString();
          } else {
            controller.clear();
          }
        }

        return almacenPrecio;
      }).toList();
    } catch (e) {
      // En caso de error, inicializar lista vacía y mostrar error en debug
      _almacenPrecios = [];
      debugPrint('Error inicializando almacen precios: $e');
    }
  }

  void _toggleAlmacen(int almacenId, bool isSelected) {
    try {
      setState(() {
        _almacenPrecios = _almacenPrecios.map((ap) {
          if (ap.almacenId == almacenId) {
            return ap.copyWith(isSelected: isSelected);
          }
          return ap;
        }).toList();
      });
      _notifyChanges();
    } catch (e) {
      debugPrint('Error toggling almacen $almacenId: $e');
    }
  }

  void _updatePrice(int almacenId, String priceText) {
    try {
      final price = double.tryParse(priceText);
      setState(() {
        _almacenPrecios = _almacenPrecios.map((ap) {
          if (ap.almacenId == almacenId) {
            return ap.copyWith(
              precio: price,
              clearPrecio: priceText.isEmpty,
            );
          }
          return ap;
        }).toList();
      });
      _notifyChanges();
    } catch (e) {
      debugPrint('Error updating price for almacen $almacenId: $e');
    }
  }

  void _notifyChanges() {
    try {
      widget.onAlmacenPreciosChanged(_almacenPrecios);
    } catch (e) {
      debugPrint('Error notifying changes: $e');
    }
  }

  List<AlmacenPrecio> get _selectedAlmacenes {
    return _almacenPrecios.where((ap) => ap.isSelected).toList();
  }

  bool get _hasValidSelection {
    final selected = _selectedAlmacenes;
    return selected.isNotEmpty && selected.every((ap) => ap.hasValidPrice);
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si hay errores en los datos
    if (_almacenPrecios.isEmpty && widget.almacenes.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.error),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Error al cargar almacenes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _initializeAlmacenPrecios();
                });
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Almacenes y precios *',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (widget.onCreateAlmacen != null)
              IconButton(
                onPressed: widget.onCreateAlmacen,
                icon: const Icon(Icons.add_business),
                tooltip: 'Crear nuevo almacén',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _hasValidSelection 
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.error,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: widget.almacenes.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay almacenes disponibles'),
                )
              : Column(
                  children: _almacenPrecios.map((almacenPrecio) {
                    return _buildAlmacenPrecioTile(almacenPrecio);
                  }).toList(),
                ),
        ),
        const SizedBox(height: 8),
        if (_selectedAlmacenes.isEmpty)
          Text(
            'Selecciona al menos un almacén y especifica su precio',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          )
        else if (!_hasValidSelection)
          Text(
            'Todos los almacenes seleccionados deben tener un precio válido',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          )
        else
          Text(
            '${_selectedAlmacenes.length} almacén(es) seleccionado(s) con precios válidos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildAlmacenPrecioTile(AlmacenPrecio almacenPrecio) {
    final controller = _priceControllers[almacenPrecio.almacenId];
    
    if (controller == null) {
      // Crear controller si no existe
      _priceControllers[almacenPrecio.almacenId] = TextEditingController();
      final newController = _priceControllers[almacenPrecio.almacenId]!;
      if (almacenPrecio.precio != null) {
        newController.text = almacenPrecio.precio.toString();
      }
      return _buildAlmacenPrecioTileContent(almacenPrecio, newController);
    }
    
    return _buildAlmacenPrecioTileContent(almacenPrecio, controller);
  }

  Widget _buildAlmacenPrecioTileContent(AlmacenPrecio almacenPrecio, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: almacenPrecio.isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: almacenPrecio.isSelected,
              onChanged: (bool? value) {
                _toggleAlmacen(almacenPrecio.almacenId, value ?? false);
              },
            ),
            
            // Información del almacén
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    almacenPrecio.almacenNombre,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: almacenPrecio.isSelected 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                    ),
                  ),
                  if (almacenPrecio.almacenDireccion != null)
                    Text(
                      almacenPrecio.almacenDireccion!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Campo de precio
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: controller,
                enabled: almacenPrecio.isSelected,
                decoration: InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  errorText: almacenPrecio.isSelected && !almacenPrecio.hasValidPrice
                    ? 'Requerido'
                    : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  _updatePrice(almacenPrecio.almacenId, value);
                },
                style: TextStyle(
                  color: almacenPrecio.isSelected 
                    ? null 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
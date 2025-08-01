import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/item_calculadora.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/price_text.dart';

class CalculadoraItemCard extends StatefulWidget {
  final ItemCalculadora item;
  final Function(int) onCantidadChanged;
  final VoidCallback onEliminar;

  const CalculadoraItemCard({
    super.key,
    required this.item,
    required this.onCantidadChanged,
    required this.onEliminar,
  });

  @override
  State<CalculadoraItemCard> createState() => _CalculadoraItemCardState();
}

class _CalculadoraItemCardState extends State<CalculadoraItemCard> {
  late TextEditingController _cantidadController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _cantidadController = TextEditingController(
      text: widget.item.cantidad.toString(),
    );
  }

  @override
  void didUpdateWidget(CalculadoraItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.cantidad != widget.item.cantidad && !_isEditing) {
      _cantidadController.text = widget.item.cantidad.toString();
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.item.producto;
    
    if (producto == null) {
      return Card(
        child: ListTile(
          title: const Text('Producto no encontrado'),
          subtitle: Text('ID: ${widget.item.productoId}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onEliminar,
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      PriceBuilder(
                        price: producto.precio,
                        builder: (formattedPrice) => Text(
                          'Precio unitario: $formattedPrice',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      // Mostrar información del mejor precio si está disponible
                      if (widget.item.mejorPrecio != null && 
                          widget.item.mejorPrecio!.precio < producto.precio) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: PriceBuilder(
                                  price: widget.item.mejorPrecio!.precio,
                                  builder: (mejorPrecioFormatted) => Text(
                                    'Mejor precio en ${widget.item.mejorPrecio!.almacen.nombre}: $mejorPrecioFormatted',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.green[700],
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (producto.peso != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Peso: ${Formatters.formatWeight(producto.peso!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      if (producto.tamano != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Tamaño: ${producto.tamano}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onEliminar,
                  tooltip: 'Eliminar producto',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Cantidad controls
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.item.cantidad > 1
                          ? () => _updateCantidad(widget.item.cantidad - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                    ),
                    SizedBox(
                      width: 60,
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
                        onTap: () {
                          _isEditing = true;
                          _cantidadController.selectAll();
                        },
                        onSubmitted: (value) {
                          _isEditing = false;
                          _updateCantidadFromText(value);
                        },
                        onEditingComplete: () {
                          _isEditing = false;
                          _updateCantidadFromText(_cantidadController.text);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () => _updateCantidad(widget.item.cantidad + 1),
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                    ),
                  ],
                ),
                const Spacer(),
                // Subtotal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Subtotal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    PriceText(
                      price: widget.item.subtotal,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateCantidad(int nuevaCantidad) {
    if (nuevaCantidad > 0 && nuevaCantidad != widget.item.cantidad) {
      _cantidadController.text = nuevaCantidad.toString();
      widget.onCantidadChanged(nuevaCantidad);
    }
  }

  void _updateCantidadFromText(String text) {
    final cantidad = int.tryParse(text);
    if (cantidad != null && cantidad > 0) {
      _updateCantidad(cantidad);
    } else {
      // Reset to current value if invalid
      _cantidadController.text = widget.item.cantidad.toString();
    }
  }
}

extension on TextEditingController {
  void selectAll() {
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }
}
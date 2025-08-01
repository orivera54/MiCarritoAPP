import 'package:flutter/material.dart';
import '../../../almacenes/domain/entities/almacen.dart';

class MultiAlmacenSelector extends StatefulWidget {
  final List<Almacen> almacenes;
  final List<int> selectedAlmacenIds;
  final ValueChanged<List<int>> onSelectionChanged;
  final VoidCallback? onCreateAlmacen;

  const MultiAlmacenSelector({
    super.key,
    required this.almacenes,
    required this.selectedAlmacenIds,
    required this.onSelectionChanged,
    this.onCreateAlmacen,
  });

  @override
  State<MultiAlmacenSelector> createState() => _MultiAlmacenSelectorState();
}

class _MultiAlmacenSelectorState extends State<MultiAlmacenSelector> {
  void _toggleAlmacen(int almacenId) {
    final newSelection = List<int>.from(widget.selectedAlmacenIds);
    
    if (newSelection.contains(almacenId)) {
      newSelection.remove(almacenId);
    } else {
      newSelection.add(almacenId);
    }
    
    widget.onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Almacenes donde está disponible *',
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
              color: widget.selectedAlmacenIds.isEmpty 
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: widget.almacenes.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay almacenes disponibles'),
                )
              : Column(
                  children: widget.almacenes.map((almacen) {
                    final isSelected = widget.selectedAlmacenIds.contains(almacen.id);
                    return CheckboxListTile(
                      title: Text(almacen.nombre),
                      subtitle: almacen.direccion != null 
                        ? Text(almacen.direccion!)
                        : null,
                      value: isSelected,
                      onChanged: (bool? value) {
                        if (almacen.id != null) {
                          _toggleAlmacen(almacen.id!);
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
        ),
        if (widget.selectedAlmacenIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Selecciona al menos un almacén',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (widget.selectedAlmacenIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              '${widget.selectedAlmacenIds.length} almacén(es) seleccionado(s)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
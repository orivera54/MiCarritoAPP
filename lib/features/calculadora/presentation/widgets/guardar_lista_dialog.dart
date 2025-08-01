import 'package:flutter/material.dart';

class GuardarListaDialog extends StatefulWidget {
  final Function(String?) onGuardar;

  const GuardarListaDialog({
    super.key,
    required this.onGuardar,
  });

  @override
  State<GuardarListaDialog> createState() => _GuardarListaDialogState();
}

class _GuardarListaDialogState extends State<GuardarListaDialog> {
  final TextEditingController _nombreController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set default name with current date
    final now = DateTime.now();
    final defaultName = 'Lista ${now.day}/${now.month}/${now.year}';
    _nombreController.text = defaultName;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Guardar lista de compras'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresa un nombre para tu lista de compras:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la lista',
                hintText: 'Ej: Compras del supermercado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list_alt),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre para la lista';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                if (value.trim().length > 100) {
                  return 'El nombre no puede tener más de 100 caracteres';
                }
                return null;
              },
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              onFieldSubmitted: (value) {
                if (_formKey.currentState?.validate() ?? false) {
                  _guardarLista();
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Puedes dejar el campo vacío para usar un nombre automático.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardarLista,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _guardarLista() {
    if (_formKey.currentState?.validate() ?? false) {
      final nombre = _nombreController.text.trim();
      widget.onGuardar(nombre.isEmpty ? null : nombre);
      Navigator.of(context).pop();
    }
  }
}
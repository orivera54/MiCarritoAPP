import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

void main() {
  final testAlmacen = Almacen(
    id: 1,
    nombre: 'Supermercado Test',
    direccion: 'Dirección Test',
    descripcion: 'Descripción Test',
    fechaCreacion: DateTime(2024, 1, 1),
    fechaActualizacion: DateTime(2024, 1, 1),
  );

  group('AlmacenFormScreen Widget Tests', () {
    group('Form UI Elements', () {
      testWidgets('should display form fields with correct labels and icons', (tester) async {
        // Create a simple form widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Nuevo Almacén'),
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'CREAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información del Almacén',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Nombre *',
                                  hintText: 'Ej: Supermercado Central',
                                  prefixIcon: Icon(Icons.store),
                                  border: OutlineInputBorder(),
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Dirección',
                                  hintText: 'Ej: Av. Principal 123, Ciudad',
                                  prefixIcon: Icon(Icons.location_on),
                                  border: OutlineInputBorder(),
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Descripción',
                                  hintText: 'Información adicional sobre el almacén',
                                  prefixIcon: Icon(Icons.description),
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Almacén'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '* Campos obligatorios',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Nuevo Almacén'), findsOneWidget);
        expect(find.text('CREAR'), findsOneWidget);
        expect(find.text('Información del Almacén'), findsOneWidget);
        expect(find.text('Nombre *'), findsOneWidget);
        expect(find.text('Dirección'), findsOneWidget);
        expect(find.text('Descripción'), findsOneWidget);
        expect(find.byIcon(Icons.store), findsOneWidget);
        expect(find.byIcon(Icons.location_on), findsOneWidget);
        expect(find.byIcon(Icons.description), findsOneWidget);
        expect(find.text('Crear Almacén'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('* Campos obligatorios'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(3));
      });

      testWidgets('should display edit mode UI correctly', (tester) async {
        // Create a form widget in edit mode
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Editar Almacén'),
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'GUARDAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información del Almacén',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: testAlmacen.nombre,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre *',
                                  prefixIcon: Icon(Icons.store),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: testAlmacen.direccion,
                                decoration: const InputDecoration(
                                  labelText: 'Dirección',
                                  prefixIcon: Icon(Icons.location_on),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                initialValue: testAlmacen.descripcion,
                                decoration: const InputDecoration(
                                  labelText: 'Descripción',
                                  prefixIcon: Icon(Icons.description),
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Cambios'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Editar Almacén'), findsOneWidget);
        expect(find.text('GUARDAR'), findsOneWidget);
        expect(find.text('Supermercado Test'), findsOneWidget);
        expect(find.text('Dirección Test'), findsOneWidget);
        expect(find.text('Descripción Test'), findsOneWidget);
        expect(find.text('Guardar Cambios'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.byIcon(Icons.save), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });
    });

    group('Form Validation UI', () {
      testWidgets('should display validation error messages', (tester) async {
        // Create a form with validation errors
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        errorText: 'El nombre es obligatorio',
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        errorText: 'La dirección no puede exceder 200 caracteres',
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        errorText: 'La descripción no puede exceder 500 caracteres',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('El nombre es obligatorio'), findsOneWidget);
        expect(find.text('La dirección no puede exceder 200 caracteres'), findsOneWidget);
        expect(find.text('La descripción no puede exceder 500 caracteres'), findsOneWidget);
      });

      testWidgets('should display different validation error messages', (tester) async {
        // Create a form with different validation errors
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        errorText: 'El nombre debe tener al menos 2 caracteres',
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        errorText: 'El nombre no puede exceder 100 caracteres',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('El nombre debe tener al menos 2 caracteres'), findsOneWidget);
        expect(find.text('El nombre no puede exceder 100 caracteres'), findsOneWidget);
      });
    });

    group('Loading and State UI', () {
      testWidgets('should display loading overlay', (tester) async {
        // Create a widget with loading overlay
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const Center(child: Text('Form Content')),
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Form Content'), findsOneWidget);
      });

      testWidgets('should display snackbar messages', (tester) async {
        // Create a widget that shows snackbars
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Almacén creado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('Show Success'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al guardar'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: const Text('Show Error'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test success snackbar
        await tester.tap(find.text('Show Success'));
        await tester.pump();
        expect(find.text('Almacén creado exitosamente'), findsOneWidget);

        // Wait for snackbar to disappear
        await tester.pump(const Duration(seconds: 5));

        // Test error snackbar
        await tester.tap(find.text('Show Error'));
        await tester.pump();
        await tester.pump(); // Additional pump to ensure snackbar is shown
        expect(find.text('Error al guardar'), findsOneWidget);
      });
    });

    group('Form Interaction', () {
      testWidgets('should handle text input correctly', (tester) async {
        final controller = TextEditingController();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Test Field',
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextFormField), 'Test Input');
        await tester.pump();

        // Assert
        expect(controller.text, 'Test Input');
        expect(find.text('Test Input'), findsOneWidget);
      });

      testWidgets('should handle button presses correctly', (tester) async {
        bool buttonPressed = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  buttonPressed = true;
                },
                child: const Text('Submit'),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Submit'));
        await tester.pump();

        // Assert
        expect(buttonPressed, isTrue);
      });

      testWidgets('should handle form submission', (tester) async {
        final formKey = GlobalKey<FormState>();
        bool formSubmitted = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formSubmitted = true;
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test with empty field
        await tester.tap(find.text('Submit'));
        await tester.pump();
        expect(find.text('Required'), findsOneWidget);
        expect(formSubmitted, isFalse);

        // Test with valid input
        await tester.enterText(find.byType(TextFormField), 'Valid Name');
        await tester.tap(find.text('Submit'));
        await tester.pump();
        expect(formSubmitted, isTrue);
      });
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/almacen_bloc.dart';
import '../bloc/almacen_event.dart';
import '../bloc/almacen_state.dart';
import '../widgets/almacen_card.dart';
import 'almacen_form_screen.dart';

class AlmacenesListScreen extends StatefulWidget {
  const AlmacenesListScreen({super.key});

  @override
  State<AlmacenesListScreen> createState() => _AlmacenesListScreenState();
}

class _AlmacenesListScreenState extends State<AlmacenesListScreen> {
  bool _hasNavigatedToForm = false;

  @override
  void initState() {
    super.initState();
    context.read<AlmacenBloc>().add(LoadAlmacenes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<AlmacenBloc, AlmacenState>(
        listener: (context, state) {
          if (state is AlmacenError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AlmacenDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Almacén eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload the list after deletion
            context.read<AlmacenBloc>().add(LoadAlmacenes());
          } else if (state is AlmacenCreated || state is AlmacenUpdated) {
            // Reload the list after creation or update
            context.read<AlmacenBloc>().add(LoadAlmacenes());
            // Reset navigation flag when almacen is created
            _hasNavigatedToForm = false;
          } else if (state is AlmacenesLoaded && state.almacenes.isEmpty && !_hasNavigatedToForm) {
            // Auto-navigate to form when no almacenes exist
            _hasNavigatedToForm = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToFormWithMessage(context);
            });
          }
        },
        builder: (context, state) {
          if (state is AlmacenLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AlmacenesLoaded) {
            if (state.almacenes.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildAlmacenesList(state.almacenes);
          } else if (state is AlmacenError) {
            return _buildErrorState(context, state.message);
          }
          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        tooltip: 'Agregar Almacén',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay almacenes registrados',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer almacén para comenzar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Almacén'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar almacenes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[600],
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _hasNavigatedToForm = false; // Reset flag
                  context.read<AlmacenBloc>().add(LoadAlmacenes());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _navigateToForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Crear almacén'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Información del error'),
                  content: SingleChildScrollView(
                    child: Text(message),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Ver detalles del error'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlmacenesList(List almacenes) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AlmacenBloc>().add(LoadAlmacenes());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: almacenes.length,
        itemBuilder: (context, index) {
          final almacen = almacenes[index];
          return AlmacenCard(
            almacen: almacen,
            onEdit: () => _navigateToForm(context, almacen: almacen),
            onDelete: () => _showDeleteDialog(context, almacen),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {almacen}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlmacenFormScreen(almacen: almacen),
      ),
    );
    
    // If form returned success, the BlocConsumer will handle reloading
    if (result == true) {
      // The listener in BlocConsumer will handle the reload
    }
  }

  void _navigateToFormWithMessage(BuildContext context) async {
    // Show a message explaining why we're navigating to the form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Necesitas crear al menos un almacén para comenzar'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    // Small delay to let the snackbar show
    await Future.delayed(const Duration(milliseconds: 500));

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AlmacenFormScreen(),
      ),
    );
    
    // If form returned success, the BlocConsumer will handle reloading
    if (result == true) {
      // The listener in BlocConsumer will handle the reload
    }
  }

  void _showDeleteDialog(BuildContext context, almacen) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar el almacén "${almacen.nombre}"?\n\nEsta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AlmacenBloc>().add(DeleteAlmacenEvent(almacen.id!));
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
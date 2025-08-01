import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/integration/feature_integration_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/navigation_state.dart';
import '../../../../core/widgets/price_text.dart';
import '../bloc/comparador_bloc.dart';
import '../bloc/comparador_event.dart';
import '../bloc/comparador_state.dart';
import '../widgets/comparador_search_bar.dart';
import '../widgets/comparacion_table.dart';
import '../widgets/comparacion_empty_state.dart';
import '../widgets/almacenes_comparacion_widget.dart';

class ComparadorScreen extends StatefulWidget {
  const ComparadorScreen({super.key});

  @override
  State<ComparadorScreen> createState() => _ComparadorScreenState();
}

class _ComparadorScreenState extends State<ComparadorScreen> {
  final TextEditingController _searchController = TextEditingController();
  late NavigationState _navigationState;

  @override
  void initState() {
    super.initState();
    _navigationState = sl<NavigationState>();
    _navigationState.addListener(_onNavigationStateChanged);
    _handlePendingArguments();
  }

  @override
  void dispose() {
    _navigationState.removeListener(_onNavigationStateChanged);
    _searchController.dispose();
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
      case 'searchProduct':
        final searchTerm = args['searchTerm'] as String?;
        
        if (searchTerm != null) {
          _searchController.text = searchTerm;
          _onSearch(searchTerm);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Comparando precios para: $searchTerm'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<ComparadorBloc>().add(BuscarProductosSimilaresEvent(query.trim()));
    }
  }

  void _onQRScan(String qrCode) {
    context.read<ComparadorBloc>().add(BuscarProductosPorQREvent(qrCode));
  }

  void _clearResults() {
    _searchController.clear();
    context.read<ComparadorBloc>().add(const LimpiarResultadosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparador de Precios'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ComparadorSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onQRScan: _onQRScan,
              onClear: _clearResults,
            ),
          ),
          Expanded(
            child: BlocBuilder<ComparadorBloc, ComparadorState>(
              builder: (context, state) {
                return switch (state) {
                  ComparadorInitial() => const _InitialState(),
                  ComparadorLoading() => const _LoadingState(),
                  ComparadorLoaded() => _LoadedState(state: state),
                  ComparadorEmpty() => ComparacionEmptyState(
                      terminoBusqueda: state.terminoBusqueda,
                    ),
                  ComparadorError() => _ErrorState(message: state.message),
                  ComparadorAlmacenesLoading() => _AlmacenesLoadingState(
                      state: state,
                      searchController: _searchController,
                    ),
                  ComparadorAlmacenesLoaded() => _AlmacenesLoadedState(
                      state: state,
                      searchController: _searchController,
                    ),
                  ComparadorAlmacenesError() => _AlmacenesErrorState(
                      state: state,
                      searchController: _searchController,
                    ),
                  _ => const _InitialState(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialState extends StatelessWidget {
  const _InitialState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Busca un producto para comparar precios',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Puedes buscar por nombre o escanear un código QR',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Buscando productos...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _LoadedState extends StatelessWidget {
  final ComparadorLoaded state;

  const _LoadedState({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resultados para: "${state.terminoBusqueda}"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.productos.length} productos encontrados en ${state.cantidadAlmacenes} almacenes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (state.mejorPrecio != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children: [
                        Text(
                          'Mejor precio: ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        PriceText(
                          price: state.mejorPrecio!.producto.precio,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ComparacionTable(
            productos: state.productos,
            onProductSelected: (nombreProducto) {
              context.read<ComparadorBloc>().add(
                ObtenerAlmacenesProductoEvent(nombreProducto),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlmacenesLoadingState extends StatelessWidget {
  final ComparadorAlmacenesLoading state;
  final TextEditingController searchController;

  const _AlmacenesLoadingState({
    required this.state,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return AlmacenesComparacionWidget(
      almacenes: const [],
      nombreProducto: state.nombreProducto,
      isLoading: true,
      onBack: () {
        context.read<ComparadorBloc>().add(
          BuscarProductosSimilaresEvent(searchController.text),
        );
      },
    );
  }
}

class _AlmacenesLoadedState extends StatelessWidget {
  final ComparadorAlmacenesLoaded state;
  final TextEditingController searchController;

  const _AlmacenesLoadedState({
    required this.state,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return AlmacenesComparacionWidget(
      almacenes: state.almacenes,
      nombreProducto: state.nombreProducto,
      onBack: () {
        context.read<ComparadorBloc>().add(
          BuscarProductosSimilaresEvent(searchController.text),
        );
      },
    );
  }
}

class _AlmacenesErrorState extends StatelessWidget {
  final ComparadorAlmacenesError state;
  final TextEditingController searchController;

  const _AlmacenesErrorState({
    required this.state,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return AlmacenesComparacionWidget(
      almacenes: const [],
      nombreProducto: state.nombreProducto,
      error: state.message,
      onBack: () {
        context.read<ComparadorBloc>().add(
          BuscarProductosSimilaresEvent(searchController.text),
        );
      },
    );
  }
}
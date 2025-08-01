import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/navigation_state.dart';
import 'features/almacenes/presentation/pages/almacenes_list_screen.dart';
import 'features/productos/presentation/pages/productos_list_screen.dart';
import 'features/calculadora/presentation/pages/calculadora_screen.dart';
import 'features/comparador/presentation/pages/comparador_screen.dart';
import 'features/categorias/presentation/pages/categorias_list_screen.dart';
import 'features/configuracion/presentation/pages/configuracion_screen.dart';

class MainScreen extends StatefulWidget {
  final int? initialIndex;
  final Map<String, dynamic>? arguments;

  const MainScreen({
    super.key,
    this.initialIndex,
    this.arguments,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late NavigationState _navigationState;

  final List<Widget> _screens = [
    const AlmacenesListScreen(),
    const ProductosListScreen(),
    const CalculadoraScreen(),
    const ComparadorScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.store),
      label: 'Almacenes',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.inventory_2),
      label: 'Productos',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calculate),
      label: 'Calculadora',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.compare_arrows),
      label: 'Comparador',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navigationState = sl<NavigationState>();
    _currentIndex = widget.initialIndex ?? _navigationState.currentTabIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    // Listen to navigation state changes
    _navigationState.addListener(_onNavigationStateChanged);
    
    // Handle any arguments passed to the screen
    _handleArguments();
  }

  @override
  void dispose() {
    _navigationState.removeListener(_onNavigationStateChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationStateChanged() {
    final newIndex = _navigationState.currentTabIndex;
    if (newIndex != _currentIndex) {
      _navigateToTab(newIndex);
    }
  }

  void _handleArguments() {
    if (widget.arguments != null) {
      // Handle specific navigation arguments
      final args = widget.arguments!;
      
      if (args.containsKey('navigateToTab')) {
        final tabIndex = args['navigateToTab'] as int?;
        if (tabIndex != null && tabIndex >= 0 && tabIndex < _screens.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToTab(tabIndex);
          });
        }
      }
    }
  }

  void _navigateToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTabTapped(int index) {
    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();
    _navigateToTab(index);
    // Update navigation state
    _navigationState.setCurrentTab(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Update navigation state when page changes
    _navigationState.setCurrentTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'categorias':
                  _navigateToCategorias();
                  break;
                case 'configuracion':
                  _navigateToConfiguracion();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'categorias',
                child: ListTile(
                  leading: Icon(Icons.category),
                  title: Text('Categorías'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'configuracion',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configuración'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navigationItems,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Almacenes';
      case 1:
        return 'Productos';
      case 2:
        return 'Calculadora';
      case 3:
        return 'Comparador';
      default:
        return 'Supermercado Comparador';
    }
  }

  void _navigateToCategorias() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategoriasListScreen(),
      ),
    );
  }

  void _navigateToConfiguracion() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ConfiguracionScreen(),
      ),
    );
  }
}

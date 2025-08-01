import 'package:flutter/foundation.dart';

class NavigationState extends ChangeNotifier {
  int _currentTabIndex = 0;
  Map<String, dynamic> _navigationArguments = {};
  Map<String, dynamic> _pendingArguments = {};

  int get currentTabIndex => _currentTabIndex;
  Map<String, dynamic> get navigationArguments => _navigationArguments;
  Map<String, dynamic> get pendingArguments => _pendingArguments;

  void setCurrentTab(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  void setNavigationArguments(Map<String, dynamic> arguments) {
    _navigationArguments = arguments;
    notifyListeners();
  }

  void clearNavigationArguments() {
    _navigationArguments.clear();
    notifyListeners();
  }

  void setPendingArguments(Map<String, dynamic> arguments) {
    _pendingArguments = arguments;
    notifyListeners();
  }

  void clearPendingArguments() {
    _pendingArguments.clear();
    notifyListeners();
  }

  // Specific navigation methods for features
  void navigateToAlmacenesTab() {
    setCurrentTab(0);
  }

  void navigateToProductosTab() {
    setCurrentTab(1);
  }

  void navigateToCalculadoraTab() {
    setCurrentTab(2);
  }

  void navigateToComparadorTab() {
    setCurrentTab(3);
  }

  // Alias methods for compatibility
  void navigateToAlmacenes() => navigateToAlmacenesTab();
  void navigateToProductos() => navigateToProductosTab();
  void navigateToCalculadora() => navigateToCalculadoraTab();
  void navigateToComparador() => navigateToComparadorTab();

  // Navigation with context
  void navigateToCalculadoraWithProduct(dynamic producto) {
    setNavigationArguments({'addProduct': producto});
    setCurrentTab(2);
  }

  void navigateToComparadorWithSearch(String searchTerm) {
    setNavigationArguments({'searchTerm': searchTerm});
    setCurrentTab(3);
  }

  void navigateToProductosWithQR(String qrCode) {
    setNavigationArguments({'qrCode': qrCode});
    setCurrentTab(1);
  }
}
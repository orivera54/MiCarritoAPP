import '../entities/producto.dart';
import '../repositories/producto_repository.dart';
import '../../../../core/errors/volume_exceptions.dart';

class ProductoUniquenessService {
  final ProductoRepository _repository;

  ProductoUniquenessService(this._repository);

  /// Verifica si un producto es único por nombre y almacén
  Future<bool> isProductoUnique(
    String nombre, 
    int almacenId, {
    int? excludeId,
  }) async {
    try {
      final existingProduct = await findExistingProducto(nombre, almacenId);
      
      if (existingProduct == null) {
        return true; // No existe, es único
      }
      
      // Si estamos excluyendo un ID (para edición), verificar si es el mismo producto
      if (excludeId != null && existingProduct.id == excludeId) {
        return true; // Es el mismo producto que estamos editando
      }
      
      return false; // Existe otro producto con el mismo nombre y almacén
    } catch (e) {
      // En caso de error, asumir que no es único para ser conservadores
      return false;
    }
  }

  /// Busca un producto existente por nombre y almacén
  Future<Producto?> findExistingProducto(String nombre, int almacenId) async {
    try {
      // Normalizar el nombre para la búsqueda
      final nombreNormalizado = nombre.trim().toLowerCase();
      
      // Buscar todos los productos del almacén
      final productosEnAlmacen = await _repository.getProductosByAlmacen(almacenId);
      
      // Buscar coincidencia exacta con nombre normalizado
      for (final producto in productosEnAlmacen) {
        if (producto.nombre.trim().toLowerCase() == nombreNormalizado) {
          return producto;
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('Error al buscar producto existente: $e');
    }
  }

  /// Valida la unicidad antes de crear o actualizar un producto
  Future<void> validateUniqueness(
    String nombre,
    int almacenId, {
    int? excludeId,
    String? almacenNombre,
  }) async {
    final isUnique = await isProductoUnique(nombre, almacenId, excludeId: excludeId);
    
    if (!isUnique) {
      final existingProduct = await findExistingProducto(nombre, almacenId);
      final almacenName = almacenNombre ?? 'Almacén ID: $almacenId';
      
      if (existingProduct != null) {
        throw DuplicateProductoException.withExistingProduct(
          nombre,
          almacenName,
          {
            'id': existingProduct.id,
            'precio': existingProduct.precio,
            'peso': existingProduct.peso,
            'volumen': existingProduct.volumen,
            'tamano': existingProduct.tamano,
            'fecha_actualizacion': existingProduct.fechaActualizacion.toIso8601String(),
          },
        );
      } else {
        throw DuplicateProductoException(nombre, almacenName);
      }
    }
  }

  /// Consolida productos duplicados manualmente
  Future<void> consolidateDuplicateProductos() async {
    try {
      // Obtener todos los productos
      final allProducts = await _repository.getAllProductos();
      
      // Agrupar por nombre normalizado + almacén
      final Map<String, List<Producto>> groups = {};
      
      for (final product in allProducts) {
        final key = '${product.nombre.trim().toLowerCase()}_${product.almacenId}';
        groups[key] ??= [];
        groups[key]!.add(product);
      }
      
      // Procesar grupos con duplicados
      for (final entry in groups.entries) {
        final products = entry.value;
        if (products.length > 1) {
          await _consolidateProductGroup(products);
        }
      }
    } catch (e) {
      throw ProductConsolidationException(
        'Error durante la consolidación de productos duplicados: $e',
        'consolidateDuplicateProductos',
      );
    }
  }

  /// Consolida un grupo de productos duplicados
  Future<void> _consolidateProductGroup(List<Producto> products) async {
    if (products.length <= 1) return;
    
    // Ordenar por fecha de actualización (más reciente primero)
    products.sort((a, b) => b.fechaActualizacion.compareTo(a.fechaActualizacion));
    
    final keepProduct = products.first;
    final removeProducts = products.skip(1).toList();
    
    print('Consolidando productos: manteniendo ${keepProduct.id}, '
          'eliminando ${removeProducts.map((p) => p.id).join(', ')}');
    
    // Eliminar productos duplicados
    for (final product in removeProducts) {
      if (product.id != null) {
        await _repository.deleteProducto(product.id!);
      }
    }
  }

  /// Obtiene información sobre productos duplicados
  Future<List<Map<String, dynamic>>> getDuplicateProductsInfo() async {
    try {
      final allProducts = await _repository.getAllProductos();
      final Map<String, List<Producto>> groups = {};
      
      // Agrupar productos
      for (final product in allProducts) {
        final key = '${product.nombre.trim().toLowerCase()}_${product.almacenId}';
        groups[key] ??= [];
        groups[key]!.add(product);
      }
      
      // Filtrar solo grupos con duplicados
      final duplicates = <Map<String, dynamic>>[];
      
      for (final entry in groups.entries) {
        final products = entry.value;
        if (products.length > 1) {
          duplicates.add({
            'key': entry.key,
            'count': products.length,
            'products': products.map((p) => {
              'id': p.id,
              'nombre': p.nombre,
              'precio': p.precio,
              'almacenId': p.almacenId,
              'fechaActualizacion': p.fechaActualizacion.toIso8601String(),
            }).toList(),
          });
        }
      }
      
      return duplicates;
    } catch (e) {
      throw Exception('Error al obtener información de duplicados: $e');
    }
  }

  /// Verifica si existen productos duplicados
  Future<bool> hasDuplicateProducts() async {
    final duplicates = await getDuplicateProductsInfo();
    return duplicates.isNotEmpty;
  }

  /// Obtiene sugerencias de nombres similares para evitar duplicados
  Future<List<String>> getSimilarProductNames(String nombre, int almacenId) async {
    try {
      final productosEnAlmacen = await _repository.getProductosByAlmacen(almacenId);
      final nombreNormalizado = nombre.trim().toLowerCase();
      
      final similares = <String>[];
      
      for (final producto in productosEnAlmacen) {
        final productoNombre = producto.nombre.trim().toLowerCase();
        
        // Buscar nombres que contengan parte del nombre buscado
        if (productoNombre.contains(nombreNormalizado) || 
            nombreNormalizado.contains(productoNombre)) {
          if (productoNombre != nombreNormalizado) {
            similares.add(producto.nombre);
          }
        }
      }
      
      return similares.take(5).toList(); // Limitar a 5 sugerencias
    } catch (e) {
      return []; // En caso de error, devolver lista vacía
    }
  }
}
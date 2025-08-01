# Design Document

## Overview

Este diseño implementa un sistema donde los productos pueden existir en múltiples almacenes con precios diferentes, mejora el comparador para mostrar todos los almacenes disponibles para un producto, y agrega branding a la pantalla de splash.

## Architecture

### 1. Modelo de Datos Multi-Almacén

El modelo actual ya soporta productos por almacén, pero necesitamos ajustar la lógica de negocio para permitir productos duplicados (mismo nombre/características) en diferentes almacenes.

### 2. Comparador Mejorado

Se creará un nuevo widget para mostrar la lista de almacenes con precios, incluyendo indicadores visuales para los mejores precios.

### 3. Splash Screen con Branding

Se agregará el texto "by Agios Studio" a la pantalla de splash existente.

## Components and Interfaces

### 1. ProductoComparacionAlmacen Entity

```dart
class ProductoComparacionAlmacen {
  final int almacenId;
  final String almacenNombre;
  final double precio;
  final bool esMejorPrecio;
  final Producto producto;
}
```

### 2. AlmacenesComparacionWidget

Nuevo widget para mostrar la lista de almacenes con precios:

```dart
class AlmacenesComparacionWidget extends StatelessWidget {
  final List<ProductoComparacionAlmacen> almacenes;
  final String nombreProducto;
}
```

### 3. Servicios Actualizados

- **ComparadorService**: Método para obtener todos los almacenes de un producto
- **MejorPrecioService**: Actualizado para considerar múltiples almacenes

## Data Models

### ProductoComparacionAlmacen

```dart
class ProductoComparacionAlmacen extends Equatable {
  final int almacenId;
  final String almacenNombre;
  final double precio;
  final bool esMejorPrecio;
  final Producto producto;

  const ProductoComparacionAlmacen({
    required this.almacenId,
    required this.almacenNombre,
    required this.precio,
    required this.esMejorPrecio,
    required this.producto,
  });

  @override
  List<Object?> get props => [almacenId, almacenNombre, precio, esMejorPrecio, producto];
}
```

## Error Handling

### 1. Productos No Encontrados
- Mostrar mensaje cuando no hay productos en ningún almacén
- Manejar casos donde el producto existe pero no tiene precios

### 2. Errores de Base de Datos
- Manejo de errores al consultar múltiples almacenes
- Fallback cuando no se pueden cargar los datos

### 3. Estados de Carga
- Loading states para la carga de almacenes
- Skeleton loading para mejor UX

## Testing Strategy

### 1. Unit Tests
- Tests para ProductoComparacionAlmacen entity
- Tests para servicios actualizados (ComparadorService, MejorPrecioService)
- Tests para lógica de identificación de mejores precios

### 2. Widget Tests
- Tests para AlmacenesComparacionWidget
- Tests para splash screen actualizada
- Tests para indicadores visuales de mejor precio

### 3. Integration Tests
- Tests end-to-end para flujo de comparación
- Tests para compatibilidad con funcionalidades existentes
- Tests para productos multi-almacén

## Implementation Details

### 1. Base de Datos

No se requieren cambios en la estructura de la base de datos, ya que el modelo actual ya soporta productos por almacén.

### 2. Lógica de Negocio

#### Identificación de Productos Similares
```dart
// Buscar productos con el mismo nombre en diferentes almacenes
List<Producto> productosEnAlmacenes = await repository.searchProductosByName(nombreProducto);

// Agrupar por almacén y identificar mejores precios
Map<int, ProductoComparacionAlmacen> almacenesMap = {};
double precioMinimo = double.infinity;

for (Producto producto in productosEnAlmacenes) {
  if (producto.precio < precioMinimo) {
    precioMinimo = producto.precio;
  }
  almacenesMap[producto.almacenId] = ProductoComparacionAlmacen(...);
}

// Marcar mejores precios
for (var almacen in almacenesMap.values) {
  almacen.esMejorPrecio = (almacen.precio == precioMinimo);
}
```

### 3. UI Components

#### Indicador de Mejor Precio
```dart
Widget _buildPrecioIndicator(ProductoComparacionAlmacen almacen) {
  return Container(
    decoration: BoxDecoration(
      color: almacen.esMejorPrecio ? Colors.green.withOpacity(0.1) : null,
      borderRadius: BorderRadius.circular(8),
      border: almacen.esMejorPrecio ? Border.all(color: Colors.green) : null,
    ),
    child: Row(
      children: [
        if (almacen.esMejorPrecio) Icon(Icons.star, color: Colors.green),
        Text('\$${almacen.precio.toStringAsFixed(2)}'),
      ],
    ),
  );
}
```

#### Splash Screen Actualizada
```dart
// Agregar al final del Column existente en splash_screen.dart
Text(
  'by Agios Studio',
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
    fontWeight: FontWeight.w300,
  ),
),
```

### 4. Servicios

#### ComparadorService Actualizado
```dart
Future<List<ProductoComparacionAlmacen>> obtenerAlmacenesProducto(String nombreProducto) async {
  final productos = await _productoRepository.searchProductosByName(nombreProducto);
  final almacenes = await _almacenRepository.getAllAlmacenes();
  
  // Crear mapa de almacenes para lookup rápido
  final almacenesMap = {for (var a in almacenes) a.id!: a};
  
  // Encontrar precio mínimo
  final precioMinimo = productos.map((p) => p.precio).reduce(math.min);
  
  // Crear lista de comparación
  return productos.map((producto) {
    final almacen = almacenesMap[producto.almacenId]!;
    return ProductoComparacionAlmacen(
      almacenId: producto.almacenId,
      almacenNombre: almacen.nombre,
      precio: producto.precio,
      esMejorPrecio: producto.precio == precioMinimo,
      producto: producto,
    );
  }).toList()..sort((a, b) => a.precio.compareTo(b.precio));
}
```

## Performance Considerations

### 1. Caching
- Cache de resultados de comparación para evitar consultas repetidas
- Cache de almacenes para lookup rápido

### 2. Optimización de Consultas
- Usar joins para obtener datos de producto y almacén en una sola consulta
- Indexar por nombre de producto para búsquedas rápidas

### 3. UI Performance
- Lazy loading para listas grandes de almacenes
- Debouncing para búsquedas en tiempo real

## Migration Strategy

### 1. Backward Compatibility
- Mantener APIs existentes funcionando
- Migración gradual de componentes

### 2. Data Migration
- No se requiere migración de datos
- Verificar integridad de datos existentes

### 3. Feature Flags
- Implementar feature flags para rollout gradual
- Permitir rollback rápido si es necesario
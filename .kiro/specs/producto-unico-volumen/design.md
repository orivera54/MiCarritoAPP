# Design Document

## Overview

Este diseño aborda la implementación de unicidad de productos por almacén y la adición del campo de volumen. La solución incluye modificaciones en la entidad Producto, validaciones de unicidad, y mejoras en la interfaz de usuario para manejar productos líquidos.

## Architecture

### Database Schema Changes

```sql
-- Modificar tabla productos para agregar volumen
ALTER TABLE productos ADD COLUMN volumen REAL;

-- Crear índice único compuesto para garantizar unicidad
CREATE UNIQUE INDEX idx_producto_almacen_unique 
ON productos(LOWER(TRIM(nombre)), almacen_id);
```

### Entity Updates

La entidad `Producto` se extenderá para incluir:
- Campo `volumen` (double?, nullable)
- Validaciones de unicidad
- Métodos de comparación por volumen

## Components and Interfaces

### 1. Enhanced Producto Entity

```dart
class Producto extends Equatable {
  final int? id;
  final String nombre;
  final double precio;
  final double? peso;
  final double? volumen; // Nuevo campo en ml
  final String? tamano;
  final String? codigoQR;
  final int categoriaId;
  final int almacenId;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  // Métodos adicionales
  double? get precioPorMl => volumen != null && volumen! > 0 ? precio / volumen! : null;
  String get volumenDisplay => volumen != null ? _formatVolumen(volumen!) : '';
}
```

### 2. Uniqueness Validation Service

```dart
class ProductoUniquenessService {
  Future<bool> isProductoUnique(String nombre, int almacenId, {int? excludeId});
  Future<Producto?> findExistingProducto(String nombre, int almacenId);
  Future<void> consolidateDuplicateProductos();
}
```

### 3. Volume Utilities

```dart
class VolumeUtils {
  static String formatVolume(double volumeInMl);
  static double? parseVolume(String input); // Convierte L, ml a ml
  static List<String> getVolumeSuggestions();
}
```

## Data Models

### Updated Producto Model

```dart
class ProductoModel extends Equatable {
  final int? id;
  final String nombre;
  final double precio;
  final double? peso;
  final double? volumen; // en ml
  final String? tamano;
  final String? codigoQR;
  final int categoriaId;
  final int almacenId;
  final String fechaCreacion;
  final String fechaActualizacion;

  // Conversión y validación
  factory ProductoModel.fromEntity(Producto producto);
  Producto toEntity();
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre.trim().toLowerCase(), // Normalizado para comparación
      'precio': precio,
      'peso': peso,
      'volumen': volumen,
      'tamano': tamano,
      'codigo_qr': codigoQR,
      'categoria_id': categoriaId,
      'almacen_id': almacenId,
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
    };
  }
}
```

### Database Migration

```dart
class DatabaseMigration {
  static Future<void> migrateToVersion2(Database db) async {
    // Agregar columna volumen
    await db.execute('ALTER TABLE productos ADD COLUMN volumen REAL');
    
    // Crear índice único (manejar conflictos existentes)
    await _consolidateExistingDuplicates(db);
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_producto_almacen_unique 
      ON productos(LOWER(TRIM(nombre)), almacen_id)
    ''');
  }
  
  static Future<void> _consolidateExistingDuplicates(Database db);
}
```

## Error Handling

### Uniqueness Violations

```dart
class DuplicateProductoException extends AppException {
  final String productName;
  final String almacenName;
  final Producto existingProduct;
  
  DuplicateProductoException(this.productName, this.almacenName, this.existingProduct)
    : super('Ya existe un producto "${productName}" en ${almacenName}');
}
```

### Volume Validation

```dart
class InvalidVolumeException extends ValidationException {
  InvalidVolumeException(String message) : super(message);
}
```

## Testing Strategy

### Unit Tests

1. **Producto Entity Tests**
   - Validación de volumen
   - Cálculo de precio por ml
   - Formateo de volumen

2. **Uniqueness Service Tests**
   - Detección de duplicados
   - Consolidación de productos
   - Validación de unicidad

3. **Volume Utils Tests**
   - Parsing de diferentes formatos
   - Conversión de unidades
   - Formateo de display

### Integration Tests

1. **Database Tests**
   - Migración de esquema
   - Índices únicos
   - Consolidación de duplicados

2. **Form Tests**
   - Validación en tiempo real
   - Manejo de duplicados
   - Entrada de volumen

### UI Tests

1. **Product Form Tests**
   - Campo de volumen
   - Validación de duplicados
   - Mensajes de error

2. **Product List Tests**
   - Display de volumen
   - Filtrado por volumen
   - Comparación de precios

## Implementation Approach

### Phase 1: Database and Entity Updates
1. Crear migración de base de datos
2. Actualizar entidad Producto
3. Implementar ProductoModel con volumen
4. Crear utilidades de volumen

### Phase 2: Uniqueness Implementation
1. Implementar ProductoUniquenessService
2. Actualizar repositorio con validaciones
3. Crear excepciones específicas
4. Implementar consolidación de duplicados

### Phase 3: UI Updates
1. Actualizar ProductoFormScreen con campo volumen
2. Implementar validación de duplicados en tiempo real
3. Mejorar mensajes de error y confirmación
4. Actualizar widgets de display de productos

### Phase 4: Testing and Validation
1. Ejecutar tests unitarios e integración
2. Validar migración de datos existentes
3. Probar escenarios de duplicados
4. Validar entrada y display de volumen

## Performance Considerations

### Database Optimization
- Índice único compuesto para búsquedas rápidas
- Normalización de nombres para comparación eficiente
- Paginación en consultas de productos

### Memory Management
- Lazy loading de productos relacionados
- Caché de validaciones de unicidad
- Optimización de queries de duplicados

## Security Considerations

### Data Validation
- Sanitización de nombres de productos
- Validación de rangos de volumen
- Prevención de inyección SQL en búsquedas

### Integrity Constraints
- Validación de integridad referencial
- Transacciones para operaciones de consolidación
- Rollback en caso de errores de migración
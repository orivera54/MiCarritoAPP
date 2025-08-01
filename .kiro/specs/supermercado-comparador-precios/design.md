# Design Document

## Overview

La aplicación será desarrollada en Flutter utilizando una arquitectura limpia (Clean Architecture) con separación clara de responsabilidades. Se utilizará SQLite como base de datos local para garantizar funcionamiento offline, y se implementará un patrón Repository para el acceso a datos. La interfaz seguirá Material Design 3 para una experiencia de usuario consistente y moderna.

## Architecture

### Arquitectura General
```
Presentation Layer (UI)
    ↓
Business Logic Layer (BLoC/Cubit)
    ↓
Data Layer (Repository Pattern)
    ↓
Local Database (SQLite)
```

### Estructura de Directorios
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── database/
├── features/
│   ├── almacenes/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── productos/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── calculadora/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── comparador/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
```

## Components and Interfaces

### Core Components

#### Database Manager
- **Responsabilidad**: Gestión de la base de datos SQLite
- **Tecnología**: sqflite package
- **Funciones principales**:
  - Inicialización de base de datos
  - Migración de esquemas
  - Operaciones CRUD base

#### QR Scanner Service
- **Responsabilidad**: Escaneo de códigos QR
- **Tecnología**: qr_code_scanner package
- **Funciones principales**:
  - Activación de cámara
  - Procesamiento de códigos QR
  - Validación de códigos

### Feature Components

#### Almacenes Feature
- **AlmacenRepository**: Interface para operaciones de almacenes
- **AlmacenLocalDataSource**: Implementación SQLite para almacenes
- **AlmacenBloc**: Gestión de estado para almacenes
- **AlmacenScreens**: Pantallas de lista, creación y edición

#### Productos Feature
- **ProductoRepository**: Interface para operaciones de productos
- **ProductoLocalDataSource**: Implementación SQLite para productos
- **ProductoBloc**: Gestión de estado para productos
- **ProductoScreens**: Pantallas de lista, búsqueda, creación y edición

#### Calculadora Feature
- **CalculadoraRepository**: Interface para listas de compras
- **CalculadoraBloc**: Gestión de estado para cálculos
- **CalculadoraScreen**: Pantalla principal de calculadora

#### Comparador Feature
- **ComparadorService**: Lógica de comparación de precios
- **ComparadorBloc**: Gestión de estado para comparaciones
- **ComparadorScreen**: Pantalla de comparación de precios

## Data Models

### Almacen Model
```dart
class Almacen {
  final int? id;
  final String nombre;
  final String? direccion;
  final String? descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
}
```

### Producto Model
```dart
class Producto {
  final int? id;
  final String nombre;
  final double precio;
  final double? peso;
  final String? tamano;
  final String? codigoQR;
  final String categoria;
  final int almacenId;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
}
```

### ItemCalculadora Model
```dart
class ItemCalculadora {
  final int? id;
  final int productoId;
  final Producto producto;
  final int cantidad;
  final double subtotal;
}
```

### ListaCompra Model
```dart
class ListaCompra {
  final int? id;
  final String? nombre;
  final List<ItemCalculadora> items;
  final double total;
  final DateTime fechaCreacion;
}
```

### Categoria Model
```dart
class Categoria {
  final int? id;
  final String nombre;
  final String? descripcion;
  final DateTime fechaCreacion;
}
```

## Database Schema

### Tablas SQLite

#### almacenes
```sql
CREATE TABLE almacenes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  direccion TEXT,
  descripcion TEXT,
  fecha_creacion TEXT NOT NULL,
  fecha_actualizacion TEXT NOT NULL
);
```

#### categorias
```sql
CREATE TABLE categorias (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL UNIQUE,
  descripcion TEXT,
  fecha_creacion TEXT NOT NULL
);
```

#### productos
```sql
CREATE TABLE productos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  precio REAL NOT NULL,
  peso REAL,
  tamano TEXT,
  codigo_qr TEXT,
  categoria_id INTEGER NOT NULL,
  almacen_id INTEGER NOT NULL,
  fecha_creacion TEXT NOT NULL,
  fecha_actualizacion TEXT NOT NULL,
  FOREIGN KEY (categoria_id) REFERENCES categorias (id),
  FOREIGN KEY (almacen_id) REFERENCES almacenes (id),
  UNIQUE(codigo_qr, almacen_id)
);
```

#### listas_compra
```sql
CREATE TABLE listas_compra (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT,
  total REAL NOT NULL,
  fecha_creacion TEXT NOT NULL
);
```

#### items_calculadora
```sql
CREATE TABLE items_calculadora (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lista_compra_id INTEGER NOT NULL,
  producto_id INTEGER NOT NULL,
  cantidad INTEGER NOT NULL,
  subtotal REAL NOT NULL,
  FOREIGN KEY (lista_compra_id) REFERENCES listas_compra (id),
  FOREIGN KEY (producto_id) REFERENCES productos (id)
);
```

## User Interface Design

### Navegación Principal
- **Bottom Navigation Bar** con 4 tabs:
  - Almacenes
  - Productos
  - Calculadora
  - Comparador

### Pantallas Principales

#### Pantalla de Almacenes
- Lista de almacenes con cards
- FloatingActionButton para agregar
- Opciones de editar/eliminar por almacén

#### Pantalla de Productos
- Barra de búsqueda en la parte superior
- Botón de escaneo QR
- Filtros por categoría y almacén
- Lista de productos con información resumida

#### Pantalla de Calculadora
- Lista de productos seleccionados
- Botón para agregar productos
- Campos de cantidad editables
- Total en la parte inferior
- Botón para guardar lista

#### Pantalla de Comparador
- Búsqueda de producto
- Tabla comparativa de precios
- Indicador visual del mejor precio

## Error Handling

### Estrategia de Manejo de Errores

#### Database Errors
- **DatabaseException**: Errores de SQLite
- **ValidationException**: Errores de validación de datos
- **NotFoundException**: Entidades no encontradas

#### QR Scanner Errors
- **CameraException**: Errores de acceso a cámara
- **QRFormatException**: Códigos QR inválidos
- **PermissionException**: Permisos de cámara denegados

#### User Feedback
- **SnackBars** para errores menores
- **Dialogs** para errores críticos
- **Loading indicators** durante operaciones

### Validaciones
- Validación de campos obligatorios
- Validación de formato de precios
- Validación de códigos QR únicos por almacén
- Validación de nombres de almacenes únicos

## Testing Strategy

### Unit Tests
- Modelos de datos y validaciones
- Repositories y data sources
- Business logic en BLoCs
- Servicios de utilidad

### Widget Tests
- Pantallas individuales
- Componentes reutilizables
- Formularios y validaciones
- Navegación entre pantallas

### Integration Tests
- Flujos completos de usuario
- Operaciones de base de datos
- Escaneo QR y búsqueda
- Calculadora de compras

### Test Coverage
- Objetivo: 80% de cobertura mínima
- Prioridad en lógica de negocio
- Casos edge y manejo de errores

## Performance Considerations

### Database Optimization
- Índices en campos de búsqueda frecuente
- Paginación para listas grandes
- Lazy loading de relaciones

### UI Performance
- ListView.builder para listas grandes
- Cached network images (si se implementan imágenes)
- Debouncing en búsquedas

### Memory Management
- Dispose de controllers y streams
- Optimización de imágenes
- Gestión eficiente de estado

## Security Considerations

### Data Protection
- Validación de entrada de datos
- Sanitización de códigos QR
- Protección contra inyección SQL

### Permissions
- Solicitud explícita de permisos de cámara
- Manejo graceful de permisos denegados
- Información clara sobre uso de permisos
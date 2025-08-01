# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-25

### Agregado
- ✅ Gestión completa de almacenes/supermercados
  - Crear, editar y eliminar almacenes
  - Validación de datos de almacenes
  - Interfaz intuitiva para gestión

- ✅ Catálogo de productos completo
  - Registro de productos con información detallada
  - Soporte para códigos QR únicos por almacén
  - Sistema de categorías con categoría "General" por defecto
  - Búsqueda por nombre de producto
  - Escaneo de códigos QR con cámara

- ✅ Comparador de precios inteligente
  - Comparación automática entre almacenes
  - Identificación visual del mejor precio
  - Algoritmo de matching de productos similares
  - Interfaz de tabla comparativa

- ✅ Calculadora de compras avanzada
  - Agregar productos con cantidades personalizables
  - Cálculo automático de subtotales y totales
  - Modificación de cantidades en tiempo real
  - Guardar listas de compras para referencia futura
  - Interfaz intuitiva con gestión de items

- ✅ Arquitectura robusta
  - Clean Architecture con separación de capas
  - Patrón Repository para acceso a datos
  - BLoC pattern para gestión de estado reactiva
  - Base de datos SQLite local optimizada

- ✅ Experiencia de usuario completa
  - Material Design 3 con interfaz moderna
  - Navegación principal con 4 secciones
  - Onboarding para configuración inicial
  - Splash screen con animaciones
  - Manejo robusto de errores con feedback visual

- ✅ Funcionalidad offline completa
  - Base de datos SQLite local
  - Sin dependencia de conexión a internet
  - Persistencia de datos garantizada
  - Rendimiento optimizado

### Técnico
- ✅ Testing comprehensivo
  - Tests unitarios para todos los componentes
  - Tests de widget para UI
  - Tests de integración para flujos completos
  - Cobertura de testing superior al 80%

- ✅ Configuración de producción
  - Build optimizado para release
  - Minificación y ofuscación de código
  - ProGuard rules configuradas
  - Permisos de Android configurados

- ✅ Documentación completa
  - Guía de usuario detallada
  - Guía de build y despliegue
  - README comprehensivo
  - Documentación técnica de arquitectura

### Dependencias
- Flutter SDK >=3.10.0
- Dart SDK >=3.0.0
- flutter_bloc ^8.1.3 - Gestión de estado
- sqflite ^2.3.0 - Base de datos local
- qr_code_scanner ^1.0.1 - Escaneo QR
- permission_handler ^11.0.1 - Permisos
- equatable ^2.0.5 - Comparación de objetos
- intl ^0.18.1 - Internacionalización
- get_it ^7.6.4 - Inyección de dependencias

### Configuración
- Permisos de cámara para Android configurados
- Configuración de build para release optimizada
- Estructura de proyecto siguiendo Clean Architecture
- Base de datos con esquema optimizado y migraciones

### Notas de Release
- Primera versión estable de la aplicación
- Funcionalidad core completa y probada
- Lista para distribución en tiendas de aplicaciones
- Soporte para Android API 21+

## [Unreleased]

### Planificado para futuras versiones
- Sincronización opcional en la nube
- Reportes y estadísticas de compras
- Sistema de etiquetas y favoritos
- Widgets de pantalla principal
- Soporte multi-idioma
- Modo oscuro
- Exportación de listas de compras
- Notificaciones de precios
- Integración con códigos de barras estándar
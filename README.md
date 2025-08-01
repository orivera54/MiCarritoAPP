# Supermercado Comparador de Precios

Una aplicación Flutter completa para comparar precios de productos entre diferentes supermercados y calcular el costo total de compras. Diseñada para funcionar completamente offline con una base de datos local SQLite.

## 🚀 Características Principales

- ✅ **Gestión de Almacenes**: Administra múltiples supermercados con información detallada
- ✅ **Catálogo de Productos**: Registro completo con precios, categorías y códigos QR
- ✅ **Búsqueda Inteligente**: Por nombre de producto o escaneo de código QR
- ✅ **Comparador de Precios**: Encuentra automáticamente el mejor precio entre almacenes
- ✅ **Calculadora de Compras**: Calcula totales en tiempo real con gestión de cantidades
- ✅ **Funcionamiento Offline**: Base de datos local SQLite, sin necesidad de internet
- ✅ **Interfaz Moderna**: Material Design 3 con navegación intuitiva
- ✅ **Arquitectura Limpia**: Código mantenible y escalable

## 🛠️ Tecnologías y Arquitectura

### Stack Tecnológico
- **Flutter** (>=3.10.0) - Framework de desarrollo
- **Dart** (>=3.0.0) - Lenguaje de programación
- **SQLite** (sqflite) - Base de datos local
- **BLoC Pattern** - Gestión de estado reactiva
- **QR Code Scanner** - Escaneo de códigos QR
- **Permission Handler** - Gestión de permisos

### Arquitectura
```
📁 Clean Architecture
├── 🎨 Presentation Layer (UI + BLoC)
├── 💼 Business Logic Layer (Use Cases)
├── 📊 Data Layer (Repository Pattern)
└── 🗄️ Local Database (SQLite)
```

### Estructura del Proyecto
```
lib/
├── core/                    # Componentes compartidos
│   ├── constants/          # Constantes de la aplicación
│   ├── database/           # Configuración de SQLite
│   ├── errors/             # Manejo de errores
│   └── utils/              # Utilidades y helpers
├── features/               # Características por dominio
│   ├── almacenes/         # Gestión de supermercados
│   ├── productos/         # Catálogo de productos
│   ├── calculadora/       # Calculadora de compras
│   └── comparador/        # Comparación de precios
└── main.dart              # Punto de entrada
```

## 📱 Capturas de Pantalla y Flujos

### Navegación Principal
- **Almacenes**: Lista y gestión de supermercados
- **Productos**: Catálogo con búsqueda y QR
- **Calculadora**: Lista de compras con totales
- **Comparador**: Comparación de precios

### Flujos Principales
1. **Configuración inicial** → Crear primer almacén
2. **Gestión de productos** → Agregar/editar con QR
3. **Comparación** → Buscar mejores precios
4. **Calculadora** → Planificar compras

## 🚀 Instalación y Configuración

### Requisitos Previos
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio o VS Code
- Dispositivo Android (API 21+) o emulador

### Instalación Rápida
```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd supermercado-comparador-precios

# 2. Instalar dependencias
flutter pub get

# 3. Generar iconos de aplicación
flutter pub run flutter_launcher_icons:main

# 4. Ejecutar en modo desarrollo
flutter run
```

### Configuración de Permisos
La aplicación requiere permisos de cámara para el escaneo QR:
- Android: Configurado automáticamente en `AndroidManifest.xml`
- El usuario debe otorgar permisos en tiempo de ejecución

## 🧪 Testing

### Ejecutar Tests
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Análisis de código
flutter analyze

# Cobertura de tests
flutter test --coverage
```

### Cobertura de Testing
- ✅ **Unit Tests**: Modelos, repositorios, BLoCs
- ✅ **Widget Tests**: Pantallas y componentes UI
- ✅ **Integration Tests**: Flujos completos de usuario
- 🎯 **Cobertura objetivo**: 80%+

## 📦 Build y Distribución

### Build de Desarrollo
```bash
flutter run                    # Modo debug
flutter build apk --debug     # APK debug
```

### Build de Producción
```bash
flutter build apk --release      # APK release
flutter build appbundle --release # App Bundle (Google Play)
```

### Optimizaciones de Release
- ✅ Minificación de código habilitada
- ✅ Reducción de recursos
- ✅ Ofuscación con ProGuard
- ✅ Compilación AOT para rendimiento

## 📚 Documentación

### Guías Disponibles
- 📖 [**Guía de Usuario**](docs/USER_GUIDE.md) - Manual completo para usuarios finales
- 🔧 [**Guía de Build**](docs/BUILD_GUIDE.md) - Instrucciones de construcción y despliegue

### Documentación Técnica
- **Arquitectura**: Clean Architecture con separación de capas
- **Base de Datos**: Esquema SQLite con relaciones optimizadas
- **Estado**: BLoC pattern para gestión reactiva
- **Testing**: Estrategia de testing multinivel

## 🔧 Desarrollo y Contribución

### Configuración de Desarrollo
```bash
# Instalar dependencias de desarrollo
flutter pub get

# Generar código (si es necesario)
flutter packages pub run build_runner build

# Ejecutar en modo debug
flutter run --debug
```

### Estándares de Código
- **Linting**: flutter_lints configurado
- **Formato**: `dart format .`
- **Análisis**: `flutter analyze`
- **Tests**: Obligatorios para nuevas características

## 🚀 Características Técnicas Avanzadas

### Base de Datos
- **SQLite local** con esquema optimizado
- **Migraciones** automáticas de base de datos
- **Índices** para búsquedas rápidas
- **Transacciones** para integridad de datos

### Rendimiento
- **Lazy loading** para listas grandes
- **Debouncing** en búsquedas
- **Paginación** automática
- **Optimización de memoria**

### Seguridad
- **Validación** de entrada de datos
- **Sanitización** de códigos QR
- **Manejo seguro** de permisos
- **Protección** contra inyección SQL

## 📋 Roadmap y Mejoras Futuras

### Versión Actual (1.0.0)
- ✅ Funcionalidad core completa
- ✅ Interfaz de usuario pulida
- ✅ Testing comprehensivo
- ✅ Documentación completa

### Mejoras Planificadas
- 🔄 Sincronización en la nube (opcional)
- 📊 Reportes y estadísticas
- 🏷️ Etiquetas y favoritos
- 📱 Widgets de pantalla principal
- 🌐 Soporte multi-idioma

## 🐛 Solución de Problemas

### Problemas Comunes
```bash
# Limpiar build cache
flutter clean && flutter pub get

# Problemas de Gradle
cd android && ./gradlew clean

# Reinstalar dependencias
flutter pub deps && flutter pub upgrade
```

### Soporte
- 📧 Reportar bugs a través de issues
- 💡 Sugerencias de mejoras bienvenidas
- 🤝 Contribuciones siguiendo estándares del proyecto

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👥 Créditos

Desarrollado Por Oscar Javier Rivera - Agios Studio 

---

**Versión**: 1.0.0  
**Última actualización**: Julio 2025  
**Compatibilidad**: Android API 21+
# Guía de Construcción y Despliegue

## Requisitos Previos

### Herramientas Necesarias
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio o VS Code
- Android SDK (API level 21+)
- Java JDK 8 o superior

### Verificación del Entorno
```bash
flutter doctor
```

## Configuración del Proyecto

### 1. Instalación de Dependencias
```bash
flutter pub get
```

### 2. Generación de Iconos de Aplicación
```bash
flutter pub run flutter_launcher_icons:main
```

### 3. Generación de Código (si es necesario)
```bash
flutter packages pub run build_runner build
```

## Construcción para Desarrollo

### Debug Build
```bash
flutter run
```

### Debug APK
```bash
flutter build apk --debug
```

## Construcción para Producción

### 1. Preparación para Release

#### Actualizar Versión
Edita `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Incrementa según sea necesario
```

#### Verificar Configuración de Android
Asegúrate de que `android/app/build.gradle` tenga la configuración correcta:
- `minSdkVersion 21`
- `targetSdkVersion` actualizado
- Configuración de signing para release

### 2. Build de Release

#### APK de Release
```bash
flutter build apk --release
```

#### App Bundle (Recomendado para Google Play)
```bash
flutter build appbundle --release
```

### 3. Ubicación de Archivos Generados

#### APK
```
build/app/outputs/flutter-apk/app-release.apk
```

#### App Bundle
```
build/app/outputs/bundle/release/app-release.aab
```

## Configuración de Firma (Producción)

### 1. Crear Keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configurar key.properties
Crea `android/key.properties`:
```properties
storePassword=<password del keystore>
keyPassword=<password de la key>
keyAlias=upload
storeFile=<ubicación del keystore>
```

### 3. Actualizar build.gradle
Descomenta y configura la sección `signingConfigs` en `android/app/build.gradle`.

## Testing

### Tests Unitarios
```bash
flutter test
```

### Tests de Integración
```bash
flutter test integration_test/
```

### Análisis de Código
```bash
flutter analyze
```

## Optimizaciones de Release

### 1. Reducción de Tamaño
- Habilitado `minifyEnabled true`
- Habilitado `shrinkResources true`
- Configurado ProGuard rules

### 2. Rendimiento
- Compilación AOT habilitada automáticamente en release
- Tree shaking para eliminar código no utilizado
- Compresión de assets

### 3. Seguridad
- Debugging deshabilitado en release
- Logs de desarrollo removidos
- Ofuscación de código habilitada

## Verificación Pre-Release

### Checklist de Release
- [ ] Todos los tests pasan
- [ ] Análisis de código sin errores críticos
- [ ] Versión actualizada en pubspec.yaml
- [ ] Iconos de aplicación generados
- [ ] Permisos de Android configurados correctamente
- [ ] Configuración de firma para release
- [ ] Testing manual en dispositivos físicos
- [ ] Verificación de funcionamiento offline
- [ ] Documentación actualizada

### Testing Manual
1. Instalar APK de release en dispositivo físico
2. Verificar todos los flujos principales:
   - Creación de almacenes
   - Gestión de productos
   - Escaneo QR (requiere permisos de cámara)
   - Calculadora de compras
   - Comparador de precios
3. Verificar funcionamiento sin conexión a internet
4. Probar en diferentes tamaños de pantalla

## Distribución

### Google Play Store
1. Crear cuenta de desarrollador en Google Play Console
2. Subir App Bundle (.aab)
3. Completar información de la aplicación
4. Configurar clasificación de contenido
5. Revisar y publicar

### Distribución Directa
1. Compartir APK directamente
2. Habilitar "Fuentes desconocidas" en dispositivos Android
3. Instalar manualmente

## Mantenimiento

### Actualizaciones
1. Incrementar número de versión
2. Actualizar changelog
3. Repetir proceso de build y testing
4. Distribuir nueva versión

### Monitoreo
- Revisar crashes reportados
- Monitorear feedback de usuarios
- Actualizar dependencias regularmente

## Solución de Problemas

### Errores Comunes

#### Build Fallido
```bash
flutter clean
flutter pub get
flutter build apk --release
```

#### Problemas de Dependencias
```bash
flutter pub deps
flutter pub upgrade
```

#### Errores de Gradle
```bash
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### Logs de Debug
```bash
flutter logs
```

### Análisis de APK
```bash
flutter build apk --analyze-size
```

## Recursos Adicionales

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)
- [Google Play Console](https://play.google.com/console)

---

**Nota**: Esta guía asume un entorno de desarrollo estándar. Ajusta los comandos según tu configuración específica.
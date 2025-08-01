# Guía de Usuario - Comparador de Precios de Supermercados

## Introducción

La aplicación Comparador de Precios de Supermercados te permite gestionar una base de datos local de productos de diferentes supermercados, facilitando la comparación de precios y el cálculo del costo total de tus compras.

## Características Principales

- ✅ Gestión de almacenes/supermercados
- ✅ Registro de productos con información detallada
- ✅ Búsqueda por nombre y escaneo de códigos QR
- ✅ Comparación de precios entre almacenes
- ✅ Calculadora de compras con totales automáticos
- ✅ Funcionamiento completamente offline

## Primeros Pasos

### 1. Configuración Inicial

Al abrir la aplicación por primera vez:

1. Se te pedirá crear tu primer almacén/supermercado
2. Ingresa el nombre, dirección (opcional) y descripción (opcional)
3. Guarda para continuar

### 2. Navegación Principal

La aplicación cuenta con 4 secciones principales accesibles desde la barra inferior:

- **Almacenes**: Gestiona tus supermercados
- **Productos**: Administra el catálogo de productos
- **Calculadora**: Calcula el costo total de tus compras
- **Comparador**: Compara precios entre almacenes

## Gestión de Almacenes

### Agregar un Almacén

1. Ve a la pestaña "Almacenes"
2. Toca el botón "+" (FloatingActionButton)
3. Completa la información:
   - **Nombre** (obligatorio): Ej. "Supermercado ABC"
   - **Dirección** (opcional): Ubicación del almacén
   - **Descripción** (opcional): Notas adicionales
4. Toca "Guardar"

### Editar o Eliminar Almacenes

1. En la lista de almacenes, toca el almacén que deseas modificar
2. Selecciona "Editar" para modificar la información
3. Selecciona "Eliminar" para remover el almacén (se pedirá confirmación)

## Gestión de Productos

### Agregar un Producto

1. Ve a la pestaña "Productos"
2. Toca el botón "+" para agregar un producto
3. Completa la información:
   - **Nombre** (obligatorio): Nombre del producto
   - **Precio** (obligatorio): Precio en moneda local
   - **Peso** (opcional): Peso del producto
   - **Tamaño** (opcional): Descripción del tamaño
   - **Código QR** (opcional): Escanea o ingresa manualmente
   - **Categoría**: Selecciona o crea una nueva categoría
   - **Almacén**: Selecciona el almacén correspondiente
4. Toca "Guardar"

### Buscar Productos

#### Búsqueda por Nombre
1. En la pestaña "Productos", usa la barra de búsqueda superior
2. Ingresa el nombre del producto
3. Los resultados se mostrarán automáticamente

#### Búsqueda por Código QR
1. Toca el ícono de QR en la barra de búsqueda
2. Permite el acceso a la cámara cuando se solicite
3. Apunta la cámara al código QR del producto
4. El producto se mostrará automáticamente si existe en la base de datos

### Filtrar Productos

- Usa los filtros por categoría y almacén para encontrar productos específicos
- Los filtros se pueden combinar para búsquedas más precisas

## Comparador de Precios

### Comparar un Producto

1. Ve a la pestaña "Comparador"
2. Busca el producto que deseas comparar
3. Selecciona el producto de la lista
4. Se mostrará una tabla comparativa con:
   - Precios en diferentes almacenes
   - El mejor precio destacado
   - Información adicional del producto

### Interpretar los Resultados

- El precio más bajo aparece destacado en verde
- Se muestran todos los almacenes donde está disponible el producto
- Si el producto no existe en otros almacenes, se mostrará un mensaje informativo

## Calculadora de Compras

### Crear una Lista de Compras

1. Ve a la pestaña "Calculadora"
2. Toca "Agregar Producto" para comenzar
3. Busca y selecciona productos de tu base de datos
4. Especifica la cantidad deseada para cada producto
5. El total se calcula automáticamente

### Gestionar la Lista

- **Modificar cantidades**: Toca el campo de cantidad y ajusta el valor
- **Eliminar productos**: Desliza el producto hacia la izquierda o usa el botón eliminar
- **Ver totales**: El subtotal y total se actualizan en tiempo real

### Guardar la Lista

1. Una vez completada tu lista, toca "Guardar Lista"
2. Opcionalmente, asigna un nombre a tu lista
3. La lista se guardará para referencia futura

## Gestión de Categorías

### Categoría por Defecto

- Todos los productos sin categoría específica se asignan a "General"
- Esta categoría se crea automáticamente al iniciar la aplicación

### Crear Nuevas Categorías

1. Al agregar o editar un producto, selecciona "Nueva Categoría"
2. Ingresa el nombre de la categoría
3. La categoría estará disponible para futuros productos

## Permisos y Configuración

### Permisos de Cámara

La aplicación requiere acceso a la cámara para:
- Escanear códigos QR de productos
- Buscar productos rápidamente

**Para habilitar el permiso:**
1. Ve a Configuración > Aplicaciones > Comparador de Precios
2. Selecciona "Permisos"
3. Activa el permiso de "Cámara"

### Funcionamiento Offline

- La aplicación funciona completamente sin conexión a internet
- Todos los datos se almacenan localmente en tu dispositivo
- No se requiere registro ni cuenta de usuario

## Solución de Problemas

### La cámara no funciona
- Verifica que los permisos de cámara estén habilitados
- Reinicia la aplicación
- Verifica que no haya otras aplicaciones usando la cámara

### Los productos no aparecen en la búsqueda
- Verifica que el producto esté registrado en la base de datos
- Revisa la ortografía del nombre del producto
- Intenta buscar por categoría o almacén

### Error al guardar datos
- Verifica que todos los campos obligatorios estén completos
- Asegúrate de que el código QR no esté duplicado en el mismo almacén
- Reinicia la aplicación si el problema persiste

### La aplicación se cierra inesperadamente
- Reinicia la aplicación
- Verifica que tengas suficiente espacio de almacenamiento
- Si el problema persiste, reinstala la aplicación

## Consejos de Uso

### Para Mejores Resultados

1. **Mantén la información actualizada**: Revisa y actualiza precios regularmente
2. **Usa categorías consistentes**: Esto facilita la búsqueda y organización
3. **Aprovecha los códigos QR**: Acelera la búsqueda y reduce errores
4. **Compara antes de comprar**: Usa el comparador para encontrar los mejores precios

### Organización Eficiente

- Crea almacenes para cada supermercado que visites frecuentemente
- Usa categorías descriptivas (Lácteos, Carnes, Limpieza, etc.)
- Mantén nombres de productos consistentes para facilitar comparaciones

## Soporte

Esta aplicación está diseñada para funcionar de manera autónoma. Todos los datos se almacenan localmente y no se requiere conexión a internet.

Para reportar problemas o sugerir mejoras, contacta al desarrollador a través de los canales oficiales de la aplicación.

---

**Versión de la Guía**: 1.0.0  
**Última Actualización**: Enero 2025
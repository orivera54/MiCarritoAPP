# Requirements Document

## Introduction

Esta especificación aborda dos problemas críticos en el sistema de gestión de productos: la duplicación de productos al editar y la necesidad de agregar un campo de volumen para productos líquidos. El objetivo es garantizar que cada producto sea único por almacén y proporcionar mejor categorización para productos líquidos.

## Requirements

### Requirement 1: Unicidad de Productos por Almacén

**User Story:** Como usuario del sistema, quiero que cada producto sea único por almacén, para que no se creen duplicados al editar productos existentes.

#### Acceptance Criteria

1. WHEN un usuario edita un producto existente THEN el sistema SHALL verificar si ya existe un producto con el mismo nombre en el mismo almacén
2. IF un producto con el mismo nombre ya existe en el almacén THEN el sistema SHALL actualizar el producto existente en lugar de crear uno nuevo
3. WHEN se actualiza un producto existente THEN el sistema SHALL mantener el ID original y actualizar solo los campos modificados
4. WHEN se guarda un producto THEN el sistema SHALL validar la unicidad usando la combinación de nombre + almacén
5. IF se intenta crear un producto duplicado THEN el sistema SHALL mostrar un mensaje de error claro al usuario

### Requirement 2: Campo de Volumen para Productos Líquidos

**User Story:** Como usuario que gestiona productos líquidos, quiero poder especificar el volumen del producto, para que pueda comparar precios por unidad de volumen correctamente.

#### Acceptance Criteria

1. WHEN un usuario crea o edita un producto THEN el sistema SHALL mostrar un campo opcional de volumen
2. WHEN se especifica un volumen THEN el sistema SHALL validar que sea un número positivo
3. WHEN se guarda un producto con volumen THEN el sistema SHALL almacenar el volumen en mililitros (ml) como unidad estándar
4. WHEN se muestra un producto con volumen THEN el sistema SHALL mostrar el volumen en formato legible (ej: 1L, 500ml)
5. WHEN se comparan productos con volumen THEN el sistema SHALL calcular el precio por ml para comparaciones
6. IF un producto tiene tanto peso como volumen THEN el sistema SHALL mostrar ambos campos
7. WHEN se buscan productos THEN el sistema SHALL permitir filtrar por rango de volumen

### Requirement 3: Validación de Integridad de Datos

**User Story:** Como administrador del sistema, quiero que se mantenga la integridad de los datos de productos, para que no haya inconsistencias en la base de datos.

#### Acceptance Criteria

1. WHEN se actualiza un producto THEN el sistema SHALL verificar que no se rompa la integridad referencial
2. WHEN se elimina un producto duplicado THEN el sistema SHALL actualizar todas las referencias en calculadora y comparador
3. WHEN se migran datos existentes THEN el sistema SHALL identificar y consolidar productos duplicados automáticamente
4. IF existen productos duplicados THEN el sistema SHALL mantener el producto más reciente y migrar los datos del más antiguo
5. WHEN se consolidan productos duplicados THEN el sistema SHALL preservar el historial de precios más completo

### Requirement 4: Interfaz de Usuario Mejorada

**User Story:** Como usuario, quiero una interfaz clara que me permita gestionar el volumen de productos y evitar duplicados, para que pueda trabajar de manera eficiente.

#### Acceptance Criteria

1. WHEN se muestra el formulario de producto THEN el sistema SHALL mostrar campos separados para peso y volumen
2. WHEN se detecta un posible duplicado THEN el sistema SHALL mostrar una advertencia antes de guardar
3. WHEN se edita un producto existente THEN el sistema SHALL mostrar claramente que se está editando, no creando
4. WHEN se especifica volumen THEN el sistema SHALL mostrar sugerencias de unidades comunes (ml, L)
5. WHEN se guarda un producto THEN el sistema SHALL mostrar confirmación con los detalles del producto guardado
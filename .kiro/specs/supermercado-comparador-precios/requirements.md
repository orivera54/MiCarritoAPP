# Requirements Document

## Introduction

Esta aplicación móvil en Flutter permitirá a los usuarios gestionar una base de datos local de productos de diferentes supermercados, facilitando la comparación de precios y el cálculo del costo total de compras. Los usuarios podrán almacenar información detallada de productos organizados por almacén/supermercado, buscar productos por nombre o código QR, y utilizar una calculadora de compras para conocer el costo total antes de realizar sus compras.

## Requirements

### Requirement 1

**User Story:** Como usuario, quiero poder crear y gestionar diferentes almacenes/supermercados en la aplicación, para poder organizar los productos por establecimiento.

#### Acceptance Criteria

1. WHEN el usuario abre la aplicación por primera vez THEN el sistema SHALL mostrar una pantalla para crear el primer almacén
2. WHEN el usuario selecciona "Agregar Almacén" THEN el sistema SHALL permitir ingresar nombre, dirección y descripción del almacén
3. WHEN el usuario guarda un almacén THEN el sistema SHALL almacenar la información en la base de datos local
4. WHEN el usuario visualiza la lista de almacenes THEN el sistema SHALL mostrar todos los almacenes creados con opción de editar o eliminar

### Requirement 2

**User Story:** Como usuario, quiero poder agregar productos a cada almacén con información detallada, para mantener un registro completo de los productos disponibles.

#### Acceptance Criteria

1. WHEN el usuario selecciona un almacén THEN el sistema SHALL mostrar la opción de agregar productos
2. WHEN el usuario agrega un producto THEN el sistema SHALL permitir ingresar nombre, precio, peso, tamano, código QR y categoría
3. WHEN el usuario guarda un producto THEN el sistema SHALL validar que todos los campos obligatorios estén completos
4. WHEN el usuario guarda un producto válido THEN el sistema SHALL almacenar el producto asociado al almacén correspondiente
5. IF el código QR ya existe en el mismo almacén THEN el sistema SHALL mostrar un mensaje de advertencia

### Requirement 3

**User Story:** Como usuario, quiero poder buscar productos por nombre o escanear código QR, para encontrar rápidamente la información que necesito.

#### Acceptance Criteria

1. WHEN el usuario ingresa texto en el campo de búsqueda THEN el sistema SHALL mostrar productos que coincidan con el nombre
2. WHEN el usuario selecciona "Escanear QR" THEN el sistema SHALL activar la cámara para escanear códigos QR
3. WHEN el sistema escanea un código QR válido THEN el sistema SHALL mostrar el producto correspondiente si existe
4. WHEN el usuario busca un producto THEN el sistema SHALL mostrar resultados de todos los almacenes con indicación del almacén
5. IF no se encuentran resultados THEN el sistema SHALL mostrar un mensaje indicando que no hay productos que coincidan

### Requirement 4

**User Story:** Como usuario, quiero poder comparar precios del mismo producto entre diferentes almacenes, para tomar decisiones informadas de compra.

#### Acceptance Criteria

1. WHEN el usuario selecciona un producto THEN el sistema SHALL mostrar una opción de "Comparar Precios"
2. WHEN el usuario selecciona "Comparar Precios" THEN el sistema SHALL buscar el mismo producto en otros almacenes
3. WHEN existen productos similares THEN el sistema SHALL mostrar una lista comparativa con precios y almacenes
4. WHEN se muestra la comparación THEN el sistema SHALL destacar el precio más bajo
5. IF el producto no existe en otros almacenes THEN el sistema SHALL mostrar un mensaje indicando que no hay comparaciones disponibles

### Requirement 5

**User Story:** Como usuario, quiero utilizar una calculadora de compras para conocer el costo total de mi lista de compras, para controlar mi presupuesto.

#### Acceptance Criteria

1. WHEN el usuario accede a la calculadora THEN el sistema SHALL mostrar una lista vacía de productos seleccionados
2. WHEN el usuario agrega un producto a la calculadora THEN el sistema SHALL permitir especificar la cantidad deseada
3. WHEN el usuario agrega productos THEN el sistema SHALL calcular automáticamente el subtotal y total
4. WHEN el usuario modifica cantidades THEN el sistema SHALL recalcular los totales en tiempo real
5. WHEN el usuario finaliza la lista THEN el sistema SHALL mostrar el total final con opción de guardar la lista
6. IF el usuario intenta agregar un producto sin especificar cantidad THEN el sistema SHALL usar cantidad 1 por defecto

### Requirement 6

**User Story:** Como usuario, quiero poder editar y eliminar productos existentes, para mantener la información actualizada.

#### Acceptance Criteria

1. WHEN el usuario selecciona un producto THEN el sistema SHALL mostrar opciones de editar y eliminar
2. WHEN el usuario selecciona "Editar" THEN el sistema SHALL mostrar un formulario con la información actual del producto
3. WHEN el usuario guarda cambios THEN el sistema SHALL validar y actualizar la información en la base de datos
4. WHEN el usuario selecciona "Eliminar" THEN el sistema SHALL solicitar confirmación antes de proceder
5. WHEN el usuario confirma eliminación THEN el sistema SHALL remover el producto de la base de datos

### Requirement 7

**User Story:** Como usuario, quiero que la aplicación funcione sin conexión a internet, para poder usarla en cualquier momento durante mis compras.

#### Acceptance Criteria

1. WHEN la aplicación se inicia THEN el sistema SHALL funcionar completamente sin conexión a internet
2. WHEN el usuario realiza operaciones THEN el sistema SHALL utilizar únicamente la base de datos local
3. WHEN el usuario escanea códigos QR THEN el sistema SHALL procesar la información localmente
4. WHEN la aplicación se cierra THEN el sistema SHALL mantener todos los datos almacenados localmente

### Requirement 8

**User Story:** Como usuario, quiero poder categorizar productos para una mejor organización y búsqueda, para encontrar productos más fácilmente.

#### Acceptance Criteria

1. WHEN el usuario agrega un producto THEN el sistema SHALL permitir seleccionar o crear una categoría
2. WHEN el usuario busca productos THEN el sistema SHALL permitir filtrar por categoría
3. WHEN el usuario visualiza productos THEN el sistema SHALL mostrar la categoría de cada producto
4. WHEN el usuario crea una nueva categoría THEN el sistema SHALL validar que no exista previamente
5. IF el usuario no selecciona categoría THEN el sistema SHALL asignar una categoría "General" por defecto
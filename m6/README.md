# M6 – Pipeline ETL con Power Query y M

**Archivo:** `Pipeline_ETL_Benedetti_Teresa.pbix`
**Fuente:** `Pipeline_ETL_Dataset.xlsx` (dataset provisto por el curso)
**Herramienta:** Power BI Desktop – Editor de Power Query

## 1. Perfilado de datos

Se activaron Calidad de columnas, Distribución de columnas y Perfil de columna (pestaña Vista) para diagnosticar cada tabla antes de transformarla.

## 2. Problemas detectados y decisiones

| Tabla | Problema | Decisión | Justificación |
|---|---|---|---|
| Todas | Filas vacías del Excel (999 filas leídas por tabla) | Quitar filas en blanco | Son filas con formato pero sin datos. Inflan los conteos y generan IDs nulos que romperían las relaciones entre tablas. |
| Dim_Clientes | id_cliente 1 duplicado | Quitar duplicados por la columna id_cliente | La dimensión necesita una clave única para ser el lado "1" de la relación 1:N con Fact_Ventas. Se quita por ID y no por todas las columnas. |
| Dim_Clientes | Email nulo (cliente 9, Valentina Paz) | Reemplazar por "Sin dato" | La clienta tiene ventas registradas: eliminarla las dejaría fuera del análisis. Un email no se puede inventar ni se usa en cálculos. |
| Dim_Clientes | Ciudad nula (cliente 11, Roberto Díaz) | Reemplazar por "Sin dato" | Es un campo de segmentación, no de cálculo. "Sin dato" lo deja visible como opción propia en los filtros en lugar de un valor en blanco. |
| Dim_Productos | id_producto 103 duplicado (Monitor 4K 27") | Quitar duplicados por la columna id_producto | Un ID repetido rompe la cardinalidad 1:N con Fact_Ventas y duplicaría las ventas de ese producto. |
| Dim_Productos | Precio nulo (producto 109, SSD Externo 1TB) | Reemplazar por 130 | Es el precio_unitario registrado en sus 5 ventas de Fact_Ventas: dato real, no estimado. No se elimina porque el producto tiene ventas. |
| Dim_Productos | Categoría nula (producto 111, Laptop Gaming Pro) | Asignar "Computación" | Su subcategoría es Laptops, igual que los productos 101 y 105, que pertenecen a Computación. Como "Sin categoría", sus $15.840 en ventas quedarían fuera del análisis por categoría. |

## 3. Transformaciones

- **Tipos de datos:** fechas como Fecha (llegaban como número serial de Excel, por ejemplo 44936), importes (precio, costo, precio_unitario, descuento, total_venta) como Número decimal, IDs, cantidades, stock y activo como Número entero, y nombres, categorías, canal y email como Texto.
- **Nomenclatura:** consultas renombradas como Dim_Clientes, Dim_Productos, Dim_Categorias y Fact_Ventas. Las columnas ya estaban en español con snake_case.
- **Merge:** Fact_Ventas se combinó con Dim_Productos por id_producto (combinación externa izquierda, 50 de 50 filas coincidentes) para agregar las columnas nombre_producto y categoria.

## 4. Documentación en lenguaje M

Los pasos de Dim_Clientes, Dim_Productos y Fact_Ventas se renombraron con nombres descriptivos y se documentaron con comentarios `//` en el Editor avanzado, explicando el motivo técnico de cada decisión.

## 5. Verificación

Se cerró y aplicó sin errores de carga. Conteo final de filas:

| Tabla | Filas |
|---|---|
| Dim_Clientes | 11 |
| Dim_Productos | 12 |
| Fact_Ventas | 50 |
| Dim_Categorias | 4 |
